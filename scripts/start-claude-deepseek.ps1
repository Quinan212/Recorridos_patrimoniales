param(
  [string]$ProxyBaseUrl = $env:ANTHROPIC_BASE_URL,
  [string]$Model = $env:ANTHROPIC_MODEL,
  [switch]$LaunchClaude
)

$ErrorActionPreference = "Stop"

function Write-Step($Message) {
  Write-Host $Message -ForegroundColor Cyan
}

function Write-Warn($Message) {
  Write-Host $Message -ForegroundColor Yellow
}

function Write-Ok($Message) {
  Write-Host $Message -ForegroundColor Green
}

Write-Step "Verificando prerrequisitos..."

$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd) {
  Write-Warn "Claude Code no esta instalado o no esta en PATH."
  Write-Host "Instalalo con: winget install Anthropic.ClaudeCode" -ForegroundColor Gray
  Write-Host "O: npm install -g @anthropic-ai/claude-code" -ForegroundColor Gray
  exit 1
}

$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
  Write-Warn "Node.js no esta instalado o no esta en PATH."
  Write-Host "Claude Code requiere Node.js 18 o superior." -ForegroundColor Gray
  exit 1
}

if (-not $ProxyBaseUrl) {
  $ProxyBaseUrl = Read-Host "URL base del proxy Anthropic-compatible, por ejemplo http://localhost:3000"
}

if (-not $Model) {
  $Model = "deepseek-v4-pro"
}

if ($ProxyBaseUrl.EndsWith("/")) {
  $ProxyBaseUrl = $ProxyBaseUrl.TrimEnd("/")
}

$env:ANTHROPIC_BASE_URL = $ProxyBaseUrl
$env:ANTHROPIC_MODEL = $Model
$env:ANTHROPIC_CUSTOM_MODEL_OPTION = $Model
$env:ANTHROPIC_CUSTOM_MODEL_OPTION_NAME = "DeepSeek V4 Pro"
$env:ANTHROPIC_CUSTOM_MODEL_OPTION_DESCRIPTION = "DeepSeek V4 Pro a través de un proxy compatible con Anthropic"
$env:ENABLE_TOOL_SEARCH = "true"

Write-Ok "Configuracion activa:"
Write-Host "  ANTHROPIC_BASE_URL = $env:ANTHROPIC_BASE_URL" -ForegroundColor Gray
Write-Host "  ANTHROPIC_MODEL = $env:ANTHROPIC_MODEL" -ForegroundColor Gray
Write-Host "  ENABLE_TOOL_SEARCH = $env:ENABLE_TOOL_SEARCH" -ForegroundColor Gray

Write-Step "Probando si el proxy responde en /v1/models..."
try {
  $modelsUrl = "$ProxyBaseUrl/v1/models"
  $response = Invoke-RestMethod -Uri $modelsUrl -Method Get -TimeoutSec 10
  Write-Ok "El proxy responde correctamente en /v1/models."
  if ($response) {
    $response | ConvertTo-Json -Depth 6 | Write-Host
  }
}
catch {
  Write-Warn "No pude validar /v1/models. Puede ser normal si tu proxy usa otro endpoint."
  Write-Host $_.Exception.Message -ForegroundColor DarkYellow
}

if ($LaunchClaude -or $Host.Name -ne "ConsoleHost") {
  Write-Step "Lanzando Claude Code..."
  & claude
}
else {
  Write-Ok "Listo. Ejecuta 'claude' en esta misma ventana para usar el proxy."
}
