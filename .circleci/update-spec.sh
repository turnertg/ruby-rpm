#!/bin/bash

set -xeu

cd $(dirname $0)/..

for f in $(ls -1 ruby-*.spec)
do
    ruby_x_y_version=$(basename $f .spec | cut -d '-' -f 2)
    ruby_x_y_z_version=$(curl https://cache.ruby-lang.org/pub/ruby/${ruby_x_y_version}/ \
        | grep "ruby-${ruby_x_y_version}.*.tar.gz" | sort | tail -1 \
        | sed -E 's/.*ruby-([0-9]+\.[0-9]+\.[0-9]+)\.tar\.gz.*/\1/')

    if [[ ${ruby_x_y_z_version} != ${ruby_x_y_version}.* ]]
    then
        echo "Can't detect newest Ruby version."
        continue
    fi

    if grep -q "^Version: ${ruby_x_y_z_version}" $f
    then
        echo "SPEC file is up to date."
        continue
    fi

    message="* $(date +'%a %b %d %Y') ${CHANGELOG_AUTHOR} - ${ruby_x_y_z_version}\\n- Update ruby version to ${ruby_x_y_z_version}"
    sed -i "s/^Version: .*\$/Version: ${ruby_x_y_z_version}/" $f
    sed -i "/^%changelog/a \\\n${message}" $f

    git config --global user.email "${GITHUB_EMAIL}"
    git config --global user.name "${GITHUB_USER}"

    branch=ruby-${ruby_x_y_z_version}

    if git branch -a | grep -q remotes/origin/${branch}
    then
        echo "PR branch `${branch}` exists."
        continue
    fi

    git checkout -b ${branch} ${CIRCLE_BRANCH}
    git add $f
    git commit -m "feat: bump up Ruby to ${ruby_x_y_z_version}".
    git push origin ${branch}

    curl --fail \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token ${GITHUB_TOKEN}" \
      -d "{\"title\": \"${branch}\", \"head\":\"${branch}\", \"base\":\"${CIRCLE_BRANCH}\", \"body\":\"Check for [News](https://www.ruby-lang.org/en/news/).\" }" \
      https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/pulls
done
