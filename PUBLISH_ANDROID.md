# Publicação no Google Play (Teste Interno)

Guia para publicar o Showtime App no Google Play para testes.

---

## 1. Criar conta no Google Play Console

1. Acesse [Google Play Console](https://play.google.com/console)
2. Faça login com uma conta Google
3. Pague a taxa única de **US$ 25** (necessária para criar a conta de desenvolvedor)
4. Aceite o acordo de desenvolvedor

---

## 2. Criar o keystore de assinatura

O keystore é usado para assinar o app. **Guarde com segurança** — se perder, não poderá atualizar o app na Play Store.

No terminal (PowerShell ou CMD), execute:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- Defina uma senha forte e anote
- Preencha nome, organização e cidade quando solicitado
- O arquivo `upload-keystore.jks` será criado — mova-o para uma pasta segura (ex: `app/android/` ou fora do projeto)

---

## 3. Configurar key.properties

1. Copie o arquivo de exemplo:
   ```
   android/key.properties.example  →  android/key.properties
   ```

2. Edite `android/key.properties` com os dados do seu keystore:

   ```properties
   storePassword=senha_que_voce_definiu
   keyPassword=mesma_senha
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

   Se o keystore estiver em outro local, use o caminho completo, ex.:
   ```properties
   storeFile=C:/Users/Leo/keystores/showtime-upload.jks
   ```

⚠️ **Nunca** commite `key.properties` ou arquivos `.jks` no Git — eles já estão no `.gitignore`.

---

## 4. Gerar o App Bundle (AAB)

O Google Play exige o formato **AAB** (Android App Bundle), não APK.

Na pasta do app:

```bash
cd "c:\Users\Leo\Desktop\Projetos\Trabalho\Showtime App V2\app"
flutter build appbundle
```

O arquivo será gerado em:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 5. Criar o app no Google Play Console

1. No [Play Console](https://play.google.com/console), clique em **Criar app**
2. Preencha:
   - Nome do app: **Showtime**
   - Idioma padrão: Português (Brasil)
   - Tipo: App
   - Categoria: ex. Entretenimento ou Música
3. Declare políticas (conteúdo, privacidade, etc.) conforme os avisos

---

## 6. Configurar teste interno

1. No menu lateral: **Testar** → **Teste interno**
2. Clique em **Criar nova versão**
3. Faça upload do `app-release.aab`
4. Adicione uma **nota da versão** (ex: "Versão inicial para testes")
5. Clique em **Salvar** e depois **Revisar versão**
6. Clique em **Iniciar implantação para teste interno**

---

## 7. Adicionar testadores

1. Em **Teste interno**, vá em **Testadores**
2. Clique em **Criar lista de e-mails**
3. Crie uma lista (ex: "Equipe Showtime") e adicione os e-mails dos testadores
4. Salve e vincule a lista ao teste interno
5. Os testadores receberão um link para se inscrever no programa de teste

---

## 8. Completar a ficha da loja (obrigatório)

Antes de qualquer teste, é preciso preencher:

- **Painel do app** → **Ficha da loja**:
  - Descrição curta (80 caracteres)
  - Descrição completa
  - Ícone do app (512x512 px)
  - Imagem de destaque (1024x500 px)
  - Capturas de tela (pelo menos 2 por tipo de dispositivo)

- **Política de privacidade**: URL de uma página com a política de privacidade
- **Classificação de conteúdo**: questionário sobre o app
- **Público-alvo e conteúdo**: faixa etária e tipo de conteúdo

---

## Comandos rápidos

```bash
# Gerar AAB para publicação
flutter build appbundle

# Local do AAB gerado
# build/app/outputs/bundle/release/app-release.aab
```

---

## Próximos passos (produção)

Quando quiser publicar para todos os usuários:

1. Crie um **Teste fechado** ou **Teste aberto** antes
2. Depois crie uma versão em **Produção**
3. O Google pode levar até 7 dias para revisar o app
