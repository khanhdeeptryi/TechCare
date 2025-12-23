class Clinic {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String description;
  // Thêm các trường mới
  final String hotline;
  final String openHours;
  final List<String> services;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.description,
    required this.hotline,
    required this.openHours,
    required this.services,
  });

  factory Clinic.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Clinic(
      id: documentId,
      name: data['name']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      hotline: data['hotline']?.toString() ?? '',
      openHours: data['openHours']?.toString() ?? '',
      services: (data['services'] is List)
          ? List<String>.from((data['services'] as List).map((e) => e.toString()))
          : [],
    );
  }
}