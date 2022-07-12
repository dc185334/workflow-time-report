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

print_table_header {
    echo '| workflow id | status badge | name/source | state | total billable time |'
    echo '| ----------- | ------------ | ----------- | ----- | ------------------- |'
}

print_table_rows {
    while IFS="|" read -r id name html_url state badge_url path; do
        local total=0
        for ms in $(gh api "/repos/$1}/actions/workflows/$id/timing" --jq ".billable[].total_ms")
        do
            total=$(( total + ms ))
            repo_total=$(( repo_total + ms ))
        done
        echo "| $id | [![$name]($badge_url)](/$1/actions/workflows/${path##*/}) | [$name]($html_url) | $state | $(millsec_humanize $total) |"
    done < <(gh api "/repos/$1/actions/workflows" --jq '.workflows[] | "\(.id)|\(.name)|\(.html_url)|\(.state)|\(.badge_url)|\(.path)"')
    echo "| | | | | __$(millsec_humanize $repo_total)__ |"
}

print_table_header
print_table_rows $TARGET_REPOSITORY
