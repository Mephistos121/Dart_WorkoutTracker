/**
 * Exercise class
 */
class Exercise {
  String name;
  int nbSets;
  num weight;
  String description;

  /**
   * 2 constructeurs : un pour les nouveaux exercises, un pour les exercises de base
   */
  Exercise({
    required this.name,
    required this.nbSets,
    required this.weight,
    required this.description,
  });

  Exercise.preset(
      {required this.name,
      this.nbSets = 0,
      this.weight = 0,
      this.description = ''});

  /**
   * convertis un Map en Exercise object
   */
  factory Exercise.fromMap(Map<dynamic, dynamic> map) {
    return Exercise(
        name: map['name'],
        nbSets: map['nbSets'],
        weight: map['weight'],
        description: map['description']);
  }

  /**
   * convertis un Exercise object en Map<String, dynamic>
   */
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nbSets': nbSets,
      'weight': weight,
      'description': description,
    };
  }
}
