# AutoCenter

Aplicativo Flutter de orçamentos automotivos. O fluxo aprovado é a entrada principal, no mesmo padrão do Sales: configuração do servidor → login do core → lista → detalhes → edição/veículo/checklist.

## Rodar

Na pasta `D:\git\valdosouza\GestaoApps\apps\budget_autocenter`:

```powershell
flutter pub get
flutter run
```

Não precisa de `--target`. Para escolher o navegador:

```powershell
flutter run -d chrome
```

A API é o projeto `local-gestao-api` e deve estar rodando uma única vez. No navegador deste PC, configure o servidor como `127.0.0.1`. No celular via Wi-Fi, use o IP do computador na rede local. Se servidor/sessão já estiverem salvos, o app pode ir direto ao login ou à lista.

## Estado atual

Login, configuração e seleção de estabelecimento usam o core/API reais. Os orçamentos e o catálogo ainda são demonstrativos, em memória, com aviso na interface. Fechar ou recarregar perde os rascunhos desta sessão. A integração de orçamento, veículo e checklist com o ERP continua pendente.

Web e Android possuem estrutura de execução. Android usa SDK 36, NDK 28.2.13676358 e JDK 21, alinhados à base usada no Sales. O identificador próprio é `com.setes.budget_autocenter`; assinatura de publicação ainda precisa ser configurada.

Veja [DESENVOLVIMENTO.md](DESENVOLVIMENTO.md) para estrutura, testes e limites.
