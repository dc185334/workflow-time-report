# Workflow Time Report

利用元 Repository の Workflows Billable Time レポートを ISSUE に起票します。

## Usage

```yaml
- uses: MichinaoShimizu/workflow-time-report@main
  with:
    create-issue: 'true'
```

## Example

```yaml
name: Weekly Report Tasks

on:
  schedule:
    - cron: '0 1 * * 1'

  workflow_dispatch:

jobs:
  reporting:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v3
      - uses: MichinaoShimizu/workflow-time-report@main
        with:
          create-issue: 'true'
```
