#! /bin/bash

set -puo pipefail

humanize() {
    local millsec=$1
    if (( millsec < 1000 )); then
        printf "%s ms" $millsec
    elif (( millsec < 60000 )); then
        printf "%s ms (%s s)" $millsec $((millsec / 1000))
    else
        printf "%s ms (%s m)" $millsec $((millsec / 60000))
    fi
}

get_workflows() {
    gh api "/repos/$1/actions/workflows" --jq '.workflows[] | "\(.id)|\(.name)|\(.html_url)|\(.state)|\(.badge_url)|\(.path)"'
}

get_workflow() {
    gh api "/repos/${repo}/actions/workflows/$id/timing" --jq ".billable[].total_ms"
}

main() {
    local repo=$1
    echo '| workflow id | status badge | name/source | state | total billable time |'
    echo '| ----------- | ------------ | ----------- | ----- | ------------------- |'
    while IFS="|" read -r id name html_url state badge_url path; do
        local total_time=0
        for workflow_time in $(get_workflow $repo)
        do
            total_time=$(( total_time + workflow_time ))
        done
        echo "| $id | [![$name]($badge_url)](/$repo/actions/workflows/${path##*/}) | [$name]($html_url) | $state | $(humanize $total_time) |"
    done < <(get_workflows $repo)
    echo "| | | | | __$(humanize $total_time)__ |"
}
main "$TARGET_REPOSITORY"
