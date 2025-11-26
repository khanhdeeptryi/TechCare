import 'package:flutter/material.dart';
import '../models/hospital.dart';

class HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final VoidCallback onTap;

  const HospitalCard({Key? key, required this.hospital, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            hospital.imageUrl, 
            width: 60, height: 60, fit: BoxFit.cover,
            errorBuilder: (_,__,___) => const Icon(Icons.local_hospital, size: 40, color: Colors.grey),
          ),
        ),
        title: Text(hospital.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(hospital.address, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: onTap,
      ),
    );
  }
}