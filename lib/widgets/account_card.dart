import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import 'currency_text.dart';
import 'bank_logo_widget.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final bool showProgress;
  final VoidCallback? onLongPress;
  final bool isHomeScreen;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.showProgress = false,
    this.onLongPress,
    this.isHomeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isArabic = appState.isArabic;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BankLogoWidget(
                        bank: account.bank,
                        radius: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    account.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (appState.mainAccountId == account.id) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              account.displayMaskedNumber,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isHomeScreen)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getAccountTypeColor(account.type),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getAccountTypeText(account.type, isArabic),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.getLocalizedString('totalBalance'),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          CurrencyText(
                            amount: account.balance,
                            showSign: account.type == AccountType.credit && account.balance < 0,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      if (account.type == AccountType.credit || account.type == AccountType.child)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              appState.getLocalizedString('spendingLimit'),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            CurrencyText(
                              amount: account.spendingLimit ?? 0,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (isHomeScreen) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getAccountTypeColor(account.type),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getAccountTypeText(account.type, isArabic),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (showProgress && (account.type == AccountType.credit || account.type == AccountType.child))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              appState.getLocalizedString('usedAmount'),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            CurrencyText(
                              amount: account.usedAmount ?? 0,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: account.progressPercentage.clamp(0.0, 1.0),
                          backgroundColor: AppColors.progressBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            account.progressPercentage > 0.8 
                                ? AppColors.warning 
                                : AppColors.progressFill,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return AppColors.primaryBlue;
      case AccountType.credit:
        return AppColors.warning;
      case AccountType.child:
        return AppColors.success;
    }
  }

  String _getAccountTypeText(AccountType type, bool isArabic) {
    switch (type) {
      case AccountType.bank:
        return isArabic ? 'حساب جاري' : 'Bank Account';
      case AccountType.credit:
        return isArabic ? 'بطاقة ائتمان' : 'Credit Card';
      case AccountType.child:
        return isArabic ? 'بطاقة طفل' : 'Child Card';
    }
  }

  
}
