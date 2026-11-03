# Homologação AutoCenter com o Gestão

Use uma cópia de teste do banco. As verificações automáticas não criaram orçamentos comerciais; as gravações reais deste roteiro serão feitas por você.

## Preparar

1. Atualize a API. Nesta máquina, a tabela técnica TB_APP_BUDGET_OP já foi criada, sem alterar registros comerciais. Em outra instalação: `node scripts/setup-autocenter.js --apply`, executado na pasta da API.
2. Reinicie o processo existente da API (`Ctrl+C` e `npm start`), mantendo uma única instância.
3. Na pasta do AutoCenter: `flutter run -d chrome --web-port=4182`, ou `flutter run -d ID_DO_APARELHO` para Android. Use sempre o mesmo navegador/perfil/porta para reencontrar os pendentes web.
4. Configure o servidor, selecione o estabelecimento e entre com um usuário que tenha vendedor associado e permissões de visualizar/inserir/alterar orçamento; excluir é verificado no servidor quando itens são removidos.

Na base examinada, a pesquisa de cores de veículo retornou zero registros. Cadastre as cores pelo Gestão antes de testar um veículo novo. Peças, serviços, preços, estoques, marcas, modelos, tipos e veículos responderam às consultas reais.

## Roteiro principal

| Teste | Ação | Resultado a conferir |
| --- | --- | --- |
| Consulta | Toque em um orçamento existente e expanda as seções | Cliente, pagamento, itens, peças/mão de obra, valores e dados existentes devem corresponder ao desktop. |
| Edição | Feche a edição desse documento no desktop e toque em Editar no app | O app deve abrir os dados carregados, sem criar inspeção fictícia. |
| Novo | Escolha cliente/pagamento, adicione uma peça com tabela de preço/estoque e um serviço | Cadastros reais; quantidade fracionária e preço devem ser preservados. Os serviços são produtos com PRO_TIPO = S. |
| Itens | Altere quantidade, preço e desconto; inclua e exclua um item | Conferir soma de peças, soma de mão de obra, desconto, frete, adicional e total. |
| Pendente | Saia antes de enviar e reabra o app | Item laranja PENDENTE; cliente, itens e demais campos preenchidos devem ser restaurados. Ainda não deve existir um orçamento novo no ERP. |
| Veículo | Pesquise uma placa ou informe os dados com marca/modelo/tipo/cor reais | Verificar vínculo ao cliente. Uma placa existente deve ser selecionada pela pesquisa antes de alterar seu cadastro. |
| Checklist | Inicie a inspeção, marque um dano numa região e confira as demais, pneus, combustível, válvulas e acessórios | O app só deve aceitar o checklist completo; não transformar regiões pendentes em normais sem sua confirmação. |
| Envio | Toque em Salvar rascunho e confirme | O documento completo é gravado numa transação. O pendente sai da lista após confirmação do ID remoto. |
| Desktop | Localize o orçamento no Gestão | Conferir itens P/S, quantidades, descontos e totais, observações com acentos, placa, detalhes e as mesmas posições do checklist. |
| Retorno | Altere no desktop, feche a edição e atualize no app | A consulta deve refletir os dados atuais. |

## Conflitos e interrupções

- Com o orçamento em uso no desktop, o app deve permitir consulta e impedir gravação.
- Se o desktop alterar os dados depois de o app carregá-los, a gravação deve ser recusada com conflito. O pendente é preservado. A integração não faz mesclagem automática: confira a versão atual e reaplique as alterações necessárias.
- Em falha sem confirmação, o pendente fica como CONFERIR ENVIO. Use Conferir envio no servidor. Repetir o mesmo envio utiliza a mesma chave persistida; a API não deve criar outro orçamento para essa chave.
- Descartar um pendente remove apenas o preenchimento local. Não exclui orçamento já confirmado no ERP.
- Ao editar somente itens, veículo e checklist não alterados devem permanecer intactos, inclusive campos antigos incompletos. Alterar esses dados exige completar os campos correspondentes.

## Limites para validar antes da entrega ao cliente

- A numeração comercial de documentos existentes é preservada. Orçamento novo fica sem CTC_NUMERO nesta etapa, para numeração pelo fluxo legado do Gestão. A atribuição imediata pelo app ainda precisa de contrato que conviva com o MAX usado pelo desktop, sem duplicidade.
- Comissões/regras comerciais específicas, campanhas, permissões especiais de alteração de preço, serviços associados automaticamente a produtos e técnicos não foram declarados equivalentes ao Delphi. Precisam de levantamento/validação antes de uso em produção. Os IDs de itens existentes são mantidos nas alterações; vínculos podem impedir exclusão.
- Aprovação, conversão em pedido, faturamento, impressão/envio ao cliente e cadastro de produtos/serviços/auxiliares não fazem parte deste fluxo implementado.
- A retenção local usa JSON/SharedPreferences, agora com o documento completo. Não há sincronização offline automática ou backup do ERP. Limpar dados do site ou desinstalar o app remove pendentes locais.
- O APK gerado é debug para testes. Assinatura de distribuição e homologação física em celular/tablet continuam necessárias.

Registre para cada falha: operação realizada, número/ID do orçamento, estabelecimento, mensagem apresentada e o comportamento esperado no Gestão. Evite reenviar um orçamento incerto com uma chave nova antes de conferir o servidor.
