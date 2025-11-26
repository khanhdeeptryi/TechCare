class Hospital {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String description;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.description,
  });

  factory Hospital.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Hospital(
      id: documentId,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
    );
  }
}