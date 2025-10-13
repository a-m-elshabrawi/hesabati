import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/currency_text.dart';
import '../widgets/bank_logo_widget.dart';
import '../widgets/navigation_drawer.dart';
import '../utils/number_formatter.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final spendingByCategory = appState.getSpendingByCategory();
        final totalSpent = spendingByCategory.values.fold(0.0, (sum, amount) => sum + amount);
        final totalIncome = appState.getIncomeByCategory().values.fold(0.0, (sum, amount) => sum + amount);
        final monthlySpending = appState.getMonthlySpending();
        final accountContributions = appState.getAccountSpendingContributions();
        
        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(appState.getLocalizedString('analytics')),
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
                // Summary Cards
                _buildSummaryCards(context, appState, totalSpent, totalIncome),
                const SizedBox(height: 24),
                
                // Monthly Spending Trend
                if (monthlySpending.isNotEmpty) ...[
                  _buildMonthlyTrend(context, appState, monthlySpending),
                  const SizedBox(height: 24),
                ],
                
                // Account Contributions
                if (accountContributions.isNotEmpty) ...[
                  _buildAccountContributions(context, appState, accountContributions, totalSpent),
                  const SizedBox(height: 24),
                ],
                
                // Spending by Category
                _buildSpendingByCategory(context, appState, spendingByCategory, totalSpent),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, AppState appState, double totalSpent, double totalIncome) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            appState,
            appState.getLocalizedString('totalSpent'),
            totalSpent,
            AppColors.error,
            Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            appState,
            appState.getLocalizedString('totalIncome'),
            totalIncome,
            AppColors.success,
            Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    AppState appState,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appState.formatCurrency(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrend(BuildContext context, AppState appState, Map<String, double> monthlySpending) {
    final months = monthlySpending.keys.toList()..sort();
    final maxAmount = monthlySpending.values.reduce((a, b) => a > b ? a : b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appState.getLocalizedString('monthlySpendingTrend'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: months.map((month) {
                  final amount = monthlySpending[month]!;
                  final height = maxAmount > 0 ? (amount / maxAmount) * 80 : 0.0;
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        appState.formatCurrency(amount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: height,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        month,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountContributions(
    BuildContext context,
    AppState appState,
    Map<String, double> accountContributions,
    double totalSpent,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appState.getLocalizedString('spendingByAccount'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...accountContributions.entries.map((entry) {
              final account = appState.getAccountById(entry.key);
              final amount = entry.value;
              final percentage = totalSpent > 0 ? (amount / totalSpent) * 100 : 0.0;
              
              if (account == null) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    BankLogoWidget(
                      bank: account.bank,
                      radius: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            NumberFormatter.formatPercentage(percentage, isArabic: appState.isArabic),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CurrencyText(
                      amount: amount,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingByCategory(
    BuildContext context, 
    AppState appState, 
    Map<TransactionCategory, double> spendingByCategory,
    double totalSpent,
  ) {
    if (spendingByCategory.isEmpty) {
      return _buildEmptyAnalytics(context, appState);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.getLocalizedString('spendingByCategory'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: spendingByCategory.length,
          itemBuilder: (context, index) {
            final category = spendingByCategory.keys.elementAt(index);
            final amount = spendingByCategory[category]!;
            final percentage = totalSpent > 0 ? (amount / totalSpent) * 100 : 0.0;
            
            return _buildCategoryItem(
              context, 
              appState, 
              category, 
              amount, 
              percentage.toDouble(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    AppState appState,
    TransactionCategory category,
    double amount,
    double percentage,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showCategoryDetails(context, appState, category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: _getCategoryColor(category),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Category Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCategoryName(category, appState.isArabic),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormatter.formatPercentage(percentage, isArabic: appState.isArabic)} ${appState.getLocalizedString('ofTotal')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Amount and Arrow
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CurrencyText(
                    amount: amount,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(BuildContext context, AppState appState, TransactionCategory category) {
    final categoryTransactions = appState.allTransactions
        .where((t) => t.category == category && t.isExpense)
        .toList();
    
    final accountContributions = <String, double>{};
    for (final transaction in categoryTransactions) {
      accountContributions[transaction.accountId] = 
          (accountContributions[transaction.accountId] ?? 0) + transaction.amount.abs();
    }
    
    final totalCategorySpending = categoryTransactions
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: _getCategoryColor(category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCategoryName(category, appState.isArabic),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CurrencyText(
                          amount: totalCategorySpending,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Account Contributions
              Text(
                appState.getLocalizedString('accountContributions'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: accountContributions.entries.map((entry) {
                    final account = appState.getAccountById(entry.key);
                    final amount = entry.value;
                    final percentage = totalCategorySpending > 0 
                        ? (amount / totalCategorySpending) * 100 
                        : 0.0;
                    
                    if (account == null) return const SizedBox.shrink();
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: BankLogoWidget(
                          bank: account.bank,
                          radius: 20,
                        ),
                        title: Text(account.name),
                        subtitle: Text(NumberFormatter.formatPercentage(percentage, isArabic: appState.isArabic)),
                        trailing: CurrencyText(
                          amount: amount,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAnalytics(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            appState.getLocalizedString('noSpendingData'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appState.getLocalizedString('startMakingTransactions'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
}
