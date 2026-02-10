# Webhook: Atualizar índice de contratos ao confirmar pagamento

## Problema

Quando o pagamento é confirmado pelo **webhook** (Mercado Pago), o contrato é atualizado para `status: PAID` no Firestore, mas o **índice de contratos** (`user_contracts_index/{userId}`) **não é atualizado**. Com isso:

- O contrato aparece na tab correta (**Confirmadas**) ao recarregar a lista.
- O **badge de notificação** (número de “não vistos”) aparece na tab **errada** (**Em aberto**) para artista e cliente.

O app só atualiza esse índice quando a ação é feita dentro do app (aceitar, rejeitar, cancelar etc.). No fluxo de pagamento, quem muda o status é o webhook, então o webhook também precisa atualizar o índice.

## Solução

Quando o webhook confirmar o pagamento e alterar o contrato para **PAID**, ele deve atualizar o documento de índice de **cada usuário** envolvido no contrato (cliente e artista), movendo o contrato da tab **Em aberto (0)** para **Confirmadas (1)**.

---

## Firestore

- **Coleção:** `user_contracts_index`
- **Documento:** `{userId}` (um doc por usuário; usar `refClient`, `refArtist` ou `refArtistOwner` do contrato).

## Mapeamento status → tab (igual ao app)

| Tab | Nome no app  | Artista (status na tab) | Cliente (status na tab) |
|-----|--------------|------------------------|--------------------------|
| 0   | Em aberto    | PENDING, PAYMENT_PENDING, etc. | PENDING, PAYMENT_PENDING, PAYMENT_EXPIRED, PAYMENT_REFUSED, PAYMENT_FAILED |
| 1   | Confirmadas  | PAID                   | PAID                     |
| 2   | Finalizadas  | COMPLETED, REJECTED, CANCELED, RATED | COMPLETED, REJECTED, CANCELED, RATED |

Ao passar de **PAYMENT_PENDING → PAID**:

- **oldTab = 0** (Em aberto)
- **newTab = 1** (Confirmadas)

## Lógica para cada usuário

Para **cada um** dos usuários do contrato (cliente e artista):

1. **Quem atualizar**
   - **Cliente:** `refClient`
   - **Artista:** `refArtist` (contrato individual) ou `refArtistOwner` (contrato de grupo).

2. **Prefixo do role no documento**
   - Cliente: `client` → campos `clientTab0Total`, `clientTab0Unseen`, `clientTab1Total`, `clientTab1Unseen`, etc.
   - Artista: `artist` → campos `artistTab0Total`, `artistTab0Unseen`, `artistTab1Total`, `artistTab1Unseen`, etc.

3. **Operações (merge no doc `user_contracts_index/{userId}`)**

   - **Tab 0 (Em aberto)** – remover um contrato:
     - `{rolePrefix}Tab0Total` = máximo(0, valor_atual - 1)
     - `{rolePrefix}Tab0Unseen` = máximo(0, valor_atual - 1)

   - **Tab 1 (Confirmadas)** – adicionar um contrato:
     - `{rolePrefix}Tab1Total` = valor_atual + 1
     - `{rolePrefix}Tab1Unseen`:  
       - Ler `lastSeen{Role}Tab1` (ex.: `lastSeenClientTab1`, `lastSeenArtistTab1`).  
       - Se o contrato tem `statusChangedAt` (ou `updatedAt`) **posterior** a esse timestamp (ou se não existir lastSeen), incrementar:  
         `{rolePrefix}Tab1Unseen` = valor_atual + 1.  
       - Caso contrário: só incrementar Total, deixar Unseen como está.

   - **Sempre:**  
     - `lastUpdate` = `Timestamp.now()` (ou equivalente).

## Nomes dos campos no documento

- **Artista:**  
  `artistTab0Total`, `artistTab0Unseen`, `artistTab1Total`, `artistTab1Unseen`, `artistTab2Total`, `artistTab2Unseen`,  
  `lastSeenArtistTab0`, `lastSeenArtistTab1`, `lastSeenArtistTab2`

- **Cliente:**  
  `clientTab0Total`, `clientTab0Unseen`, `clientTab1Total`, `clientTab1Unseen`, `clientTab2Total`, `clientTab2Unseen`,  
  `lastSeenClientTab0`, `lastSeenClientTab1`, `lastSeenClientTab2`

- **Comum:**  
  `lastUpdate`

Use **merge** ao escrever (ex.: `set(updates, { merge: true })`) para não apagar outros campos.

## Resumo para o webhook de pagamento

1. Ao confirmar pagamento, além de atualizar o contrato para **PAID**:
2. Para **refClient**: atualizar `user_contracts_index/{refClient}` (decrementar tab 0, incrementar tab 1 e, se for o caso, tab1Unseen).
3. Para **refArtist** ou **refArtistOwner** (se for contrato de grupo): mesmo passo para `user_contracts_index/{refArtist}` ou `user_contracts_index/{refArtistOwner}`.
4. Garantir que Total e Unseen nunca fiquem negativos (usar máximo com 0).

Com isso, o badge de “não vistos” passa a aparecer na tab **Confirmadas** para artista e anfitrião, em linha com o comportamento do app.
