class BankInfo {
  const BankInfo({
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
  });

  final String bankName;
  final String accountName;
  final String accountNumber;
}

class ResortConfig {
  const ResortConfig({
    required this.resortName,
    required this.currency,
    required this.timezone,
    required this.businessMobile,
    required this.businessEmail,
    required this.businessAddress,
    required this.operatingHours,
    required this.bankInfo,
    required this.rules,
  });

  final String resortName;
  final String currency;
  final String timezone;
  final String businessMobile;
  final String businessEmail;
  final String businessAddress;
  final String operatingHours;
  final BankInfo bankInfo;
  final List<String> rules;
}
