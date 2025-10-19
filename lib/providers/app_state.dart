import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../constants/app_strings.dart';
import '../utils/number_formatter.dart';

class AppState extends ChangeNotifier {
  // Settings
  bool _isDarkMode = false;
  bool _isArabic = false;
  bool _useBiometric = false;
  bool _useTwoFactor = false;
  bool _useDarkLogo = false; // false = light logo, true = dark logo

  // Data
  List<Account> _accounts = [];
  List<Transaction> _allTransactions = [];
  String? _mainAccountId;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isArabic => _isArabic;
  bool get useBiometric => _useBiometric;
  bool get useTwoFactor => _useTwoFactor;
  bool get useDarkLogo => _useDarkLogo;
  
  // Check if device supports dynamic icons
  Future<bool> get supportsDynamicIcons async {
    try {
      return await FlutterDynamicIcon.supportsAlternateIcons;
    } catch (e) {
      return false;
    }
  }
  List<Account> get accounts => _accounts;
  List<Transaction> get allTransactions => _allTransactions;
  String? get mainAccountId => _mainAccountId;

  /// Returns accounts with the main account (if any) at the top
  List<Account> get sortedAccounts {
    if (_mainAccountId == null) return List<Account>.from(_accounts);
    final List<Account> copy = List<Account>.from(_accounts);
    copy.sort((a, b) {
      if (a.id == _mainAccountId && b.id != _mainAccountId) return -1;
      if (b.id == _mainAccountId && a.id != _mainAccountId) return 1;
      return 0;
    });
    return copy;
  }

  // Computed getters
  double get totalBalance {
    // Include all accounts, including credit (debts represented as negative balances)
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  double get totalCreditDebt {
    // Sum of absolute values of negative balances for credit accounts
    return _accounts
        .where((a) => a.type == AccountType.credit && a.balance < 0)
        .fold(0.0, (sum, a) => sum + a.balance.abs());
  }

  List<Account> get childAccounts {
    return _accounts.where((account) => account.type == AccountType.child).toList();
  }

  List<Account> get transferableAccounts {
    return _accounts.where((account) => account.type != AccountType.child).toList();
  }

  /// Find the first account with sufficient balance to cover the specified amount
  /// Prioritizes main account if it has sufficient balance, otherwise finds any account
  Account? findAccountWithSufficientBalance(double amount) {
    // First try the main account
    if (_mainAccountId != null) {
      final mainAccount = getAccountById(_mainAccountId!);
      if (mainAccount != null && mainAccount.type != AccountType.child) {
        if (mainAccount.type == AccountType.credit) {
          if (mainAccount.availableBalance >= amount) {
            return mainAccount;
          }
        } else {
          if (mainAccount.balance >= amount) {
            return mainAccount;
          }
        }
      }
    }
    
    // If main account doesn't have sufficient balance, find any account that does
    for (final account in _accounts) {
      if (account.type == AccountType.child) continue; // Skip child accounts
      
      if (account.type == AccountType.credit) {
        if (account.availableBalance >= amount) {
          return account;
        }
      } else {
        if (account.balance >= amount) {
          return account;
        }
      }
    }
    
    return null; // No account with sufficient balance found
  }

  /// Find the best account to use for clearing debt from a specific credit card
  /// Never returns the credit card that has the debt
  Account? findBestAccountForClearingDebt(String creditCardId, double debtAmount) {
    final creditCard = getAccountById(creditCardId);
    if (creditCard == null || creditCard.type != AccountType.credit) return null;
    
    // First try the main account (if it's not the credit card with debt)
    if (_mainAccountId != null && _mainAccountId != creditCardId) {
      final mainAccount = getAccountById(_mainAccountId!);
      if (mainAccount != null && mainAccount.type != AccountType.child) {
        if (mainAccount.type == AccountType.credit) {
          if (mainAccount.availableBalance >= debtAmount) {
            return mainAccount;
          }
        } else {
          if (mainAccount.balance >= debtAmount) {
            return mainAccount;
          }
        }
      }
    }
    
    // If main account doesn't have sufficient balance, find any other account that does
    for (final account in _accounts) {
      // Skip the credit card that has the debt
      if (account.id == creditCardId) continue;
      
      // Skip child accounts
      if (account.type == AccountType.child) continue;
      
      if (account.type == AccountType.credit) {
        if (account.availableBalance >= debtAmount) {
          return account;
        }
      } else {
        if (account.balance >= debtAmount) {
          return account;
        }
      }
    }
    
    return null; // No suitable account found
  }

  /// Check if an account can be safely deleted (no debt or balance)
  bool canSafelyDeleteAccount(String accountId) {
    final account = getAccountById(accountId);
    if (account == null) return false;
    
    // Child accounts can always be deleted
    if (account.type == AccountType.child) return true;
    
    // Check if account has any balance (positive or negative)
    return account.balance == 0;
  }

  /// Check if an account has debt that needs to be cleared before deletion
  bool hasDebtToClear(String accountId) {
    final account = getAccountById(accountId);
    if (account == null) return false;
    
    // Only credit cards can have debt
    if (account.type != AccountType.credit) return false;
    
    return account.balance < 0;
  }

  /// Check if an account has positive balance that should be transferred before deletion
  bool hasBalanceToTransfer(String accountId) {
    final account = getAccountById(accountId);
    if (account == null) return false;
    
    return account.balance > 0;
  }

  // Initialize with mock data
  AppState() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Create mock accounts
    final account1 = Account(
      id: '1',
      name: 'Main Bank Account',
      maskedNumber: '****1234',
      fullNumber: '00001234',
      type: AccountType.bank,
      bank: Bank.nbk,
      category: BankCategory.currentSalary,
      balance: 5000.0,
      transactions: [],
    );

    final account2 = Account(
      id: '2',
      name: 'Credit Card',
      maskedNumber: '****5678',
      fullNumber: '00005678',
      type: AccountType.credit,
      bank: Bank.cbk,
      category: BankCategory.creditCards,
      balance: -1500.0,
      spendingLimit: 5000.0,
      usedAmount: 1500.0,
      transactions: [],
    );

    final account3 = Account(
      id: '3',
      name: 'Savings Account',
      maskedNumber: '****9012',
      fullNumber: '00009012',
      type: AccountType.bank,
      bank: Bank.kfh,
      category: BankCategory.savings,
      balance: 2500.0,
      transactions: [],
    );

    final childAccount1 = Account(
      id: '4',
      name: 'Ahmad\'s Card',
      maskedNumber: '****3456',
      fullNumber: '00003456',
      type: AccountType.child,
      bank: Bank.nbk,
      category: BankCategory.kids,
      balance: 250.0,
      spendingLimit: 500.0,
      usedAmount: 250.0,
      notificationsEnabled: true,
      transactions: [],
    );

    final childAccount2 = Account(
      id: '5',
      name: 'Fatima\'s Card',
      maskedNumber: '****7890',
      fullNumber: '00007890',
      type: AccountType.child,
      bank: Bank.kfh,
      category: BankCategory.kids,
      balance: 180.0,
      spendingLimit: 300.0,
      usedAmount: 120.0,
      notificationsEnabled: false,
      transactions: [],
    );


    _accounts = [
      account1, account2, account3, childAccount1, childAccount2
    ];
    // Set default main account if none
    _mainAccountId ??= _accounts.isNotEmpty ? _accounts.first.id : null;

    // Create mock transactions
    _allTransactions = [
      Transaction(
        id: '1',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Grocery Shopping',
        amount: -85.50,
        category: TransactionCategory.food,
        accountId: '1',
      ),
      Transaction(
        id: '2',
        dateTime: DateTime.now().subtract(const Duration(days: 20)),
        description: 'Gas Station',
        amount: -45.00,
        category: TransactionCategory.transportation,
        accountId: '1',
      ),
      Transaction(
        id: '3',
        dateTime: DateTime.now().subtract(const Duration(days: 30)),
        description: 'Salary Deposit',
        amount: 3000.00,
        category: TransactionCategory.salary,
        accountId: '1',
      ),
      Transaction(
        id: '4',
        dateTime: DateTime.now().subtract(const Duration(days: 4)),
        description: 'Online Shopping',
        amount: -120.00,
        category: TransactionCategory.shopping,
        accountId: '2',
      ),
      Transaction(
        id: '5',
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Restaurant',
        amount: -65.00,
        category: TransactionCategory.food,
        accountId: '2',
      ),
      Transaction(
        id: '6',
        dateTime: DateTime.now().subtract(const Duration(days: 6)),
        description: 'Movie Tickets',
        amount: -35.00,
        category: TransactionCategory.entertainment,
        accountId: '4',
      ),
      Transaction(
        id: '7',
        dateTime: DateTime.now().subtract(const Duration(days: 7)),
        description: 'School Supplies',
        amount: -45.00,
        category: TransactionCategory.education,
        accountId: '5',
      ),
    ];

    // Add transactions to accounts
    _updateAccountTransactions();
    
    // Add a test transfer to demonstrate balance changes
    _addTestTransfer();
  }
  
  void _addTestTransfer() {
    // Perform a test transfer from Main Bank Account to Savings Account
    performTransfer('1', '3', 500.0, 'Test transfer to demonstrate balance changes');
    
    // Add a test expense transaction
    addTransaction(Transaction(
      id: 'test_expense_${DateTime.now().millisecondsSinceEpoch}',
      dateTime: DateTime.now(),
      description: 'Test Coffee Purchase',
      amount: -15.50,
      category: TransactionCategory.food,
      accountId: '1',
    ));
    
    // Add a test income transaction
    addTransaction(Transaction(
      id: 'test_income_${DateTime.now().millisecondsSinceEpoch}',
      dateTime: DateTime.now(),
      description: 'Test Bonus',
      amount: 200.0,
      category: TransactionCategory.salary,
      accountId: '1',
    ));
  }

  void _updateAccountTransactions() {
    for (var account in _accounts) {
      final accountTransactions = _allTransactions
          .where((transaction) => transaction.accountId == account.id)
          .toList();
      
      // Calculate new balance based on transactions
      final calculatedBalance = accountTransactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
      
      // For credit cards, update usedAmount based on negative transactions
      double? newUsedAmount = account.usedAmount;
      if (account.type == AccountType.credit) {
        final negativeTransactions = accountTransactions
            .where((t) => t.amount < 0)
            .fold(0.0, (sum, t) => sum + t.amount.abs());
        newUsedAmount = negativeTransactions;
      }
      
      final updatedAccount = account.copyWith(
        transactions: accountTransactions,
        balance: calculatedBalance,
        usedAmount: newUsedAmount,
      );
      
      final index = _accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _accounts[index] = updatedAccount;
      }
    }
  }

  // Settings methods
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleLanguage() {
    _isArabic = !_isArabic;
    notifyListeners();
  }

  void toggleBiometric() {
    _useBiometric = !_useBiometric;
    notifyListeners();
  }

  void toggleTwoFactor() {
    _useTwoFactor = !_useTwoFactor;
    notifyListeners();
  }

  void toggleLogoPreference() async {
    _useDarkLogo = !_useDarkLogo;
    
    // Change app icon based on preference
    try {
      final supportsAlternateIcons = await FlutterDynamicIcon.supportsAlternateIcons;
      if (supportsAlternateIcons) {
        if (_useDarkLogo) {
          await FlutterDynamicIcon.setAlternateIconName('dark_icon');
        } else {
          await FlutterDynamicIcon.setAlternateIconName(null); // Default icon
        }
      } else {
        // Show user feedback that dynamic icons are not supported
        // This will be handled in the UI layer
      }
    } catch (e) {
      // Handle error - dynamic icon changing might not be supported on all devices
      // This will be handled in the UI layer
    }
    
    notifyListeners();
  }

  // Logout: reset settings and data to initial state
  void logout() {
    _isDarkMode = false;
    _isArabic = false;
    _useBiometric = false;
    _useTwoFactor = false;
    _useDarkLogo = false;
    _accounts = [];
    _allTransactions = [];
    _initializeMockData();
    notifyListeners();
  }

  // Create new user with empty state
  void createNewUser() {
    _isDarkMode = false;
    _isArabic = false;
    _useBiometric = false;
    _useTwoFactor = false;
    _useDarkLogo = false;
    _accounts = [];
    _allTransactions = [];
    _mainAccountId = null;
    notifyListeners();
  }

  // Account methods
  void addAccount(Account account) {
    _accounts.add(account);
    // If there is no main account yet, set the newly added as main
    _mainAccountId ??= account.id;
    notifyListeners();
  }

  void updateAccount(Account account) {
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      notifyListeners();
    }
  }

  void deleteAccount(String accountId) {
    if (_accounts.length > 1) {
      // Collect transfer group prefixes for transfers belonging to the deleted account
      final Set<String> transferIdPrefixes = _allTransactions
          .where((t) => t.accountId == accountId && t.category == TransactionCategory.transfer)
          .map((t) {
            final String id = t.id;
            final int underscoreIndex = id.indexOf('_');
            return underscoreIndex == -1 ? id : id.substring(0, underscoreIndex);
          })
          .toSet();

      // Remove the account
      _accounts.removeWhere((account) => account.id == accountId);

      // Remove all transactions for the deleted account AND any counterpart transfer transactions
      _allTransactions.removeWhere((transaction) {
        if (transaction.accountId == accountId) {
          return true;
        }
        if (transaction.category == TransactionCategory.transfer && transferIdPrefixes.isNotEmpty) {
          for (final String prefix in transferIdPrefixes) {
            if (transaction.id.startsWith(prefix)) {
              return true;
            }
          }
        }
        return false;
      });
      // If the deleted account was the main one, select the first remaining as main
      if (_mainAccountId == accountId) {
        _mainAccountId = _accounts.isNotEmpty ? _accounts.first.id : null;
      }
      _updateAccountTransactions();
      notifyListeners();
    }
  }

  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  // Transaction methods
  void addTransaction(Transaction transaction) {
    _allTransactions.add(transaction);
    _updateAccountTransactions();
    notifyListeners();
  }

  List<Transaction> getTransactionsForAccount(String accountId) {
    return _allTransactions
        .where((transaction) => transaction.accountId == accountId)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Transfer methods
  bool canTransfer(String fromAccountId, String toAccountId, double amount) {
    if (fromAccountId == toAccountId) return false;
    
    final fromAccount = getAccountById(fromAccountId);
    if (fromAccount == null) return false;
    
    if (fromAccount.type == AccountType.credit) {
      return fromAccount.availableBalance >= amount;
    } else {
      return fromAccount.balance >= amount;
    }
  }

  String? getTransferValidationError(String fromAccountId, String toAccountId, double amount) {
    if (fromAccountId == toAccountId) return 'Cannot transfer to the same account';
    
    final fromAccount = getAccountById(fromAccountId);
    if (fromAccount == null) return 'Source account not found';
    
    if (fromAccount.type == AccountType.credit) {
      if (fromAccount.availableBalance < amount) {
        return 'Amount exceeds available credit limit';
      }
    } else {
      if (fromAccount.balance < amount) {
        return 'Insufficient funds';
      }
    }
    
    return null;
  }

  void performTransfer(String fromAccountId, String toAccountId, double amount, String description) {
    if (!canTransfer(fromAccountId, toAccountId, amount)) return;

    final fromAccount = getAccountById(fromAccountId);
    final toAccount = getAccountById(toAccountId);
    
    if (fromAccount == null || toAccount == null) return;

    // Add transfer transactions - balances will be automatically calculated
    final transferId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Use clean transfer descriptions without user descriptions
    final fromDescription = 'Transfer to ${toAccount.name}';
    final toDescription = 'Transfer from ${fromAccount.name}';

    addTransaction(Transaction(
      id: '${transferId}_from',
      dateTime: DateTime.now(),
      description: fromDescription,
      amount: -amount,
      category: TransactionCategory.transfer,
      accountId: fromAccountId,
    ));

    addTransaction(Transaction(
      id: '${transferId}_to',
      dateTime: DateTime.now(),
      description: toDescription,
      amount: amount,
      category: TransactionCategory.transfer,
      accountId: toAccountId,
    ));
  }

  // Main account methods
  void setMainAccount(String accountId) {
    if (_mainAccountId == accountId) return;
    final exists = _accounts.any((a) => a.id == accountId);
    if (!exists) return;
    _mainAccountId = accountId;
    notifyListeners();
  }

  // Child account methods
  void updateChildSpendingLimit(String accountId, double newLimit) {
    final account = getAccountById(accountId);
    if (account != null && account.type == AccountType.child) {
      final updatedAccount = account.copyWith(spendingLimit: newLimit);
      updateAccount(updatedAccount);
    }
  }

  void toggleChildNotifications(String accountId) {
    final account = getAccountById(accountId);
    if (account != null && account.type == AccountType.child) {
      final updatedAccount = account.copyWith(
        notificationsEnabled: !account.notificationsEnabled,
      );
      updateAccount(updatedAccount);
    }
  }

  // Analytics methods
  Map<TransactionCategory, double> getSpendingByCategory() {
    final Map<TransactionCategory, double> categoryTotals = {};
    
    for (final transaction in _allTransactions) {
      if (transaction.isExpense) {
        final category = transaction.category;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + transaction.amount.abs();
      }
    }
    
    return categoryTotals;
  }

  Map<TransactionCategory, double> getIncomeByCategory() {
    final Map<TransactionCategory, double> categoryTotals = {};
    
    for (final transaction in _allTransactions) {
      if (transaction.isIncome) {
        final category = transaction.category;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + transaction.amount;
      }
    }
    
    return categoryTotals;
  }

  Map<String, double> getMonthlySpending() {
    final Map<String, double> monthlyTotals = {};
    
    for (final transaction in _allTransactions) {
      if (transaction.isExpense) {
        final month = '${transaction.dateTime.month}/${transaction.dateTime.year}';
        monthlyTotals[month] = (monthlyTotals[month] ?? 0) + transaction.amount.abs();
      }
    }
    
    return monthlyTotals;
  }

  Map<String, double> getAccountSpendingContributions() {
    final Map<String, double> accountTotals = {};
    
    for (final transaction in _allTransactions) {
      if (transaction.isExpense) {
        accountTotals[transaction.accountId] = 
            (accountTotals[transaction.accountId] ?? 0) + transaction.amount.abs();
      }
    }
    
    return accountTotals;
  }

  // Transaction methods
  void createTransaction(Transaction transaction) {
    _allTransactions.add(transaction);
    
    // Update the account's balance
    final account = getAccountById(transaction.accountId);
    if (account != null) {
      final updatedAccount = account.copyWith(
        balance: account.balance + transaction.amount,
      );
      updateAccount(updatedAccount);
    }
    
    notifyListeners();
  }

  // Utility methods
  String getLocalizedString(String key) {
    return AppStrings.getString(key, _isArabic);
  }

  String formatCurrency(double amount) {
    final currency = _isArabic ? 'د.ك' : 'KWD';
    return NumberFormatter.formatCurrency(amount, currency, isArabic: _isArabic);
  }
}
