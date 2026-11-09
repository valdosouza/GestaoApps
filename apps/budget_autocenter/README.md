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
flutter run -d chrome --web-port=4182
```

A API é o projeto `local-gestao-api` e deve estar rodando uma única vez. No navegador deste PC, configure o servidor como `127.0.0.1`. No celular via Wi-Fi, use o IP do computador na rede local. Se servidor/sessão já estiverem salvos, o app pode ir direto ao login ou à lista.

No navegador, mantenha a mesma porta (4182 no comando acima), o mesmo perfil e o armazenamento do site para reencontrar a sessão e os rascunhos. Cada porta é um armazenamento separado. No Android, os rascunhos pertencem à instalação do app.

## Estado atual

Configuração/login usam o core/API reais. A lista tem filtros e paginação; tocar no orçamento abre os detalhes reais. É possível criar e editar cabeçalho, peças e mão de obra, selecionar tabela de preço/estoque, informar veículo e conferir o checklist moderno de 22 regiões.

O preenchimento completo é salvo automaticamente no aparelho como **PENDENTE**, em laranja. Ao sair/voltar, toque para continuar. Os dados ficam separados por servidor, estabelecimento e usuário. Salvar rascunho e confirmar envia o documento completo em uma transação. Se houver resposta incerta, confira o envio no servidor ou repita o mesmo envio com a mesma chave; confirmações repetidas não criam outro orçamento.

Reinicie a API existente para carregar as novas rotas. Nesta máquina, a tabela técnica de envios já está preparada. Em outra instalação da API, execute uma vez: `node scripts/setup-autocenter.js --apply`. Nenhum orçamento comercial foi criado pelos testes automáticos.

Consulte [HOMOLOGACAO.md](HOMOLOGACAO.md) para testar no Gestão. As cores vêm de TB_COLOR, como no Delphi. Marca, modelo, tipo e cor permitem cadastro pelo app, conforme permissão do usuário, com seleção automática após salvar. Numeração comercial nova permanece para o fluxo legado; aprovação, pedido/faturamento, comissões e regras comerciais especiais ainda precisam do escopo/validação descritos no roteiro. Pendentes de envio incerto da versão antiga de cabeçalho precisam de conferência manual no ERP; não são reenviados pelo novo protocolo automaticamente.

Web e Android possuem estrutura de execução. Android usa SDK 36, NDK 28.2.13676358 e JDK 21, alinhados à base usada no Sales. O identificador próprio é `com.setes.budget_autocenter`; assinatura de publicação ainda precisa ser configurada.

Veja [DESENVOLVIMENTO.md](DESENVOLVIMENTO.md) para estrutura, testes e limites.
