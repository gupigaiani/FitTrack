# FitTrack

## 1. Sobre o FitTrack

Aplicativo acadêmico referente a NP2 da matéria de Desenvolvimento Mobile do curso de ADS. Permite registrar exercícios de musculação, consultar o histórico em nuvem e acompanhar a evolução das cargas. Não possui login: os registros são compartilhados entre as instâncias conectadas ao mesmo projeto Firebase.

## 2. Tecnologias

- Flutter e Dart, com widgets Material.
- `StatefulWidget` e `setState` para estado local.
- `Navigator.push` e `MaterialPageRoute` para navegação.
- `firebase_core` e `cloud_firestore` para persistência.
- `fl_chart` para o gráfico, único recurso adicional pesquisado.
- `flutter_test` e `flutter_lints` para testes e análise.

## 3. Funcionalidades e telas

- **Início:** apresentação, imagens e ícones, acesso ao cadastro e ao histórico, seleção do exercício e gráfico de evolução.
- **Registrar treino:** quatro TextFields para exercício, séries, repetições e carga; grupo muscular com Radio e enum; Checkbox de conclusão; validação e gravação com `add()`.
- **Histórico de treinos:** exercícios cadastrados, grupo muscular, séries, repetições, carga, data e conclusão. Usa `snapshots()` e `StreamBuilder`, com indicador de carregamento, estado vazio e tratamento básico de erros.

## 4. Estrutura do projeto

```text
lib/
  main.dart                         # Inicialização Firebase e MaterialApp
  firebase_options.dart             # Configuração oficial FlutterFire
  pages/
    home_page.dart                  # Início e gráfico
    register_workout_page.dart      # Formulário e gravação
    workout_history_page.dart       # Histórico em tempo real
assets/images/                      # Duas imagens locais
web/                                # Estrutura para execução web
docs/                               # Documentos do projeto
test/widget_test.dart               # Teste de navegação, validação e seleções
pubspec.yaml                        # Dependências e assets
pubspec.lock                        # Versões resolvidas
analysis_options.yaml               # Análise estática
.gitignore
.metadata
.firebaserc
firebase.json
firestore.rules
README.md
```

## 5. Configuração do Firebase

O aplicativo web está configurado oficialmente para o projeto `fittrack-5b367`, com banco Firestore padrão na região `southamerica-east1` (São Paulo).

Para configurar outra instalação ou associar outro projeto, instale a CLI oficial Firebase e execute:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --platforms=web
```

Selecione o projeto desejado e gere `lib/firebase_options.dart` pelo FlutterFire. Confirme que o Cloud Firestore está habilitado e que suas regras permitem o uso previsto. Reinicie o aplicativo após mudanças de configuração.

### Coleção `treinos`

| Campo | Tipo |
|---|---|
| `exercicio` | String |
| `series` | int |
| `repeticoes` | int |
| `carga` | double |
| `grupoMuscular` | String |
| `concluido` | bool |
| `dataRegistro` | Timestamp |

O formulário usa `add()` e registra data e hora com `Timestamp.now()`, conforme o relógio do dispositivo. A carga zero é permitida para exercícios com peso corporal.

### Acesso temporário

As regras em `firestore.rules` permitem leitura e criação de documentos em `treinos` enquanto `request.time` for anterior a **23/11/2026 às 21h37min54s UTC**, equivalente a **23/11/2026 às 18h37min54s no horário de Brasília**. Edição e exclusão permanecem bloqueadas.

O acesso não utiliza autenticação: durante essa janela, qualquer pessoa com a configuração do projeto pode ler e criar registros. Utilize o ambiente apenas para a atividade acadêmica, sem dados pessoais. Após a apresentação, recomenda-se bloquear o acesso público. A partir da expiração, leitura e cadastro serão negados pelas regras.

## 6. Como executar

Pré-requisitos: Flutter e Dart instalados e disponíveis no PATH, Google Chrome e conexão com a internet para acessar o Firestore.

Na pasta do projeto:

```bash
flutter pub get
flutter run -d chrome
```

Para gerar a compilação web:

```bash
flutter build web
```

## 7. Gráfico de evolução

O gráfico de linhas utiliza exclusivamente os dados cadastrados no Firestore. Cada registro corresponde a um ponto: carga em quilogramas no eixo vertical e sequência cronológica no horizontal. Os documentos são consultados em ordem de `dataRegistro`.

O `DropdownButton` seleciona o exercício. A comparação remove espaços nas extremidades, unifica espaços internos e ignora diferenças entre maiúsculas e minúsculas, inclusive em documentos antigos. O nome exibido permanece legível.

O `StreamBuilder` atualiza a visualização quando os registros mudam. Sem dados, há uma orientação para cadastrar treinos; com apenas um registro do exercício, a interface informa que são necessários pelo menos dois. Não há dados fictícios fixos no gráfico.

## 8. Requisitos acadêmicos RF01 a RF09

| Requisito | Arquivos responsáveis | Evidência de implementação e verificação |
|---|---|---|
| RF01 — Estrutura e Chrome | `main.dart` e três páginas | MaterialApp, Scaffold, AppBar personalizada, body e TextStyle no código; análise e build aprovados; execução no Chrome confirmada. |
| RF02 — Imagens e ícones | `home_page.dart`, `register_workout_page.dart`, `pubspec.yaml` | Duas imagens locais com BoxFit e ícones; assets carregados no teste de widgets. |
| RF03 — Layout | `home_page.dart` e demais páginas | Column, Row, alinhamentos, SingleChildScrollView, Stack, Positioned e Padding presentes; renderização coberta pelo teste de widgets. |
| RF04 — Navegação e parâmetros | Três arquivos em `lib/pages/` | Navigator.push e MaterialPageRoute; teste automatizado verifica navegação, retorno e orientação recebida por parâmetro. |
| RF05 — Estado | `home_page.dart`, `register_workout_page.dart` | StatefulWidget e setState; alteração das seleções verificada no teste automatizado. |
| RF06 — Formulário | `register_workout_page.dart` | Quatro TextFields com controllers, InputDecoration, leitura .text e onChanged; validação  testada; preenchimento e salvamento confirmados. |
| RF07 — Checkbox e Radio | `register_workout_page.dart` | RadioGroup com enum e CheckboxListTile; alterações verificadas no teste automatizado. |
| RF08 — Firebase | `main.dart`, `firebase_options.dart`, cadastro e histórico | initializeApp, add(), snapshots(), StreamBuilder e CircularProgressIndicator no código; persistência e atualização automática entre duas janelas confirmadas. |
| RF09 — Gráfico | `home_page.dart` | fl_chart, seleção do exercício, filtro e ordenação implementados; funcionamento com dados cadastrados confirmado. |

## 9. Testes realizados

### Verificações executadas

- `flutter pub get`: dependências resolvidas.
- `flutter analyze`: sem problemas na revisão final.
- `flutter test`: aprovado; cobre navegação, retorno, parâmetro visual, validação do formulário vazio, Radio e Checkbox.
- `flutter build web`: compilação concluída.
- Consulta REST real ao Firestore: HTTP 200 após propagação das regras, quando a coleção ainda estava vazia.
- Abertura e funcionamento no Google Chrome.
- Preenchimento do formulário e salvamento de um treino.
- Persistência do registro no Firebase Cloud Firestore.
- Execução simultânea em duas janelas do navegador.
- Atualização automática do histórico entre as duas janelas.
- Funcionamento do gráfico com os dados cadastrados.

## 10. Referências

O PDF `docs/PropostaAppFlutter.pdf` e as aulas foram consultados durante o desenvolvimento. A integração Firebase segue as instruções explícitas da proposta e a documentação oficial.

- [Aula 01 — Aplicativo padrão](https://viniciusdenovaes.github.io/aulas/indie/mobile_flutter/flutter/aulas/01/01.default_app.html)
- [Aula 02 — Text e AppBar](https://viniciusdenovaes.github.io/aulas/indie/mobile_flutter/flutter/aulas/02/02.text.html)
- [Aula 03 — Imagens e ícones](https://viniciusdenovaes.github.io/aulas/indie/mobile_flutter/flutter/aulas/03/03.images.html)
- [Aula 04 — Layout](https://viniciusdenovaes.github.io/aulas/indie/mobile_flutter/flutter/aulas/04/04.colunas.html)
- [Aula 05 — Navegação](https://viniciusdenovaes.github.io/aulas/indie/mobile_flutter/flutter/aulas/05/05.pages.html)
- [Aula 06 — Stateless e Stateful](https://viniciusdenovaes.github.io/aulas/indie/mobile_flutter/flutter/aulas/06/06.default_project.html)
- [Aula 07 — TextField](https://viniciusdenovaes.github.io/aulas/indie/mobile_flutter/flutter/aulas/07/07.textfield.html)
- [Aula 08 — Checkbox e Radio](https://viniciusdenovaes.github.io/aulas/indie/mobile_flutter/flutter/aulas/08/08.check_and_radio.html)
- [Documentação Flutter](https://docs.flutter.dev)
- [RadioGroup](https://api.flutter.dev/flutter/widgets/RadioGroup-class.html)
- [Configuração Firebase para Flutter](https://firebase.google.com/docs/flutter/setup)
- [fl_chart](https://pub.dev/packages/fl_chart)