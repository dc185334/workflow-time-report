# Workflow Time Report

[![Test](https://github.com/MichinaoShimizu/workflow-time-report/actions/workflows/test.yml/badge.svg)](https://github.com/MichinaoShimizu/workflow-time-report/actions/workflows/test.yml)

Github Action that outputs Billable Time for each Workflow to ISSUE.

## Usage

```yaml
- uses: MichinaoShimizu/workflow-time-report@v2
```

## Example

If you create a workflow like the one below,

```yaml
name: Weekly Report Tasks

on:
  schedule:
    - cron: '0 1 * * 1'

  workflow_dispatch: ~

jobs:
  reporting:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v3
      - uses: MichinaoShimizu/workflow-time-report@v2
```
