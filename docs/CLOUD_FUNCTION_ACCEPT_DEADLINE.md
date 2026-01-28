# Cloud Function: Cancelamento Automático de Contratos Expirados

## 📋 Visão Geral

Esta Cloud Function é responsável por cancelar automaticamente contratos que expiraram o prazo de aceitação sem resposta do artista.

### Regras de Negócio

- **Prazo de 1h30min**: Se o evento é nas próximas 36h (ex: criado hoje 12h, evento depois de amanhã 12h = 48h, então se for menos de 36h)
- **Prazo de 24h**: Para todos os outros casos
- **Cancelamento automático**: Se o artista não aceitar até o `acceptDeadline`, o contrato é cancelado automaticamente com motivo "Não resposta do artista"

## 🏗️ Estrutura da Implementação

### 1. Cloud Function (TypeScript)

**Localização**: `functions/src/index.ts` (ou similar)

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

/**
 * Cloud Function que cancela contratos expirados
 * Executa a cada 15 minutos via Cloud Scheduler
 * 
 * OTIMIZAÇÃO:
 * - Usa query com índice composto para buscar apenas contratos expirados
 * - Processa em lotes de 100 para evitar timeouts
 * - Atualiza índice de contratos após cancelamento
 */
export const cancelExpiredContracts = functions
  .region('southamerica-east1') // Ajustar para sua região
  .pubsub
  .schedule('every 15 minutes') // Executa a cada 15 minutos
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    
    console.log(`[CancelExpiredContracts] Iniciando verificação às ${new Date().toISOString()}`);
    
    try {
      // Query otimizada: busca apenas contratos PENDING com acceptDeadline expirado
      // IMPORTANTE: Criar índice composto no Firestore:
      // Collection: Contracts
      // Fields: status (Ascending), acceptDeadline (Ascending)
      const expiredContractsQuery = db
        .collection('Contracts')
        .where('status', '==', 'PENDING')
        .where('acceptDeadline', '<', now)
        .limit(100); // Processar em lotes de 100
      
      const snapshot = await expiredContractsQuery.get();
      
      if (snapshot.empty) {
        console.log('[CancelExpiredContracts] Nenhum contrato expirado encontrado');
        return null;
      }
      
      console.log(`[CancelExpiredContracts] Encontrados ${snapshot.size} contratos expirados`);
      
      const batch = db.batch();
      const contractIds: string[] = [];
      
      // Processar cada contrato expirado
      snapshot.forEach((doc) => {
        const contractId = doc.id;
        const contractData = doc.data();
        
        contractIds.push(contractId);
        
        // Atualizar contrato para CANCELED
        const contractRef = db.collection('Contracts').doc(contractId);
        batch.update(contractRef, {
          status: 'CANCELED',
          canceledAt: now,
          canceledBy: 'SYSTEM',
          cancelReason: 'Não resposta do artista',
          statusChangedAt: now,
        });
        
        console.log(`[CancelExpiredContracts] Contrato ${contractId} marcado para cancelamento`);
      });
      
      // Commit do batch
      await batch.commit();
      console.log(`[CancelExpiredContracts] ${contractIds.length} contratos cancelados com sucesso`);
      
      // Atualizar índices de contratos para cada usuário afetado
      // (Pode ser feito em uma segunda função ou aqui mesmo)
      await updateContractsIndexForCanceledContracts(db, contractIds, snapshot);
      
      return { canceledCount: contractIds.length };
    } catch (error) {
      console.error('[CancelExpiredContracts] Erro ao processar contratos expirados:', error);
      throw error;
    }
  });

/**
 * Atualiza o índice de contratos após cancelamento
 */
async function updateContractsIndexForCanceledContracts(
  db: admin.firestore.Firestore,
  contractIds: string[],
  snapshot: admin.firestore.QuerySnapshot
): Promise<void> {
  const userIds = new Set<string>();
  
  // Coletar todos os userIds afetados (artistas e clientes)
  snapshot.forEach((doc) => {
    const data = doc.data();
    if (data.refArtist) userIds.add(data.refArtist);
    if (data.refGroup) userIds.add(data.refGroup);
    if (data.refClient) userIds.add(data.refClient);
  });
  
  // Atualizar índice para cada usuário
  const updatePromises = Array.from(userIds).map(async (userId) => {
    try {
      const indexRef = db.collection('user_contracts_index').doc(userId);
      const indexDoc = await indexRef.get();
      
      if (!indexDoc.exists) {
        // Criar índice se não existir
        await indexRef.set({
          artistTab0Total: 0,
          artistTab1Total: 0,
          artistTab2Total: 0,
          artistTab0Unseen: 0,
          artistTab1Unseen: 0,
          artistTab2Unseen: 0,
          clientTab0Total: 0,
          clientTab1Total: 0,
          clientTab2Total: 0,
          clientTab0Unseen: 0,
          clientTab1Unseen: 0,
          clientTab2Unseen: 0,
          lastUpdate: admin.firestore.FieldValue.serverTimestamp(),
        });
        return;
      }
      
      const indexData = indexDoc.data()!;
      
      // Para cada contrato, determinar qual tab decrementar
      // Como os contratos foram cancelados, eles devem sair da Tab 0 (Em aberto)
      // e ir para Tab 2 (Finalizadas)
      
      // Contar quantos contratos eram do artista e quantos do cliente
      let artistTab0Decrement = 0;
      let clientTab0Decrement = 0;
      
      snapshot.forEach((doc) => {
        const data = doc.data();
        if (data.refArtist === userId || data.refGroup === userId) {
          artistTab0Decrement++;
        }
        if (data.refClient === userId) {
          clientTab0Decrement++;
        }
      });
      
      // Atualizar índices
      const updates: any = {
        lastUpdate: admin.firestore.FieldValue.serverTimestamp(),
      };
      
      if (artistTab0Decrement > 0) {
        const currentTab0Total = indexData.artistTab0Total || 0;
        const currentTab0Unseen = indexData.artistTab0Unseen || 0;
        const currentTab2Total = indexData.artistTab2Total || 0;
        
        updates.artistTab0Total = Math.max(0, currentTab0Total - artistTab0Decrement);
        updates.artistTab0Unseen = Math.max(0, currentTab0Unseen - artistTab0Decrement);
        updates.artistTab2Total = (currentTab2Total || 0) + artistTab0Decrement;
      }
      
      if (clientTab0Decrement > 0) {
        const currentTab0Total = indexData.clientTab0Total || 0;
        const currentTab0Unseen = indexData.clientTab0Unseen || 0;
        const currentTab2Total = indexData.clientTab2Total || 0;
        
        updates.clientTab0Total = Math.max(0, currentTab0Total - clientTab0Decrement);
        updates.clientTab0Unseen = Math.max(0, currentTab0Unseen - clientTab0Decrement);
        updates.clientTab2Total = (currentTab2Total || 0) + clientTab0Decrement;
      }
      
      await indexRef.update(updates);
      console.log(`[CancelExpiredContracts] Índice atualizado para usuário ${userId}`);
    } catch (error) {
      console.error(`[CancelExpiredContracts] Erro ao atualizar índice para ${userId}:`, error);
      // Não falhar a função inteira se um índice falhar
    }
  });
  
  await Promise.all(updatePromises);
}
```

### 2. Índice Composto no Firestore

**IMPORTANTE**: Criar índice composto antes de fazer deploy da função.

1. Acesse o Firebase Console
2. Vá em Firestore Database > Indexes
3. Clique em "Create Index"
4. Configure:
   - **Collection ID**: `Contracts`
   - **Fields to index**:
     - `status` (Ascending)
     - `acceptDeadline` (Ascending)
   - **Query scope**: Collection

### 3. Cloud Scheduler (Configuração Automática)

O Cloud Scheduler será criado automaticamente quando você fizer deploy da função usando `pubsub.schedule()`.

**Configuração manual (se necessário)**:
- **Nome**: `cancel-expired-contracts`
- **Frequência**: `*/15 * * * *` (a cada 15 minutos)
- **Timezone**: `America/Sao_Paulo`
- **Target**: Cloud Function `cancelExpiredContracts`

### 4. package.json (Dependências)

```json
{
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^4.5.0"
  }
}
```

## 🚀 Deploy

```bash
# Na pasta functions/
npm install
firebase deploy --only functions:cancelExpiredContracts
```

## 📊 Monitoramento

### Logs
- Acesse: Firebase Console > Functions > Logs
- Filtre por: `cancelExpiredContracts`

### Métricas
- Execuções por dia
- Contratos cancelados por execução
- Tempo de execução
- Erros (se houver)

## 💰 Estimativa de Custos

**Cenário**: 1000 contratos/mês, 10% expiram sem resposta

- **Execuções**: 2.880/mês (a cada 15min)
- **Leituras Firestore**: ~2.880/mês (queries)
- **Escritas Firestore**: ~100/mês (cancelamentos)
- **Custo estimado**: **~$0.10-0.50/mês**

## ⚠️ Considerações Importantes

1. **Índice Composto**: Criar ANTES do deploy para evitar erros
2. **Processamento em Lotes**: Limite de 100 por execução evita timeouts
3. **Atualização de Índices**: Pode ser otimizada para processar em paralelo
4. **Idempotência**: A função é idempotente (pode executar múltiplas vezes sem problemas)
5. **Notificações**: Considerar enviar notificação push quando contrato for cancelado

## 🔄 Alternativa: Verificação no App (Complementar)

Para feedback imediato, o app já verifica se o prazo expirou e mostra visualmente.
**IMPORTANTE**: O app NÃO cancela contratos, apenas mostra feedback visual.
O cancelamento real é feito pela Cloud Function.

## 📝 Checklist de Implementação

- [ ] Criar índice composto no Firestore
- [ ] Implementar Cloud Function
- [ ] Testar localmente com emulador
- [ ] Fazer deploy da função
- [ ] Verificar Cloud Scheduler criado automaticamente
- [ ] Monitorar logs nas primeiras execuções
- [ ] Verificar atualização de índices
- [ ] Configurar alertas para erros (opcional)
