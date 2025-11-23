import 'package:cloud_firestore/cloud_firestore.dart';

class Clinic {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String description; 

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.description,
  });

  factory Clinic.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Clinic(
      id: documentId,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
    );
  }
}