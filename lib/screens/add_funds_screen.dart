import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import '../widgets/bank_logo_widget.dart';
import '../widgets/navigation_drawer.dart';
import '../utils/number_formatter.dart';

class AddFundsScreen extends StatefulWidget {
  final String? initialAccountId;
  final double? initialAmount;

  const AddFundsScreen({
    super.key,
    this.initialAccountId,
    this.initialAmount,
  });

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedAccountId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _amountController.text = NumberFormatter.formatNumber(widget.initialAmount!, isArabic: false);
    }
    _descriptionController.text = 'Deposit'; // Default description
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = context.read<AppState>();
    final accounts = appState.accounts;
    
    // Set initial account if not set and valid
    if (_selectedAccountId == null && widget.initialAccountId != null) {
      if (accounts.any((account) => account.id == widget.initialAccountId)) {
        _selectedAccountId = widget.initialAccountId;
      }
    }
    
    // Check if current account is still valid
    if (_selectedAccountId != null && !accounts.any((account) => account.id == _selectedAccountId)) {
      _selectedAccountId = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Parse a formatted number string (with thousand separators) to double
  double? _parseFormattedNumber(String value) {
    if (value.trim().isEmpty) return null;
    
    // Split by decimal point first to handle decimal numbers
    final decimalParts = value.split('.');
    if (decimalParts.length > 2) {
      return null; // Invalid: multiple decimal points
    }
    
    // Check the integer part for proper comma placement
    final integerPart = decimalParts[0];
    final commaParts = integerPart.split(',');
    
    // First part can be 1-3 digits, subsequent parts must be exactly 3 digits
    for (int i = 1; i < commaParts.length; i++) {
      if (commaParts[i].length != 3) {
        return null;
      }
    }
    
    // Remove thousand separators (commas) and parse
    final cleanValue = value.replaceAll(',', '');
    return double.tryParse(cleanValue);
  }

  /// Format amount as user types
  void _formatAmount(String value) {
    final cursorPosition = _amountController.selection.baseOffset;
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    
    if (cleanValue.isEmpty) {
      _amountController.text = '';
      _amountController.selection = const TextSelection.collapsed(offset: 0);
      return;
    }

    final parts = cleanValue.split('.');
    if (parts.length > 2) {
      // Invalid format, don't update
      return;
    }

    // Count digits before cursor position to maintain proper cursor placement
    int digitsBeforeCursor = 0;
    for (int i = 0; i < cursorPosition && i < value.length; i++) {
      if (value[i].contains(RegExp(r'\d'))) {
        digitsBeforeCursor++;
      }
    }

    // Format the integer part with thousand separators
    final integerPart = parts[0];
    final formattedInteger = NumberFormatter.formatWholeNumber(
      double.parse(integerPart.isEmpty ? '0' : integerPart),
      isArabic: false,
    );

    // Reconstruct the formatted number
    String formattedValue;
    if (parts.length == 2) {
      formattedValue = '$formattedInteger.${parts[1]}';
    } else {
      formattedValue = formattedInteger;
    }

    // Calculate new cursor position based on digit count
    int newCursorPosition = 0;
    int digitCount = 0;
    for (int i = 0; i < formattedValue.length; i++) {
      if (formattedValue[i].contains(RegExp(r'\d'))) {
        digitCount++;
        if (digitCount > digitsBeforeCursor) {
          break;
        }
      }
      newCursorPosition = i + 1;
    }

    // Update the text field
    _amountController.text = formattedValue;
    
    // Set cursor position
    _amountController.selection = TextSelection.collapsed(
      offset: newCursorPosition.clamp(0, formattedValue.length)
    );
  }

  void _addFunds() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) return;

    final appState = context.read<AppState>();
    final amount = _parseFormattedNumber(_amountController.text);
    if (amount == null) return; // This should not happen due to validation
    final description = _descriptionController.text.trim().isEmpty ? 'Deposit' : _descriptionController.text.trim();

    setState(() {
      _isLoading = true;
    });

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Create the transaction
      final transaction = Transaction(
        id: 'fund_${DateTime.now().millisecondsSinceEpoch}',
        dateTime: DateTime.now(),
        description: description,
        amount: amount, // Positive amount for adding funds
        category: TransactionCategory.salary, // Treat as income
        accountId: _selectedAccountId!,
      );

      // Add the transaction to the app state
      appState.addTransaction(transaction);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.getLocalizedString('fundsAddedSuccessfully')),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final accounts = appState.accounts;
        
        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(appState.getLocalizedString('addFunds')),
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
          body: Stack(
            children: [
              if (accounts.isEmpty)
                _buildEmptyState(context, appState)
              else
                _buildAddFundsForm(context, appState, accounts),
              
              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppState appState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              appState.getLocalizedString('noAccountsYet'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to add account screen
                Navigator.pushNamed(context, '/account-form');
              },
              icon: const Icon(Icons.add),
              label: Text(appState.getLocalizedString('addAccount')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFundsForm(
    BuildContext context,
    AppState appState,
    List<Account> accounts,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Information Card
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
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    selectedItemBuilder: (context) {
                      return accounts.map((account) {
                        return Row(
                          children: [
                            BankLogoWidget(
                              bank: account.bank,
                              radius: 12,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                account.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Row(
                          children: [
                            BankLogoWidget(
                              bank: account.bank,
                              radius: 12,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    account.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    account.maskedNumber,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    appState.formatCurrency(account.balance),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: account.balance >= 0 
                                        ? AppColors.success 
                                        : AppColors.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return appState.getLocalizedString('pleaseSelectFromAccount');
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Amount Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    onChanged: _formatAmount,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      suffixText: appState.getLocalizedString('currency'),
                      prefixIcon: const Icon(Icons.attach_money),
                      hintText: appState.getLocalizedString('enterAmount'),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return appState.getLocalizedString('pleaseEnterAmount');
                      }
                      final amount = _parseFormattedNumber(value);
                      if (amount == null || amount <= 0) {
                        return appState.getLocalizedString('pleaseEnterValidAmount');
                      }
                      if (amount > 1000000) { // Maximum amount limit
                        return appState.getLocalizedString('amountTooLarge');
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.getLocalizedString('transactionDescription'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Add Funds Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addFunds,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: Text(
                appState.getLocalizedString('addFunds'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}