# REDGLOW

Aplicativo Flutter para contratação segura de profissionais de beleza em
domicílio. Esta base implementa a interface aprovada na versão 7 do Figma.

## Fluxos implementados

- Login e cadastro demonstrativos com escolha entre Cliente e Prestadora.
- Home do cliente com pontos, serviços, parceiros e profissionais.
- Confirmação do pedido com mapa urbano em modo escuro.
- Trajeto da prestadora e mensagens rápidas sem chat livre.
- Avaliação mútua e relato pós-atendimento.
- Painel da prestadora, agenda, ganhos e central de emergência.
- Verificação bilateral de identidade.
- Assinatura profissional com zero comissão por atendimento.
- Estado demonstrativo compartilhado entre cliente e prestadora.
- Busca, agenda, perfil, pontos e ações secundárias com retorno funcional.

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

## Executar

```bash
flutter pub get
flutter run
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

Na primeira configuração de uma máquina, execute na raiz do projeto:

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=redglow-54a5f
```

No `flutterfire configure`, selecione Android, iOS e Web. O comando gera
`lib/firebase_options.dart` e associa as plataformas ao projeto existente.
Depois, habilite **E-mail/senha** em Firebase Console > Authentication >
Método de login.

As regras podem ser publicadas somente depois de revisar o projeto selecionado:

```bash
firebase use redglow-54a5f
firebase deploy --only firestore:rules,firestore:indexes
```

O mapa da demonstração é vetorial e não depende de uma API externa. Antes da
publicação, ele deve ser substituído pelo provedor de mapas e localização
definido para produção.

Enquanto `firebase_options.dart` ainda não tiver sido gerado, o login permanece
demonstrativo e não envia nem persiste dados. Isso preserva o roteiro completo
da versão 7 durante a migração para o backend real.
