# Workflow Time Report

利用元 Repository の Workflows Billable Time レポートを ISSUE に起票します。

Repository Admin は Workflows Billable Time が過剰に肥大化していないことを確認します。

## Usage

任意の Workflow ファイルで任意の `jobs.<job-name>.steps.uses` に指定します。

```yaml
      - uses: MichinaoShimizu/workflow-time-report@main
```

### Example

毎週月曜日から火曜日の朝10にISSUEを作成する場合下記の通り指定します。

```yaml
name: Workflow Time Report

on:
  schedule:
    - cron: '0 1 * * 1-5'

  workflow_dispatch:

jobs:
  reporting:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v3
      - uses: MichinaoShimizu/workflow-time-report@main
```

## I/F

### Input



### Output

N/A
