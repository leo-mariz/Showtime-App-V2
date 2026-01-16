# Análise de Custos - Streams de Chat

## 📊 Situação Atual

### 1. **Stream de Mensagens Individuais (ChatDetailScreen)**
- **Custo**: ✅ **BAIXO**
- **Comportamento**: 
  - 1 stream por conversa aberta
  - Apenas quando o usuário está na tela de chat
  - Stream é cancelado quando sai da tela
- **Reads do Firestore**: 
  - 1 read por mudança (nova mensagem, atualização de status)
  - Apenas para o contrato específico

### 2. **Stream de Total de Não Lidas (Navbar)**
- **Custo**: ⚠️ **MÉDIO A ALTO** (depende do número de contratos)
- **Comportamento**:
  - **N streams simultâneos** (um para cada contrato do usuário)
  - Streams permanecem ativos enquanto o app está aberto
  - Cada stream monitora TODAS as mensagens do contrato
- **Reads do Firestore**:
  - Se usuário tem 10 contratos = 10 streams
  - Cada mudança em qualquer mensagem = 1 read
  - **Problema**: Baixa TODAS as mensagens de cada contrato, mesmo que só precise contar não lidas

## 💰 Estimativa de Custos (Firestore)

### Cenário 1: Usuário com 5 contratos
- **Streams ativos**: 5 (navbar) + 1 (se chat aberto) = 6 streams
- **Reads por mudança**: ~5-6 reads
- **Custo mensal estimado** (1000 mudanças/dia):
  - 5-6 reads × 1000 × 30 = 150k-180k reads/mês
  - **Custo**: ~$0.06/mês (dentro do tier gratuito)

### Cenário 2: Usuário com 20 contratos
- **Streams ativos**: 20 (navbar) + 1 (se chat aberto) = 21 streams
- **Reads por mudança**: ~20-21 reads
- **Custo mensal estimado** (1000 mudanças/dia):
  - 20-21 reads × 1000 × 30 = 600k-630k reads/mês
  - **Custo**: ~$0.18/mês

### Cenário 3: Usuário com 50 contratos (artista popular)
- **Streams ativos**: 50 (navbar) + 1 (se chat aberto) = 51 streams
- **Reads por mudança**: ~50-51 reads
- **Custo mensal estimado** (1000 mudanças/dia):
  - 50-51 reads × 1000 × 30 = 1.5M-1.53M reads/mês
  - **Custo**: ~$0.36/mês

## ⚠️ Problemas Identificados

### 1. **Múltiplos Streams Simultâneos**
- Cada contrato = 1 stream = 1 conexão WebSocket
- Usuários com muitos contratos podem ter dezenas de conexões abertas
- Impacto na bateria e dados móveis

### 2. **Baixa Todas as Mensagens**
- O stream atual baixa TODAS as mensagens de cada contrato
- Mesmo que só precise contar não lidas
- Se um contrato tem 1000 mensagens, baixa todas a cada mudança

### 3. **Sem Limite de Contratos**
- Não há limite de quantos contratos são monitorados
- Artistas populares podem ter 100+ contratos ativos

## ✅ Otimizações Recomendadas

### **Opção 1: Polling Inteligente (RECOMENDADO)**
- Substituir stream contínuo por polling periódico
- Atualizar a cada 30-60 segundos quando app está em foreground
- Reduz drasticamente reads e conexões

### **Opção 2: Limitar Streams por Prioridade**
- Monitorar apenas contratos com atividade recente (últimos 30 dias)
- Contratos inativos: polling a cada 5 minutos
- Reduz de N streams para ~5-10 streams

### **Opção 3: Query Otimizada (IDEAL)**
- Criar campo `unreadCount` no documento do contrato
- Atualizar via Cloud Function quando mensagem chega
- Stream monitora apenas 1 campo ao invés de todas as mensagens
- **Redução**: De N×M reads para N reads (onde M = mensagens por contrato)

### **Opção 4: Cache + Invalidação**
- Cachear total de não lidas
- Invalidar apenas quando:
  - Nova mensagem chega (via FCM)
  - Usuário marca como lida
  - App volta para foreground

## 🎯 Recomendação Final

**Implementar Opção 3 (Query Otimizada) + Opção 4 (Cache)**:
1. Adicionar campo `unreadCount` no documento Contract
2. Atualizar via Cloud Function quando mensagem é criada/lida
3. Stream monitora apenas o campo `unreadCount` de cada contrato
4. Cache local para reduzir reads quando app está em background

**Redução estimada**: De 50+ reads por mudança para 1-2 reads por mudança.
