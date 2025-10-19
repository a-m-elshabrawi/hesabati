import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../domain/models.dart';
import '../data/snapshot_loader.dart';
import '../domain/converter.dart';
import 'currency_picker.dart';
import '../../../widgets/navigation_drawer.dart';
import '../../../providers/app_state.dart';

/// Main currency exchange rates screen with snapshot data
class CurrencyRatesScreen extends StatefulWidget {
  const CurrencyRatesScreen({super.key});

  @override
  State<CurrencyRatesScreen> createState() => _CurrencyRatesScreenState();
}

class _CurrencyRatesScreenState extends State<CurrencyRatesScreen> {
  FxSnapshot? _snapshot;
  String _fromCurrency = 'USD';
  String _toCurrency = 'KWD';
  double _amount = 1.0;
  bool _isLoading = true;
  String? _error;
  late TextEditingController _amountController;
  late TextEditingController _convertedAmountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _amount.toStringAsFixed(2));
    _convertedAmountController = TextEditingController();
    _loadSnapshot();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _convertedAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadSnapshot() async {
    try {
      final snapshot = await SnapshotLoader.loadSnapshot();
      setState(() {
        _snapshot = snapshot;
        _isLoading = false;
      });
      _updateConvertedAmount();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _updateConvertedAmount();
  }

  void _updateConvertedAmount() {
    final convertedAmount = _getConvertedAmount();
    _convertedAmountController.text = convertedAmount.toStringAsFixed(2);
  }

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
    String integerPart = parts[0];
    String formattedIntegerPart = '';
    
    for (int i = integerPart.length - 1; i >= 0; i--) {
      formattedIntegerPart = integerPart[i] + formattedIntegerPart;
      if ((integerPart.length - i) % 3 == 0 && i > 0) {
        formattedIntegerPart = ',$formattedIntegerPart';
      }
    }

    // Combine with decimal part if exists
    String formattedValue = parts.length > 1 ? '$formattedIntegerPart.${parts[1]}' : formattedIntegerPart;

    // Calculate new cursor position
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

  double? _parseFormattedNumber(String value) {
    if (value.trim().isEmpty) return null;
    
    // Remove thousand separators (commas) and parse
    final cleanValue = value.replaceAll(',', '');
    return double.tryParse(cleanValue);
  }

  List<String> get _availableCurrencies {
    return _snapshot?.rates.keys.toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (_isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (_error != null || _snapshot == null) {
          return Scaffold(
            drawer: const AppNavigationDrawer(),
            appBar: AppBar(
              title: Text(appState.getLocalizedString('currencyExchange')),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
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
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appState.getLocalizedString('failedToLoadRates'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error ?? appState.getLocalizedString('unknownError'),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(appState.getLocalizedString('currencyExchange')),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
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
          body: Column(
            children: [
              _buildBanner(appState),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildControls(appState),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBanner(AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.orange.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                appState.getLocalizedString('staticRates'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            appState.getLocalizedString('ratesInfo'),
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appState.getLocalizedString('currencyConverter'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // FROM Section
            _buildConverterSection(
              appState.getLocalizedString('from'),
              _fromCurrency,
              _amount,
              (currency) {
                setState(() {
                  _fromCurrency = currency;
                });
                _updateConvertedAmount();
              },
              (amount) {
                setState(() {
                  _amount = amount;
                });
                _updateConvertedAmount();
              },
              appState,
            ),
            
            const SizedBox(height: 20),
            
            // Swap Button
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: _swapCurrencies,
                  icon: Icon(
                    Icons.swap_vert,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  tooltip: appState.getLocalizedString('swapCurrencies'),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // TO Section
            _buildConverterSection(
              appState.getLocalizedString('to'),
              _toCurrency,
              _getConvertedAmount(),
              (currency) {
                setState(() {
                  _toCurrency = currency;
                });
                _updateConvertedAmount();
              },
              null, // Read-only for the "To" section
              appState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConverterSection(
    String label,
    String selectedCurrency,
    double amount,
    Function(String) onCurrencyChanged,
    Function(double)? onAmountChanged,
    AppState appState,
  ) {
    final isReadOnly = onAmountChanged == null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        // Amount Input - Full Width
        TextFormField(
          controller: isReadOnly ? _convertedAmountController : _amountController,
          decoration: InputDecoration(
            labelText: appState.getLocalizedString('amount'),
            border: const OutlineInputBorder(),
            suffixText: selectedCurrency,
            suffixStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            filled: isReadOnly,
            fillColor: isReadOnly ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: isReadOnly ? null : [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          readOnly: isReadOnly,
          onChanged: isReadOnly ? null : (value) {
            if (!isReadOnly) {
              _formatAmount(value);
              final parsed = _parseFormattedNumber(value);
              if (parsed != null && parsed >= 0) {
                onAmountChanged(parsed);
              }
            }
          },
        ),
        const SizedBox(height: 12),
        // Currency Selector - Full Width
        CurrencySelector(
          selectedCurrency: selectedCurrency,
          availableCurrencies: _availableCurrencies,
          onCurrencySelected: onCurrencyChanged,
          label: label == appState.getLocalizedString('from') 
              ? appState.getLocalizedString('fromCurrency')
              : appState.getLocalizedString('toCurrency'),
        ),
      ],
    );
  }

  double _getConvertedAmount() {
    if (_snapshot == null) return 0.0;
    
    try {
      return CurrencyConverter.convert(
        _snapshot!.rates,
        _fromCurrency,
        _toCurrency,
        _amount,
      );
    } catch (e) {
      return 0.0;
    }
  }


}
