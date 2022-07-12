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

main() {
    local repo=$1
    local total_time=0
    local table='| workflow id | status badge | name/source | state | total billable time |'
    local chart="\\\`\\\`\\\`mermaid"
    chart="$chart\npie showData"
    chart="$chart\n  title Workflows Billable Time"
    table="$table\n| ----------- | ------------ | ----------- | ----- | ------------------- |"
    while IFS="|" read -r id name html_url state badge_url path; do
        local workflow_time=$(gh api "/repos/${repo}/actions/workflows/$id/timing" --jq ".billable[].total_ms")
        total_time=$(( total_time + workflow_time ))
        table="$table\n| $id | [![$name]($badge_url)](/$repo/actions/workflows/${path##*/}) | [$name]($html_url) | $state | $(humanize $workflow_time) |"
        chart="$chart\n  \\"$name\\" : $workflow_time"
    done < <(gh api "/repos/$repo/actions/workflows" --jq '.workflows[] | "\(.id)|\(.name)|\(.html_url)|\(.state)|\(.badge_url)|\(.path)"')
    table="$table\n| | | | | $(humanize $total_time) |"
    chart="$chart\n\\\`\\\`\\\`"
    echo -e $table
    echo ''
    echo -e $chart
}

main "$TARGET_REPOSITORY"
