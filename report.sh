#! /bin/bash

set -puo pipefail

humanize() {
    local millsec=$1
    if ((millsec < 1000)); then
        printf "%s ms" "$millsec"
    elif ((millsec < 60000)); then
        printf "%s s (%s ms)" $((millsec / 1000)) "$millsec"
    else
        printf "%s m (%s ms)" $((millsec / 60000)) "$millsec"
    fi
}

print_markdown() {
    local table_rows=$(echo -e $1)
    local chart_rows=$(echo -e $2)

    cat <<-EOS
## Billable Time

### Top List

| workflow id | status badge | state | billable time |
| ----------- | ------------ | ----- | ------------- |
$table_rows

### Percentage

\\\`\\\`\\\`mermaid
pie showData
title Billable Time Per Workflow
$chart_rows
\\\`\\\`\\\`
EOS
}

main() {
    local repo=$1
    local total_time=0
    local table_rows=''
    local chart_rows=''

    while IFS="|" read -r id name state badge_url path; do
        workflow_time=$(gh api "/repos/${repo}/actions/workflows/$id/timing" --jq ".billable[].total_ms")
        if [ -z "$workflow_time" ]; then
            continue
        fi
        total_time=$((total_time + workflow_time))
        table_rows="$table_rows| $id | [![$name]($badge_url)](/$repo/actions/workflows/${path##*/}) | $state | $(humanize $workflow_time) |\n"
        chart_rows="$chart_rows\\\"$id\\\" : $workflow_time\n"
    done < <(gh api "/repos/$repo/actions/workflows" --jq '.workflows[] | "\(.id)|\(.name)|\(.state)|\(.badge_url)|\(.path)"')

    table_rows="$table_rows| Total | | | $(humanize $total_time) |"
    print_markdown "$table_rows" "$chart_rows"
}

main "${TARGET_REPOSITORY:-MichinaoShimizu/workflow-time-report}"
