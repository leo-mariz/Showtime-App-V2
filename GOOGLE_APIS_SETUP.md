# Configuração das APIs do Google

Este documento explica como configurar as APIs do Google necessárias para o sistema de endereços do ShowtimeApp.

## 📋 APIs Necessárias

Você precisará habilitar as seguintes APIs no Google Cloud Console:

1. **Places API (Autocomplete)** - Para busca e autocomplete de endereços enquanto o usuário digita
2. **Geocoding API** - Para conversão de coordenadas ↔ endereços (obrigatório)
3. **Maps SDK for Android** - Para exibir mapas no Android
4. **Maps SDK for iOS** - Para exibir mapas no iOS

**Nota**: Não é necessário habilitar Place Details API, pois usamos Geocoding que é mais barato ($5/1000 vs $17/1000).

## 🔑 Passo a Passo

### 1. Criar/Selecionar Projeto no Google Cloud Console

1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Selecione um projeto existente ou crie um novo
3. Anote o **Project ID** para referência

### 2. Habilitar as APIs

1. No menu lateral, vá em **APIs & Services** > **Library**
2. Busque e habilite cada uma das seguintes APIs:
   - **Places API** (apenas Autocomplete)
   - **Geocoding API** (obrigatório)
   - **Maps SDK for Android**
   - **Maps SDK for iOS**

### 3. Criar Chave de API

1. Vá em **APIs & Services** > **Credentials**
2. Clique em **+ CREATE CREDENTIALS** > **API Key**
3. Uma chave será gerada automaticamente
4. **IMPORTANTE**: Clique na chave criada para configurar restrições

### 4. Configurar Restrições da Chave (Recomendado)

#### Restrições de Aplicativo:

1. Em **Application restrictions**, selecione:
   - **Android apps** para a chave Android
   - **iOS apps** para a chave iOS

2. **Para Android:**
   - Adicione o **Package name**: (encontre em `android/app/build.gradle` ou `AndroidManifest.xml`)
   - Adicione o **SHA-1 certificate fingerprint**: 
     ```bash
     # Para debug
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     
     # Para release (quando tiver)
     keytool -list -v -keystore /caminho/para/seu/keystore.jks -alias seu-alias
     ```

3. **Para iOS:**
   - Adicione o **Bundle identifier**: (encontre em `ios/Runner/Info.plist` como `CFBundleIdentifier`)

#### Restrições de API:

1. Em **API restrictions**, selecione **Restrict key**
2. Selecione apenas as APIs necessárias:
   - ✅ Places API (apenas para Autocomplete)
   - ✅ Geocoding API (obrigatório)
   - ✅ Maps SDK for Android (se for chave Android)
   - ✅ Maps SDK for iOS (se for chave iOS)

### 5. Adicionar Chave no Projeto

1. Abra o arquivo `.env` na raiz do projeto `app/`
2. Adicione a chave:

```env
GOOGLE_PLACES_API_KEY=sua_chave_aqui
```

**Nota**: Se você criou chaves separadas para Android e iOS, você pode:
- Usar a mesma chave (se não configurou restrições de aplicativo)
- Ou criar variáveis separadas: `GOOGLE_PLACES_API_KEY_ANDROID` e `GOOGLE_PLACES_API_KEY_IOS`

### 6. Configuração Android (OBRIGATÓRIO para Google Maps)

O Google Maps precisa da chave configurada no AndroidManifest.xml. Adicione no arquivo:

**`android/app/src/main/AndroidManifest.xml`**:

```xml
<manifest>
    <application>
        <!-- ... outras configurações ... -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="SUA_CHAVE_AQUI"/>
    </application>
</manifest>
```

**Nota**: Você pode usar a mesma chave do `.env` ou criar uma chave específica para Android.

### 7. Configuração iOS (OBRIGATÓRIO para Google Maps)

O Google Maps precisa da chave configurada no AppDelegate.swift. Atualize o arquivo:

**`ios/Runner/AppDelegate.swift`**:

```swift
import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Adicione esta linha com sua chave do Google Maps
    GMSServices.provideAPIKey("SUA_CHAVE_AQUI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Nota**: Você pode usar a mesma chave do `.env` ou criar uma chave específica para iOS.

## 🔒 Segurança

### Boas Práticas:

1. **Sempre configure restrições de API** - Limite quais APIs podem ser usadas
2. **Configure restrições de aplicativo** - Limite quais apps podem usar a chave
3. **Não commite a chave no Git** - Mantenha o `.env` no `.gitignore`
4. **Use chaves diferentes para desenvolvimento e produção**
5. **Monitore o uso** - Configure alertas de quota no Google Cloud Console

### Limites e Custos:

- **Places API (Autocomplete)**: 
  - Primeiros $200/mês são gratuitos
  - Autocomplete: $2.83 por 1000 requisições
- **Geocoding API**: 
  - Primeiros $200/mês são gratuitos
  - $5 por 1000 requisições (muito mais barato que Place Details que custa $17/1000)
- **Maps SDK**: 
  - Primeiros $200/mês são gratuitos
  - $7 por 1000 carregamentos de mapa

**Economia**: Ao usar Geocoding ao invés de Place Details, economizamos ~70% nos custos de conversão de endereços.

**Recomendação**: Configure alertas de billing no Google Cloud Console para evitar surpresas.

## ✅ Verificação

Após configurar tudo:

1. Execute `flutter pub get`
2. Execute `flutter run`
3. Teste a funcionalidade de adicionar endereço:
   - Buscar endereço
   - Usar localização atual
   - Verificar se o mapa carrega corretamente

## 🐛 Troubleshooting

### Erro: "API key not valid"
- Verifique se a chave está correta no `.env`
- Verifique se as APIs estão habilitadas
- Verifique se as restrições de aplicativo estão corretas

### Erro: "This API project is not authorized"
- Verifique se as APIs estão habilitadas no projeto
- Aguarde alguns minutos após habilitar (pode levar tempo para propagar)

### Mapa não carrega no Android
- Verifique se adicionou a chave no `AndroidManifest.xml` (se necessário)
- Verifique se o SHA-1 está correto nas restrições

### Mapa não carrega no iOS
- Verifique se adicionou a chave no `AppDelegate.swift` (se necessário)
- Verifique se o Bundle ID está correto nas restrições

## 📚 Referências

- [Google Maps Platform](https://developers.google.com/maps)
- [Places API Documentation](https://developers.google.com/maps/documentation/places)
- [Maps SDK for Android](https://developers.google.com/maps/documentation/android-sdk)
- [Maps SDK for iOS](https://developers.google.com/maps/documentation/ios-sdk)
- [Pricing](https://developers.google.com/maps/billing-and-pricing/pricing)

