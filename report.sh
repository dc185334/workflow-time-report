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

| # | workflow id | status badge | state | billable time |
| - | ----------- | ------------ | ----- | ------------- |
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
    local rows=()

    # get workflows list
    while read -r fields; do
        id="$(echo $fields | cut -d'|' -f1)"
        btime=$(gh api "/repos/${repo}/actions/workflows/$id/timing" --jq ".billable[].total_ms")
        if [ -z "$btime" ]; then
            continue
        fi
        # add billable time of workflow
        rows+=("$btime|$fields")
    done < <(gh api "/repos/$repo/actions/workflows" --jq '.workflows[] | "\(.id)|\(.name)|\(.state)|\(.badge_url)|\(.path)"')

    # sort by billable time
    rows=( $( printf "%s\n" "${rows[@]}" | sort -nr -t'|' -k1) )

    local table_rows=''
    local chart_rows=''
    local total=0
    local i=1
    for row in "${rows[@]}"; do
        IFS='|'
        read -r btime id name state badge_url path < <(echo "${row[@]}")
        unset IFS
        badge="[![$name]($badge_url)](/$repo/actions/workflows/${path##*/})"
        table_rows="$table_rows| $i | $id | $badge | $state | $(humanize $btime) |\n"
        chart_rows="$chart_rows\\\"$id\\\" : $btime\n"
        total=$((total + btime))
        i=$((i+1))
    done
    table_rows="$table_rows| - | - | - | - | $(humanize $total) |"
    print_markdown "$table_rows" "$chart_rows"
}

main "${TARGET_REPOSITORY:-MichinaoShimizu/workflow-time-report}"
