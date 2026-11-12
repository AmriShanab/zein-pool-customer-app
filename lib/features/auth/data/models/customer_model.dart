import '../../domain/entities/customer_profile.dart';

class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.mobile,
    required this.normalizedMobile,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String vendorId;
  final String name;
  final String mobile;
  final String normalizedMobile;
  final String? notes;
  final String? createdAt;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Guest',
      mobile: json['mobile']?.toString() ?? '',
      normalizedMobile: json['normalized_mobile']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vendor_id': vendorId,
    'name': name,
    'mobile': mobile,
    'normalized_mobile': normalizedMobile,
    'notes': notes,
    'created_at': createdAt,
  };

  CustomerProfile toEntity() {
    DateTime? parsedDate;
    if (createdAt != null) {
      try {
        parsedDate = DateTime.parse(createdAt!);
      } catch (_) {}
    }
    return CustomerProfile(
      id: id,
      vendorId: vendorId,
      name: name,
      mobile: mobile,
      normalizedMobile: normalizedMobile,
      notes: notes,
      createdAt: parsedDate,
    );
  }
}
