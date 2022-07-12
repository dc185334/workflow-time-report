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
    echo '| workflow id | status badge | name/source | state | total billable time |'
    echo '| ----------- | ------------ | ----------- | ----- | ------------------- |'
    while IFS="|" read -r id name html_url state badge_url path; do
        local workflow_time=$(gh api "/repos/${repo}/actions/workflows/$id/timing" --jq ".billable[].total_ms")
        total_time=$(( total_time + workflow_time ))
        echo "| $id | [![$name]($badge_url)](/$repo/actions/workflows/${path##*/}) | [$name]($html_url) | $state | $(humanize $workflow_time) |"
    done < <(gh api "/repos/$repo/actions/workflows" --jq '.workflows[] | "\(.id)|\(.name)|\(.html_url)|\(.state)|\(.badge_url)|\(.path)"')
    echo "| | | | | $(humanize $total_time) |"
}
main "$TARGET_REPOSITORY"
