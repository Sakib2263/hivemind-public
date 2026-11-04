# Usage overlay: a small always-on-top window showing what's left per provider and model.
# Started by windows\shortcuts\20 Usage Overlay.bat. Shows USAGE.json (made by scripts/usage.py) and refreshes it
# through WSL every 5 minutes; the relay also refreshes it after every job.
# Three views: simple (each provider and % left), detailed (every window, reset times, not connected list) and
# minimised (one line). Header buttons: minimise, detailed view, close. Drag to move. Right-click: Refresh now,
# Open full report, Start with Windows, Close.
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
try { $Host.UI.RawUI.WindowTitle = 'Hivemind usage window (close it from its right-click menu)' } catch { }   # if a console ever shows, it has a name
try {   # hide this script's own console window, if there is one
    Add-Type -Name W -Namespace Hm -MemberDefinition '[DllImport("kernel32.dll")] public static extern System.IntPtr GetConsoleWindow(); [DllImport("user32.dll")] public static extern bool ShowWindow(System.IntPtr h, int n);'
    $cw = [Hm.W]::GetConsoleWindow(); if ($cw -ne [System.IntPtr]::Zero) { [void][Hm.W]::ShowWindow($cw, 0) }
} catch { }
$Root    = Split-Path -Parent $PSScriptRoot
$Json    = Join-Path $Root 'USAGE.json'
$Report  = Join-Path $Root 'USAGE.md'
$PosFile = Join-Path $Root 'logs\overlay-pos.txt'
$StateFile = Join-Path $Root 'logs\overlay-state.txt'   # view and minimised state, remembered for next time
$st = if (Test-Path $StateFile) { (Get-Content $StateFile -Raw).Trim() } else { '' }
$script:Compact = $st -like 'compact*'
$script:Detailed = $st -like '*detailed' -or $st -eq 'full'   # 'full' = detailed, from before the simple view
$Bat     = Join-Path $Root 'windows\Start Hivemind.bat'   # what Start with Windows launches: relay + this window
$Startup = Join-Path ([Environment]::GetFolderPath('Startup')) 'Hivemind Usage Overlay.lnk'

if (Test-Path $Startup) {   # an entry from before a folder move: point it at the current Start Hivemind
    try { $sc = (New-Object -ComObject WScript.Shell).CreateShortcut($Startup); if ($sc.TargetPath -ne $Bat) { $sc.TargetPath = $Bat; $sc.WorkingDirectory = (Split-Path $Bat); $sc.Save() } } catch { }
}
$ErrLog = Join-Path $Root 'logs\overlay-error.log'   # the window is hidden from the console: errors go here
function Log-Error($e) { try { "$(Get-Date -Format s) $e $($e.ScriptStackTrace)" | Add-Content $ErrLog } catch { } }
trap { Log-Error $_; continue }
# one copy only. A second launch (20 Usage Overlay, Start Hivemind) asks the open window to come back, then exits.
$mutex = New-Object System.Threading.Mutex($false, 'HivemindUsageOverlay')
$ShowMe = New-Object System.Threading.EventWaitHandle($false, [System.Threading.EventResetMode]::AutoReset, 'HivemindUsageOverlayShow')
$got = $false; try { $got = $mutex.WaitOne(0) } catch [System.Threading.AbandonedMutexException] { $got = $true }   # an old copy crashed: take over
if (-not $got) { [void]$ShowMe.Set(); exit }

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

function Save-State { try { "$(if ($script:Compact) { 'compact-' } else { '' })$(if ($script:Detailed) { 'detailed' } else { 'simple' })" | Set-Content $StateFile } catch { } }
function Toggle { $script:Compact = -not $script:Compact; Save-State; Render }               # minimise / expand
function Toggle-View { $script:Detailed = -not $script:Detailed; $script:Compact = $false; Save-State; Render }   # simple / detailed

function Btn($glyph, $tip, $action, $on = $false) {   # header icon button (Segoe MDL2 Assets, on every Windows 10/11)
    $b = New-Object System.Windows.Controls.TextBlock
    $b.Text = [string][char]$glyph; $b.FontFamily = 'Segoe MDL2 Assets'; $b.FontSize = 11; $b.Padding = '6,3,6,3'
    $b.Foreground = Brush $(if ($on) { '#58A6FF' } else { '#C9D1D9' }); $b.VerticalAlignment = 'Center'
    $b.Cursor = 'Hand'; $b.ToolTip = $tip; $b.Background = [System.Windows.Media.Brushes]::Transparent
    $b.Add_MouseEnter({ param($s) $s.Background = Brush '#30363D' }); $b.Add_MouseLeave({ param($s) $s.Background = [System.Windows.Media.Brushes]::Transparent })
    $b.Add_PreviewMouseLeftButtonDown($action)   # handled there, so the click doesn't start a window drag
    $b
}
function Buttons($panel) {
    $g = New-Object System.Windows.Controls.StackPanel; $g.Orientation = 'Horizontal'; $g.Margin = '6,0,0,0'
    [void]$g.Children.Add((Btn $(if ($script:Compact) { 0xE923 } else { 0xE921 }) $(if ($script:Compact) { 'Expand' } else { 'Minimise to one line' }) { param($s, $e) $e.Handled = $true; Toggle }))
    [void]$g.Children.Add((Btn 0xE72C 'Refresh now (asks every provider again)' { param($s, $e) $e.Handled = $true; Refresh-Data $true }))
    [void]$g.Children.Add((Btn 0xE8FD $(if ($script:Detailed) { 'Simple view' } else { 'Detailed view' }) { param($s, $e) $e.Handled = $true; Toggle-View } $script:Detailed))
    [void]$g.Children.Add((Btn 0xE8BB 'Close (Start Hivemind or 20 Usage Overlay opens it again)' { param($s, $e) $e.Handled = $true; $w.Close() }))
    [void]$panel.Children.Add($g)
}

# simple view: one line per provider, the tightest window's % left
$Short = [ordered]@{ 'Claude Pro (lead)' = 'Claude'; 'opencode GLM (free)' = 'GLM (opencode)'; 'opencode DeepSeek (free2)' = 'DeepSeek (opencode)';
                     'NVIDIA MiniMax (nv)' = 'MiniMax (NVIDIA)'; 'NVIDIA Nemotron (nv2)' = 'Nemotron (NVIDIA)';
                     'Antigravity (Gemini)' = 'Gemini (Antigravity)'; 'OpenRouter free (PAL)' = 'OpenRouter'; 'Codex' = 'Codex' }
function Simple-Rows($d) {
    $missing = @($d.providers | Where-Object { $_.needed -and $_.status -ne 'ok' } | ForEach-Object { $_.provider })
    $off = @{}; if ($missing -like 'opencode*') { $off['GLM (opencode)'] = 1; $off['DeepSeek (opencode)'] = 1 }
    if ($missing -like 'Antigravity*') { $off['Gemini (Antigravity)'] = 1 }
    $out = @()
    $groups = @{}; foreach ($g in ($d.rows | Group-Object provider)) { $groups[$g.Name] = $g }
    $order = @($Short.Keys)
    foreach ($grp in ($order | Where-Object { $groups.ContainsKey($_) } | ForEach-Object { $groups[$_] })) {
        $name = if ($Short.Contains($grp.Name)) { $Short[$grp.Name] } else { $null }
        if (-not $name) { continue }   # Claude Code tokens, Antigravity job counts: detailed view only
        $withPct = @($grp.Group | Where-Object { $null -ne $_.pct } | Sort-Object { [double]$_.pct } -Descending)
        $r = if ($withPct.Count) { $withPct[0] } else { $grp.Group[0] }
        $hit = $grp.Group | Where-Object { $_.status -like 'LIMIT*' } | Select-Object -First 1
        if ($off[$name]) { $txt = 'not connected'; $col = '#E5534B' }
        elseif ($hit) { $txt = $hit.status.ToLower(); $col = '#E5534B' }
        elseif ($null -ne $r.pct) { $txt = '{0:0}% left' -f [math]::Max(0, 100 - [double]$r.pct); $col = StatusColor $r }
        elseif ($r.left -match 'jobs|no published') { $txt = 'free'; $col = '#3FB950' }
        else { $txt = 'not read'; $col = '#8B949E' }
        $out += [pscustomobject]@{ name = $name; text = $txt; color = $col; pct = $r.pct; tip = "$($grp.Name): $($r.window), used $($r.used), left $($r.left)" }
    }
    foreach ($p in ($d.providers | Where-Object { $_.needed -and $_.status -ne 'ok' -and $_.provider -notlike 'opencode*' -and $_.provider -notlike 'Antigravity*' })) {
        $out += [pscustomobject]@{ name = $p.provider; text = 'not connected'; color = '#E5534B'; pct = $null; tip = "To add: $($p.fix)" }
    }
    $out
}

function Bar($pct, $c) {
    $bar = New-Object System.Windows.Controls.Border
    $bar.Width = 70; $bar.Height = 6; $bar.CornerRadius = 3; $bar.Background = Brush '#30363D'; $bar.Margin = '0,0,8,0'
    if ($null -ne $pct) {
        $fill = New-Object System.Windows.Controls.Border
        $fill.Width = [math]::Max(2, 70 * [math]::Min(100, [double]$pct) / 100); $fill.HorizontalAlignment = 'Left'
        $fill.CornerRadius = 3; $fill.Background = Brush $c; $bar.Child = $fill
    } else { $bar.Opacity = 0.3 }
    $bar
}

function Render { try { Render-Now } catch { Log-Error $_ } }
function Render-Now {
    $stack.Children.Clear()
    $d = $null
    try { $d = Get-Content $Json -Raw -Encoding UTF8 | ConvertFrom-Json } catch { }
    $head = New-Object System.Windows.Controls.DockPanel; $head.Margin = '0,0,0,6'; $head.LastChildFill = $true
    $right = New-Object System.Windows.Controls.StackPanel; $right.Orientation = 'Horizontal'
    [System.Windows.Controls.DockPanel]::SetDock($right, 'Right'); [void]$head.Children.Add($right)
    $left = New-Object System.Windows.Controls.StackPanel; $left.Orientation = 'Horizontal'; [void]$head.Children.Add($left)
    [void]$left.Children.Add((Text 'Usage left' '#E6EDF3' 13 0 $true))
    if (-not $d) { [void]$left.Children.Add((Text 'loading...' '#8B949E' 11)); Buttons $right; [void]$stack.Children.Add($head); return }
    $age = [int]([DateTimeOffset]::Now - (Dto $d.updated)).TotalMinutes
    $note = if ($script:Busy) { 'refreshing...' } elseif ($age -gt 15) { "updated $age min ago" } else { 'updated ' + (Dto $d.updated).ToLocalTime().ToString('HH:mm') }
    try { if ((Get-Content (Join-Path $Root 'relay\awake.state') -Raw).Trim() -eq 'on') { $note += '  |  awake (jobs running)' } } catch { }   # windows\keep-awake.ps1
    if ($script:Compact) {   # one line: Claude left + how many need attention
        $cl = Simple-Rows $d | Where-Object { $_.name -eq 'Claude' } | Select-Object -First 1
        $bad = @($d.rows | Where-Object { $_.status -like 'LIMIT*' -or $_.status -eq 'OUT' -or $_.status -eq 'LOW' })
        $bad += @($d.providers | Where-Object { $_.needed -and $_.status -ne 'ok' })   # a needed worker not connected
        $sum = 'Claude ' + $(if ($cl) { $cl.text } else { '?' }) + $(if ($bad.Count) { "  |  $($bad.Count) need attention" } else { '  |  all ok' })
        $col = if ($bad | Where-Object { $_.status -like 'LIMIT*' -or $_.status -eq 'OUT' -or $_.status -like 'not *' }) { '#E5534B' } elseif ($bad.Count) { '#D29922' } else { '#3FB950' }
        [void]$left.Children.Add((Text $sum $col 12 0 $true))
        Buttons $right; $head.Margin = '0'
        [void]$stack.Children.Add($head); return
    }
    [void]$left.Children.Add((Text $note ($(if ($age -gt 15) { '#D29922' } else { '#8B949E' })) 11))
    Buttons $right
    [void]$stack.Children.Add($head)
    if (-not $script:Detailed) {
        foreach ($r in (Simple-Rows $d)) {
            $line = New-Object System.Windows.Controls.StackPanel; $line.Orientation = 'Horizontal'; $line.Margin = '0,1,0,1'
            [void]$line.Children.Add((Text $r.name '#C9D1D9' 12 140))
            [void]$line.Children.Add((Bar $(if ($null -ne $r.pct) { 100 - [double]$r.pct } else { $null }) $r.color))
            [void]$line.Children.Add((Text $r.text $r.color 12 0 $true))
            $line.ToolTip = $r.tip
            [void]$stack.Children.Add($line)
        }
        return
    }
    foreach ($r in $d.rows) {
        $line = New-Object System.Windows.Controls.StackPanel; $line.Orientation = 'Horizontal'; $line.Margin = '0,1,0,1'
        $c = StatusColor $r
        [void]$line.Children.Add((Text ($r.provider -replace ' \(lead\)', '') '#C9D1D9' 12 150))
        [void]$line.Children.Add((Text $r.window '#8B949E' 11 110))
        [void]$line.Children.Add((Bar $r.pct $c))
        $lt = if ($r.status -like 'LIMIT*') { $r.status.ToLower() } else { $r.left }
        [void]$line.Children.Add((Text $lt $c 12 120 $true))
        [void]$line.Children.Add((Text (Until $r.resets) '#8B949E' 11))
        $line.ToolTip = "$($r.provider) $($r.window): used $($r.used), left $($r.left), $($r.status)"
        [void]$stack.Children.Add($line)
    }
    $miss = @($d.providers | Where-Object { $_.status -ne 'ok' })   # tools or keys not set up (scripts/providers.py)
    if ($miss.Count) {
        [void]$stack.Children.Add((Text 'Not connected' '#E6EDF3' 12 0 $true))
        foreach ($p in $miss) {
            $line = New-Object System.Windows.Controls.StackPanel; $line.Orientation = 'Horizontal'; $line.Margin = '0,1,0,1'
            $c = if ($p.needed) { '#E5534B' } else { '#8B949E' }
            [void]$line.Children.Add((Text $p.provider '#C9D1D9' 12 150))
            [void]$line.Children.Add((Text $(if ($p.needed) { 'needed' } else { 'optional' }) '#8B949E' 11 110))
            [void]$line.Children.Add((Text $p.status $c 12 0 $true))
            $line.ToolTip = "$($p.provider): $($p.status). To add: $($p.fix)"
            [void]$stack.Children.Add($line)
        }
        [void]$stack.Children.Add((Text 'Hover a line to see how to add it' '#8B949E' 10))
    }
}

function Refresh-Data($fresh = $false) {   # runs scripts/usage.py in Ubuntu, hidden; re-draws as soon as it finishes
    if ($script:Proc -and -not $script:Proc.HasExited) { return }   # one refresh at a time
    try {   # no console window at all (Start-Process -WindowStyle Hidden still opens a Terminal tab on Windows 11)
        $arg = 'quiet' + $(if ($fresh) { ' fresh' } else { '' })   # fresh: ask Claude/Antigravity now, not the 5-minute cache
        $si = New-Object System.Diagnostics.ProcessStartInfo 'wsl.exe', "-e bash -c `"python3 ./scripts/usage.py $arg > logs/overlay-refresh.log 2>&1`""
        $si.WorkingDirectory = $Root; $si.UseShellExecute = $false; $si.CreateNoWindow = $true
        $script:Proc = [System.Diagnostics.Process]::Start($si); $script:Busy = $true; Render
    } catch { $script:Busy = $false }
}

# menu
$menu = New-Object System.Windows.Controls.ContextMenu
function Item($label, $action) { $i = New-Object System.Windows.Controls.MenuItem; $i.Header = $label; $i.Add_Click($action); [void]$menu.Items.Add($i); $i }
[void](Item 'Refresh now' { Refresh-Data $true })
[void](Item 'Minimise / expand' { Toggle })
[void](Item 'Simple / detailed view' { Toggle-View })
[void](Item 'Open full report' { if (Test-Path $Report) { Start-Process notepad.exe -ArgumentList "`"$Report`"" } })
$auto = Item 'Start Hivemind with Windows (relay + this window)' {
    if (Test-Path $Startup) { Remove-Item $Startup -Force }
    else { $s = (New-Object -ComObject WScript.Shell).CreateShortcut($Startup); $s.TargetPath = $Bat; $s.WorkingDirectory = (Split-Path $Bat); $s.WindowStyle = 7; $s.Save() }
    $auto.IsChecked = Test-Path $Startup
}
$auto.IsChecked = Test-Path $Startup
[void](Item 'Close' { $w.Close() })
$border.ContextMenu = $menu

# position: last place, else bottom-right
$w.Add_MouseLeftButtonDown({ $w.DragMove() })
$w.Add_SizeChanged({   # a bigger view near the screen edge: move it back inside
    $wa = [System.Windows.SystemParameters]::WorkArea
    if ($w.Left + $w.ActualWidth -gt $wa.Right) { $w.Left = [math]::Max($wa.Left, $wa.Right - $w.ActualWidth - 4) }
    if ($w.Top + $w.ActualHeight -gt $wa.Bottom) { $w.Top = [math]::Max($wa.Top, $wa.Bottom - $w.ActualHeight - 4) }
})
$w.Add_LocationChanged({ if ($w.Left -gt -10000 -and $w.Top -gt -10000) { try { "$([int]$w.Left),$([int]$w.Top)" | Set-Content $PosFile } catch { } } })
function Place-Home { $wa = [System.Windows.SystemParameters]::WorkArea; $w.Left = $wa.Right - $w.ActualWidth - 12; $w.Top = $wa.Bottom - $w.ActualHeight - 12 }
$w.Add_Loaded({
    $p = if (Test-Path $PosFile) { (Get-Content $PosFile -Raw).Trim() -split ',' } else { $null }
    $wa = [System.Windows.SystemParameters]::WorkArea
    if ($p -and $p.Count -eq 2 -and [int]$p[0] -ge $wa.Left -and [int]$p[1] -ge $wa.Top -and [int]$p[0] -lt $wa.Right - 40 -and [int]$p[1] -lt $wa.Bottom - 40) { $w.Left = [int]$p[0]; $w.Top = [int]$p[1] }
    else { Place-Home }   # no saved place, or it was off screen (other monitor, Show desktop)
})

$t1 = New-Object System.Windows.Threading.DispatcherTimer; $t1.Interval = [TimeSpan]::FromSeconds(30); $t1.Add_Tick({ Render }); $t1.Start()
$t2 = New-Object System.Windows.Threading.DispatcherTimer; $t2.Interval = [TimeSpan]::FromMinutes(5); $t2.Add_Tick({ Refresh-Data }); $t2.Start()
$t3 = New-Object System.Windows.Threading.DispatcherTimer; $t3.Interval = [TimeSpan]::FromSeconds(1)   # a refresh finished: show it now
$t3.Add_Tick({
    if ($script:Busy -and $script:Proc -and $script:Proc.HasExited) { $script:Busy = $false; Render }
    if ($ShowMe.WaitOne(0)) {   # launched again: bring this window back on screen
        $w.Show(); $w.WindowState = 'Normal'; $w.Topmost = $true
        $wa = [System.Windows.SystemParameters]::WorkArea
        if ($w.Left -lt $wa.Left -or $w.Top -lt $wa.Top -or $w.Left -gt $wa.Right - 40 -or $w.Top -gt $wa.Bottom - 40) { Place-Home }
        [void]$w.Activate(); Refresh-Data $true
    }
}); $t3.Start()
Render
Refresh-Data
try { [void]$w.ShowDialog() } catch { Log-Error $_ }
try { $mutex.ReleaseMutex() } catch { }
