class Doctor {
  final String id;
  final String name;
  final String title;           
  final int experience;        
  final String address;
  final String imageUrl;
  final List<String> specialties;
  final String bio;            

  Doctor({
    required this.id,
    required this.name,
    required this.title,
    required this.experience,
    required this.address,
    required this.imageUrl,
    required this.specialties,
    required this.bio,
  });

  factory Doctor.fromFirestore(Map<String, dynamic> data, String docId) {
    return Doctor(
      id: docId,
      name: data['name']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      experience:
          int.tryParse(data['experience']?.toString() ?? '0') ?? 0,
      address: data['address']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      specialties: (data['specialties'] is List)
          ? List<String>.from(
              (data['specialties'] as List).map((e) => e.toString()))
          : <String>[],
      bio: data['bio']?.toString() ?? '',   
    );
  }
}
