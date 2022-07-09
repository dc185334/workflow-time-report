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
echo '${repo_name}における、今月のワークフロー別実行時間です。'
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

echo "## Repository Total"
echo '${repo_name}における、今月の総ワークフロー実行時間です。'
echo "__$(humanize $repo_total)__"

echo '## Message'
echo '- Enterprise全体で月 __50000分__ が現在の上限です。'
echo '- _timeout-minutes_ を指定しないジョブは最大 __6時間(3600分)__ 実行されます。'
echo '- _timeout-minutes_ を指定したジョブは最大でも指定した時間で終了します。'
echo '- ワークフローを記載する際 _jobs_ には _timeout-minutes_ を指定してください。'
exit 0
