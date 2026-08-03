# REDGLOW

Aplicativo Flutter para contratação segura de profissionais de beleza em
domicílio. Esta base implementa a interface aprovada na versão 7 do Figma.

### Atualização 7.0.7

- marca escolhida pelo coautor aplicada sem redesenhar o símbolo, preservando
  o elo rosa e roxo com o brilho central;
- composição ajustada somente para margem segura e formato quadrado dos ícones;
- identidade substituída no login, nas áreas internas e nos ícones instalados
  do Android, iOS e web.

### Atualização 7.0.6

- recebimento do pedido corrigido com presença online renovável e código
  público da prestadora (`RG-XXXXXX`) nas duas pontas do atendimento;
- cada sessão profissional começa pausada e somente fica disponível após a
  própria prestadora ativar o modo online;
- erros de sincronização do Firestore agora aparecem na interface em vez de
  deixar a fila silenciosamente vazia;
- localização real, endereço obtido por consentimento, mapa OpenStreetMap,
  cálculo de rota/ETA e atualização controlada durante o deslocamento;
- localização exata da prestadora preservada no perfil privado e compartilhada
  com a cliente somente depois do aceite;
- nova assinatura visual R+G em forma de rota, aplicada no login, no aplicativo
  e no ícone instalado do Android, iOS e web.

### Atualização 7.0.5

- foto persistida e localização durante o uso;
- múltiplos nichos e serviços por profissional;
- certificados profissionais sujeitos a análise manual;
- fila de atendimentos e avaliações pendentes;
- ciclo bilateral sincronizado e avaliação independente;
- painel da prestadora em abas, com dados reais do histórico.
- preço individual por procedimento, com piso domiciliar e combinação de
  mais de um serviço no mesmo pedido;
- seleção de serviços antes de solicitar tanto na home quanto na busca;
- REDGLOW Pontos com crédito por conclusão, recompensa piloto e código de
  reserva;
- nova marca vetorial com pin, pétala e brilho, aplicada nas duas áreas.

Pagamentos, saques, assinaturas e taxas continuam apenas simulados no beta.

## Fluxos implementados

- Cadastro, login, recuperação de senha, sessão persistente e logout com Firebase.
- Home do cliente com pontos, serviços, parceiros e profissionais.
- Escolha de um ou mais serviços preservada da home ou busca até a criação
  do pedido, com soma dos preços cadastrados pela prestadora.
- Perfil da prestadora com serviços realmente selecionados e validados.
- Confirmação do pedido com mapa urbano em modo escuro.
- Trajeto da prestadora e mensagens rápidas sem chat livre.
- Avaliação mútua e relato pós-atendimento.
- Avaliações duplo-cegas, relatos visíveis e histórico de atendimentos.
- Painel da prestadora, agenda e análise interativa de ganhos.
- Central de emergência padronizada para cliente e prestadora.
- Perfis editáveis e central interna de notificações.
- Cancelamento com motivo e taxa zero explicitamente simulada.
- Relatos operacionais e painel administrativo com acesso restrito.
- Verificação bilateral de identidade.
- Assinatura profissional com zero comissão por atendimento.
- Ciclo de atendimento real sincronizado entre cliente e prestadora pelo Firestore.
- Modo demonstrativo independente, sem gravação no Firebase.
- Busca, agenda, perfil, pontos e ações secundárias com retorno funcional.
- Solicitação autenticada de exclusão de conta para cliente e prestadora.
- Avisos explícitos nas integrações ainda simuladas, sem cobrança ou autoaprovação de identidade.

## Roteiro da demonstração local

1. Entre como **Cliente**, escolha Lari e selecione um ou mais serviços.
2. Confira preço total, duração e pontos antes de confirmar.
3. Use a demonstração para validar telas e botões localmente.
4. Para testar a conversa bilateral entre dois aparelhos ou navegadores, siga o
   roteiro com contas reais abaixo.

As áreas são separadas por papel: pontos, busca e agendamentos pertencem à
cliente; ganhos, assinatura, agenda profissional e emergência pertencem à
prestadora. Apenas o estado do atendimento é compartilhado entre as duas.

## Roteiro com contas reais

1. Abra a conta **Prestadora** no APK ou em um navegador e mantenha essa sessão
   aberta. Ative **Online** e anote o código público `RG-XXXXXX` exibido.
2. Abra a conta **Cliente** em outro celular, outro navegador ou em uma janela
   anônima. Duas abas normais do mesmo navegador compartilham a mesma sessão do
   Firebase e não servem para este teste bilateral.
3. Na cliente, confira se a profissional disponível possui o mesmo código,
   selecione um ou mais serviços e confirme o pedido.
4. Volte à sessão ainda aberta da prestadora: o pedido deve entrar em
   **Atendimentos** sem sair e entrar novamente.
5. Aceite o pedido, inicie o trajeto, confirme a chegada e conclua o serviço.
6. Avalie a cliente na sessão da prestadora.
7. Volte à sessão da cliente, abra **Meus atendimentos** e avalie a prestadora.
8. Confira os pontos creditados pela conclusão. Uma manicure tradicional rende
   10 pontos; abra **Ver recompensas** e reserve o par de brincos piloto por 10
   pontos.

Perfil, disponibilidade, pedido, etapas, mensagens rápidas e avaliações ficam
salvos no Firestore e são restaurados ao entrar novamente. A mesma conta não
pode ser cliente e prestadora; cada papel precisa de um e-mail próprio.

## Executar

```bash
flutter pub get
flutter run -d chrome
```

## Verificar

```bash
flutter analyze
flutter test
```

## Preparar o Firebase

O repositório está associado ao projeto Firebase `redglow-54a5f` e usa o
identificador definitivo `br.com.redglow.app`. A base inclui Firebase Core,
Authentication, Firestore, Storage e regras de acesso por papel.

Os arquivos de configuração das plataformas já estão versionados. Em uma nova
máquina, basta autenticar a CLI antes de publicar regras:

```bash
npm install -g firebase-tools
firebase login
```

No Windows/PowerShell, use `npm.cmd` e `firebase.cmd` caso a execução de scripts
`.ps1` esteja bloqueada. O método **E-mail/senha** deve permanecer habilitado em
Firebase Console > Authentication > Método de login.

As regras podem ser publicadas somente depois de revisar o projeto selecionado:

```bash
firebase use redglow-54a5f
firebase.cmd deploy --only firestore:rules,firestore:indexes
```

Fotos e certificados usam Cloud Storage. Desde fevereiro de 2026, o Firebase
exige o plano Blaze para habilitar ou manter esse serviço. Depois de ativá-lo
com alerta de orçamento, publique as regras separadamente:

```bash
firebase.cmd deploy --only storage
```

## APK de beta interno

Cada atualização da branch gera, após análise e testes, um APK Android
instalável chamado `redglow-v7.0.7-android` nos artefatos do GitHub Actions.
Ele usa assinatura de desenvolvimento e serve somente para testes em aparelhos
autorizados. A assinatura definitiva para Play Store será criada separadamente
antes da distribuição pública.

Para gerar o mesmo APK no computador:

```bash
flutter build apk --debug
```

## Limites atuais do MVP

- No beta, os pontos são derivados dos atendimentos concluídos e as trocas ficam
  registradas no Firestore. A recompensa piloto gera somente uma reserva de
  teste; não existe entrega real.
- Antes do lançamento comercial, preço final, pontos, saldo, estoque e troca
  devem ser validados por uma função segura no servidor. As regras atuais
  reduzem abuso acidental, mas não substituem esse backend transacional.
- Pix, cartão e assinatura ainda são simulações de produto, não integrações
  financeiras finais.
- A prévia do ID Check não consulta CPF nem realiza biometria. O ID profissional
  aceita certificados, mas nenhuma conta é aprovada automaticamente.
- Os preços do plano são hipóteses comerciais. Contas reais não ativam assinatura
  nem recebem cobrança enquanto a integração financeira estiver desabilitada.
- O pedido de exclusão cria um registro protegido no Firestore. A remoção final
  será executada por processo administrativo/backend após definir retenções legais.
- Cliente e prestadora não possuem ligação direta ou chat livre; durante o
  atendimento são permitidas somente mensagens rápidas predefinidas.
- O beta usa OpenStreetMap para os blocos visuais, Nominatim para obter o
  endereço e OSRM para a rota. Esses serviços públicos não oferecem SLA e
  deverão ser substituídos por um provedor contratado antes da operação
  comercial.
- Agenda e ganhos usam o histórico real da conta; os valores de demonstração
  continuam claramente identificados no acesso de teste.
- O painel financeiro é demonstrativo e não representa saldo para saque.
- Cancelamentos registram motivo, mas a taxa permanece em R$ 0,00 e nenhuma
  cobrança é realizada durante o beta.
- A central de notificações é interna. Alertas push no aparelho ainda serão
  conectados a um serviço de mensageria.
- O painel administrativo só aparece para conta marcada pelo backend com
  `isAdmin: true`; o aplicativo não permite que um usuário conceda essa
  permissão a si próprio.

O Firebase é inicializado por `lib/main.dart`. O acesso **Acessar demonstração**
continua sem enviar dados e preserva o roteiro completo da versão 7.

Depois de atualizar esta versão, publique as regras para habilitar o pedido de
exclusão em contas reais:

```bash
firebase.cmd deploy --only firestore:rules,firestore:indexes
```
