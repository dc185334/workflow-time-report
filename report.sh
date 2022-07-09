#! /bin/bash

set -puo pipefail

humanize() {
    local millsec=$1
    if (( millsec < 1000 )); then
        printf "%s ms" $millsec
    fi
    if (( millsec < 60000 )); then
        printf "%s s" $((millsec / 1000))
    fi
    printf "%s m" $((millsec / 60000))
}

repo_name=$1
declare repo_total=0

echo '## Billable Time'
echo '### Workflows'
echo '| status badge | id | name/source | state | billable time |'
echo '| ------------ | -- | ----------- | ----- | ------------- |'
while IFS="|" read -r id name html_url state badge_url path; do
    total=0
    for ms in $(gh api "/repos/${repo_name}/actions/workflows/$id/timing" --jq ".billable[].total_ms")
    do
        total=$(( total + ms ))
        repo_total=$(( repo_total + ms ))
    done
    echo "| [![$name]($badge_url)](/$repo_name/actions/workflows/${path##*/}) | $id | [$name]($html_url) | $state | $(humanize $total) |"
done < <(gh api /repos/$repo_name/actions/workflows --jq '.workflows[] | "\(.id)|\(.name)|\(.html_url)|\(.state)|\(.badge_url)|\(.path)"')

echo "### Repository Total"
echo "__$(humanize $repo_total)__"

echo "## Message"
echo "### `timeput-minutes` は必須"
echo "あらゆるワークフローを記載する際 `jobs` には `timeout-minutes` を指定してください。"
echo "`timeout-minutes` を指定しないジョブは最大 _6時間（3600分）_ 実行されてしまいます。"
exit 0
