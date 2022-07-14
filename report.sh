#! /bin/bash

set -puo pipefail

humanize() {
    local millsec=$1
    if ((millsec < 1000)); then
        printf "%s ms" "$millsec"
    elif ((millsec < 60000)); then
        printf "%s s" $((millsec / 1000))
    else
        printf "%s m" $((millsec / 60000))
    fi
}

print_markdown() {
    local table_rows=$(echo -e $1)
    local chart_rows=$(echo -e $2)

    cat <<-EOS
## Billable Time

### Top List

| # | workflow id | badge | state | file | total ms | billable time |
| - | ----------- | ----- | ----- | ---- | -------- | ------------- |
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
        btime=$(gh api "/repos/$repo/actions/workflows/$id/timing" --jq ".billable[].total_ms")
        if [ -z "$btime" ]; then
            continue
        fi
        # add billable time of workflow
        rows+=("$btime|$fields")
    done < <(gh api "/repos/$repo/actions/workflows" --jq '.workflows[] | "\(.id)|\(.name)|\(.state)|\(.badge_url)|\(.path)|\(.html_url)"')

    # sort by billable time
    rows=( $( printf "%s\n" "${rows[@]}" | sort -nr -t'|' -k1) )

    local table=''
    local chart=''
    local total=0
    local i=1
    for row in "${rows[@]}"; do
        IFS='|'
        read -r btime id name state badge_url path html_url < <(echo "${row[@]}")
        unset IFS
        badge="[![$name]($badge_url)](/$repo/actions/workflows/${path##*/})"
        table="$table| $i | $id | $badge | $state | [:pencil:]($html_url) | $btime ms | $(humanize $btime) |\n"
        chart="$chart\\\"$id\\\" : $btime\n"
        total=$((total + btime))
        i=$((i+1))
    done
    table="$table|||||| $total ms | $(humanize $total) |"
    print_markdown "$table" "$chart"
}

main "${TARGET_REPOSITORY:-MichinaoShimizu/workflow-time-report}"
