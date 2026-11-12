class CustomerProfile {
  const CustomerProfile({
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
  final DateTime? createdAt;

  CustomerProfile copyWith({String? name, String? notes}) {
    return CustomerProfile(
      id: id,
      vendorId: vendorId,
      name: name ?? this.name,
      mobile: mobile,
      normalizedMobile: normalizedMobile,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
