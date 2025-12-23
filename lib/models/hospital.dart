class Hospital {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String description;
  // Thêm các trường mới
  final String hotline;
  final String website;
  final List<String> departments; // Chuyên khoa

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.description,
    required this.hotline,
    required this.website,
    required this.departments,
  });

  factory Hospital.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Hospital(
      id: documentId,
      name: data['name']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      hotline: data['hotline']?.toString() ?? '',
      website: data['website']?.toString() ?? '',
      departments: (data['departments'] is List)
          ? List<String>.from((data['departments'] as List).map((e) => e.toString()))
          : [],
    );
  }
}