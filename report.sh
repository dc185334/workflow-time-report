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

echo '## Workflow Billable Time'
echo '| badge | id | name | source | state | billable time |'
echo '| ----- | -- | ---- | ------ | ----- | ------------- |'

while IFS="|" read -r id name html_url state badge_url; do
    total=0
    for ms in $(gh api "/repos/${repo_name}/actions/workflows/$id/timing" --jq ".billable[].total_ms")
    do
        total=$(( total + ms ))
        repo_total=$(( repo_total + ms ))
    done
    echo "| [![$name]($badge_url)]() | $id | $name | $html_url | $state | $(humanize $total) |"
done < <(gh api /repos/$repo_name/actions/workflows --jq '.workflows[] | "\(.id)|\(.name)|\(.html_url)|\(.state)|\(.badge_url)"')

echo "### Total"
echo "__$(humanize $repo_total)__"

exit 0
