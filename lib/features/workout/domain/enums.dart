enum SetType {
  normal('Normal'),
  warmup('Aquecimento'),
  dropset('Drop Set'),
  failure('Falha');

  const SetType(this.label);
  final String label;
}
