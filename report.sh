#! /bin/bash

set -puo pipefail

humanize() {
    local millsec=$1
    if (( millsec < 1000 )); then
        printf "%s ms" $millsec
    elif (( millsec < 60000 )); then
        printf "%s s (%s ms)" $((millsec / 1000)) $millsec
    else
        printf "%s m (%s ms)" $((millsec / 60000)) $millsec
    fi
}

# Summary Table
print_table() {
    cat <<-EOS
| workflow id | status badge | name/source | state | billable time |
| ----------- | ------------ | ----------- | ----- | ------------- |
$1
EOS
}

# Mermaid Pie Chart
print_chart() {
    cat <<-EOS
\\\`\\\`\\\`mermaid
    pie showData
        title Billable Time Per Workflow
        $1
\\\`\\\`\\\`
EOS
}

main() {
    local repo=$1
    local total_time=0
    local table_rows=''
    local chart_rows=''
    while IFS="|" read -r id name html_url state badge_url path; do
        local workflow_time=$(gh api "/repos/${repo}/actions/workflows/$id/timing" --jq ".billable[].total_ms")
        total_time=$(( total_time + workflow_time ))
        table_rows="$table_rows| $id | [![$name]($badge_url)](/$repo/actions/workflows/${path##*/}) | [$name]($html_url) | $state | $(humanize $workflow_time) |\n"
        chart_rows="$chart_rows\\\"$name\\\" : $workflow_time\n"
    done < <(gh api "/repos/$repo/actions/workflows" --jq '.workflows[] | "\(.id)|\(.name)|\(.html_url)|\(.state)|\(.badge_url)|\(.path)"')
    table_rows="$table_rows| | | | | $(humanize $total_time) |"
    print_table "$table_rows"
    echo ''
    print_chart "$chart_rows"
}

main "$TARGET_REPOSITORY"
