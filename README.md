# REDGLOW

Aplicativo Flutter para contratação segura de profissionais de beleza em
domicílio. Esta base implementa a interface aprovada na versão 7 do Figma.

## Fluxos implementados

- Home do cliente com pontos, serviços, parceiros e profissionais.
- Confirmação do pedido com mapa urbano em modo escuro.
- Trajeto da prestadora e mensagens rápidas sem chat livre.
- Avaliação mútua e relato pós-atendimento.
- Painel da prestadora, agenda, ganhos e central de emergência.
- Verificação bilateral de identidade.
- Assinatura profissional com zero comissão por atendimento.

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
