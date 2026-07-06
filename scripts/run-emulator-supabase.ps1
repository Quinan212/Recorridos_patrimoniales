param(
  [string]$DeviceId = "emulator-5554"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$launchPath = Join-Path $projectRoot ".vscode\launch.json"
$flutterPath = "C:\flutter\flutter\bin\flutter.bat"
$gitCmdPath = "C:\Program Files\Git\cmd"

if (-not (Test-Path -LiteralPath $launchPath)) {
  throw "No existe .vscode\launch.json con los dart-defines de Supabase."
}

if (-not (Test-Path -LiteralPath $flutterPath)) {
  throw "No existe Flutter en $flutterPath."
}

if (-not (Test-Path -LiteralPath (Join-Path $gitCmdPath "git.exe"))) {
  throw "No existe git.exe en $gitCmdPath."
}

$launch = Get-Content -LiteralPath $launchPath -Raw | ConvertFrom-Json
$appConfig = $launch.configurations |
  Where-Object { $_.program -eq "lib/main.dart" } |
  Select-Object -First 1

if ($null -eq $appConfig) {
  throw "No se encontro una configuracion de VS Code para lib/main.dart."
}

$dartDefines = @($appConfig.args | Where-Object {
  $_ -like "--dart-define=SUPABASE_*"
})

$requiredDefines = @("SUPABASE_URL", "SUPABASE_ANON_KEY")
foreach ($name in $requiredDefines) {
  $exists = $false
  foreach ($define in $dartDefines) {
    if ($define.StartsWith("--dart-define=$name=")) {
      $exists = $true
      break
    }
  }

  if (-not $exists) {
    throw "Falta $name en .vscode\launch.json."
  }
}

$env:Path = "C:\Windows\System32;C:\Windows;$gitCmdPath;$env:Path"

Set-Location -LiteralPath $projectRoot
& $flutterPath run -d $DeviceId @dartDefines
