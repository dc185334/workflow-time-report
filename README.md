# Workflow Time Report

[![Test](https://github.com/MichinaoShimizu/workflow-time-report/actions/workflows/test.yml/badge.svg)](https://github.com/MichinaoShimizu/workflow-time-report/actions/workflows/test.yml)

Create a report on `Billable Time` in new ISSUE.

![image.png](image.png)

## Usage

```yaml
- uses: MichinaoShimizu/workflow-time-report@v6
```

## Example

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
      - uses: MichinaoShimizu/workflow-time-report@v6
```
