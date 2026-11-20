param(
  [int]$Port = 2026,
  [int]$TimeoutSeconds = 15
)

$ErrorActionPreference = "Stop"
$serverUrl = "http://localhost:$Port/"
$existingResponse = $null

try {
  $existingResponse = Invoke-WebRequest -Uri $serverUrl -UseBasicParsing -TimeoutSec 3
} catch {
  $existingResponse = $null
}

if ($null -ne $existingResponse) {
  if ($existingResponse.Content -notmatch "<title>Workforce") {
    throw "Port $Port is already serving a different application."
  }

  Write-Output "Workforce dashboard is already available at $serverUrl"
  exit 0
}

$serverScript = Join-Path $PSScriptRoot "serve.ps1"
$powershell = Join-Path $PSHOME "powershell.exe"
$arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $serverScript + '" -Port ' + $Port
$serverProcess = Start-Process -FilePath $powershell -ArgumentList $arguments -PassThru -WindowStyle Hidden
$deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)

while ([DateTime]::UtcNow -lt $deadline) {
  if ($serverProcess.HasExited) {
    throw "The local server exited before it became ready (exit code $($serverProcess.ExitCode))."
  }

  try {
    $response = Invoke-WebRequest -Uri $serverUrl -UseBasicParsing -TimeoutSec 2
    if ($response.Content -match "<title>Workforce") {
      Write-Output "Workforce dashboard is ready at $serverUrl"
      exit 0
    }

    throw "Port $Port responded, but it is not serving the Workforce dashboard."
  } catch {
    if ($_.Exception.Message -match "not serving the Workforce dashboard") {
      throw
    }

    Start-Sleep -Milliseconds 300
  }
}

if (-not $serverProcess.HasExited) {
  Stop-Process -Id $serverProcess.Id -ErrorAction SilentlyContinue
}
throw "The local server did not become ready at $serverUrl within $TimeoutSeconds seconds."
