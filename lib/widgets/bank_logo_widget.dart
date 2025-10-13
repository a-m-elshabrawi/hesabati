import 'package:flutter/material.dart';
import '../models/account.dart';

class BankLogoWidget extends StatelessWidget {
  final Bank bank;
  final double radius;

  const BankLogoWidget({
    super.key,
    required this.bank,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    // Create a temporary account to get the logo provider
    final tempAccount = Account(
      id: 'temp',
      name: 'temp',
      maskedNumber: 'temp',
      type: AccountType.bank,
      bank: bank,
      category: BankCategory.currentSalary,
      balance: 0.0,
    );

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Image(
          image: tempAccount.bankLogoProvider,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Return fallback widget when image fails to load
            return Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                color: _getBankColor(bank),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Center(
                child: Text(
                  _getBankInitials(bank),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
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
}
