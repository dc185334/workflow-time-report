# Workflow Time Report

[![Test](https://github.com/MichinaoShimizu/workflow-time-report/actions/workflows/test.yml/badge.svg)](https://github.com/MichinaoShimizu/workflow-time-report/actions/workflows/test.yml)

Github Action that outputs `Billable Time` for each Workflow to ISSUE.

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

The following ISSUE will be created.

| workflow id | status badge | name/source | state | total billable time |
| ----------- | ------------ | ----------- | ----- | ------------------- |
| 29963666 | [![Test](https://github.com/MichinaoShimizu/workflow-time-report/workflows/Test/badge.svg)](/MichinaoShimizu/workflow-time-report/actions/workflows/dummy.yml) | [Test](https://github.com/MichinaoShimizu/workflow-time-report/blob/main/.github/workflows/dummy.yml) | active | 10 m |
| 29913858 | [![Test](https://github.com/MichinaoShimizu/workflow-time-report/workflows/Test/badge.svg)](/MichinaoShimizu/workflow-time-report/actions/workflows/test.yml) | [Test](https://github.com/MichinaoShimizu/workflow-time-report/blob/main/.github/workflows/test.yml) | active | 56 m |

__TOTAL__ : __66 m__
