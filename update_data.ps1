$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

$branch = (& git branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or $branch -ne 'main') { throw 'Run this script on the main branch' }
& git fetch origin main
if ($LASTEXITCODE -ne 0) { throw 'Could not fetch origin/main' }
$localCommit = (& git rev-parse HEAD).Trim()
$remoteCommit = (& git rev-parse origin/main).Trim()
if ($localCommit -ne $remoteCommit) { throw 'Local main differs from origin/main; sync code first' }

$venv = Join-Path $PSScriptRoot '.venv'
$venvPython = Join-Path $venv 'Scripts\python.exe'
if (-not (Test-Path -LiteralPath $venvPython)) {
    $python = Get-Command python -ErrorAction Stop
    & $python.Source -m venv $venv
    if ($LASTEXITCODE -ne 0) { throw 'Could not create Python environment' }
}
& $venvPython -m pip install -r (Join-Path $PSScriptRoot 'requirements.txt')
if ($LASTEXITCODE -ne 0) { throw 'Could not install Python dependencies' }
& $venvPython (Join-Path $PSScriptRoot 'update_data.py')
if ($LASTEXITCODE -ne 0) { throw 'Could not update JSON' }

& git add -- panel_data.json
if ($LASTEXITCODE -ne 0) { throw 'Could not stage JSON' }
& git diff --cached --quiet -- panel_data.json
if ($LASTEXITCODE -eq 0) {
    Write-Output 'JSON unchanged; nothing to push'
    return
}
if ($LASTEXITCODE -ne 1) { throw 'Could not check JSON changes' }

& git commit --only -m 'Update dashboard data' -- panel_data.json
if ($LASTEXITCODE -ne 0) { throw 'Could not commit JSON' }
& git push origin main
if ($LASTEXITCODE -ne 0) { throw 'Could not push JSON; commit remains local' }
Write-Output 'JSON updated and pushed to GitHub'
