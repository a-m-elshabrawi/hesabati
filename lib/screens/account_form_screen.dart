import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import '../widgets/bank_logo_widget.dart';
import '../widgets/navigation_drawer.dart';
import 'transfer_screen.dart';

class AccountFormScreen extends StatefulWidget {
  final Account? account; // null for new account, non-null for editing

  const AccountFormScreen({super.key, this.account});

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _spendingLimitController = TextEditingController();
  
  AccountType _selectedType = AccountType.bank;
  Bank? _selectedBank;
  BankCategory? _selectedCategory;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      // Editing existing account
      _nameController.text = widget.account!.name;
      _numberController.text = widget.account!.fullNumber ?? widget.account!.maskedNumber;
      _selectedType = widget.account!.type;
      // Defensive defaults for legacy accounts that may lack new fields
      try {
        _selectedBank = widget.account!.bank;
      } catch (_) {
        _selectedBank = _fallbackBankById(widget.account!.id);
      }
      try {
        _selectedCategory = widget.account!.category;
      } catch (_) {
        _selectedCategory = _inferCategoryFromType(widget.account!.type);
      }
      // For Weyay, avoid duplicate generic entries: prefer age-restricted Youth over Current
      if (_selectedBank == Bank.weyay && _selectedCategory == BankCategory.currentSalary) {
        _selectedCategory = BankCategory.youth;
        _selectedType = Account.inferTypeFromCategory(_selectedCategory!);
      }
      _notificationsEnabled = widget.account!.notificationsEnabled;
      if (widget.account!.spendingLimit != null) {
        _spendingLimitController.text = widget.account!.spendingLimit!.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _spendingLimitController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBank == null || _selectedCategory == null) return;

    final appState = context.read<AppState>();
    final accountId = widget.account?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    final rawNumber = _numberController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final masked = Account.maskAccountNumber(rawNumber);

    final account = Account(
      id: accountId,
      name: _nameController.text.trim(),
      maskedNumber: masked,
      fullNumber: rawNumber,
      type: Account.inferTypeFromCategory(_selectedCategory!),
      bank: _selectedBank!,
      category: _selectedCategory!,
      balance: widget.account?.balance ?? 0.0,
      spendingLimit: _selectedType == AccountType.credit || _selectedType == AccountType.child
          ? double.tryParse(_spendingLimitController.text) ?? 0.0
          : null,
      usedAmount: widget.account?.usedAmount ?? 0.0,
      notificationsEnabled: _notificationsEnabled,
      transactions: widget.account?.transactions ?? [],
    );

    if (widget.account != null) {
      appState.updateAccount(account);
    } else {
      appState.addAccount(account);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isEditing = widget.account != null;
        
        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(
              isEditing 
                  ? appState.getLocalizedString('editAccount')
                  : appState.getLocalizedString('addAccount'),
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _showDeleteDialog,
                ),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_selectedBank != null) ...[
                  Row(
                    children: [
                      BankLogoWidget(
                        bank: _selectedBank!,
                        radius: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _bankLabel(_selectedBank!, isArabic: appState.isArabic),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                // Account Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: appState.getLocalizedString('accountName'),
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return appState.getLocalizedString('pleaseEnterAccountName');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Account Number
                TextFormField(
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: appState.getLocalizedString('accountNumber'),
                    helperText: appState.getLocalizedString('digitsOnlyMinMax'),
                    prefixIcon: const Icon(Icons.credit_card),
                  ),
                  validator: (value) {
                    final raw = value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                    if (raw.isEmpty) {
                      return appState.getLocalizedString('pleaseEnterAccountNumber');
                    }
                    if (raw.length < 8 || raw.length > 24) {
                      return appState.getLocalizedString('pleaseEnterValidAccountNumber');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bank
                DropdownButtonFormField<Bank>(
                  value: _selectedBank,
                  decoration: InputDecoration(
                    labelText: appState.getLocalizedString('bank'),
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                  items: Bank.values
                      .map((b) => DropdownMenuItem(
                            value: b,
                            child: Text(
                              _bankLabel(b, isArabic: appState.isArabic),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBank = value;
                      _selectedCategory = null;
                      _selectedType = AccountType.bank;
                    });
                  },
                  validator: (value) => value == null ? appState.getLocalizedString('pleaseSelectBank') : null,
                ),
                const SizedBox(height: 16),

                // Account Category (dependent on bank)
                DropdownButtonFormField<BankCategory>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: appState.getLocalizedString('accountType'),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: _categoryOptionsForBank(_selectedBank)
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              _categoryDisplayFor(_selectedBank, c),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      if (value != null) {
                        _selectedType = Account.inferTypeFromCategory(value);
                      }
                    });
                  },
                  validator: (value) => value == null ? appState.getLocalizedString('pleaseSelectAccountType') : null,
                ),
                const SizedBox(height: 16),

                // Spending Limit (for credit and child cards)
                if (_selectedType == AccountType.credit || _selectedType == AccountType.child) ...[
                  TextFormField(
                    controller: _spendingLimitController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: appState.getLocalizedString('spendingLimit'),
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: appState.getLocalizedString('currency'),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return appState.getLocalizedString('pleaseEnterSpendingLimit');
                      }
                      final limit = double.tryParse(value);
                      if (limit == null || limit <= 0) {
                        return appState.getLocalizedString('pleaseEnterValidAmount');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Notifications (for child cards)
                if (_selectedType == AccountType.child) ...[
                  SwitchListTile(
                    title: Text(appState.getLocalizedString('notifications')),
                    subtitle: Text(appState.getLocalizedString('enableNotificationsForChildCard')),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeTrackColor: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                ],

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveAccount,
                    child: Text(
                      appState.getLocalizedString('save'),
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
        );
      },
    );
  }

  void _showDeleteDialog() {
    final appState = context.read<AppState>();
    
    if (appState.accounts.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.getLocalizedString('cannotDeleteLastAccount')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final account = widget.account!;
        
        // Check if account can be safely deleted
        if (appState.canSafelyDeleteAccount(account.id)) {
          return AlertDialog(
            title: Text(appState.getLocalizedString('deleteAccount')),
            content: Text(appState.getLocalizedString('deleteAccountConfirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(appState.getLocalizedString('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.deleteAccount(account.id);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close form screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: Text(appState.getLocalizedString('deleteAccount')),
              ),
            ],
          );
        }
        
        // Check if account has debt that needs to be cleared
        if (appState.hasDebtToClear(account.id)) {
          final accountWithBalance = appState.findBestAccountForClearingDebt(account.id, account.balance.abs());
          
          return AlertDialog(
            title: Text(appState.getLocalizedString('deleteAccount')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${appState.getLocalizedString('creditCardHasDebt')} ${appState.formatCurrency(account.balance.abs())}.'),
                const SizedBox(height: 8),
                Text(appState.getLocalizedString('debtBeforeDeletion')),
                if (accountWithBalance != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${appState.getLocalizedString('fromAccount')}: ${accountWithBalance.name}')),
                    ],
                  ),
                ],
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(appState.getLocalizedString('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  // Navigate to TransferScreen with prefilled values to clear debt
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransferScreen(
                        initialFromAccountId: accountWithBalance?.id,
                        initialToAccountId: account.id,
                        initialAmount: account.balance.abs(),
                        initialDescription: appState.getLocalizedString('clearingCreditCardDebt'),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                child: Text(appState.getLocalizedString('clearDebt')),
              ),
            ],
          );
        }
        
        // Check if account has positive balance that should be transferred
        if (appState.hasBalanceToTransfer(account.id)) {
          final mainId = appState.mainAccountId;
          final mainAccount = mainId != null ? appState.getAccountById(mainId) : null;
          
          return AlertDialog(
            title: Text(appState.getLocalizedString('deleteAccount')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${appState.getLocalizedString('accountHasBalance')} ${appState.formatCurrency(account.balance)}.'),
                const SizedBox(height: 8),
                Text(appState.getLocalizedString('canTransferRemainingBalance')),
                if (mainAccount != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${appState.getLocalizedString('mainAccount')}: ${mainAccount.name}')),
                    ],
                  ),
                ],
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(appState.getLocalizedString('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  // Navigate to TransferScreen with prefilled values
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransferScreen(
                        initialFromAccountId: account.id,
                        initialToAccountId: mainAccount?.id,
                        initialAmount: account.balance.abs(),
                        initialDescription: appState.getLocalizedString('emptyingAccountToDelete'),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text(appState.getLocalizedString('transfer')),
              ),
            ],
          );
        }
        
        // Fallback: should not reach here, but just in case
        return AlertDialog(
          title: Text(appState.getLocalizedString('deleteAccount')),
          content: Text(appState.getLocalizedString('deleteAccountConfirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(appState.getLocalizedString('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                appState.deleteAccount(account.id);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close form screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text(appState.getLocalizedString('deleteAccount')),
            ),
          ],
        );
      },
    );
  }
}

// Helpers for bank/category labels and options
String _bankLabel(Bank bank, {bool isArabic = false}) {
  // Create a temporary account to get the localized bank name
  final tempAccount = Account(
    id: 'temp',
    name: 'temp',
    maskedNumber: 'temp',
    type: AccountType.bank,
    bank: bank,
    category: BankCategory.currentSalary,
    balance: 0.0,
  );
  
  return tempAccount.getBankDisplayNameForLanguage(isArabic);
}

// Removed old label helper; replaced by _categoryDisplayFor which includes product and age

String _categoryDisplayFor(Bank? bank, BankCategory category) {
  final product = _productNameFor(bank, category);
  final age = _ageRequirementFor(bank, category);
  return age.isEmpty ? product : '$product ($age)';
}

String _productNameFor(Bank? bank, BankCategory category) {
  final b = bank ?? Bank.nbk;
  switch (b) {
    case Bank.weyay:
      switch (category) {
        case BankCategory.kids:
          return 'Jeel';
        case BankCategory.currentSalary:
        case BankCategory.youth:
          return 'Weyay Account';
        case BankCategory.creditCards:
          return 'Debit/Virtual Card';
        case BankCategory.savings:
          return 'Weyay Account';
      }
    case Bank.tam:
      switch (category) {
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
      switch (category) {
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
      switch (category) {
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
      switch (category) {
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
      switch (category) {
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
      switch (category) {
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
      switch (category) {
        case BankCategory.currentSalary:
          return 'Current Accounts';
        case BankCategory.savings:
          return 'Kanz / Savings';
        default:
          return 'Account';
      }
    case Bank.kib:
      switch (category) {
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
      switch (category) {
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
      switch (category) {
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

String _ageRequirementFor(Bank? bank, BankCategory category) {
  switch (category) {
    case BankCategory.kids:
      // Weyay Jeel is 8–14; otherwise kids generally ≤14
      return (bank == Bank.weyay) ? '8–14' : '≤14';
    case BankCategory.youth:
      return '15–25';
    case BankCategory.creditCards:
      return '18+';
    case BankCategory.currentSalary:
    case BankCategory.savings:
      return '';
  }
}

BankCategory _inferCategoryFromType(AccountType type) {
  switch (type) {
    case AccountType.credit:
      return BankCategory.creditCards;
    case AccountType.child:
      return BankCategory.kids;
    case AccountType.bank:
      return BankCategory.currentSalary;
  }
}

List<BankCategory> _categoryOptionsForBank(Bank? bank) {
  if (bank == null) return const [];
  switch (bank) {
    case Bank.nbk:
      return const [
        BankCategory.currentSalary,
        BankCategory.savings,
        BankCategory.kids,
        BankCategory.youth,
        BankCategory.creditCards,
      ];
    case Bank.kfh:
      return const [
        BankCategory.currentSalary,
        BankCategory.savings,
        BankCategory.kids,
        BankCategory.youth,
        BankCategory.creditCards,
      ];
    case Bank.gulfBank:
      return const [
        BankCategory.currentSalary,
        BankCategory.savings,
        BankCategory.kids,
        BankCategory.youth,
      ];
    case Bank.cbk:
      return const [
        BankCategory.currentSalary,
        BankCategory.savings,
        BankCategory.kids,
        BankCategory.youth,
        BankCategory.creditCards,
      ];
    case Bank.abk:
      return const [
        BankCategory.savings,
        BankCategory.kids,
      ];
    case Bank.burgan:
      return const [
        BankCategory.currentSalary,
        BankCategory.savings,
      ];
    case Bank.kib:
      return const [
        BankCategory.currentSalary,
        BankCategory.savings,
        BankCategory.kids,
        BankCategory.youth,
      ];
    case Bank.boubyan:
      return const [
        BankCategory.currentSalary,
        BankCategory.savings,
        BankCategory.kids,
        BankCategory.youth,
      ];
    case Bank.warba:
      return const [
        BankCategory.savings,
        BankCategory.kids,
        BankCategory.youth,
      ];
    case Bank.weyay:
      // Only show the age-restricted youth option and Jeel (kids)
      return const [
        BankCategory.kids,
        BankCategory.youth,
      ];
    case Bank.tam:
      return const [
        BankCategory.currentSalary,
        BankCategory.savings,
        BankCategory.youth,
      ];
  }
}


Bank _fallbackBankById(String id) {
  final index = id.hashCode.abs() % Bank.values.length;
  return Bank.values[index];
}
