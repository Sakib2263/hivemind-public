# Video Studio setup (Windows, NVIDIA). Opened by "9 Optional - Video Studio.bat" (GUI) or run directly:
#   powershell -ExecutionPolicy Bypass -File video-studio-setup.ps1 -Dir "E:\AI\Video Studio" -Video -Images -Music -Voice
# Installs into the folder you choose (never inside hivemind). The choice is saved in config\studio.env,
# so the shortcuts (14, 15, 16) find it. Safe to run again: finished downloads are skipped, broken ones resume.
param([string]$Dir, [switch]$Video, [switch]$Images, [switch]$Music, [switch]$Voice)
$ErrorActionPreference = 'Stop'
$Hive = Split-Path $PSScriptRoot -Parent
$Cfg  = Join-Path $Hive 'config\studio.env'
function Say($t) { Write-Host ""; Write-Host "== $t" -ForegroundColor Cyan }

if (-not $Dir -and (Test-Path $Cfg)) { $Dir = ((Get-Content $Cfg) | Where-Object { $_ -like 'STUDIO_DIR=*' }) -replace '^STUDIO_DIR=', '' }
if (-not $Dir) { $Dir = Join-Path (Split-Path $Hive -Parent) 'Video Studio' }
$Studio = [System.IO.Path]::GetFullPath($Dir.Trim('"'))
if ($Studio -like "$Hive*") { throw "Pick a folder outside hivemind (models are tens of GB and must not go into git)." }
if (-not ($Video -or $Images -or $Music -or $Voice)) { $Video = $true; $Images = $true }
$Dl = Join-Path $Studio 'downloads'
New-Item -ItemType Directory -Force $Dl | Out-Null
Set-Content -Path $Cfg -Value "STUDIO_DIR=$Studio" -Encoding ASCII
Start-Transcript -Path (Join-Path $Studio 'install.log') -Append | Out-Null
Write-Host "Installing into: $Studio  (saved in config\studio.env)"

function Get-File($url, $dst) {
  if (Test-Path $dst) { Write-Host "have $(Split-Path $dst -Leaf)"; return }
  New-Item -ItemType Directory -Force (Split-Path $dst -Parent) | Out-Null
  Write-Host "downloading $(Split-Path $dst -Leaf) ..."
  & curl.exe -L --fail --retry 5 --retry-delay 5 -C - -o "$dst.part" $url
  if ($LASTEXITCODE -ne 0) { throw "download failed: $url (run setup again to resume)" }
  Move-Item -Force "$dst.part" $dst
}
function Expand-7z($file, $to) {
  $sz = @("$env:ProgramFiles\7-Zip\7z.exe", "${env:ProgramFiles(x86)}\7-Zip\7z.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
  if ($sz) { & $sz x -y "-o$to" $file | Out-Null } else { & tar.exe -xf $file -C $to }
  if ($LASTEXITCODE -ne 0) { throw "could not unpack $file. Install 7-Zip (winget install 7zip.7zip) and run setup again." }
}

Say "Checks"
try { & nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader }
catch { throw "nvidia-smi not found: install the NVIDIA driver first (nvidia.com/drivers)." }
$need = 3
if ($Video -or $Images) { $need += 8 }; if ($Video) { $need += 17 }; if ($Images) { $need += 17 }
if ($Music) { $need += 15 }; if ($Voice) { $need += 6 }
$free = [math]::Round((New-Object System.IO.DriveInfo ([System.IO.Path]::GetPathRoot($Studio))).AvailableFreeSpace / 1GB)
Write-Host "free on that drive: $free GB, this install needs about $need GB"
if ($free -lt $need) { throw "not enough free space: pick another drive or fewer parts" }

$Comfy = Join-Path $Studio 'ComfyUI_windows_portable'
$M = "$Comfy\ComfyUI\models"
$hf = 'https://huggingface.co/Comfy-Org'
if ($Video -or $Images) {
  Say "ComfyUI portable (engine for AI video and images)"
  if (-not (Test-Path "$Comfy\ComfyUI\main.py")) {
    $z = Join-Path $Dl 'ComfyUI_windows_portable_nvidia.7z'
    Get-File 'https://github.com/Comfy-Org/ComfyUI/releases/latest/download/ComfyUI_windows_portable_nvidia.7z' $z
    Expand-7z $z $Studio
  } else { Write-Host "have ComfyUI" }
}
if ($Video) {
  Say "Video: Wan 2.2 TI2V 5B"
  Get-File "$hf/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_ti2v_5B_fp16.safetensors" "$M\diffusion_models\wan2.2_ti2v_5B_fp16.safetensors"
  Get-File "$hf/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan2.2_vae.safetensors" "$M\vae\wan2.2_vae.safetensors"
  Get-File "$hf/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "$M\text_encoders\umt5_xxl_fp8_e4m3fn_scaled.safetensors"
}
if ($Images) {
  Say "Images: FLUX.1 schnell fp8"
  Get-File "$hf/flux1-schnell/resolve/main/flux1-schnell-fp8.safetensors" "$M\checkpoints\flux1-schnell-fp8.safetensors"
}
if ($Video -or $Images) {
  Say "Let the relay (WSL) reach ComfyUI on localhost"
  $wc = Join-Path $env:USERPROFILE '.wslconfig'
  $txt = if (Test-Path $wc) { Get-Content $wc -Raw } else { '' }
  if ($txt -match 'networkingMode') { Write-Host ".wslconfig already sets networkingMode: left as is" }
  else {
    if ($txt -match '(?m)^\[wsl2\]') { $txt = $txt -replace '(?m)^\[wsl2\]', "[wsl2]`r`nnetworkingMode=mirrored" }
    else { $txt = $txt.TrimEnd() + "`r`n[wsl2]`r`nnetworkingMode=mirrored`r`n" }
    Set-Content -Path $wc -Value $txt.TrimStart() -Encoding ASCII
    Write-Host "set networkingMode=mirrored. Takes effect after: wsl --shutdown (then start the relay again)."
  }
}
if ($Music) {
  Say "Music: ACE-Step 1.5"
  if (-not (Get-ChildItem $Studio -Directory -Filter 'ACE-Step*' -ErrorAction SilentlyContinue)) {
    $z = Join-Path $Dl 'ACE-Step-1.5.7z'
    Get-File 'https://files.acemusic.ai/acemusic/win/ACE-Step-1.5.7z' $z
    Expand-7z $z $Studio
  } else { Write-Host "have ACE-Step" }
}
if ($Voice) {
  Say "Voice cloning: Chatterbox"
  if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
  }
  $V = Join-Path $Studio 'voice\.venv'
  if (-not (Test-Path "$V\Scripts\python.exe")) { & uv venv $V --python 3.11 }
  & uv pip install --python "$V\Scripts\python.exe" torch==2.6.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu124
  & uv pip install --python "$V\Scripts\python.exe" chatterbox-tts
  if ($LASTEXITCODE -ne 0) { throw "Chatterbox install failed (see above)" }
}
Say "DONE. Installed in $Studio. Log: install.log there."
Write-Host "Next: wsl --shutdown, start the relay, then windows\shortcuts\14 Start Video Studio.bat."
Stop-Transcript | Out-Null
