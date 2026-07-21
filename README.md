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

O mapa da demonstração é vetorial e não depende de uma API externa. Antes da
publicação, ele deve ser substituído pelo provedor de mapas e localização
definido para produção.

O login atual é demonstrativo e não envia nem persiste dados. A autenticação e
o banco de dados reais serão conectados na próxima etapa do MVP.
