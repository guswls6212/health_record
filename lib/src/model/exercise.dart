class Exercise {
  final String name;
  final List<Set> sets;

  Exercise({required this.name, required this.sets});
}

class Set {
  final int set;
  final double weight;
  final int reps;
  final double rm;

  Set(
      {required this.set,
      required this.weight,
      required this.reps,
      required this.rm});
}
