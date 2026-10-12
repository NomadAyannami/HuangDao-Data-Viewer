$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$python = Join-Path $projectRoot '.venv\Scripts\python.exe'
$server = Join-Path $projectRoot 'local_data_server.py'

while ($true) {
    if (Test-Path -LiteralPath $python) {
        try {
            & $python $server
        } catch {
            Write-Error "本地数据服务异常退出: $_" -ErrorAction Continue
        }
    } else {
        Write-Error "找不到 Python 环境: $python" -ErrorAction Continue
    }
    Start-Sleep -Seconds 3
}
