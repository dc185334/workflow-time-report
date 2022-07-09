# Workflow Time Report

利用元 Repository の Workflows Billable Time レポートを ISSUE に起票します。

Repository Admin は Workflows Billable Time が過剰ではないことを確認します。

## Usage

任意の `jobs.<job-name>.steps.uses` で下記を指定します。

```yaml
- uses: MichinaoShimizu/workflow-time-report@main

```

### Example

下記を記載した `.github/workflows/weekly_report.yml` を作成すると毎週月曜10時に実行されます。

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
```

## Input

```yaml
  label:
    description: Attached Label
    required: false
    default: workflow-time-report
```

## Output

N/A
