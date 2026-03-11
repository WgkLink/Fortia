import 'package:drift/drift.dart';
import '../features/exercises/data/exercises_table.dart';

final exerciseSeeds = <ExercisesCompanion>[
  // === PEITO (Chest) ===
  _ex('Supino Reto com Barra', 'chest', '', 'barbell', 'compound'),
  _ex('Supino Inclinado com Barra', 'chest', 'shoulders,triceps', 'barbell', 'compound'),
  _ex('Supino Declinado com Barra', 'chest', 'triceps', 'barbell', 'compound'),
  _ex('Supino Reto com Halteres', 'chest', 'shoulders,triceps', 'dumbbell', 'compound'),
  _ex('Supino Inclinado com Halteres', 'chest', 'shoulders,triceps', 'dumbbell', 'compound'),
  _ex('Crucifixo com Halteres', 'chest', '', 'dumbbell', 'isolation'),
  _ex('Crucifixo Inclinado', 'chest', '', 'dumbbell', 'isolation'),
  _ex('Crossover', 'chest', '', 'cable', 'isolation'),
  _ex('Peck Deck', 'chest', '', 'machine', 'isolation'),
  _ex('Supino Maquina', 'chest', 'triceps', 'machine', 'compound'),
  _ex('Flexao de Bracos', 'chest', 'shoulders,triceps', 'bodyweight', 'compound'),
  _ex('Mergulho no Paralelo', 'chest', 'triceps,shoulders', 'bodyweight', 'compound'),

  // === COSTAS (Back) ===
  _ex('Puxada Frontal', 'lats', 'biceps', 'cable', 'compound'),
  _ex('Puxada Supinada', 'lats', 'biceps', 'cable', 'compound'),
  _ex('Remada Curvada com Barra', 'back', 'biceps,lats', 'barbell', 'compound'),
  _ex('Remada Unilateral com Halter', 'back', 'biceps,lats', 'dumbbell', 'compound'),
  _ex('Remada Cavalinho', 'back', 'biceps', 'machine', 'compound'),
  _ex('Remada Baixa no Cabo', 'back', 'biceps', 'cable', 'compound'),
  _ex('Barra Fixa', 'lats', 'biceps', 'bodyweight', 'compound'),
  _ex('Pullover no Cabo', 'lats', '', 'cable', 'isolation'),
  _ex('Remada na Maquina', 'back', 'biceps', 'machine', 'compound'),
  _ex('Levantamento Terra', 'back', 'hamstrings,glutes', 'barbell', 'compound'),
  _ex('Remada Alta', 'traps', 'shoulders', 'barbell', 'compound'),
  _ex('Encolhimento com Halteres', 'traps', '', 'dumbbell', 'isolation'),

  // === OMBROS (Shoulders) ===
  _ex('Desenvolvimento com Barra', 'shoulders', 'triceps', 'barbell', 'compound'),
  _ex('Desenvolvimento com Halteres', 'shoulders', 'triceps', 'dumbbell', 'compound'),
  _ex('Desenvolvimento Arnold', 'shoulders', 'triceps', 'dumbbell', 'compound'),
  _ex('Elevacao Lateral', 'shoulders', '', 'dumbbell', 'isolation'),
  _ex('Elevacao Lateral no Cabo', 'shoulders', '', 'cable', 'isolation'),
  _ex('Elevacao Frontal', 'shoulders', '', 'dumbbell', 'isolation'),
  _ex('Crucifixo Inverso', 'shoulders', 'back', 'dumbbell', 'isolation'),
  _ex('Crucifixo Inverso na Maquina', 'shoulders', 'back', 'machine', 'isolation'),
  _ex('Face Pull', 'shoulders', 'traps', 'cable', 'isolation'),
  _ex('Desenvolvimento na Maquina', 'shoulders', 'triceps', 'machine', 'compound'),

  // === BICEPS ===
  _ex('Rosca Direta com Barra', 'biceps', 'forearms', 'barbell', 'isolation'),
  _ex('Rosca Direta com Halteres', 'biceps', 'forearms', 'dumbbell', 'isolation'),
  _ex('Rosca Alternada', 'biceps', 'forearms', 'dumbbell', 'isolation'),
  _ex('Rosca Martelo', 'biceps', 'forearms', 'dumbbell', 'isolation'),
  _ex('Rosca Concentrada', 'biceps', '', 'dumbbell', 'isolation'),
  _ex('Rosca Scott com Barra EZ', 'biceps', '', 'ezBar', 'isolation'),
  _ex('Rosca no Cabo', 'biceps', '', 'cable', 'isolation'),
  _ex('Rosca Inclinada', 'biceps', '', 'dumbbell', 'isolation'),
  _ex('Rosca Spider', 'biceps', '', 'barbell', 'isolation'),

  // === TRICEPS ===
  _ex('Triceps Pulley', 'triceps', '', 'cable', 'isolation'),
  _ex('Triceps Corda', 'triceps', '', 'cable', 'isolation'),
  _ex('Triceps Frances com Halter', 'triceps', '', 'dumbbell', 'isolation'),
  _ex('Triceps Frances com Barra', 'triceps', '', 'barbell', 'isolation'),
  _ex('Triceps Testa', 'triceps', '', 'barbell', 'isolation'),
  _ex('Mergulho no Banco', 'triceps', 'chest,shoulders', 'bodyweight', 'compound'),
  _ex('Triceps Kickback', 'triceps', '', 'dumbbell', 'isolation'),
  _ex('Supino Fechado', 'triceps', 'chest', 'barbell', 'compound'),

  // === QUADRICEPS ===
  _ex('Agachamento Livre', 'quadriceps', 'glutes,hamstrings', 'barbell', 'compound'),
  _ex('Agachamento Frontal', 'quadriceps', 'glutes', 'barbell', 'compound'),
  _ex('Agachamento Hack', 'quadriceps', 'glutes', 'machine', 'compound'),
  _ex('Leg Press', 'quadriceps', 'glutes,hamstrings', 'machine', 'compound'),
  _ex('Leg Press 45', 'quadriceps', 'glutes,hamstrings', 'machine', 'compound'),
  _ex('Cadeira Extensora', 'quadriceps', '', 'machine', 'isolation'),
  _ex('Agachamento Bulgaro', 'quadriceps', 'glutes', 'dumbbell', 'compound'),
  _ex('Passada com Halteres', 'quadriceps', 'glutes', 'dumbbell', 'compound'),
  _ex('Agachamento Goblet', 'quadriceps', 'glutes', 'dumbbell', 'compound'),
  _ex('Sissy Squat', 'quadriceps', '', 'bodyweight', 'isolation'),

  // === POSTERIORES (Hamstrings) ===
  _ex('Mesa Flexora', 'hamstrings', '', 'machine', 'isolation'),
  _ex('Cadeira Flexora', 'hamstrings', '', 'machine', 'isolation'),
  _ex('Stiff', 'hamstrings', 'glutes,back', 'barbell', 'compound'),
  _ex('Stiff com Halteres', 'hamstrings', 'glutes', 'dumbbell', 'compound'),
  _ex('Levantamento Terra Romeno', 'hamstrings', 'glutes,back', 'barbell', 'compound'),
  _ex('Good Morning', 'hamstrings', 'back', 'barbell', 'compound'),

  // === GLUTEOS (Glutes) ===
  _ex('Hip Thrust com Barra', 'glutes', 'hamstrings', 'barbell', 'compound'),
  _ex('Hip Thrust na Maquina', 'glutes', 'hamstrings', 'machine', 'compound'),
  _ex('Elevacao Pelvica', 'glutes', 'hamstrings', 'bodyweight', 'compound'),
  _ex('Abdutora na Maquina', 'abductors', 'glutes', 'machine', 'isolation'),
  _ex('Adutora na Maquina', 'adductors', '', 'machine', 'isolation'),
  _ex('Kickback no Cabo', 'glutes', '', 'cable', 'isolation'),

  // === PANTURRILHAS (Calves) ===
  _ex('Panturrilha em Pe na Maquina', 'calves', '', 'machine', 'isolation'),
  _ex('Panturrilha Sentado', 'calves', '', 'machine', 'isolation'),
  _ex('Panturrilha no Leg Press', 'calves', '', 'machine', 'isolation'),
  _ex('Panturrilha em Pe com Halter', 'calves', '', 'dumbbell', 'isolation'),

  // === ABDOMINAIS (Abs) ===
  _ex('Abdominal Crunch', 'abs', '', 'bodyweight', 'isolation'),
  _ex('Abdominal Infra', 'abs', '', 'bodyweight', 'isolation'),
  _ex('Prancha', 'abs', '', 'bodyweight', 'isolation'),
  _ex('Abdominal na Polia', 'abs', '', 'cable', 'isolation'),
  _ex('Elevacao de Pernas', 'abs', 'hipFlexors', 'bodyweight', 'isolation'),
  _ex('Russian Twist', 'obliques', 'abs', 'bodyweight', 'isolation'),
  _ex('Abdominal Bicicleta', 'abs', 'obliques', 'bodyweight', 'isolation'),
  _ex('Abdominal na Roda', 'abs', '', 'other', 'isolation'),

  // === ANTEBRACOS (Forearms) ===
  _ex('Rosca de Punho', 'forearms', '', 'barbell', 'isolation'),
  _ex('Rosca de Punho Invertida', 'forearms', '', 'barbell', 'isolation'),
];

ExercisesCompanion _ex(
  String name,
  String primaryMuscle,
  String secondaryMuscles,
  String equipment,
  String category,
) {
  return ExercisesCompanion.insert(
    name: name,
    primaryMuscleGroup: primaryMuscle,
    secondaryMuscleGroups: Value(secondaryMuscles),
    equipmentType: equipment,
    category: category,
  );
}
