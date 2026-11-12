# HTML 讲义 → A4 PDF（无头 Chrome / Edge 打印）
# 用法:
#   powershell -ExecutionPolicy Bypass -File .\agent_tools\make_pdf.ps1 -Html .\agent_tools\file_exception.html
#   -Out 省略时, 输出到项目根目录、与 html 同名 .pdf
param(
    [Parameter(Mandatory = $true)][string]$Html,
    [string]$Out
)

$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path $chrome)) { $chrome = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' }
if (-not (Test-Path $chrome)) { throw 'Chrome / Edge not found' }

$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path $Html)) { $Html = Join-Path $PSScriptRoot $Html }
if (-not $Out) {
    $Out = Join-Path $root ((Split-Path -Leaf $Html) -replace '\.html$', '.pdf')
}

$url = 'file:///' + ((Resolve-Path $Html).Path -replace '\\', '/')

& $chrome --headless=new --disable-gpu --no-pdf-header-footer `
          --virtual-time-budget=4000 --print-to-pdf="$Out" $url 2>$null | Out-Null

Start-Sleep -Milliseconds 500

if (Test-Path $Out) {
    $bytes = [IO.File]::ReadAllBytes($Out)
    $text  = [Text.Encoding]::GetEncoding(28591).GetString($bytes)
    $pages = [regex]::Match($text, '/Count\s+(\d+)').Groups[1].Value
    Write-Output ("SAVED {0}  ({1} pages, {2:N0} bytes)" -f $Out, $pages, $bytes.Length)
} else {
    throw "PDF not created: $Out"
}
