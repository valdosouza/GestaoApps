# Contexto
	Tela principal do aplicativo para informar a contagem de estoque de produtos
	
# Objetivo
	Fornecer ao usuario uma opcao rapida para identificar o produto informar a quantidade disponivel no estoque.

# Feature
	Stock_count

# Stack e Versões

	| Tecnologia 			| Versão mínima |
	| Flutter 				| 3.41+ |
	| Dart 					| 3.11+ |
	| Kotlin (Android) 		| 2.1.0 |
	| Android Gradle Plugin | 8.8 |
	| Gradle 				| 8.10.2 |
	| compileSdk 			| 36 |
	| NDK 					| 28.2.13676358 |

# Arquitetura

	**Clean Architecture** com três camadas por módulo: `data`, `domain`, `presentation`.
	
# Gerenciamento de Estado

	**BLoC** com `bloc` + `flutter_bloc`. Padrão obrigatório:
	
# Fluxo
	1 - Ao abrir a tela temos que ter disponibilizar uma lista dos nomes dos estoques disponiveis por estabelecimento.
		1.2  - Tela Principal 
			1.2.1 - Lista de Estoques disponiveis para o estabelecimento;
			
	2 - Usuario digita codigo interno ou utiliza o leitor de codigo de barras (ver Referencia 1.1) para buscar o produto
		2.1 - Tela Princial
			2.1.1 - Botao buscar para o codigo do produto
					API /products/{id}
			2.1.2 - Leitura do codigo de barras automatico apos a leitura
					API /products/codebar/{codeBar}
			2.1.3 - Botao tela de Pesquisa por descricao
				2.1.3.1 - Tela de pesquisa (ver Referencia 1.1)
					2.1.3.1.1 - Campo descricao para digitacao
					2.1.3.1.2 - Campo Codigo de Fabrica para digitacao
					2.1.3.1.3 - Campo botao para efetuar a pesquisa
					2.1.3.1.4 - Lista mostrando codigo interno codigo de barras e descricao do produto					
				2.1.3.2 - Clicando sobre o item pesquisado, direcionar para a tela principal da contagem de estoque.
					API /products
							
	3 - Escolhido o produto deve aparece os dados do produto com a quantidade de estoque atual.
		3.1 - Tela Princial - 
			3.1.1 - Dados do produto mostrando Codigo Interno / Codigo de Fabrica / Codigo barras / Descricao.
			3.1.1 - Tabelas de precos disponiveis mostrando apenas precos maiores que zero.		
							API /prices/product/{productId}
	
	4 - O Usuario tera um campo livre de digitacao para que ele informe a quantidade atual.
		4.1 - Tela Principal
			4.1.1 - Campo para digitacao da quantiade atual
			4.1.2 - Botao Atualizar Saldo
			4.1.3 - Regras para atualizacao
				Quantidade informada = QIN
				Quantidade Atual = QAT
				Quantidade Ajustar = QAJ
				Regra 1 
					If QI = QA mostrar mensagem quantidades informadas iguais nada a fazer.
					If QI > QA - Lancar a diferenca como entrada no caso QAJ = (QIN - QAT);
					If QI < QA - Lancar a diferenca como Saida no caso   QAJ = (QAT - QIN);
						Para os casos em que houver a execucao 
							Terminar a operacao com a mensagem de atualizacao com sucesso e limpeza da tela.				

#Referencia
	1.1 - Nesta tela temmos a busca do produto por codigo descricao e codigo de barras	
			D:\GestaoERPApps\apps\budget_sales\lib\src\features\budget\presentation\widget\product_search_dialog.dart
		
	1.2 - Fucionalidade ja existe no sistema de Gestao desenvolvida em Delphi
			D:\Gestao2016\Tarefas\un_estoque_manual.pas
		
	1.3 - Este arquivos sao do mesmo projeto utilize os para manter o Codigo
			1.3.1 - Padronizado
			1.3.2 - Reutilizavel
			1.3.3 - Path files
					D:\GestaoERPApps\core
					D:\GestaoERPApps\apps\budget_sales
	
