import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import '../widgets/bank_logo_widget.dart';
import '../widgets/navigation_drawer.dart';
import 'account_form_screen.dart';
import 'two_factor_auth_screen.dart';
import '../utils/number_formatter.dart';

class TransferScreen extends StatefulWidget {
  final String? initialFromAccountId;
  final String? initialToAccountId;
  final double? initialAmount;
  final String? initialDescription;

  const TransferScreen({
    super.key,
    this.initialFromAccountId,
    this.initialToAccountId,
    this.initialAmount,
    this.initialDescription,
  });

  /// Parse a formatted number string (with thousand separators) to double
  static double? parseFormattedNumber(String value) {
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

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _fromAccountId;
  String? _toAccountId;
  bool _isLoading = false;
  bool _showBiometricDialog = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _amountController.text = NumberFormatter.formatNumber(widget.initialAmount!, isArabic: false);
    }
    if (widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Validate initial values against available accounts
    final appState = context.read<AppState>();
    final fromAccounts = appState.transferableAccounts;
    final toAccountsAll = appState.accounts;
    
    // Set initial from account if not set and valid
    if (_fromAccountId == null && widget.initialFromAccountId != null) {
      if (fromAccounts.any((account) => account.id == widget.initialFromAccountId)) {
        _fromAccountId = widget.initialFromAccountId;
      }
    }
    
    // Set initial to account if not set and valid
    if (_toAccountId == null && widget.initialToAccountId != null) {
      if (toAccountsAll.any((account) => account.id == widget.initialToAccountId)) {
        _toAccountId = widget.initialToAccountId;
      }
    }
    
    // Check if current from account is still valid
    if (_fromAccountId != null && !fromAccounts.any((account) => account.id == _fromAccountId)) {
      _fromAccountId = null;
    }
    
    // Check if current to account is still valid
    if (_toAccountId != null && !toAccountsAll.any((account) => account.id == _toAccountId)) {
      _toAccountId = null;
    }
    
    // Ensure we don't have the same account in both dropdowns
    if (_fromAccountId == _toAccountId && _fromAccountId != null) {
      _toAccountId = null;
    }
    
    // Special handling for debt clearing: if we have a to account (credit card with debt) but no from account,
    // try to find the best account to clear the debt
    if (_toAccountId != null && _fromAccountId == null && widget.initialAmount != null) {
      final toAccount = appState.getAccountById(_toAccountId!);
      if (toAccount != null && toAccount.type == AccountType.credit && toAccount.balance < 0) {
        final bestAccount = appState.findBestAccountForClearingDebt(_toAccountId!, widget.initialAmount!);
        if (bestAccount != null) {
          _fromAccountId = bestAccount.id;
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Parse a formatted number string (with thousand separators) to double
  double? _parseFormattedNumber(String value) => TransferScreen.parseFormattedNumber(value);

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

    // Update the text field
    _amountController.text = formattedValue;
    
    // Adjust cursor position
    final newCursorPosition = (cursorPosition <= formattedValue.length) 
        ? cursorPosition 
        : formattedValue.length;
    _amountController.selection = TextSelection.collapsed(offset: newCursorPosition);
  }

  void _performTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromAccountId == null || _toAccountId == null) return;

    final appState = context.read<AppState>();
    final amount = _parseFormattedNumber(_amountController.text);
    if (amount == null) return; // This should not happen due to validation
    final description = _descriptionController.text.trim();

    // Authentication priority: Biometric takes precedence over 2FA
    if (appState.useBiometric) {
      setState(() {
        _showBiometricDialog = true;
      });

      // Simulate biometric authentication
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _showBiometricDialog = false;
        });
      }
    } else if (appState.useTwoFactor) {
      // Only show 2FA if biometric is disabled but 2FA is enabled
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TwoFactorAuthScreen()),
      );
      
      // If user cancels 2FA, don't proceed with transfer
      if (result == null) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate transfer processing
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Perform the actual transfer
      appState.performTransfer(_fromAccountId!, _toAccountId!, amount, description);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.getLocalizedString('transferSuccessful')),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final fromAccounts = appState.transferableAccounts; // exclude child as source
        final toAccountsAll = appState.accounts; // include child as destination
        
        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(appState.getLocalizedString('transfer')),
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
          body: Stack(
            children: [
              if (fromAccounts.isEmpty || toAccountsAll.length < 2)
                _buildNeedMoreAccounts(context, appState)
              else
                _buildTransferForm(context, appState, fromAccounts, toAccountsAll),
              
              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              
              // Biometric dialog
              if (_showBiometricDialog)
                _buildBiometricDialog(context, appState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeedMoreAccounts(BuildContext context, AppState appState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              appState.getLocalizedString('needTwoAccounts'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(appState.getLocalizedString('addAccount')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferForm(
    BuildContext context,
    AppState appState,
    List<Account> fromAccounts,
    List<Account> toAccountsAll,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // From Account
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.getLocalizedString('fromAccount'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _fromAccountId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    selectedItemBuilder: (context) {
                      return fromAccounts.map((account) {
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
                    items: fromAccounts.map((account) {
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromAccountId = value;
                        // Reset to account if it's the same
                        if (_toAccountId == value) {
                          _toAccountId = null;
                        }
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

          // To Account
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.getLocalizedString('toAccount'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _toAccountId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    selectedItemBuilder: (context) {
                      return toAccountsAll
                          .where((account) => account.id != _fromAccountId)
                          .map((account) {
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
                    items: toAccountsAll
                        .where((account) => account.id != _fromAccountId)
                        .map((account) {
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _toAccountId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return appState.getLocalizedString('pleaseSelectToAccount');
                      }
                      if (value == _fromAccountId) {
                        return appState.getLocalizedString('sameAccountError');
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Amount
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
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return appState.getLocalizedString('pleaseEnterAmount');
                      }
                      final amount = _parseFormattedNumber(value);
                      if (amount == null || amount <= 0) {
                        return appState.getLocalizedString('pleaseEnterValidAmount');
                      }
                      
                      // Check if sufficient funds
                      if (_fromAccountId != null) {
                        final validationError = appState.getTransferValidationError(_fromAccountId!, _toAccountId ?? '', amount);
                        if (validationError != null) {
                          return validationError;
                        }
                      }
                      
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.getLocalizedString('description'),
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

          // Transfer Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _performTransfer,
              child: Text(
                appState.getLocalizedString('confirmTransfer'),
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

  Widget _buildBiometricDialog(BuildContext context, AppState appState) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fingerprint,
                  size: 64,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 16),
                Text(
                  appState.getLocalizedString('biometricAuthentication'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appState.getLocalizedString('pleaseAuthenticate'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
