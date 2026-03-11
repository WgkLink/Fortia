enum MuscleGroup {
  chest('Peito'),
  back('Costas'),
  shoulders('Ombros'),
  biceps('Biceps'),
  triceps('Triceps'),
  forearms('Antebracos'),
  quadriceps('Quadriceps'),
  hamstrings('Posteriores'),
  glutes('Gluteos'),
  calves('Panturrilhas'),
  abs('Abdominais'),
  traps('Trapezio'),
  lats('Dorsal'),
  obliques('Obliquos'),
  hipFlexors('Flexores do Quadril'),
  adductors('Adutores'),
  abductors('Abdutores');

  const MuscleGroup(this.label);
  final String label;
}

enum EquipmentType {
  barbell('Barra'),
  dumbbell('Halter'),
  machine('Maquina'),
  cable('Cabo'),
  bodyweight('Peso Corporal'),
  smithMachine('Smith Machine'),
  ezBar('Barra EZ'),
  kettlebell('Kettlebell'),
  resistanceBand('Elastico'),
  other('Outro');

  const EquipmentType(this.label);
  final String label;
}

enum ExerciseCategory {
  compound('Composto'),
  isolation('Isolado'),
  cardio('Cardio'),
  stretching('Alongamento');

  const ExerciseCategory(this.label);
  final String label;
}
