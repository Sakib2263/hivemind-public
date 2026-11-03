# Video Studio setup window. Opened by "9 Optional - Video Studio.bat".
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$Hive = Split-Path $PSScriptRoot -Parent
$Cfg  = Join-Path $Hive 'config\studio.env'
$def  = Join-Path (Split-Path $Hive -Parent) 'Video Studio'
if (Test-Path $Cfg) { $c = ((Get-Content $Cfg) | Where-Object { $_ -like 'STUDIO_DIR=*' }) -replace '^STUDIO_DIR=', ''; if ($c) { $def = $c } }

$f = New-Object System.Windows.Forms.Form
$f.Text = 'Hivemind Video Studio - setup'; $f.Size = New-Object System.Drawing.Size(620, 460)
$f.StartPosition = 'CenterScreen'; $f.FormBorderStyle = 'FixedDialog'; $f.MaximizeBox = $false
$font = New-Object System.Drawing.Font('Segoe UI', 10); $f.Font = $font
function L($text, $x, $y, $w = 560, $h = 22) { $l = New-Object System.Windows.Forms.Label; $l.Text = $text; $l.Location = New-Object System.Drawing.Point($x, $y); $l.Size = New-Object System.Drawing.Size($w, $h); $f.Controls.Add($l); $l }

L 'Install folder. Models are big: pick a drive with space. It must be outside hivemind.' 15 15 | Out-Null
$tb = New-Object System.Windows.Forms.TextBox; $tb.Location = New-Object System.Drawing.Point(15, 42); $tb.Size = New-Object System.Drawing.Size(470, 26); $tb.Text = $def; $f.Controls.Add($tb)
$br = New-Object System.Windows.Forms.Button; $br.Text = 'Browse...'; $br.Location = New-Object System.Drawing.Point(495, 40); $br.Size = New-Object System.Drawing.Size(95, 28); $f.Controls.Add($br)
$space = L '' 15 74

$parts = @(
  @('Video clips: Wan 2.2 5B (text or image to video)', 17, $true),
  @('Images: FLUX.1 schnell (stills, thumbnails, start frames)', 17, $true),
  @('Music: ACE-Step 1.5 (songs and background music)', 15, $false),
  @('Voice cloning: Chatterbox (your own voice)', 6, $false))
$boxes = @(); $y = 108
foreach ($p in $parts) {
  $cb = New-Object System.Windows.Forms.CheckBox; $cb.Text = "$($p[0])  ~$($p[1]) GB"; $cb.Checked = $p[2]
  $cb.Location = New-Object System.Drawing.Point(15, $y); $cb.Size = New-Object System.Drawing.Size(570, 26); $f.Controls.Add($cb); $boxes += $cb; $y += 32
}
L 'ComfyUI engine (~8 GB) is added automatically for video or images.' 15 ($y + 4) | Out-Null
$total = L '' 15 ($y + 34)
L 'Needs an NVIDIA GPU. Downloads resume if the internet drops: just run setup again.' 15 ($y + 64) | Out-Null

function Upd {
  $need = 3; if ($boxes[0].Checked -or $boxes[1].Checked) { $need += 8 }
  for ($i = 0; $i -lt 4; $i++) { if ($boxes[$i].Checked) { $need += $parts[$i][1] } }
  $total.Text = "Total: about $need GB"
  try { $free = [math]::Round((New-Object System.IO.DriveInfo ([System.IO.Path]::GetPathRoot($tb.Text))).AvailableFreeSpace / 1GB)
        $space.Text = "Free on that drive: $free GB"; $space.ForeColor = $(if ($free -lt $need) { [System.Drawing.Color]::Firebrick } else { [System.Drawing.Color]::DarkGreen }) }
  catch { $space.Text = 'Free space: unknown (check the path)'; $space.ForeColor = [System.Drawing.Color]::Firebrick }
}
$tb.Add_TextChanged({ Upd }); foreach ($cb in $boxes) { $cb.Add_CheckedChanged({ Upd }) }
$br.Add_Click({
  $d = New-Object System.Windows.Forms.FolderBrowserDialog; $d.Description = 'Pick a drive or folder for the Video Studio'
  if ($d.ShowDialog() -eq 'OK') { $p = $d.SelectedPath; if ((Split-Path $p -Leaf) -ne 'Video Studio') { $p = Join-Path $p 'Video Studio' }; $tb.Text = $p }
})
$ok = New-Object System.Windows.Forms.Button; $ok.Text = 'Install'; $ok.Location = New-Object System.Drawing.Point(390, 375); $ok.Size = New-Object System.Drawing.Size(95, 32); $f.Controls.Add($ok)
$cn = New-Object System.Windows.Forms.Button; $cn.Text = 'Cancel'; $cn.Location = New-Object System.Drawing.Point(495, 375); $cn.Size = New-Object System.Drawing.Size(95, 32); $f.Controls.Add($cn)
$cn.Add_Click({ $f.Close() })
$ok.Add_Click({
  $dir = $tb.Text.Trim()
  if (-not $dir) { [System.Windows.Forms.MessageBox]::Show('Pick a folder first.') | Out-Null; return }
  if ([System.IO.Path]::GetFullPath($dir) -like "$Hive*") { [System.Windows.Forms.MessageBox]::Show('Pick a folder outside hivemind.') | Out-Null; return }
  if (-not ($boxes | Where-Object { $_.Checked })) { [System.Windows.Forms.MessageBox]::Show('Tick at least one part.') | Out-Null; return }
  $a = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-NoExit', '-File', "`"$PSScriptRoot\video-studio-setup.ps1`"", '-Dir', "`"$dir`"")
  $sw = @('-Video', '-Images', '-Music', '-Voice'); for ($i = 0; $i -lt 4; $i++) { if ($boxes[$i].Checked) { $a += $sw[$i] } }
  Start-Process powershell -ArgumentList $a
  $f.Close()
})
Upd
[void]$f.ShowDialog()
