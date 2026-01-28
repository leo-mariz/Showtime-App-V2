# PROMPT: Criar Cloud Function para Cancelamento Automático de Contratos Expirados

## 📋 Contexto do Projeto

Você precisa criar uma Cloud Function para o Firebase que cancela automaticamente contratos que expiraram o prazo de aceitação sem resposta do artista.

### Estrutura do Firestore

**Coleção: `Contracts`**
- Documentos representam contratos entre clientes e artistas
- Campos relevantes:
  - `status`: String (valores: 'PENDING', 'PAID', 'CANCELED', 'REJECTED', 'COMPLETED', etc.)
  - `acceptDeadline`: Timestamp (data/hora limite para aceitar)
  - `refArtist`: String (UID do artista, se individual)
  - `refGroup`: String (UID do grupo, se grupo)
  - `refClient`: String (UID do cliente)
  - `contractorType`: String ('ARTIST' ou 'GROUP')
  - `canceledAt`: Timestamp (quando foi cancelado)
  - `canceledBy`: String ('CLIENT', 'ARTIST', ou 'SYSTEM')
  - `cancelReason`: String (motivo do cancelamento)
  - `statusChangedAt`: Timestamp (última mudança de status)

**Coleção: `user_contracts_index`**
- Documentos: `user_contracts_index/{userId}`
- Estrutura do índice:
  ```typescript
  {
    // Contadores para ARTISTA
    artistTab0Total: number,      // Total na Tab 0 (Em aberto)
    artistTab1Total: number,      // Total na Tab 1 (Confirmadas)
    artistTab2Total: number,      // Total na Tab 2 (Finalizadas)
    artistTab0Unseen: number,     // Não vistos na Tab 0
    artistTab1Unseen: number,     // Não vistos na Tab 1
    artistTab2Unseen: number,     // Não vistos na Tab 2
    lastSeenArtistTab0: Timestamp,
    lastSeenArtistTab1: Timestamp,
    lastSeenArtistTab2: Timestamp,
    
    // Contadores para CLIENTE
    clientTab0Total: number,
    clientTab1Total: number,
    clientTab2Total: number,
    clientTab0Unseen: number,
    clientTab1Unseen: number,
    clientTab2Unseen: number,
    lastSeenClientTab0: Timestamp,
    lastSeenClientTab1: Timestamp,
    lastSeenClientTab2: Timestamp,
    
    lastUpdate: Timestamp
  }
  ```

### Regras de Negócio

1. **Prazo de Aceitação**:
   - Se evento é nas próximas 36h: prazo de 1h30min
   - Caso contrário: prazo de 24h
   - O campo `acceptDeadline` já é calculado e salvo no frontend

2. **Cancelamento Automático**:
   - Se `status == 'PENDING'` e `acceptDeadline < now`: cancelar automaticamente
   - Atualizar campos:
     - `status`: 'CANCELED'
     - `canceledAt`: Timestamp atual
     - `canceledBy`: 'SYSTEM'
     - `cancelReason`: 'Artista não respondeu a tempo'
     - `statusChangedAt`: Timestamp atual

3. **Atualização de Índices**:
   - Quando um contrato é cancelado, ele sai da Tab 0 (Em aberto) e vai para Tab 2 (Finalizadas)
   - Decrementar `artistTab0Total` e `artistTab0Unseen` se ambos > 0 (se for artista)
   - Decrementar `clientTab0Total` e `clientTab0Unseen` se ambos > 0 (se for cliente)
   - Incrementar `artistTab2Total` (se for artista)
   - Incrementar `clientTab2Total` (se for cliente)
   - Atualizar `lastUpdate` com timestamp atual

## 🎯 Tarefa

Criar uma Cloud Function que:

1. **Executa a cada 15 minutos** via Cloud Scheduler
2. **Busca contratos expirados** usando query otimizada com índice composto:
   - `status == 'PENDING'`
   - `acceptDeadline < now`
   - Limite de 100 por execução (processar em lotes)
3. **Cancela os contratos** em batch (usando Firestore batch)
4. **Atualiza índices** de todos os usuários afetados (artistas e clientes)
5. **Logs detalhados** para monitoramento

## 📝 Requisitos Técnicos

### 1. Estrutura da Função

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const cancelExpiredContracts = functions
  .region('us-central1') // Ajustar para sua região
  .pubsub
  .schedule('every 15 minutes')
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    // Implementação aqui
  });
```

### 2. Query Otimizada

**IMPORTANTE**: Criar índice composto no Firestore ANTES do deploy:
- Collection: `Contracts`
- Fields: `status` (Ascending), `acceptDeadline` (Ascending)

```typescript
const expiredContractsQuery = db
  .collection('Contracts')
  .where('status', '==', 'PENDING')
  .where('acceptDeadline', '<', admin.firestore.Timestamp.now())
  .limit(100);
```

### 3. Processamento em Batch

- Usar `db.batch()` para atualizar múltiplos contratos
- Limite do Firestore: 500 operações por batch
- Processar em lotes de 100 contratos por execução

### 4. Atualização de Índices

Para cada usuário afetado (artista/grupo e cliente):
- Ler documento `user_contracts_index/{userId}`
- Se não existir, criar com valores padrão (todos 0)
- Calcular decrementos/incrementos baseado nos contratos cancelados
- Atualizar usando `update()` com valores calculados
- Garantir que valores nunca fiquem negativos (usar `Math.max(0, value)`)

### 5. Tratamento de Erros

- Try/catch em cada operação crítica
- Logs detalhados para debugging
- Não falhar a função inteira se um índice falhar (usar Promise.all com tratamento individual)
- Retornar estatísticas de sucesso/falha

## 🔧 Estrutura de Código Sugerida

```typescript
export const cancelExpiredContracts = functions
  .region('us-central1')
  .pubsub
  .schedule('every 15 minutes')
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    
    console.log(`[CancelExpiredContracts] Iniciando verificação às ${new Date().toISOString()}`);
    
    try {
      // 1. Buscar contratos expirados
      const expiredContracts = await buscarContratosExpirados(db, now);
      
      if (expiredContracts.empty) {
        console.log('[CancelExpiredContracts] Nenhum contrato expirado encontrado');
        return { canceledCount: 0 };
      }
      
      console.log(`[CancelExpiredContracts] Encontrados ${expiredContracts.size} contratos expirados`);
      
      // 2. Cancelar contratos em batch
      const contractIds = await cancelarContratos(db, expiredContracts, now);
      
      // 3. Atualizar índices
      await atualizarIndices(db, expiredContracts);
      
      console.log(`[CancelExpiredContracts] ${contractIds.length} contratos cancelados com sucesso`);
      return { canceledCount: contractIds.length };
      
    } catch (error) {
      console.error('[CancelExpiredContracts] Erro ao processar contratos expirados:', error);
      throw error;
    }
  });

// Função auxiliar: buscar contratos expirados
async function buscarContratosExpirados(
  db: admin.firestore.Firestore,
  now: admin.firestore.Timestamp
): Promise<admin.firestore.QuerySnapshot> {
  return await db
    .collection('Contracts')
    .where('status', '==', 'PENDING')
    .where('acceptDeadline', '<', now)
    .limit(100)
    .get();
}

// Função auxiliar: cancelar contratos
async function cancelarContratos(
  db: admin.firestore.Firestore,
  snapshot: admin.firestore.QuerySnapshot,
  now: admin.firestore.Timestamp
): Promise<string[]> {
  const batch = db.batch();
  const contractIds: string[] = [];
  
  snapshot.forEach((doc) => {
    const contractId = doc.id;
    contractIds.push(contractId);
    
    const contractRef = db.collection('Contracts').doc(contractId);
    batch.update(contractRef, {
      status: 'CANCELED',
      canceledAt: now,
      canceledBy: 'SYSTEM',
      cancelReason: 'Não resposta do artista',
      statusChangedAt: now,
    });
  });
  
  await batch.commit();
  return contractIds;
}

// Função auxiliar: atualizar índices
async function atualizarIndices(
  db: admin.firestore.Firestore,
  snapshot: admin.firestore.QuerySnapshot
): Promise<void> {
  // Implementar lógica de atualização de índices
  // Coletar todos os userIds únicos
  // Para cada userId, calcular decrementos/incrementos
  // Atualizar índices em paralelo usando Promise.all
}
```

## 📋 Checklist de Implementação

- [ ] Criar função principal `cancelExpiredContracts`
- [ ] Implementar função `buscarContratosExpirados`
- [ ] Implementar função `cancelarContratos` com batch
- [ ] Implementar função `atualizarIndices` com lógica completa
- [ ] Adicionar logs detalhados em cada etapa
- [ ] Tratamento de erros robusto
- [ ] Garantir idempotência (pode executar múltiplas vezes sem problemas)
- [ ] Testar com emulador local
- [ ] Fazer deploy

## ⚠️ Pontos de Atenção

1. **Índice Composto**: Criar ANTES do deploy, senão a query vai falhar
2. **Valores Negativos**: Sempre usar `Math.max(0, value)` ao decrementar
3. **Processamento Paralelo**: Usar `Promise.all` para atualizar índices em paralelo
4. **Limites do Firestore**: Batch limit de 500 operações, então processar em lotes se necessário
5. **Idempotência**: A função deve poder executar múltiplas vezes sem causar problemas (ex: se um contrato já foi cancelado, não cancelar novamente)

## 🎨 Exemplo de Log Esperado

```
[CancelExpiredContracts] Iniciando verificação às 2026-01-27T20:30:00.000Z
[CancelExpiredContracts] Encontrados 5 contratos expirados
[CancelExpiredContracts] Contrato abc123 marcado para cancelamento
[CancelExpiredContracts] Contrato def456 marcado para cancelamento
...
[CancelExpiredContracts] 5 contratos cancelados com sucesso
[CancelExpiredContracts] Índice atualizado para usuário artist123
[CancelExpiredContracts] Índice atualizado para usuário client456
[CancelExpiredContracts] Processamento concluído
```

## 📦 Dependências Necessárias

```json
{
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^4.5.0"
  }
}
```

## 🚀 Deploy

Após implementar:

```bash
cd functions
npm install
firebase deploy --only functions:cancelExpiredContracts
```

---

**IMPORTANTE**: Esta função deve seguir os padrões de Clean Code e Clean Architecture do projeto, com funções auxiliares bem definidas, tratamento de erros robusto e logs detalhados para facilitar debugging e monitoramento.
