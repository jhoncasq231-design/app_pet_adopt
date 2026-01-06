class PetModel {
  final String name;
  final String breed;
  final String age;
  final String sex;
  final String size;
  final String distance;

  PetModel({
    required this.name,
    required this.breed,
    required this.age,
    required this.sex,
    required this.size,
    required this.distance,
  });

  factory PetModel.empty() {
    return PetModel(
      name: '',
      breed: '',
      age: '',
      sex: '',
      size: '',
      distance: '',
    );
  }
}
