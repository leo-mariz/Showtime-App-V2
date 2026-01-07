# Scripts de Seed

## seed_firestore.dart

Script para popular o Firestore com dados mockados de artistas e disponibilidades.

### O que faz:
- Cria 100 artistas com dados aleatórios
- Cria 5 disponibilidades para cada artista
- Processa em batches de 10 para não sobrecarregar o Firestore

### Como executar:

**1. Verificar dispositivos disponíveis:**
```bash
cd app
flutter devices
```

**2. Executar o script com um dispositivo Android ou iOS:**

Para Android (emulador ou dispositivo físico):
```bash
cd app
flutter run -d android -t scripts/seed_firestore.dart
```

Para iOS (simulador ou dispositivo físico):
```bash
cd app
flutter run -d ios -t scripts/seed_firestore.dart
```

Se você tiver apenas um dispositivo conectado, pode omitir o `-d`:
```bash
cd app
flutter run -t scripts/seed_firestore.dart
```

### Nota importante:
- Este script precisa ser executado com `flutter run` e não com `dart run`
- Você precisa ter um dispositivo Android ou iOS disponível (emulador/simulador ou físico)
- O script não requer macOS desktop - funciona com Android ou iOS

### Aviso:
⚠️ Este script irá criar dados no Firestore. Certifique-se de estar conectado ao projeto correto do Firebase antes de executar.

