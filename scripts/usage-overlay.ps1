# Usage overlay: a small always-on-top window showing what's left per provider and model.
# Started by shortcuts\20 Usage Overlay.bat. Shows USAGE.json (made by scripts/usage.py) and refreshes it
# through WSL every 5 minutes; the relay also refreshes it after every job.
# Drag to move. Right-click: Refresh now, Open full report, Start with Windows, Close.
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
$Root    = Split-Path -Parent $PSScriptRoot
$Json    = Join-Path $Root 'USAGE.json'
$Report  = Join-Path $Root 'USAGE.md'
$PosFile = Join-Path $Root 'logs\overlay-pos.txt'
$Bat     = Join-Path $Root 'shortcuts\20 Usage Overlay.bat'
$Startup = Join-Path ([Environment]::GetFolderPath('Startup')) 'Hivemind Usage Overlay.lnk'

$mutex = New-Object System.Threading.Mutex($false, 'HivemindUsageOverlay')   # one copy only
if (-not $mutex.WaitOne(0)) { exit }

function Brush($hex) { (New-Object System.Windows.Media.BrushConverter).ConvertFromString($hex) }
function Text($s, $hex, $size = 12, $width = 0, $bold = $false) {
    $t = New-Object System.Windows.Controls.TextBlock
    $t.Text = $s; $t.Foreground = Brush $hex; $t.FontSize = $size; $t.FontFamily = 'Segoe UI'
    $t.VerticalAlignment = 'Center'; $t.Margin = '0,0,8,0'
    if ($width) { $t.Width = $width; $t.TextTrimming = 'CharacterEllipsis' }
    if ($bold) { $t.FontWeight = 'SemiBold' }
    $t
}
function StatusColor($r) {
    if ($r.status -like 'LIMIT*' -or $r.status -eq 'OUT') { return '#E5534B' }
    if ($r.status -eq 'LOW') { return '#D29922' }
    if ($r.status -eq '?') { return '#8B949E' }
    '#3FB950'
}
function Dto($v) {   # JSON time as DateTimeOffset (PowerShell 7 already turns it into a DateTime)
    if ($v -is [datetime]) { return [DateTimeOffset]$v }
    [DateTimeOffset]::Parse([string]$v, [Globalization.CultureInfo]::InvariantCulture)
}
function Until($iso) {
    if (-not $iso) { return '' }
    $m = [int]((Dto $iso) - [DateTimeOffset]::Now).TotalMinutes
    if ($m -le 0) { return 'resets now' }
    if ($m -ge 1440) { return ('resets {0}d {1}h' -f [math]::Floor($m / 1440), [math]::Floor(($m % 1440) / 60)) }
    'resets {0}h {1:00}m' -f [math]::Floor($m / 60), ($m % 60)
}

$w = New-Object System.Windows.Window
$w.WindowStyle = 'None'; $w.AllowsTransparency = $true; $w.Background = [System.Windows.Media.Brushes]::Transparent; $w.Topmost = $true
$w.ShowInTaskbar = $false; $w.SizeToContent = 'WidthAndHeight'; $w.ResizeMode = 'NoResize'; $w.Title = 'Hivemind usage'
$border = New-Object System.Windows.Controls.Border
$border.CornerRadius = 8; $border.Padding = '10,8,10,8'
$border.Background = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromArgb(220, 22, 24, 29))
$stack = New-Object System.Windows.Controls.StackPanel
$border.Child = $stack; $w.Content = $border

function Render {
    $stack.Children.Clear()
    $d = $null
    try { $d = Get-Content $Json -Raw -Encoding UTF8 | ConvertFrom-Json } catch { }
    $head = New-Object System.Windows.Controls.StackPanel; $head.Orientation = 'Horizontal'; $head.Margin = '0,0,0,6'
    [void]$head.Children.Add((Text 'Usage left' '#E6EDF3' 13 0 $true))
    if (-not $d) { [void]$head.Children.Add((Text 'loading...' '#8B949E' 11)); [void]$stack.Children.Add($head); return }
    $age = [int]([DateTimeOffset]::Now - (Dto $d.updated)).TotalMinutes
    $note = if ($age -gt 15) { "updated $age min ago" } else { 'updated ' + (Dto $d.updated).ToLocalTime().ToString('HH:mm') }
    [void]$head.Children.Add((Text $note ($(if ($age -gt 15) { '#D29922' } else { '#8B949E' })) 11))
    [void]$stack.Children.Add($head)
    foreach ($r in $d.rows) {
        $line = New-Object System.Windows.Controls.StackPanel; $line.Orientation = 'Horizontal'; $line.Margin = '0,1,0,1'
        $c = StatusColor $r
        [void]$line.Children.Add((Text ($r.provider -replace ' \(lead\)', '') '#C9D1D9' 12 150))
        [void]$line.Children.Add((Text $r.window '#8B949E' 11 110))
        $bar = New-Object System.Windows.Controls.Border
        $bar.Width = 70; $bar.Height = 6; $bar.CornerRadius = 3; $bar.Background = Brush '#30363D'; $bar.Margin = '0,0,8,0'
        if ($null -ne $r.pct) {
            $fill = New-Object System.Windows.Controls.Border
            $fill.Width = [math]::Max(2, 70 * [math]::Min(100, [double]$r.pct) / 100); $fill.HorizontalAlignment = 'Left'
            $fill.CornerRadius = 3; $fill.Background = Brush $c; $bar.Child = $fill
        } else { $bar.Opacity = 0.3 }
        [void]$line.Children.Add($bar)
        $left = if ($r.status -like 'LIMIT*') { $r.status.ToLower() } else { $r.left }
        [void]$line.Children.Add((Text $left $c 12 120 $true))
        [void]$line.Children.Add((Text (Until $r.resets) '#8B949E' 11))
        $line.ToolTip = "$($r.provider) $($r.window): used $($r.used), left $($r.left), $($r.status)"
        [void]$stack.Children.Add($line)
    }
}

function Refresh-Data {   # runs scripts/usage.py in Ubuntu, hidden; Render picks up the new USAGE.json
    try { Start-Process -FilePath 'wsl.exe' -ArgumentList '-e', 'python3', './scripts/usage.py', 'quiet' -WorkingDirectory $Root -WindowStyle Hidden } catch { }
}

# menu
$menu = New-Object System.Windows.Controls.ContextMenu
function Item($label, $action) { $i = New-Object System.Windows.Controls.MenuItem; $i.Header = $label; $i.Add_Click($action); [void]$menu.Items.Add($i); $i }
[void](Item 'Refresh now' { Refresh-Data })
[void](Item 'Open full report' { if (Test-Path $Report) { Start-Process notepad.exe -ArgumentList "`"$Report`"" } })
$auto = Item 'Start with Windows' {
    if (Test-Path $Startup) { Remove-Item $Startup -Force }
    else { $s = (New-Object -ComObject WScript.Shell).CreateShortcut($Startup); $s.TargetPath = $Bat; $s.WorkingDirectory = (Split-Path $Bat); $s.WindowStyle = 7; $s.Save() }
    $auto.IsChecked = Test-Path $Startup
}
$auto.IsChecked = Test-Path $Startup
[void](Item 'Close' { $w.Close() })
$border.ContextMenu = $menu

# position: last place, else bottom-right
$w.Add_MouseLeftButtonDown({ $w.DragMove() })
$w.Add_LocationChanged({ try { "$([int]$w.Left),$([int]$w.Top)" | Set-Content $PosFile } catch { } })
$w.Add_Loaded({
    $p = if (Test-Path $PosFile) { (Get-Content $PosFile -Raw).Trim() -split ',' } else { $null }
    $wa = [System.Windows.SystemParameters]::WorkArea
    if ($p -and $p.Count -eq 2 -and [int]$p[0] -lt $wa.Right - 40 -and [int]$p[1] -lt $wa.Bottom - 40) { $w.Left = [int]$p[0]; $w.Top = [int]$p[1] }
    else { $w.Left = $wa.Right - $w.ActualWidth - 12; $w.Top = $wa.Bottom - $w.ActualHeight - 12 }
})

$t1 = New-Object System.Windows.Threading.DispatcherTimer; $t1.Interval = [TimeSpan]::FromSeconds(30); $t1.Add_Tick({ Render }); $t1.Start()
$t2 = New-Object System.Windows.Threading.DispatcherTimer; $t2.Interval = [TimeSpan]::FromMinutes(5); $t2.Add_Tick({ Refresh-Data }); $t2.Start()
Render
Refresh-Data
[void]$w.ShowDialog()
$mutex.ReleaseMutex()
