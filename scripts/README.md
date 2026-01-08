# Scripts de População do Firestore

## populate_app_lists.dart

Script para popular as listas estáticas do app no Firestore.

### O que o script faz:

1. **Popula Talentos**: Adiciona 46 talentos de artistas
2. **Popula Tipos de Evento**: Adiciona 40 tipos de evento
3. **Popula Assuntos de Suporte**: Adiciona 10 assuntos de suporte

### Como executar:

```bash
cd app
dart run scripts/populate_app_lists.dart
```

### Pré-requisitos:

**IMPORTANTE:** Você precisa de uma chave de conta de serviço do Firebase.

1. Vá no Firebase Console > Configurações do Projeto > Contas de Serviço
2. Clique em "Gerar nova chave privada"
3. Salve o arquivo JSON como `serviceAccountKey.json` na raiz do projeto `app/`
4. **OU** defina a variável de ambiente `GOOGLE_APPLICATION_CREDENTIALS` apontando para o arquivo

### Verificação:

O script verifica automaticamente se o arquivo existe e mostra instruções caso não encontre.

### Estrutura criada no Firestore:

```
AppLists/
  ├── talents/
  │   └── items/
  │       └── {id}/
  │           ├── name: String
  │           ├── description: null
  │           ├── order: int
  │           ├── isActive: true
  │           ├── createdAt: Timestamp
  │           └── updatedAt: Timestamp
  │
  ├── eventTypes/
  │   └── items/
  │       └── {id}/
  │           └── (mesma estrutura)
  │
  └── supportSubjects/
      └── items/
          └── {id}/
              └── (mesma estrutura)
```

### Notas:

- O script **não limpa** dados existentes por padrão. 
- Se você quiser limpar antes de adicionar, descomente as linhas indicadas no código.
- **ATENÇÃO**: Execute apenas em ambiente de desenvolvimento/teste.
- Certifique-se de que o Firebase está configurado corretamente no projeto.

### Personalização:

Você pode editar os arrays no código para adicionar/remover/modificar itens:

- `_populateTalents()`: Edite o array `talents`
- `_populateEventTypes()`: Edite o array `eventTypes`
- `_populateSupportSubjects()`: Edite o array `supportSubjects`

