# Arquitetura do Fortia

## Visão Geral

Fortia é um aplicativo de rastreamento de treinos inspirado no Hevy, desenvolvido com Flutter para suporte multiplataforma (Android, Web, iOS). Permite criar rotinas de treino, registrar sessões, acompanhar o progresso de exercícios e visualizar métricas de desempenho.

---

## Stack Tecnológica

| Categoria | Tecnologia | Versão |
|---|---|---|
| Framework principal | Flutter / Dart | Dart 3.7.0+ |
| Gerenciamento de estado | Flutter Riverpod + Riverpod Generator | 2.6.1 |
| Banco de dados | Drift (ORM SQLite type-safe) | 2.22.1 |
| Navegação | Go Router | — |
| Gráficos | FL Chart | 0.70.2 |
| Animações | Flutter Animate | 4.5.2 |
| Geração de código | Freezed + JSON Serializable + Build Runner | — |
| UI | Material Design 3 (tema escuro, seed color: `0xFF6C63FF`) | — |
| Localização | Intl (pt_BR) | 0.19.0 |
| Build | Podman Compose (APK Android / Web) | — |
| Testes | Mocktail | 1.0.4 |

---

## Estrutura de Diretórios

```
Fortia/
├── lib/
│   ├── main.dart                          # Ponto de entrada; inicializa Riverpod e seed do banco
│   ├── app.dart                           # Widget raiz (MaterialApp + GoRouter)
│   ├── core/                              # Infraestrutura compartilhada
│   │   ├── database/
│   │   │   └── app_database.dart          # Configuração do Drift (schema v1)
│   │   ├── providers/
│   │   │   └── core_providers.dart        # Providers globais (DB, DAOs)
│   │   ├── router/
│   │   │   └── app_router.dart            # Rotas GoRouter
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Tema Material 3
│   │   ├── utils/
│   │   │   └── formatters.dart            # Utilitários (duração, peso, volume, 1RM)
│   │   └── widgets/
│   │       ├── app_shell.dart             # Shell com bottom navigation
│   │       ├── confirm_dialog.dart        # Diálogo de confirmação
│   │       ├── stat_card.dart             # Card de estatística
│   │       └── empty_state.dart           # Estado vazio
│   ├── features/
│   │   ├── exercises/                     # Biblioteca de exercícios
│   │   │   ├── data/
│   │   │   │   ├── exercises_table.dart   # Schema da tabela Exercises
│   │   │   │   └── exercises_dao.dart     # DAO: CRUD, filtros, busca
│   │   │   ├── domain/
│   │   │   │   └── enums.dart             # MuscleGroup, EquipmentType, ExerciseCategory
│   │   │   └── presentation/
│   │   │       ├── exercise_library_screen.dart
│   │   │       ├── exercise_detail_screen.dart
│   │   │       ├── exercise_progress_screen.dart
│   │   │       └── exercises_provider.dart
│   │   ├── routines/                      # Gerenciamento de rotinas
│   │   │   ├── data/
│   │   │   │   ├── routines_table.dart    # Tabelas Routines e RoutineExercises
│   │   │   │   └── routines_dao.dart      # DAO com joins compostos
│   │   │   └── presentation/
│   │   │       ├── routines_list_screen.dart
│   │   │       ├── routine_editor_screen.dart
│   │   │       ├── routine_detail_screen.dart
│   │   │       └── routines_provider.dart
│   │   ├── workout/                       # Treino ativo
│   │   │   ├── data/
│   │   │   │   ├── workouts_table.dart    # Tabelas Workouts, WorkoutExercises, WorkoutSets
│   │   │   │   └── workouts_dao.dart      # DAO: histórico, estatísticas, PRs
│   │   │   ├── domain/
│   │   │   │   └── enums.dart             # SetType (normal, warmup, dropset, failure)
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── home_screen.dart
│   │   │       ├── active_workout_screen.dart
│   │   │       └── active_workout_provider.dart
│   │   ├── history/                       # Histórico de treinos
│   │   │   └── presentation/
│   │   │       ├── history_screen.dart
│   │   │       └── workout_detail_screen.dart
│   │   ├── progress/                      # Analytics e progresso
│   │   │   ├── domain/
│   │   │   │   ├── pr_detector.dart       # Algoritmo de detecção de recordes (PRs)
│   │   │   │   └── overload_suggestion.dart # Sugestão de sobrecarga progressiva
│   │   │   └── presentation/
│   │   │       ├── progress_dashboard_screen.dart
│   │   │       ├── streak_graph.dart
│   │   │       ├── muscle_heatmap.dart
│   │   │       └── pr_celebration_dialog.dart
│   │   └── settings/
│   │       └── presentation/
│   │           └── settings_screen.dart
│   └── seed/
│       ├── seed_database.dart             # Inicialização do banco
│       └── exercise_seeds.dart            # Exercícios pré-definidos
├── test/
├── container/
│   └── compose.yaml                       # Podman Compose (build e dev)
├── pubspec.yaml
└── analysis_options.yaml
```

---

## Arquitetura em Camadas (Clean Architecture)

O projeto segue os princípios de Clean Architecture, separando responsabilidades em três camadas:

```
┌──────────────────────────────────────────────┐
│              Presentation Layer              │
│   Screens · Widgets · Riverpod Providers     │
├──────────────────────────────────────────────┤
│               Domain Layer                   │
│   Enums · PR Detector · Overload Suggestion  │
├──────────────────────────────────────────────┤
│                Data Layer                    │
│     DAOs · Drift Tables · Database           │
└──────────────────────────────────────────────┘
```

- **Data Layer:** Esquema de banco de dados (Drift), DAOs com queries tipadas.
- **Domain Layer:** Lógica de negócio pura (detecção de PRs, sugestão de sobrecarga, enums de domínio).
- **Presentation Layer:** Telas, widgets reutilizáveis e providers Riverpod que conectam dados ao estado de UI.

---

## Schema do Banco de Dados

```
┌─────────────────┐        ┌───────────────────────┐        ┌──────────────────┐
│    Exercises     │        │   RoutineExercises    │        │    Routines      │
│─────────────────│        │───────────────────────│        │──────────────────│
│ id (PK)         │◄───────│ exerciseId (FK)       │───────►│ id (PK)          │
│ name            │        │ routineId (FK)        │        │ name             │
│ primaryMuscle   │        │ sortOrder             │        │ dayOfWeek (1-7)  │
│ secondaryMuscles│        │ targetSets            │        │ colorHex         │
│ equipmentType   │        │ targetReps            │        │ createdAt        │
│ category        │        │ targetRestSeconds     │        │ updatedAt        │
│ instructions    │        │ notes                 │        └──────────────────┘
│ isCustom        │        └───────────────────────┘
└────────┬────────┘
         │
         │          ┌─────────────────────────┐        ┌──────────────────┐
         │          │    WorkoutExercises      │        │    Workouts      │
         │          │─────────────────────────│        │──────────────────│
         └─────────►│ exerciseId (FK)         │◄───────│ id (PK)          │
                    │ workoutId (FK)          │        │ routineId (FK?)  │
                    │ sortOrder               │        │ name             │
                    │ supersetGroup           │        │ startedAt        │
                    └──────────┬──────────────┘        │ finishedAt       │
                               │                       │ durationSeconds  │
                    ┌──────────▼──────────────┐        │ notes            │
                    │      WorkoutSets         │        └──────────────────┘
                    │─────────────────────────│
                    │ id (PK)                 │
                    │ workoutExerciseId (FK)  │
                    │ sortOrder               │
                    │ weightKg                │
                    │ reps                    │
                    │ setType                 │
                    │ restSeconds             │
                    │ isCompleted             │
                    │ rpe                     │
                    └─────────────────────────┘
```

---

## Gerenciamento de Estado (Riverpod)

```
core_providers.dart
  └── appDatabaseProvider      → instância do banco Drift
  └── exercisesDaoProvider     → DAO de exercícios
  └── routinesDaoProvider      → DAO de rotinas
  └── workoutsDaoProvider      → DAO de treinos

features/exercises/
  └── exercisesProvider        → StreamProvider (lista reativa)
  └── exerciseDetailProvider   → FutureProvider (detalhe único)

features/routines/
  └── routinesProvider         → StreamProvider (lista reativa)
  └── routineDetailProvider    → FutureProvider

features/workout/
  └── activeWorkoutProvider    → NotifierProvider (estado em memória do treino ativo)
  └── restTimerProvider        → NotifierProvider (temporizador de descanso)
  └── workoutDurationProvider  → StreamProvider (tick a cada segundo)

features/progress/
  └── weeklyVolumeProvider     → FutureProvider (volume semanal por dia)
  └── trainingStreakProvider   → FutureProvider (sequência de treinos)
  └── muscleHeatmapProvider    → FutureProvider (volume por grupo muscular)
```

---

## Navegação

GoRouter com um shell route para a bottom navigation bar principal:

```
/ (redirect → /home)
├── /home                         # Tela inicial (rotinas do dia, treinos recentes)
├── /history                      # Histórico de treinos
│   └── /workout/:id              # Detalhe de um treino concluído
├── /routines                     # Lista de rotinas
│   ├── /routines/new             # Criar nova rotina
│   └── /routines/:id
│       ├── (view)                # Detalhe da rotina
│       └── /edit                 # Editar rotina
├── /progress                     # Dashboard de progresso
├── /exercises                    # Biblioteca de exercícios
│   └── /exercises/:id
│       └── /progress             # Progresso do exercício
├── /workout/active               # Treino ativo (tela cheia, sem bottom nav)
└── /settings                     # Configurações
```

---

## Fluxo Principal: Treino Ativo

```
Usuário escolhe rotina ou "Treino Rápido"
         │
         ▼
ActiveWorkoutProvider.startWorkout()
  └── Carrega exercícios da rotina (RoutinesDao)
  └── Busca desempenho anterior por exercício (WorkoutsDao.getPreviousSets)
         │
         ▼
Usuário registra séries (peso, reps, tipo de série)
  └── Estado em memória atualizado via ActiveWorkoutNotifier
  └── Timer de descanso acionado ao completar série
         │
         ▼
Usuário finaliza o treino
  └── WorkoutsDao persiste Workout + WorkoutExercises + WorkoutSets
  └── PRDetector analisa recordes (MaxWeight e 1RM estimado)
  └── Diálogo de celebração de PR exibido (se houver PRs)
         │
         ▼
Navegação de volta para /home
```

---

## Lógica de Domínio

### Detecção de Recordes Pessoais (PR)

- **MaxWeight PR:** peso máximo já registrado para o exercício.
- **Max1RM (Epley):** estimativa de 1 repetição máxima = `peso × (1 + reps / 30)`.
- O `PRDetector` compara os valores do treino atual com o histórico e retorna os PRs encontrados.

### Sugestão de Sobrecarga Progressiva

| Situação | Ação sugerida |
|---|---|
| 2 sessões consecutivas atingiram as reps-alvo | Aumentar peso em +2,5 kg (ou +1,25 kg para cargas leves) |
| Última sessão atingiu as reps-alvo | Manter peso atual |
| Longe das reps-alvo | Consolidar com o peso atual |

---

## Build e Deploy

| Ambiente | Comando (Podman Compose) | Saída |
|---|---|---|
| Desenvolvimento Web | `podman compose run web-dev` | `localhost:8080` |
| Geração de código | `podman compose run build-runner` | Arquivos `.g.dart` |
| Build APK (Android) | `podman compose run build-apk` | `build/app/outputs/...` |
| Build Web (produção) | `podman compose run build-web` | `build/web/` |
| Testes | `podman compose run test` | Relatório no terminal |

> O banco de dados SQLite é armazenado no diretório de documentos do app (mobile) ou em memória (web).

---

## Boas Práticas Adotadas

- **Clean Code:** nomes descritivos, funções com responsabilidade única.
- **Clean Architecture:** separação clara entre dados, domínio e apresentação.
- **Reactive Programming:** Riverpod com `StreamProvider` para atualizações em tempo real.
- **Type Safety:** Drift gera código tipado para todas as queries SQL.
- **Imutabilidade:** Freezed para data classes imutáveis.
- **AutoDispose:** providers descartados automaticamente para eficiência de memória.
- **Localização:** todo o texto em pt_BR via pacote Intl.
- **Linting:** regras configuradas em `analysis_options.yaml`.
