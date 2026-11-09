# Checklist para testar o budget_sales

## Já preparado

- [x] Arquivos de assinatura e Firebase restaurados do ZIP nos apps de vendas e estoque.
- [x] Senhas e aliases dos arquivos de assinatura validados.
- [x] Arquivos privados conferidos como ignorados pelo Git.
- [x] Caminhos locais do Flutter e Android configurados para este notebook.
- [x] Arquivos auxiliares do Gradle preparados.
- [x] Arquivos gerados do core encontrados no projeto.
- [x] Dependências do budget_sales resolvidas; a preparação dos links dos plugins ainda depende do Modo Desenvolvedor.
- [x] Análise estática do budget_sales concluída sem problemas.
- [x] Java 21 instalado e configurado no Flutter para o Gradle 8.14 do projeto.
- [x] APK Android de debug compilado em `apps/budget_sales/build/app/outputs/flutter-apk/app-debug.apk`.

## Fazer em casa

- [ ] Se `flutter pub get` reclamar de links simbólicos, ativar o **Modo Desenvolvedor do Windows**. Procure por “Modo de desenvolvedor” nas Configurações.
- [x] No **SDK Manager** do Android Studio, instalar a **Android SDK Platform 36** (presença confirmada no SDK usado pelo Flutter).
- [x] Em **SDK Tools**, instalar **Android SDK Command-line Tools (latest)**.
- [x] Em **SDK Tools**, ativar **Show Package Details** e instalar **NDK (Side by side) 28.2.13676358**.
- [x] Licenças Android aceitas e toolchain Android reconhecida pelo `flutter doctor -v`. Para conferir novamente:

```powershell
flutter doctor --android-licenses
flutter doctor -v
```

- [x] Celular `2602BPC18G` conectado por USB e reconhecido pelo Flutter.
- [x] Instalação por USB autorizada; budget_sales instalado e aberto no celular.
- [x] API iniciada e consulta de estabelecimentos ao Firebird confirmada. Para conferir novamente:

```powershell
Invoke-RestMethod 'http://localhost:3000/api/v1/health'
Invoke-RestMethod 'http://localhost:3000/api/v1/institutions'
```

- [x] Budget_sales compilado e executado no celular. Para executar novamente:

```powershell
Set-Location 'D:\git\valdosouza\GestaoApps\apps\budget_sales'
flutter pub get
flutter devices
flutter run
```

- [x] Encaminhamento USB da porta 3000 preparado para o celular conectado. Na configuração do app, usar `127.0.0.1` enquanto esse encaminhamento estiver ativo; ele precisa ser refeito após reconectar o aparelho.
- [ ] Alternativamente, usar `10.0.2.2` no emulador Android padrão com a API no notebook, ou o IP do notebook na rede para um celular físico.
- [ ] Selecionar o estabelecimento e fazer login com usuário ativo do ERP que possua vendedor associado.

A Platform 36 é usada na compilação; o emulador pode usar outra versão compatível do Android. A leitura da API no Firebird foi validada; login e gravações pelo aplicativo ainda precisam ser testados.
