#! /bin/bash

set -puo pipefail

declare repo_total=0

millsec_humanize() {
    local millsec=$1
    if (( millsec < 1000 )); then
        printf "%s ms" $millsec
    elif (( millsec < 60000 )); then
        printf "%s s" $((millsec / 1000))
    else
        printf "%s m" $((millsec / 60000))
    fi
}

get_workflows() {
    gh api "/repos/$1/actions/workflows" --jq '.workflows[] | "\(.id)|\(.name)|\(.html_url)|\(.state)|\(.badge_url)|\(.path)"'
}

get_workflow_timing() {
    local repo_name=
    gh api "/repos/$1/actions/workflows/$id/timing" --jq ".billable[].total_ms"
}

print_markdown_table() {
    local repo_name=$1
    echo '| workflow id | status badge | name/source | state | total billable time |'
    echo '| ----------- | ------------ | ----------- | ----- | ------------------- |'
    while IFS="|" read -r id name html_url state badge_url path; do
        local total=0
        for ms in $(get_workflow_timing $repo_name)
        do
            total=$(( total + ms ))
            repo_total=$(( repo_total + ms ))
        done
        echo "| $id | [![$name]($badge_url)](/$repo_name/actions/workflows/${path##*/}) | [$name]($html_url) | $state | $(millsec_humanize $total) |"
    done < <($(get_workflows $repo_name))
    echo "| | | | | __$(millsec_humanize $repo_total)__ |"
}

print_markdown_table "$TARGET_REPOSITORY"
