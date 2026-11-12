import '../../domain/entities/resort_config.dart';

class ResortConfigModel {
  const ResortConfigModel({
    required this.resortName,
    required this.currency,
    required this.timezone,
    required this.businessMobile,
    required this.businessEmail,
    required this.businessAddress,
    required this.operatingHours,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.rules,
  });

  final String resortName;
  final String currency;
  final String timezone;
  final String businessMobile;
  final String businessEmail;
  final String businessAddress;
  final String operatingHours;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final List<String> rules;

  factory ResortConfigModel.fromJson(Map<String, dynamic> json) {
    final bank = json['bank_info'] as Map? ?? {};
    final rulesRaw = (json['rules'] ?? json['guidelines']) as List? ?? [];

    return ResortConfigModel(
      resortName: json['resort_name']?.toString() ?? "Zein's Pool",
      currency: json['currency']?.toString() ?? 'LKR',
      timezone: json['timezone']?.toString() ?? 'Asia/Colombo',
      businessMobile: json['business_mobile']?.toString() ?? '+94789238808',
      businessEmail:
          json['business_email']?.toString() ?? 'contact@zeinspool.com',
      businessAddress:
          json['business_address']?.toString() ??
          'Kattankudy, Batticaloa, Sri Lanka',
      operatingHours:
          json['operating_hours']?.toString() ?? '07:00 AM – 11:00 PM Daily',
      bankName: bank['bank_name']?.toString() ?? 'Commercial Bank',
      accountName: bank['account_name']?.toString() ?? "Zein's Pool Resort",
      accountNumber: bank['account_number']?.toString() ?? '8001234567',
      rules: rulesRaw.map((r) => r.toString()).toList(),
    );
  }

  ResortConfig toEntity() {
    return ResortConfig(
      resortName: resortName,
      currency: currency,
      timezone: timezone,
      businessMobile: businessMobile,
      businessEmail: businessEmail,
      businessAddress: businessAddress,
      operatingHours: operatingHours,
      bankInfo: BankInfo(
        bankName: bankName,
        accountName: accountName,
        accountNumber: accountNumber,
      ),
      rules: rules,
    );
  }
}
