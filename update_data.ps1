$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

$branch = (& git branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or $branch -ne 'main') { throw '请在 main 分支运行更新脚本' }
& git fetch origin main
if ($LASTEXITCODE -ne 0) { throw '无法检查 GitHub 上的 main 分支' }
$localCommit = (& git rev-parse HEAD).Trim()
$remoteCommit = (& git rev-parse origin/main).Trim()
if ($localCommit -ne $remoteCommit) { throw '本地 main 与 GitHub 不一致，请先同步代码' }

$venv = Join-Path $PSScriptRoot '.venv'
$venvPython = Join-Path $venv 'Scripts\python.exe'
if (-not (Test-Path -LiteralPath $venvPython)) {
    $python = Get-Command python -ErrorAction Stop
    & $python.Source -m venv $venv
    if ($LASTEXITCODE -ne 0) { throw '创建 Python 环境失败' }
}
& $venvPython -m pip install -r (Join-Path $PSScriptRoot 'requirements.txt')
if ($LASTEXITCODE -ne 0) { throw '安装 Python 依赖失败' }
& $venvPython (Join-Path $PSScriptRoot 'update_data.py')
if ($LASTEXITCODE -ne 0) { throw '更新 JSON 失败' }

& git add -- panel_data.json
if ($LASTEXITCODE -ne 0) { throw '暂存 JSON 失败' }
& git diff --cached --quiet -- panel_data.json
if ($LASTEXITCODE -eq 0) {
    Write-Output 'JSON 未变化，无需推送'
    return
}
if ($LASTEXITCODE -ne 1) { throw '检查 JSON 变化失败' }

& git commit --only -m 'Update dashboard data' -- panel_data.json
if ($LASTEXITCODE -ne 0) { throw '提交 JSON 失败' }
& git push origin main
if ($LASTEXITCODE -ne 0) { throw '推送 JSON 失败，提交已留在本地' }
Write-Output 'JSON 已更新并推送到 GitHub'
