# Keeps Windows awake while Hivemind works, then lets it sleep again. No window: started hidden by
# windows\shortcuts\1 Start Relay.bat and windows\Start Hivemind.bat. Settings: config\awake.env.
# Awake = relay running AND (a job queued or running, autopilot running, or the last job ended less than
# AWAKE_GRACE_MINUTES ago). The relay writes relay\activity; this script only reads files. Stops by itself
# 10 minutes after the relay closes. State for the usage window: relay\awake.state (on / off).
$ErrorActionPreference = 'SilentlyContinue'
try { Add-Type -Name W -Namespace Hm -MemberDefinition '[DllImport("kernel32.dll")] public static extern System.IntPtr GetConsoleWindow(); [DllImport("user32.dll")] public static extern bool ShowWindow(System.IntPtr h, int n);'
      $cw = [Hm.W]::GetConsoleWindow(); if ($cw -ne [System.IntPtr]::Zero) { [void][Hm.W]::ShowWindow($cw, 0) } } catch { }
Add-Type -Name P -Namespace HmAwake -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f);'
$mutex = New-Object System.Threading.Mutex($false, 'HivemindKeepAwake')   # one copy only
if (-not $mutex.WaitOne(0)) { exit }

$Root  = Split-Path -Parent $PSScriptRoot
$Relay = Join-Path $Root 'relay'
$State = Join-Path $Relay 'awake.state'
$CONT = [uint32]2147483648; $SYS = [uint32]1; $DISP = [uint32]2   # ES_CONTINUOUS, ES_SYSTEM_REQUIRED, ES_DISPLAY_REQUIRED

function Setting($name, $default) {
    $f = Join-Path $Root 'config\awake.env'
    if (Test-Path $f) { foreach ($l in Get-Content $f) { if ($l -match "^\s*$name=`"?([^`"#]*)") { return $matches[1].Trim() } } }
    $default
}
function Epoch($file) { try { [int64]((Get-Content (Join-Path $Relay $file) -Raw).Trim()) } catch { [int64]0 } }

$downSince = $null; $on = $false
while ($true) {
    $now   = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $up    = ($now - (Epoch 'heartbeat')) -lt 120
    $grace = [int](Setting 'AWAKE_GRACE_MINUTES' '15') * 60
    $busy  = $up -and ((Setting 'KEEP_AWAKE' 'yes') -eq 'yes') -and (($now - (Epoch 'activity')) -lt $grace)
    if ($busy) {
        $flags = $CONT -bor $SYS; if ((Setting 'AWAKE_DISPLAY' 'no') -eq 'yes') { $flags = $flags -bor $DISP }
        [void][HmAwake.P]::SetThreadExecutionState($flags)
    } else { [void][HmAwake.P]::SetThreadExecutionState($CONT) }   # back to normal: Windows may sleep
    if ($busy -ne $on) { $on = $busy; try { $(if ($on) { 'on' } else { 'off' }) | Set-Content $State } catch { } }
    if ($up) { $downSince = $null } elseif (-not $downSince) { $downSince = $now } elseif ($now - $downSince -gt 600) { break }
    Start-Sleep -Seconds 30
}
[void][HmAwake.P]::SetThreadExecutionState($CONT); try { 'off' | Set-Content $State } catch { }
$mutex.ReleaseMutex()
