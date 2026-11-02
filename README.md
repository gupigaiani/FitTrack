# FitTrack

Trabalho NP2 de Desenvolvimento Mobile (ADS). Registra exercícios no Firestore e acompanha a evolução das cargas. Flutter/Dart, widgets Material, setState, firebase_core, cloud_firestore e fl_chart. Sem login: registros compartilhados no projeto Firebase.

## Arquivos e telas

- `lib/main.dart`: Firebase.initializeApp e MaterialApp/tema.
- `lib/pages/home_page.dart`: início, navegação e gráfico.
- `lib/pages/register_workout_page.dart`: formulário e gravação.
- `lib/pages/workout_history_page.dart`: lista em tempo real.
- `lib/firebase_options.dart`: configuração oficial gerada pelo FlutterFire para `fittrack-5b367` (web).
- `assets/images/treino_1.jpg`, `treino_2.jpg`: fotos de musculação locais registradas no pubspec.
- `test/widget_test.dart`: navegação, parâmetro visual, validação vazia e seleções.
- `web/`: estrutura web gerada pelo Flutter; `pubspec.yaml` e lock: dependências.

## Configurar Firebase

1. O projeto real `fittrack-5b367` já está associado ao aplicativo web. Confira no console se Cloud Firestore está habilitado.
2. Instale a CLI oficial Firebase e execute `firebase login` com sua conta.
3. Com Flutter/Dart no PATH, execute:

```sh
dart pub global activate flutterfire_cli
flutterfire configure --platforms=web
```

Para reconfigurar, selecione `fittrack-5b367` e permita atualizar `lib/firebase_options.dart`. A configuração atual foi gerada oficialmente. Reinicie o aplicativo após alterações.

4. Publique regras temporárias apenas para leitura e criação em `treinos`. Substitua `DATA_LIMITE_UTC` por um instante UTC próximo da apresentação, no formato ISO 8601. Este modelo exige a substituição antes de publicar:

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /treinos/{id} {
      allow read, create: if request.time < timestamp.value('DATA_LIMITE_UTC');
      allow update, delete: if false;
    }
  }
}
```

Use projeto exclusivo, sem dados pessoais: na janela temporária qualquer pessoa com a configuração pode ler/criar registros. Após apresentar, publique `allow read, write: if false;` na coleção. Não mantenha acesso público permanente.

5. Cadastre pelo formulário pelo menos três registros de exercícios realmente realizados. Para demonstrar a linha, use o mesmo nome de exercício em três registros. Não existe inserção automática nem dados simulados.

Coleção única `treinos`: `exercicio` String, `series` int, `repeticoes` int, `carga` double, `grupoMuscular` String, `concluido` bool, `dataRegistro` Timestamp. O cadastro usa `add()` e `Timestamp.now()` (horário do dispositivo).

## Executar

```sh
flutter pub get
flutter run -d chrome
```

Neste ambiente, Flutter foi localizado em `C:/Users/gupigaiani/Documents/Projetos/Unip/AppFlutter/.tools/flutter/bin/flutter.bat`. Adicione a pasta ao PATH ou use o caminho completo no PowerShell com `&`.

O Firebase web e o banco Firestore padrão estão configurados em `fittrack-5b367`, região `southamerica-east1` (São Paulo), edição Standard com cota gratuita. As regras em `firestore.rules` permitem somente leitura e criação em `treinos` até **11/11/2026 às 21:37:54 UTC** (18:37:54 de Brasília); edição e exclusão são negadas. Após esse prazo, o aplicativo precisa de uma nova janela de demonstração explicitamente configurada. Para compilar: `flutter build web`.

## Gráfico

Único recurso adicional: fl_chart, escolhido para representar visualmente o progresso dos dados em nuvem. `snapshots()` recebe os documentos ordenados por data; DropdownButton seleciona o nome normalizado do exercício. Cada registro vira um ponto (X: sequência cronológica, Y: kg). Menos de dois registros apresenta uma orientação. StreamBuilder atualiza a linha quando os documentos mudam.

## Requisitos

| RF | Arquivo e trecho responsável | Verificação |
|---|---|---|
| RF01 | main/FitTrackApp; Scaffold/AppBar/body das páginas | Análise, build e inicialização Chrome |
| RF02 | home/build e register/build: Image.asset/BoxFit/Icon; pubspec/assets | Build e teste widgets; inspeção visual pendente |
| RF03 | home/build: Column/Row, alinhamentos, scroll, Stack/Positioned/Padding | Código e teste widgets |
| RF04 | home/build: Navigator.push/MaterialPageRoute; register/orientacao | Teste ida/volta e parâmetro |
| RF05 | home e register: StatefulWidget/setState | Teste seleções |
| RF06 | register/build e salvar: quatro controllers, .text, onChanged | Teste campos vazios; outros limites pendentes |
| RF07 | register: GrupoMuscular, RadioGroup, CheckboxListTile | Teste alteração Radio e Checkbox |
| RF08 | main/initializeApp; register/salvar/add; history/snapshots/StreamBuilder | Código pronto; teste real e três documentos pendentes |
| RF09 | home/evolucao: filtro, ordenação, DropdownButton, LineChart | Código pronto; teste real pendente |

Executados: analyze, teste de widgets, build web e inicialização no Chrome. Após a configuração real, analyze/test/build passaram novamente; o banco Standard foi criado e as regras temporárias foram publicadas pela CLI. Após a propagação das regras, a consulta REST real ordenada por `dataRegistro` retornou HTTP 200 e zero documentos. Gravação pelo formulário, carregamento e atualização em tempo real do histórico/gráfico ainda precisam de confirmação no aplicativo conectado. Nenhum treino foi inserido automaticamente.

Após configurar: validar nome vazio; séries/repetições inválidas ou zero; carga negativa/NaN/infinita; carga zero válida; grupo ausente; cadastro válido; tipos no console; duas instâncias atualizando lista/gráfico; zero, um e três registros por exercício; carregamento, permissão negada e layout estreito.

## Referências e limites

PDF fornecido lido; aulas 01–08 consultadas pelos links da seção 11. A aula 09 separada não foi fornecida: a integração segue os requisitos explícitos do PDF e a documentação oficial. O PDF também solicita resumo de uma página com integrantes/papéis e comunicação do tema/recurso ao professor; o grupo deve preencher esses dados.

[Aulas do professor](https://viniciusdenovaes.github.io/aulas/indie/mobile_flutter/flutter/aulas/01/01.default_app.html), [Flutter](https://docs.flutter.dev), [RadioGroup](https://api.flutter.dev/flutter/widgets/RadioGroup-class.html), [Firebase/FlutterFire](https://firebase.google.com/docs/flutter/setup), [fl_chart](https://pub.dev/packages/fl_chart).

Imagens Unsplash baixadas como assets: `photo-1534438327276-14e5300c3a48` e `photo-1517836357463-d25dfeac3438`. A aplicação não consulta serviço de imagens em execução.

## Revisao final

Nomes no grafico sao comparados com trim, espacos internos unificados e toLowerCase, incluindo documentos antigos; o seletor usa inicial maiuscula. O cadastro conserva a escrita legivel e remove espacos redundantes. Nenhum documento remoto foi alterado.

Comparacao de aulas: aulas 01 a 08 e PDF foram consultados no desenvolvimento anterior. Nesta revisao nao houve nova leitura integral; aula 09 separada continua ausente. Widgets auxiliares como Card, ClipRRect, ConstrainedBox, Expanded, SizedBox e ListView.builder nao tiveram sua presenca nas aulas confirmada; foram preservados para manter layout e funcionamento. fl_chart e a unica dependencia adicional. Nao se declara comparacao integral das nove aulas.

Pacote final: FitTrack-entrega.zip preserva codigo, imagens, web, testes, lock, metadados e configuracao Firebase. Exclui .dart_tool, build, .idea, *.iml, logs e metadados de plugins gerados. Caches locais nao foram apagados.
