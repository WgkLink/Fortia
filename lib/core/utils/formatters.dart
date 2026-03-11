class Formatters {
  Formatters._();

  static String duration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  static String weight(double kg) {
    if (kg == kg.roundToDouble()) {
      return kg.toInt().toString();
    }
    return kg.toStringAsFixed(1);
  }

  static String volume(int totalKg) {
    if (totalKg >= 1000) {
      return '${(totalKg / 1000).toStringAsFixed(1)}t';
    }
    return '${totalKg}kg';
  }

  static String dayOfWeek(int day) {
    const days = [
      'Segunda',
      'Terca',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sabado',
      'Domingo',
    ];
    return days[day - 1];
  }

  static String dayOfWeekShort(int day) {
    const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    return days[day - 1];
  }

  /// Estimated 1RM using Epley formula
  static double estimated1RM(double weight, int reps) {
    if (reps <= 0 || weight <= 0) return 0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }
}
