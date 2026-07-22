# REDGLOW

Aplicativo Flutter para contratação segura de profissionais de beleza em
domicílio. Esta base implementa a interface aprovada na versão 7 do Figma.

## Fluxos implementados

- Cadastro, login, recuperação de senha, sessão persistente e logout com Firebase.
- Home do cliente com pontos, serviços, parceiros e profissionais.
- Confirmação do pedido com mapa urbano em modo escuro.
- Trajeto da prestadora e mensagens rápidas sem chat livre.
- Avaliação mútua e relato pós-atendimento.
- Painel da prestadora, agenda, ganhos e central de emergência.
- Verificação bilateral de identidade.
- Assinatura profissional com zero comissão por atendimento.
- Ciclo de atendimento real sincronizado entre cliente e prestadora pelo Firestore.
- Modo demonstrativo independente, sem gravação no Firebase.
- Busca, agenda, perfil, pontos e ações secundárias com retorno funcional.
- Solicitação autenticada de exclusão de conta para cliente e prestadora.
- Avisos explícitos nas integrações ainda simuladas, sem cobrança ou autoaprovação de identidade.

## Roteiro da demonstração completa

1. Entre como **Cliente**, escolha Lari e confirme o pedido.
2. Volte à entrada e acesse como **Prestadora**.
3. Aceite o pedido, inicie o trajeto, confirme a chegada e conclua o serviço.
4. Avalie a cliente e volte à entrada.
5. Entre novamente como **Cliente**, abra **Meus atendimentos** e avalie Lari.
6. Confira os 60 pontos creditados na home do cliente.

As áreas são separadas por papel: pontos, busca e agendamentos pertencem à
cliente; ganhos, assinatura, agenda profissional e emergência pertencem à
prestadora. Apenas o estado do atendimento é compartilhado entre as duas.

## Roteiro com contas reais

1. Crie uma conta do tipo **Prestadora** usando um e-mail diferente da cliente.
2. Deixe a prestadora online e saia da conta.
3. Entre na conta **Cliente**, escolha a primeira profissional e confirme o pedido.
4. Saia da cliente e entre novamente como **Prestadora**.
5. Aceite o pedido, inicie o trajeto, confirme a chegada e conclua o serviço.
6. Avalie a cliente, saia e volte à conta **Cliente**.
7. Abra **Meus atendimentos**, acompanhe o status e avalie a prestadora.

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
Authentication, Firestore e regras iniciais de acesso por papel.

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
firebase deploy --only firestore:rules,firestore:indexes
```

## Limites atuais do MVP

- Pontos de contas reais são somente leitura. O crédito automático continuará
  bloqueado até existir uma função confiável no servidor.
- Na demonstração, o atendimento de R$ 60 concluído e avaliado credita 60
  pontos; o resgate de R$ 25 exige 3.000 pontos. Contas reais não fazem resgate
  local para evitar alteração de saldo pelo aplicativo.
- Pix, cartão, assinatura, verificação de identidade e GPS ainda são simulações
  de produto, não integrações finais.
- A prévia do ID Check não consulta CPF, não seleciona arquivos, não realiza
  biometria e não aprova contas reais. Use somente dados fictícios nos testes.
- Os preços do plano são hipóteses comerciais. Contas reais não ativam assinatura
  nem recebem cobrança enquanto a integração financeira estiver desabilitada.
- O pedido de exclusão cria um registro protegido no Firestore. A remoção final
  será executada por processo administrativo/backend após definir retenções legais.
- Cliente e prestadora não possuem ligação direta ou chat livre; durante o
  atendimento são permitidas somente mensagens rápidas predefinidas.
- O mapa é vetorial e não depende de API externa; deverá ser substituído por um
  provedor real de mapas e localização antes da publicação comercial.
- Agenda e ganhos exibem dados de demonstração; o pedido ativo já é real.

O Firebase é inicializado por `lib/main.dart`. O acesso **Acessar demonstração**
continua sem enviar dados e preserva o roteiro completo da versão 7.

Depois de atualizar esta versão, publique as regras para habilitar o pedido de
exclusão em contas reais:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```
