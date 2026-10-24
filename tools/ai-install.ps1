# Install a Gemini-enhanced image over a site image.
# Usage: powershell -File tools/ai-install.ps1 -Src <downloaded.jpg> -Dst images/site/xxx.jpg [-NoBackup]
# Backs up the original to tools/ai-originals/<same path> (once), then writes Src resized to 2000px wide, JPEG q84.
param([Parameter(Mandatory)][string]$Src, [Parameter(Mandatory)][string]$Dst, [switch]$NoBackup)
Add-Type -AssemblyName System.Drawing
$repo = Split-Path -Parent $PSScriptRoot
$target = Join-Path $repo $Dst
if (-not $NoBackup -and (Test-Path $target)) {
  $bak = Join-Path $repo ("tools\ai-originals\" + $Dst)
  if (-not (Test-Path $bak)) { New-Item -ItemType Directory -Force (Split-Path $bak) | Out-Null; Copy-Item $target $bak }
}
$img = [Drawing.Image]::FromFile($Src)
$w = [Math]::Min(2000, $img.Width); $h = [int]($img.Height * $w / $img.Width)
$bmp = New-Object Drawing.Bitmap $w, $h
$g = [Drawing.Graphics]::FromImage($bmp); $g.InterpolationMode = 'HighQualityBicubic'; $g.DrawImage($img, 0, 0, $w, $h)
$codec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality), 84L
$img.Dispose()
New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
$bmp.Save($target, $codec, $ep); $g.Dispose(); $bmp.Dispose()
Remove-Item $Src
"$Dst ${w}x$h $((Get-Item $target).Length)"
