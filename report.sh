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

echo '## Workflows Billable Time'
echo "今月のワークフロー別総実行時間"
echo '| workflow id | status badge | name/source | state | total billable time |'
echo '| ----------- | ------------ | ----------- | ----- | ------------------- |'

while IFS="|" read -r id name html_url state badge_url path; do
    total=0
    for ms in $(gh api "/repos/${repo_name}/actions/workflows/$id/timing" --jq ".billable[].total_ms")
    do
        total=$(( total + ms ))
        repo_total=$(( repo_total + ms ))
    done
    echo "| $id | [![$name]($badge_url)](/$repo_name/actions/workflows/${path##*/}) | [$name]($html_url) | $state | $(humanize $total) |"
done < <(gh api /repos/$repo_name/actions/workflows --jq '.workflows[] | "\(.id)|\(.name)|\(.html_url)|\(.state)|\(.badge_url)|\(.path)"')

echo '- [jobs.<job_id>.timeout-minutes](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idtimeout-minutes)を指定してください。'
echo '- [jobs.<job_id>.timeout-minutes](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idtimeout-minutes)を指定していないジョブは最大 __360分__ 中断されません。'
echo '- Enterpriseプランでは __50000分/月__ が上限でそれ以上は追加購入が必要です。'

echo "## Total Billable Time"
echo "__$(humanize $repo_total)__"

echo "## Report output source"
echo "<https://github.com/MichinaoShimizu/workflow-time-report>"
