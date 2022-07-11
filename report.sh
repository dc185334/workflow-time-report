#! /bin/bash

set -puo pipefail

humanize() {
    local millsec=$1
    if (( millsec < 1000 )); then
        printf "%s ms" $millsec
    elif (( millsec < 60000 )); then
        printf "%s s" $((millsec / 1000))
    else
        printf "%s m" $((millsec / 60000))
    fi
}

declare repo_total=0

echo '| workflow id | status badge | name/source | state | total billable time |'
echo '| ----------- | ------------ | ----------- | ----- | ------------------- |'

while IFS="|" read -r id name html_url state badge_url path; do
    total=0
    for ms in $(gh api "/repos/${TARGET_REPOSITORY}/actions/workflows/$id/timing" --jq ".billable[].total_ms")
    do
        total=$(( total + ms ))
        repo_total=$(( repo_total + ms ))
    done
    echo "| $id | [![$name]($badge_url)](/$TARGET_REPOSITORY/actions/workflows/${path##*/}) | [$name]($html_url) | $state | $(humanize $total) |"
done < <(gh api "/repos/$TARGET_REPOSITORY/actions/workflows" --jq '.workflows[] | "\(.id)|\(.name)|\(.html_url)|\(.state)|\(.badge_url)|\(.path)"')

echo ''
echo "__TOTAL__ : __$(humanize $repo_total)__"
echo ''
echo '- [jobs.<job_id>.timeout-minutes](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idtimeout-minutes)を指定してください。'
echo '- [jobs.<job_id>.timeout-minutes](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idtimeout-minutes)を指定していないジョブは最大 __360分__ 中断されません。'
echo '- Enterpriseプランでは __50000分/月__ が上限です（参考：[About billing for GitHub Actions](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions)）'
