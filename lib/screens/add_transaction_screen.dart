import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/currency_text.dart';
import '../widgets/navigation_drawer.dart';

class AddTransactionScreen extends StatefulWidget {
  final String accountId;

  const AddTransactionScreen({super.key, required this.accountId});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TransactionCategory? _selectedCategory;
  bool _categoryButtonPressed = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addTransaction() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() {
        _categoryButtonPressed = true;
      });
      return;
    }

    final appState = context.read<AppState>();
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      description: _descriptionController.text.trim(),
      amount: amount,
      category: _selectedCategory!,
      accountId: widget.accountId,
    );

    appState.createTransaction(transaction);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appState.getLocalizedString('transactionAddedSuccessfully')),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final account = appState.getAccountById(widget.accountId);
        if (account == null) {
          Navigator.pop(context);
          return const SizedBox.shrink();
        }

        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(appState.getLocalizedString('addTransaction')),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.getLocalizedString('accountInformation'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      account.maskedNumber,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CurrencyText(
                                amount: account.balance,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transaction Category
                  Text(
                    appState.getLocalizedString('transactionCategory'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCategorySelector(context, appState),
                  const SizedBox(height: 24),

                  // Amount
                  Text(
                    appState.getLocalizedString('amount'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: appState.getLocalizedString('enterAmount'),
                      prefixIcon: const Icon(Icons.attach_money),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return appState.getLocalizedString('pleaseEnterAmount');
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return appState.getLocalizedString('pleaseEnterValidAmount');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    appState.getLocalizedString('transactionDescription'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: appState.getLocalizedString('description'),
                      prefixIcon: const Icon(Icons.description),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Add Transaction Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        appState.getLocalizedString('addTransaction'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector(BuildContext context, AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: _categoryButtonPressed && _selectedCategory == null
              ? AppColors.error
              : Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _categoryButtonPressed = true;
          });
          _showCategoryDialog(context, appState);
        },
        child: Row(
          children: [
            Icon(
              Icons.category,
              color: _selectedCategory != null
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedCategory != null
                    ? _getCategoryName(_selectedCategory!, appState.isArabic)
                    : (_categoryButtonPressed && _selectedCategory == null
                        ? appState.getLocalizedString('pleaseSelectCategory')
                        : appState.getLocalizedString('selectTransactionCategory')),
                style: TextStyle(
                  color: _selectedCategory != null
                      ? Theme.of(context).colorScheme.onSurface
                      : (_categoryButtonPressed && _selectedCategory == null
                          ? AppColors.error
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.getLocalizedString('selectTransactionCategory')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: TransactionCategory.values.map((category) {
              return ListTile(
                leading: Icon(
                  _getCategoryIcon(category),
                  color: _getCategoryColor(category),
                ),
                title: Text(_getCategoryName(category, appState.isArabic)),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
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
}