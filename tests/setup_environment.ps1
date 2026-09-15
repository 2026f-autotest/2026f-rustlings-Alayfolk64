# Check setup's PowerShell control flow without installing a Windows toolchain.
# The real Rustup and Cargo processes are replaced only inside this test process.
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
$setup = Join-Path $root 'setup-windows.ps1'
$tokens = $null
$errors = $null
[void][Management.Automation.Language.Parser]::ParseFile($setup, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors -join "`n") }
Write-Output 'PowerShell syntax: PASS'

$env:OS = 'Windows_NT'
$env:PROCESSOR_ARCHITECTURE = 'AMD64'
$env:USERPROFILE = Join-Path $root 'tmp/setup-test-user'
$env:CARGO_HOME = Join-Path $root 'tmp/setup-test-cargo'
$env:RUSTUP_DIST_SERVER = 'https://original.invalid'
$env:RUSTUP_UPDATE_ROOT = 'https://original.invalid/rustup'
$names = @('RUSTUP_DIST_SERVER', 'RUSTUP_UPDATE_ROOT', 'RUSTUP_TOOLCHAIN', 'PATH', 'TMPDIR', 'TEMP', 'TMP')
$before = @{}
foreach ($name in $names) { $before[$name] = [Environment]::GetEnvironmentVariable($name, 'Process') }
$protocol = [Net.ServicePointManager]::SecurityProtocol
$config = Join-Path $root '.cargo/config.toml'
$original = if (Test-Path $config) { [IO.File]::ReadAllBytes($config) } else { $null }
$script:Calls = [Collections.Generic.List[string]]::new()
function rustup.exe {
    $script:Calls.Add('rustup ' + ($args -join ' '))
    $global:LASTEXITCODE = if ($script:FailStage -eq 'install') { 42 } else { 0 }
}
function cargo.exe {
    $script:Calls.Add('cargo ' + ($args -join ' '))
    if ($env:RUSTUP_DIST_SERVER -ne 'https://rsproxy.cn') { throw 'Mirror absent during Cargo invocation' }
    if ($env:RUSTUP_TOOLCHAIN -ne '1.98.1-x86_64-pc-windows-gnu') { throw 'GNU toolchain absent during Cargo invocation' }
    $global:LASTEXITCODE = if ($script:FailStage -eq 'cargo') { 43 } else { 0 }
}
try {
    foreach ($stage in @('success', 'install', 'cargo')) {
        $script:FailStage = $stage
        $script:Calls.Clear()
        if ($stage -eq 'success' -and (Test-Path $config)) { [IO.File]::Delete($config) }
        $caught = $null
        try { . $setup } catch { $caught = $_ }
        if ($stage -eq 'success' -and $caught) { throw $caught }
        if ($stage -ne 'success' -and -not $caught) { throw 'Native command failure was ignored' }
        if ($caught) { Write-Output ('Expected failure: ' + $caught.Exception.Message) }
        foreach ($name in $names) {
            if ([Environment]::GetEnvironmentVariable($name, 'Process') -cne $before[$name]) {
                throw "Environment leaked: $name"
            }
        }
        if ((Get-Location).Path -cne $root) { throw 'Working directory leaked' }
        if ([Net.ServicePointManager]::SecurityProtocol -ne $protocol) { throw 'TLS setting leaked' }
        if ($stage -eq 'success') {
            if (-not $script:Calls.Contains('cargo run -- watch')) { throw 'Watch was not started' }
            if (-not $script:Calls.Contains('rustup override set 1.98.1-x86_64-pc-windows-gnu --path ' + $root)) {
                throw 'Repository override missing'
            }
            if ([IO.File]::ReadAllText($config) -notmatch 'sparse\+https://rsproxy.cn/index/') { throw 'Local mirror config missing' }
        }
        Write-Output "Environment restoration ($stage): PASS"
    }
} finally {
    if ($null -eq $original) {
        if (Test-Path $config) { [IO.File]::Delete($config) }
    } else {
        [IO.File]::WriteAllBytes($config, $original)
    }
}
