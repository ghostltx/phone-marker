$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = 8765
$url = "http://127.0.0.1:$port/phone%20time.html"

Set-Location -LiteralPath $projectRoot
$serverJob = Start-Job -ScriptBlock {
  param($root, $serverPort)
  Set-Location -LiteralPath $root
  python -m http.server $serverPort --bind 127.0.0.1
} -ArgumentList $projectRoot, $port

try {
  for ($attempt = 0; $attempt -lt 30; $attempt++) {
    if (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) {
      break
    }
    Start-Sleep -Milliseconds 100
  }

  Start-Process $url
  Write-Host "phone time 已启动：$url"
  Write-Host "关闭此窗口或按 Ctrl+C 即可停止本地服务。"
  Receive-Job -Job $serverJob -Wait
}
finally {
  Stop-Job -Job $serverJob -ErrorAction SilentlyContinue
  Remove-Job -Job $serverJob -Force -ErrorAction SilentlyContinue
}
