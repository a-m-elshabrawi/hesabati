import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import '../widgets/currency_text.dart';
import '../widgets/bank_logo_widget.dart';
import '../widgets/navigation_drawer.dart';
import 'transaction_details_screen.dart';
import 'account_form_screen.dart';
import 'transfer_screen.dart';

class AccountDetailsScreen extends StatelessWidget {
  final Account account;

  const AccountDetailsScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final foundAccount = appState.getAccountById(account.id);
        if (foundAccount == null) {
          // If the account was deleted while this screen is open, go back automatically
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
          return const SizedBox.shrink();
        }
        final currentAccount = foundAccount;
        final transactions = appState.getTransactionsForAccount(currentAccount.id);
        
        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(currentAccount.name),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountFormScreen(account: currentAccount),
                    ),
                  );
                },
              ),
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
                // Account Summary Card
                _buildAccountSummary(context, appState, currentAccount),
                const SizedBox(height: 12),
                _buildMainAccountHint(context, appState, currentAccount),
                if (currentAccount.type == AccountType.credit && currentAccount.balance < 0) ...[
                  const SizedBox(height: 12),
                  _buildClearDebtButton(context, appState, currentAccount),
                ],
                const SizedBox(height: 24),
                
                // Transactions Section
                _buildTransactionsSection(context, appState, transactions),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountSummary(BuildContext context, AppState appState, Account account) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.displayMaskedNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          BankLogoWidget(
                            bank: account.bank,
                            radius: 14,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${account.getBankDisplayNameForLanguage(appState.isArabic)} • ${account.safeCategoryDisplayName}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getAccountTypeColor(account.type),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    account.productName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Balance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appState.getLocalizedString('totalBalance'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                CurrencyText(
                  amount: account.balance,
                  showSign: account.type == AccountType.credit && account.balance < 0,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            // Spending Limit and Used Amount (for credit and child cards)
            if (account.type == AccountType.credit || account.type == AccountType.child) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appState.getLocalizedString('spendingLimit'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  CurrencyText(
                    amount: account.spendingLimit ?? 0,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appState.getLocalizedString('usedAmount'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  CurrencyText(
                    amount: account.usedAmount ?? 0,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context, AppState appState, List<Transaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${transactions.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (transactions.isEmpty)
          _buildEmptyTransactions(context, appState)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionTile(context, appState, transaction);
            },
          ),
      ],
    );
  }

  Widget _buildMainAccountHint(BuildContext context, AppState appState, Account account) {
    final bool isMain = appState.mainAccountId == account.id;
    final String text = isMain
        ? 'This is your main account. Long press another account in the Accounts page to switch.'
        : 'Tip: Long press this account from the Accounts page to set it as your main account.';

    return Container
    (
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions(BuildContext context, AppState appState) {
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
            Icons.receipt_long_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transactions will appear here when you make transfers or add transactions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, AppState appState, Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getCategoryColor(transaction.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(transaction.category),
            color: _getCategoryColor(transaction.category),
            size: 20,
          ),
        ),
        title: Text(
          _getCleanTransactionTitle(transaction, appState.isArabic),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDate(transaction.dateTime),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: CurrencyText(
          amount: transaction.amount,
          showSign: true,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailsScreen(transaction: transaction),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClearDebtButton(BuildContext context, AppState appState, Account account) {
    final accountWithBalance = appState.findBestAccountForClearingDebt(account.id, account.balance.abs());

    if (accountWithBalance == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransferScreen(
                initialFromAccountId: accountWithBalance.id,
                initialToAccountId: account.id,
                initialAmount: account.balance.abs(),
                initialDescription: 'Clearing credit card debt.',
              ),
            ),
          );
        },
        icon: const Icon(Icons.payment),
        label: Text(appState.getLocalizedString('clearDebt')),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
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

  String _getCleanTransactionTitle(Transaction transaction, bool isArabic) {
    switch (transaction.category) {
      case TransactionCategory.transfer:
        // For transfers, show a clean title without the description
        return isArabic ? 'تحويل' : 'Transfer';
      case TransactionCategory.salary:
        return isArabic ? 'إيداع راتب' : 'Salary Deposit';
      case TransactionCategory.food:
        return isArabic ? 'مشتريات طعام' : 'Food Purchase';
      case TransactionCategory.transportation:
        return isArabic ? 'نفقات مواصلات' : 'Transportation';
      case TransactionCategory.shopping:
        return isArabic ? 'تسوق' : 'Shopping';
      case TransactionCategory.entertainment:
        return isArabic ? 'ترفيه' : 'Entertainment';
      case TransactionCategory.utilities:
        return isArabic ? 'فواتير مرافق' : 'Utilities';
      case TransactionCategory.healthcare:
        return isArabic ? 'رعاية صحية' : 'Healthcare';
      case TransactionCategory.education:
        return isArabic ? 'تعليم' : 'Education';
      case TransactionCategory.travel:
        return isArabic ? 'سفر' : 'Travel';
      case TransactionCategory.other:
        return isArabic ? 'معاملة أخرى' : 'Other Transaction';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
