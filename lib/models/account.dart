import 'package:final_project_unicode/models/transaction.dart';
import 'package:flutter/material.dart';

enum AccountType { bank, credit, child }

/// Supported banks for classification and logo rendering
enum Bank {
  nbk,
  kfh,
  gulfBank,
  cbk,
  abk,
  burgan,
  kib,
  boubyan,
  warba,
  weyay,
  tam,
}

/// High-level bank product categories used for selection
enum BankCategory { currentSalary, savings, kids, youth, creditCards }

class Account {
  final String id;
  final String name;
  final String maskedNumber;
  final String? fullNumber; // Sensitive: store but never show directly
  final AccountType type;
  final Bank bank;
  final BankCategory category;
  final double balance;
  final String currency;
  final List<Transaction> transactions;
  final double? spendingLimit; // For child cards
  final double? usedAmount; // For child cards
  final bool notificationsEnabled; // For child cards

  Account({
    required this.id,
    required this.name,
    required this.maskedNumber,
    this.fullNumber,
    required this.type,
    required this.bank,
    required this.category,
    required this.balance,
    this.currency = 'KWD',
    this.transactions = const [],
    this.spendingLimit,
    this.usedAmount,
    this.notificationsEnabled = true,
  });

  Account copyWith({
    String? id,
    String? name,
    String? maskedNumber,
    String? fullNumber,
    AccountType? type,
    Bank? bank,
    BankCategory? category,
    double? balance,
    String? currency,
    List<Transaction>? transactions,
    double? spendingLimit,
    double? usedAmount,
    bool? notificationsEnabled,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      fullNumber: fullNumber ?? this.fullNumber,
      type: type ?? this.type,
      bank: bank ?? this.bank,
      category: category ?? this.category,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      transactions: transactions ?? this.transactions,
      spendingLimit: spendingLimit ?? this.spendingLimit,
      usedAmount: usedAmount ?? this.usedAmount,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  double get availableBalance {
    if (type == AccountType.credit) {
      return spendingLimit! - usedAmount!;
    }
    return balance;
  }

  /// Calculate the current balance based on transactions
  double get calculatedBalance {
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get progressPercentage {
    if (spendingLimit == null || spendingLimit == 0) return 0;
    return (usedAmount ?? 0) / spendingLimit!;
  }

  bool get isChild => type == AccountType.child;
  bool get isCredit => type == AccountType.credit;
  bool get isBank => type == AccountType.bank;

  /// Returns the masked number to display
  String get displayMaskedNumber {
    if (fullNumber != null && fullNumber!.isNotEmpty) {
      return Account.maskAccountNumber(fullNumber!);
    }
    return maskedNumber;
  }

  /// Masking logic:
  /// - If length < 16: mask all but last 4 (stars count = len-4)
  /// - If length >= 16: show first 4, mask middle, show last 4
  static String maskAccountNumber(String digitsOnly) {
    final raw = digitsOnly.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return '****';
    if (raw.length < 4) return '*' * raw.length;
    if (raw.length < 16) {
      final starCount = raw.length - 4;
      return '${'*' * starCount}${raw.substring(raw.length - 4)}';
    }
    final first4 = raw.substring(0, 4);
    final last4 = raw.substring(raw.length - 4);
    final middleStars = '*' * (raw.length - 8);
    return '$first4$middleStars$last4';
  }

  /// Returns a human-friendly bank name
  String get bankDisplayName {
    switch (bank) {
      case Bank.nbk:
        return 'NBK';
      case Bank.kfh:
        return 'KFH';
      case Bank.gulfBank:
        return 'Gulf Bank';
      case Bank.cbk:
        return 'CBK';
      case Bank.abk:
        return 'ABK';
      case Bank.burgan:
        return 'Burgan Bank';
      case Bank.kib:
        return 'KIB';
      case Bank.boubyan:
        return 'Boubyan Bank';
      case Bank.warba:
        return 'Warba Bank';
      case Bank.weyay:
        return 'Weyay';
      case Bank.tam:
        return 'tam';
    }
  }

  /// Returns the full bank name in English
  String get bankFullName {
    switch (bank) {
      case Bank.nbk:
        return 'National Bank of Kuwait';
      case Bank.kfh:
        return 'Kuwait Finance House';
      case Bank.gulfBank:
        return 'Gulf Bank';
      case Bank.cbk:
        return 'Commercial Bank of Kuwait';
      case Bank.abk:
        return 'Al Ahli Bank of Kuwait';
      case Bank.burgan:
        return 'Burgan Bank';
      case Bank.kib:
        return 'Kuwait International Bank';
      case Bank.boubyan:
        return 'Boubyan Bank';
      case Bank.warba:
        return 'Warba Bank';
      case Bank.weyay:
        return 'Weyay Bank';
      case Bank.tam:
        return 'tam Bank';
    }
  }

  /// Returns the bank name in Arabic
  String get bankNameArabic {
    switch (bank) {
      case Bank.nbk:
        return 'البنك الوطني الكويتي';
      case Bank.kfh:
        return 'بيت التمويل الكويتي';
      case Bank.gulfBank:
        return 'بنك الخليج';
      case Bank.cbk:
        return 'البنك التجاري الكويتي';
      case Bank.abk:
        return 'البنك الأهلي الكويتي';
      case Bank.burgan:
        return 'بنك برقان';
      case Bank.kib:
        return 'البنك الكويتي الدولي';
      case Bank.boubyan:
        return 'بنك بوبيان';
      case Bank.warba:
        return 'بنك وربة';
      case Bank.weyay:
        return 'بنك وياي';
      case Bank.tam:
        return 'بنك تم';
    }
  }

  /// Returns the bank display name with abbreviation for English
  String get bankDisplayNameWithAbbreviation {
    switch (bank) {
      case Bank.nbk:
        return 'National Bank of Kuwait (NBK)';
      case Bank.kfh:
        return 'Kuwait Finance House (KFH)';
      case Bank.gulfBank:
        return 'Gulf Bank';
      case Bank.cbk:
        return 'Commercial Bank of Kuwait (CBK)';
      case Bank.abk:
        return 'Al Ahli Bank of Kuwait (ABK)';
      case Bank.burgan:
        return 'Burgan Bank';
      case Bank.kib:
        return 'Kuwait International Bank (KIB)';
      case Bank.boubyan:
        return 'Boubyan Bank';
      case Bank.warba:
        return 'Warba Bank';
      case Bank.weyay:
        return 'Weyay Bank';
      case Bank.tam:
        return 'tam Bank';
    }
  }

  /// Returns the bank display name with English abbreviation for Arabic
  String get bankDisplayNameArabicWithAbbreviation {
    switch (bank) {
      case Bank.nbk:
        return 'البنك الوطني الكويتي (NBK)';
      case Bank.kfh:
        return 'بيت التمويل الكويتي (KFH)';
      case Bank.gulfBank:
        return 'بنك الخليج';
      case Bank.cbk:
        return 'البنك التجاري الكويتي (CBK)';
      case Bank.abk:
        return 'البنك الأهلي الكويتي (ABK)';
      case Bank.burgan:
        return 'بنك برقان';
      case Bank.kib:
        return 'البنك الكويتي الدولي (KIB)';
      case Bank.boubyan:
        return 'بنك بوبيان';
      case Bank.warba:
        return 'بنك وربة';
      case Bank.weyay:
        return 'بنك وياي';
      case Bank.tam:
        return 'بنك تم';
    }
  }

  /// Returns bank logo URL (for network images only)
  String get bankLogoUrl {
    // All banks now have local assets, so no network URLs needed
    return '';
  }

  /// Returns the appropriate ImageProvider for the bank logo
  ImageProvider get bankLogoProvider {
    if (hasLocalAsset) {
      switch (bank) {
        case Bank.kfh:
          return const AssetImage('assets/images/KFH Logo.webp');
        case Bank.cbk:
          return const AssetImage('assets/images/CBK Square Logo.png');
        case Bank.tam:
          return const AssetImage('assets/images/Tam.png');
        case Bank.nbk:
          return const AssetImage('assets/images/NBK.jpg');
        case Bank.gulfBank:
          return const AssetImage('assets/images/Gulf Bank.png');
        case Bank.abk:
          return const AssetImage('assets/images/ABK.png');
        case Bank.burgan:
          return const AssetImage('assets/images/Burgan.png');
        case Bank.kib:
          return const AssetImage('assets/images/KIB Bank Logo.jpg');
        case Bank.boubyan:
          return const AssetImage('assets/images/Boubyan.jpg');
        case Bank.warba:
          return const AssetImage('assets/images/warba.png');
        case Bank.weyay:
          return const AssetImage('assets/images/weyay.webp');
      }
    }
    // For network images
    return NetworkImage(bankLogoUrl);
  }

  /// Returns true if the bank has a local asset image
  bool get hasLocalAsset {
    return bank == Bank.kfh || 
           bank == Bank.cbk || 
           bank == Bank.tam || 
           bank == Bank.nbk || 
           bank == Bank.gulfBank ||
           bank == Bank.abk ||
           bank == Bank.burgan ||
           bank == Bank.kib ||
           bank == Bank.boubyan ||
           bank == Bank.warba ||
           bank == Bank.weyay;
  }

  /// Returns a reliable image provider that falls back to initials if network fails
  ImageProvider get reliableBankLogoProvider {
    // All banks now have local assets
    return bankLogoProvider;
  }

  /// Returns a fallback widget when bank logo fails to load
  Widget get bankLogoFallback {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: _getBankColor(bank),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          _getBankInitials(bank),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Get bank color for fallback logo
  Color _getBankColor(Bank bank) {
    switch (bank) {
      case Bank.nbk:
        return const Color(0xFF1E3A8A); // Blue
      case Bank.kfh:
        return const Color(0xFF059669); // Green
      case Bank.gulfBank:
        return const Color(0xFFDC2626); // Red
      case Bank.cbk:
        return const Color(0xFF7C3AED); // Purple
      case Bank.abk:
        return const Color(0xFFEA580C); // Orange
      case Bank.burgan:
        return const Color(0xFF0891B2); // Cyan
      case Bank.kib:
        return const Color(0xFFBE185D); // Pink
      case Bank.boubyan:
        return const Color(0xFF16A34A); // Green
      case Bank.warba:
        return const Color(0xFFCA8A04); // Yellow
      case Bank.weyay:
        return const Color(0xFF9333EA); // Purple
      case Bank.tam:
        return const Color(0xFFEF4444); // Red
    }
  }

  /// Get bank initials for fallback logo
  String _getBankInitials(Bank bank) {
    switch (bank) {
      case Bank.nbk:
        return 'NBK';
      case Bank.kfh:
        return 'KFH';
      case Bank.gulfBank:
        return 'GB';
      case Bank.cbk:
        return 'CBK';
      case Bank.abk:
        return 'ABK';
      case Bank.burgan:
        return 'BG';
      case Bank.kib:
        return 'KIB';
      case Bank.boubyan:
        return 'BB';
      case Bank.warba:
        return 'WB';
      case Bank.weyay:
        return 'WY';
      case Bank.tam:
        return 'TM';
    }
  }

  /// Defensive accessors to tolerate legacy/null instances at runtime
  String get safeBankLogoUrl {
    try {
      return bankLogoUrl;
    } catch (_) {
      final fb = _fallbackBankById(id);
      return Account(bank: fb, id: id, name: name, maskedNumber: maskedNumber, type: type, category: BankCategory.currentSalary, balance: balance).bankLogoUrl;
    }
  }

  String get safeBankDisplayName {
    try {
      return bankDisplayName;
    } catch (_) {
      final fb = _fallbackBankById(id);
      switch (fb) {
        case Bank.nbk:
          return 'NBK';
        case Bank.kfh:
          return 'KFH';
        case Bank.gulfBank:
          return 'Gulf Bank';
        case Bank.cbk:
          return 'CBK';
        case Bank.abk:
          return 'ABK';
        case Bank.burgan:
          return 'Burgan Bank';
        case Bank.kib:
          return 'KIB';
        case Bank.boubyan:
          return 'Boubyan Bank';
        case Bank.warba:
          return 'Warba Bank';
        case Bank.weyay:
          return 'Weyay';
        case Bank.tam:
          return 'tam';
      }
    }
  }

  /// Returns the appropriate bank display name based on language setting
  String getBankDisplayNameForLanguage(bool isArabic) {
    if (isArabic) {
      return bankDisplayNameArabicWithAbbreviation;
    } else {
      return bankDisplayNameWithAbbreviation;
    }
  }

  String get safeCategoryDisplayName {
    try {
      return categoryDisplayName;
    } catch (_) {
      return 'Current / Salary';
    }
  }

  /// Returns a safe localized category display name
  String getSafeCategoryDisplayNameForLanguage(bool isArabic) {
    try {
      return getCategoryDisplayNameForLanguage(isArabic);
    } catch (_) {
      return isArabic ? 'حساب جاري / راتب' : 'Current / Salary';
    }
  }

  // Fallback mapping to distribute banks for legacy accounts without bank data
  Bank _fallbackBankById(String id) {
    final index = id.hashCode.abs() % Bank.values.length;
    return Bank.values[index];
  }

  // Fallback category based on generic account type
  BankCategory _fallbackCategoryByType(AccountType t) {
    switch (t) {
      case AccountType.credit:
        return BankCategory.creditCards;
      case AccountType.child:
        return BankCategory.kids;
      case AccountType.bank:
        return BankCategory.currentSalary;
    }
  }

  // Safe accessors for bank/category for legacy objects
  Bank get safeBank {
    try {
      return bank;
    } catch (_) {
      return _fallbackBankById(id);
    }
  }

  BankCategory get safeCategory {
    try {
      return category;
    } catch (_) {
      return _fallbackCategoryByType(type);
    }
  }

  /// Returns a human-friendly category label
  String get categoryDisplayName {
    switch (category) {
      case BankCategory.currentSalary:
        return 'Current / Salary';
      case BankCategory.savings:
        return 'Savings';
      case BankCategory.kids:
        return 'Kids';
      case BankCategory.youth:
        return 'Youth';
      case BankCategory.creditCards:
        return 'Credit Cards';
    }
  }

  /// Returns a localized category label based on language
  String getCategoryDisplayNameForLanguage(bool isArabic) {
    if (isArabic) {
      switch (category) {
        case BankCategory.currentSalary:
          return 'حساب جاري / راتب';
        case BankCategory.savings:
          return 'حساب توفير';
        case BankCategory.kids:
          return 'حساب أطفال';
        case BankCategory.youth:
          return 'حساب شباب';
        case BankCategory.creditCards:
          return 'بطاقات ائتمان';
      }
    } else {
      return categoryDisplayName;
    }
  }

  /// Helper to infer AccountType from selected bank category
  static AccountType inferTypeFromCategory(BankCategory category) {
    switch (category) {
      case BankCategory.creditCards:
        return AccountType.credit;
      case BankCategory.kids:
        return AccountType.child;
      case BankCategory.currentSalary:
      case BankCategory.savings:
      case BankCategory.youth:
        return AccountType.bank;
    }
  }

  /// Returns localized product name based on language
  String getProductNameForLanguage(bool isArabic) {
    if (isArabic) {
      return _getArabicProductName();
    } else {
      return productName;
    }
  }

  /// Bank-specific product name shown in badges and details (uses safe fallbacks)
  String get productName {
    final b = safeBank;
    final c = safeCategory;
    switch (b) {
      case Bank.weyay:
        switch (c) {
          case BankCategory.kids:
            return 'Jeel';
          case BankCategory.savings:
            return 'Saving Pots';
          case BankCategory.currentSalary:
          case BankCategory.youth:
            return 'Weyay Account';
          case BankCategory.creditCards:
            return 'Debit/Virtual Card';
        }
      case Bank.tam:
        switch (c) {
          case BankCategory.currentSalary:
          case BankCategory.youth:
            return 'tam Account';
          case BankCategory.savings:
            return 'Profit-Earning Savings';
          case BankCategory.kids:
            return 'Kids';
          case BankCategory.creditCards:
            return 'Prepaid / Virtual';
        }
      case Bank.nbk:
        switch (c) {
          case BankCategory.currentSalary:
            return 'Current Account';
          case BankCategory.savings:
            return 'Savings / Super Account';
          case BankCategory.kids:
            return 'Zeina';
          case BankCategory.youth:
            return 'Al Shabab';
          case BankCategory.creditCards:
            return 'Credit Cards';
        }
      case Bank.kfh:
        switch (c) {
          case BankCategory.currentSalary:
            return 'Current Account';
          case BankCategory.savings:
            return 'Saving (Mudaraba)';
          case BankCategory.kids:
            return 'Baiti';
          case BankCategory.youth:
            return 'Hesabi';
          case BankCategory.creditCards:
            return 'Credit Cards';
        }
      case Bank.gulfBank:
        switch (c) {
          case BankCategory.currentSalary:
            return 'Current Account';
          case BankCategory.savings:
            return 'e-Savings / Gulf Savings';
          case BankCategory.kids:
            return 'neo';
          case BankCategory.youth:
            return 'red.';
          case BankCategory.creditCards:
            return 'Cards';
        }
      case Bank.cbk:
        switch (c) {
          case BankCategory.currentSalary:
            return 'Current Account';
          case BankCategory.savings:
            return 'Salary / Base';
          case BankCategory.kids:
            return 'My First Account';
          case BankCategory.youth:
            return 'YOU';
          case BankCategory.creditCards:
            return 'Visa / Mastercard';
        }
      case Bank.abk:
        switch (c) {
          case BankCategory.savings:
            return 'Savings / Daily Interest';
          case BankCategory.kids:
            return 'ABK Heroes';
          case BankCategory.currentSalary:
            return 'Account';
          case BankCategory.youth:
            return 'Youth';
          case BankCategory.creditCards:
            return 'Cards';
        }
      case Bank.burgan:
        switch (c) {
          case BankCategory.currentSalary:
            return 'Current Accounts';
          case BankCategory.savings:
            return 'Kanz / Savings';
          default:
            return 'Account';
        }
      case Bank.kib:
        switch (c) {
          case BankCategory.currentSalary:
            return 'Current / Salary';
          case BankCategory.savings:
            return 'Al Dirwaza';
          case BankCategory.kids:
            return 'Kids';
          case BankCategory.youth:
            return 'Youth';
          case BankCategory.creditCards:
            return 'Cards';
        }
      case Bank.boubyan:
        switch (c) {
          case BankCategory.currentSalary:
            return 'Account';
          case BankCategory.savings:
            return 'Savings';
          case BankCategory.kids:
            return 'Al Ghaly';
          case BankCategory.youth:
            return 'PRIME';
          case BankCategory.creditCards:
            return 'Cards';
        }
      case Bank.warba:
        switch (c) {
          case BankCategory.savings:
            return 'Al Sunbula';
          case BankCategory.kids:
            return 'Al Sunbula Kids';
          case BankCategory.youth:
            return 'Wave / Bloom';
          default:
            return 'Account';
        }
    }
  }

  /// Returns Arabic product name for the bank and category
  String _getArabicProductName() {
    final b = safeBank;
    final c = safeCategory;
    switch (b) {
      case Bank.weyay:
        switch (c) {
          case BankCategory.kids:
            return 'جيل';
          case BankCategory.savings:
            return 'حساب وياي توفير';
          case BankCategory.currentSalary:
          case BankCategory.youth:
            return 'حساب وياي';
          case BankCategory.creditCards:
            return 'بطاقة مدفوعة / افتراضية';
        }
      case Bank.tam:
        switch (c) {
          case BankCategory.currentSalary:
          case BankCategory.youth:
            return 'حساب تم';
          case BankCategory.savings:
            return 'توفير مربح';
          case BankCategory.kids:
            return 'أطفال';
          case BankCategory.creditCards:
            return 'مدفوعة مسبقاً / افتراضية';
        }
      case Bank.nbk:
        switch (c) {
          case BankCategory.currentSalary:
            return 'حساب جاري';
          case BankCategory.savings:
            return 'توفير / سوبر';
          case BankCategory.kids:
            return 'زينة';
          case BankCategory.youth:
            return 'الشباب';
          case BankCategory.creditCards:
            return 'بطاقات ائتمان';
        }
      case Bank.kfh:
        switch (c) {
          case BankCategory.currentSalary:
            return 'حساب جاري';
          case BankCategory.savings:
            return 'توفير (مضاربة)';
          case BankCategory.kids:
            return 'بيتي';
          case BankCategory.youth:
            return 'حسابي';
          case BankCategory.creditCards:
            return 'بطاقات ائتمان';
        }
      case Bank.gulfBank:
        switch (c) {
          case BankCategory.currentSalary:
            return 'حساب جاري';
          case BankCategory.savings:
            return 'توفير إلكتروني / توفير الخليج';
          case BankCategory.kids:
            return 'نيو';
          case BankCategory.youth:
            return 'ريد';
          case BankCategory.creditCards:
            return 'بطاقات';
        }
      case Bank.cbk:
        switch (c) {
          case BankCategory.currentSalary:
            return 'حساب جاري';
          case BankCategory.savings:
            return 'راتب / أساسي';
          case BankCategory.kids:
            return 'حسابي الأول';
          case BankCategory.youth:
            return 'يو';
          case BankCategory.creditCards:
            return 'فيزا / ماستركارد';
        }
      case Bank.abk:
        switch (c) {
          case BankCategory.savings:
            return 'توفير / فائدة يومية';
          case BankCategory.kids:
            return 'أبطال الأهلي';
          case BankCategory.currentSalary:
            return 'حساب';
          case BankCategory.youth:
            return 'شباب';
          case BankCategory.creditCards:
            return 'بطاقات';
        }
      case Bank.burgan:
        switch (c) {
          case BankCategory.currentSalary:
            return 'حسابات جارية';
          case BankCategory.savings:
            return 'كنز / توفير';
          default:
            return 'حساب';
        }
      case Bank.kib:
        switch (c) {
          case BankCategory.currentSalary:
            return 'جاري / راتب';
          case BankCategory.savings:
            return 'الدروازة';
          case BankCategory.kids:
            return 'أطفال';
          case BankCategory.youth:
            return 'شباب';
          case BankCategory.creditCards:
            return 'بطاقات';
        }
      case Bank.boubyan:
        switch (c) {
          case BankCategory.currentSalary:
            return 'حساب';
          case BankCategory.savings:
            return 'توفير';
          case BankCategory.kids:
            return 'الغالي';
          case BankCategory.youth:
            return 'بريم';
          case BankCategory.creditCards:
            return 'بطاقات';
        }
      case Bank.warba:
        switch (c) {
          case BankCategory.savings:
            return 'السنبلة';
          case BankCategory.kids:
            return 'السنبلة أطفال';
          case BankCategory.youth:
            return 'موجة / بلوم';
          default:
            return 'حساب';
        }
    }
  }
}
