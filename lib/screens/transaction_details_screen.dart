import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/currency_text.dart';
import '../widgets/navigation_drawer.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final account = appState.getAccountById(transaction.accountId);
        
        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(appState.getLocalizedString('transactionDetails')),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Summary Card
                _buildTransactionSummary(context, appState),
                const SizedBox(height: 24),
                
                // Transaction Details
                _buildTransactionDetails(context, appState, account),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionSummary(BuildContext context, AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Category Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getCategoryColor(transaction.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: _getCategoryColor(transaction.category),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            
            // Amount
            CurrencyText(
              amount: transaction.amount,
              showSign: true,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Transaction Title
            Text(
              _getTransactionTitle(transaction, appState.isArabic),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getCategoryColor(transaction.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getCategoryColor(transaction.category).withOpacity(0.3),
                ),
              ),
              child: Text(
                _getCategoryName(transaction.category, appState.isArabic),
                style: TextStyle(
                  color: _getCategoryColor(transaction.category),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetails(BuildContext context, AppState appState, Account? account) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appState.getLocalizedString('transactionDetails'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Date and Time
            _buildDetailRow(
              context,
              appState.getLocalizedString('dateTime'),
              _formatDateTime(transaction.dateTime, appState),
              Icons.schedule,
            ),
            const SizedBox(height: 16),
            
            // Account
            if (account != null)
              _buildDetailRow(
                context,
                appState.getLocalizedString('account'),
                '${account.name} (${account.maskedNumber})',
                Icons.account_balance_wallet,
              ),
            const SizedBox(height: 16),
            
            // Transaction Type
            _buildDetailRow(
              context,
              appState.getLocalizedString('type'),
              transaction.isIncome ? appState.getLocalizedString('income') : appState.getLocalizedString('expense'),
              transaction.isIncome ? Icons.trending_up : Icons.trending_down,
            ),
            const SizedBox(height: 16),
            
            // Description (optional)
            if (_extractUserDescription(transaction) != null) ...[
              _buildDetailRow(
                context,
                appState.getLocalizedString('description'),
                _extractUserDescription(transaction)!,
                Icons.description,
              ),
              const SizedBox(height: 16),
            ],
            
            // Transaction ID
            _buildDetailRow(
              context,
              appState.getLocalizedString('transactionId'),
              transaction.id,
              Icons.receipt,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return AppColors.warning;
      case TransactionCategory.transportation:
        return AppColors.info;
      case TransactionCategory.shopping:
        return AppColors.primaryBlue;
      case TransactionCategory.entertainment:
        return AppColors.success;
      case TransactionCategory.utilities:
        return AppColors.error;
      case TransactionCategory.healthcare:
        return Colors.purple;
      case TransactionCategory.education:
        return Colors.teal;
      case TransactionCategory.travel:
        return Colors.orange;
      case TransactionCategory.salary:
        return AppColors.success;
      case TransactionCategory.transfer:
        return AppColors.primaryBlue;
      case TransactionCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transportation:
        return Icons.directions_car;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.utilities:
        return Icons.electric_bolt;
      case TransactionCategory.healthcare:
        return Icons.medical_services;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.travel:
        return Icons.flight;
      case TransactionCategory.salary:
        return Icons.work;
      case TransactionCategory.transfer:
        return Icons.swap_horiz;
      case TransactionCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getCategoryName(TransactionCategory category, bool isArabic) {
    switch (category) {
      case TransactionCategory.food:
        return isArabic ? AppStrings.foodAr : AppStrings.food;
      case TransactionCategory.transportation:
        return isArabic ? AppStrings.transportationAr : AppStrings.transportation;
      case TransactionCategory.shopping:
        return isArabic ? AppStrings.shoppingAr : AppStrings.shopping;
      case TransactionCategory.entertainment:
        return isArabic ? AppStrings.entertainmentAr : AppStrings.entertainment;
      case TransactionCategory.utilities:
        return isArabic ? AppStrings.utilitiesAr : AppStrings.utilities;
      case TransactionCategory.healthcare:
        return isArabic ? AppStrings.healthcareAr : AppStrings.healthcare;
      case TransactionCategory.education:
        return isArabic ? AppStrings.educationAr : AppStrings.education;
      case TransactionCategory.travel:
        return isArabic ? AppStrings.travelAr : AppStrings.travel;
      case TransactionCategory.salary:
        return isArabic ? AppStrings.salaryAr : AppStrings.salary;
      case TransactionCategory.transfer:
        return isArabic ? AppStrings.transferCategoryAr : AppStrings.transferCategory;
      case TransactionCategory.other:
        return isArabic ? AppStrings.otherAr : AppStrings.other;
    }
  }

  String _getTransactionTitle(Transaction transaction, bool isArabic) {
    switch (transaction.category) {
      case TransactionCategory.transfer:
        // For transfers, show a clean title without the description
        return isArabic ? AppStrings.transferCategoryAr : AppStrings.transferCategory;
      case TransactionCategory.salary:
        return isArabic ? AppStrings.salaryDepositAr : AppStrings.salaryDeposit;
      case TransactionCategory.food:
        return isArabic ? AppStrings.foodPurchaseAr : AppStrings.foodPurchase;
      case TransactionCategory.transportation:
        return isArabic ? AppStrings.transportationExpenseAr : AppStrings.transportationExpense;
      case TransactionCategory.shopping:
        return isArabic ? AppStrings.shoppingAr : AppStrings.shopping;
      case TransactionCategory.entertainment:
        return isArabic ? AppStrings.entertainmentAr : AppStrings.entertainment;
      case TransactionCategory.utilities:
        return isArabic ? AppStrings.utilitiesBillAr : AppStrings.utilitiesBill;
      case TransactionCategory.healthcare:
        return isArabic ? AppStrings.healthcareAr : AppStrings.healthcare;
      case TransactionCategory.education:
        return isArabic ? AppStrings.educationAr : AppStrings.education;
      case TransactionCategory.travel:
        return isArabic ? AppStrings.travelAr : AppStrings.travel;
      case TransactionCategory.other:
        return isArabic ? AppStrings.otherTransactionAr : AppStrings.otherTransaction;
    }
  }

  String? _extractUserDescription(Transaction transaction) {
    // For transfer transactions, extract the user description if present
    if (transaction.category == TransactionCategory.transfer) {
      final description = transaction.description;
      if (description.contains(': ')) {
        final parts = description.split(': ');
        if (parts.length > 1) {
          return parts.sublist(1).join(': '); // Join in case description contains colons
        }
      }
      return null; // No user description found
    }
    
    // For non-transfer transactions, return the full description
    return transaction.description;
  }

  String _formatDateTime(DateTime dateTime, AppState appState) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    String dateString;
    if (difference.inDays == 0) {
      dateString = appState.getLocalizedString('today');
    } else if (difference.inDays == 1) {
      dateString = appState.getLocalizedString('yesterday');
    } else if (difference.inDays < 7) {
      dateString = '${difference.inDays} ${appState.getLocalizedString('daysAgo')}';
    } else {
      dateString = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeString = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateString at $timeString';
  }
}
