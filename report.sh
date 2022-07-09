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

echo '## Workflows'
echo "${repo_name} における今月の Workflow 別総実行時間"
echo '| workflow(status) | workflow(source) | id | state | billable time |'
echo '| ---------------- | ---------------- | -- | ----- | ------------- |'
while IFS="|" read -r id name html_url state badge_url path; do
    total=0
    for ms in $(gh api "/repos/${repo_name}/actions/workflows/$id/timing" --jq ".billable[].total_ms")
    do
        total=$(( total + ms ))
        repo_total=$(( repo_total + ms ))
    done
    echo "| [![$name]($badge_url)](/$repo_name/actions/workflows/${path##*/}) | [$name]($html_url) | $id | $state | $(humanize $total) |"
done < <(gh api /repos/$repo_name/actions/workflows --jq '.workflows[] | "\(.id)|\(.name)|\(.html_url)|\(.state)|\(.badge_url)|\(.path)"')

echo '### Note'
echo '- Enterpriseプランでは __50000分/月__ が上限で、それ以上は追加購入が必要です。'
echo '- _timeout-minutes_ を指定しないジョブは最大 __3600分__ 中断されません。'
echo '- _timeout-minutes_ を指定したジョブは指定した時間で中断されます。'
echo '- _jobs_ あるいは _steps_ に _timeout-minutes_ を指定してください。'

echo "## Repository Total"
echo "${repo_name} における今月の Workflows 総実行時間"
echo "__$(humanize $repo_total)__"
exit 0
