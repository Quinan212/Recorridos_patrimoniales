# recorridos_patrimoniales

A new Flutter project.

## Claude Code + DeepSeek V4 Pro

Si queres usar Claude Code contra un proxy compatible con Anthropic y enrutarlo a DeepSeek V4 Pro, ya deje una guia y un launcher en el repo:

- [Guia de setup](docs/claude-deepseek-proxy.md)
- [Launcher de PowerShell](scripts/start-claude-deepseek.ps1)

Resumen rapido:

```powershell
winget install Anthropic.ClaudeCode
.\scripts\start-claude-deepseek.ps1 -ProxyBaseUrl "http://localhost:3000" -LaunchClaude
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
