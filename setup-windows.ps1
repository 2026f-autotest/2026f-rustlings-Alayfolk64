#Requires -Version 5.1
# Configure this checkout once, then start Rustlings using the temporary environment.
& {
    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version Latest

    function Invoke-Checked {
        param([string]$Program, [string[]]$Arguments)
        & $Program @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "$Program exited with code $LASTEXITCODE"
        }
    }

    if ($env:OS -ne 'Windows_NT' -or -not [Environment]::Is64BitOperatingSystem -or
        $env:PROCESSOR_ARCHITECTURE -eq 'ARM64') {
        throw 'This setup script requires x64 Windows (Intel / AMD).'
    }
    $versionMatch = [regex]::Match(
        (Get-Content -Raw (Join-Path $PSScriptRoot 'rust-toolchain.toml')),
        '(?m)^channel\s*=\s*"(\d+\.\d+\.\d+)"\s*$'
    )
    if (-not $versionMatch.Success) {
        throw 'Expected an exact Rust version in rust-toolchain.toml.'
    }
    $toolchain = $versionMatch.Groups[1].Value + '-x86_64-pc-windows-gnu'
    $savedEnvironment = @{}
    foreach ($name in @('RUSTUP_DIST_SERVER', 'RUSTUP_UPDATE_ROOT', 'RUSTUP_TOOLCHAIN',
            'PATH', 'TMPDIR', 'TEMP', 'TMP')) {
        $savedEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
    }
    $savedProtocol = [Net.ServicePointManager]::SecurityProtocol
    Push-Location $PSScriptRoot
    try {
        $env:RUSTUP_DIST_SERVER = 'https://rsproxy.cn'
        $env:RUSTUP_UPDATE_ROOT = 'https://rsproxy.cn/rustup'
        $env:RUSTUP_TOOLCHAIN = $toolchain
        $setupDir = Join-Path $PSScriptRoot 'tmp/setup'
        [void](New-Item -ItemType Directory -Force -Path $setupDir)
        $env:TMPDIR = $setupDir
        $env:TEMP = $setupDir
        $env:TMP = $setupDir
        $cargoHome = if ($env:CARGO_HOME) { $env:CARGO_HOME } else { Join-Path $env:USERPROFILE '.cargo' }
        $env:PATH = (Join-Path $cargoHome 'bin') + ';' + $env:PATH

        if (-not (Get-Command rustup.exe -ErrorAction SilentlyContinue)) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $installer = Join-Path $setupDir 'rustup-init.exe'
            $url = "$env:RUSTUP_UPDATE_ROOT/dist/x86_64-pc-windows-gnu/rustup-init.exe"
            Write-Host 'Downloading Rust installer from RsProxy...'
            Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $installer
            $checksumFile = $installer + '.sha256'
            Invoke-WebRequest -UseBasicParsing -Uri "$url.sha256" -OutFile $checksumFile
            $expectedHash = (Get-Content -Raw $checksumFile).Trim().Split(' ')[0]
            if ($expectedHash -notmatch '^[0-9a-fA-F]{64}$' -or
                (Get-FileHash -Algorithm SHA256 -Path $installer).Hash -ine $expectedHash) {
                throw 'Rust installer SHA256 verification failed.'
            }
            Invoke-Checked $installer @('-y', '--default-host', 'x86_64-pc-windows-gnu',
                '--default-toolchain', 'none', '--profile', 'minimal')
            # Keep the usual Windows host default; GNU is selected only for this checkout.
            Invoke-Checked 'rustup.exe' @('set', 'default-host', 'x86_64-pc-windows-msvc')
        }
        Invoke-Checked 'rustup.exe' @('toolchain', 'install', $toolchain, '--profile', 'minimal',
            '--component', 'clippy', '--component', 'rust-mingw', '--no-self-update', '--no-update')
        Invoke-Checked 'rustup.exe' @('override', 'set', $toolchain, '--path', $PSScriptRoot)

        # This file stays local; existing personal Cargo settings are preserved.
        [void](New-Item -ItemType Directory -Force -Path '.cargo')
        if (-not (Test-Path '.cargo/config.toml')) {
            $config = @'
[build]
target-dir = "tmp/target"

[source.crates-io]
replace-with = "rsproxy-sparse"

[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"
'@
            [IO.File]::WriteAllText((Join-Path $PSScriptRoot '.cargo/config.toml'), $config + "`n")
        }
        Write-Host 'Environment ready. Starting exercises; enter quit to exit.'
        Invoke-Checked 'cargo.exe' @('run', '--', 'watch')
    } finally {
        foreach ($name in $savedEnvironment.Keys) {
            if ($null -eq $savedEnvironment[$name]) {
                if (Test-Path "Env:$name") { Remove-Item "Env:$name" }
            } else {
                Set-Item "Env:$name" $savedEnvironment[$name]
            }
        }
        [Net.ServicePointManager]::SecurityProtocol = $savedProtocol
        Pop-Location
    }
}
