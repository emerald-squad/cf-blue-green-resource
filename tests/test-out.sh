#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

jq -n "
{
    source: {
        api: \"${CF_API}\",
        username: \"${CF_USERNAME}\",
        password: \"${CF_PASSWORD}\",
        organization: \"${CF_ORG}\",
        space: \"${CF_SPACE}\"
    },
    params: {
        name: \"cf-blue-green-resource-test\",
        manifest: \"${DIR}/manifest.yml\",
        path: \"${DIR}/app\",
        post_install: \"$DIR/post_install.sh\"
    }
}
" | tee | $DIR/../resource/out


jq -n "
{
    source: {
        api: \"${CF_API}\",
        username: \"${CF_USERNAME}\",
        password: \"${CF_PASSWORD}\",
        organization: \"${CF_ORG}\",
        space: \"${CF_SPACE}\"
    },
    params: {
        name: \"cf-blue-green-resource-test\",
        manifest: \"${DIR}/manifest.yml\",
        path: \"${DIR}/app\",
    }
}
" | tee | $DIR/../resource/out