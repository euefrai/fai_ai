# Fai AI

Assistente pessoal em Flutter para Android com comando por voz/texto, monitoramento básico do dispositivo e execução de ações locais.

## Status atual

Este repositório já contém a estrutura principal de `lib/` e permissões Android.

## Como rodar

1. Instale Flutter SDK (3.22+).
2. No diretório do projeto:

```bash
flutter pub get
flutter run
```

## Funcionalidades implementadas

- Wake word e captura de fala com `speech_to_text`.
- Resposta por voz com `flutter_tts`.
- Chat com fallback para Gemini API.
- Monitoramento de bateria/localização/apps instalados.
- Ações: abrir YouTube, abrir site, criar/deletar arquivo e criar pasta.
- Persistência de histórico com Hive.
- Serviço de monitoramento em background.

## Observação de segurança

A chave da API Gemini está em `lib/config_secrets.dart` para facilitar testes rápidos.
Para produção, use `--dart-define` ou um backend seguro.

## Build de APK via GitHub Actions

Foi adicionado o workflow `.github/workflows/android-apk.yml`.

Como usar:

1. Envie o código para o GitHub.
2. Abra a aba **Actions** no repositório.
3. Execute manualmente **Build Android APK** (workflow_dispatch) ou faça push para `main`, `master` ou `work`.
4. Ao final, baixe o artefato **fai-ai-release-apk**.
