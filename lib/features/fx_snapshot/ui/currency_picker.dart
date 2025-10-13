import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models.dart';
import '../data/iso4217_meta.dart';
import '../../../providers/app_state.dart';
import '../../../constants/app_strings.dart';

/// A searchable currency picker widget
class CurrencyPicker extends StatefulWidget {
  final String selectedCurrency;
  final List<String> availableCurrencies;
  final ValueChanged<String> onCurrencySelected;
  final String label;

  const CurrencyPicker({
    super.key,
    required this.selectedCurrency,
    required this.availableCurrencies,
    required this.onCurrencySelected,
    required this.label,
  });

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  late TextEditingController _searchController;
  List<String> _filteredCurrencies = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCurrencies = widget.availableCurrencies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCurrencies = widget.availableCurrencies;
      } else {
        _filteredCurrencies = widget.availableCurrencies.where((currency) {
          final IsoMeta meta = getIsoMeta(currency);
          final localizedName = AppStrings.getCurrencyName(currency, true); // Check Arabic names
          final englishName = AppStrings.getCurrencyName(currency, false); // Check English names
          return currency.toLowerCase().contains(_searchQuery) ||
                 meta.name.toLowerCase().contains(_searchQuery) ||
                 localizedName.toLowerCase().contains(_searchQuery) ||
                 englishName.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  void _selectCurrency(String currency) {
    widget.onCurrencySelected(currency);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return AlertDialog(
          title: Text('${appState.getLocalizedString('selectCurrency')} ${widget.label}'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: appState.getLocalizedString('searchByCodeOrName'),
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: _filterCurrencies,
                ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = _filteredCurrencies[index];
                  final meta = getIsoMeta(currency);
                  final isSelected = currency == widget.selectedCurrency;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade300,
                      child: Text(
                        currency,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      AppStrings.getCurrencyName(currency, appState.isArabic),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${meta.code} • ${appState.getLocalizedString('minorUnit')}: ${meta.minorUnit}',
                      style: TextStyle(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey.shade600,
                      ),
                    ),
                    trailing: isSelected 
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    onTap: () => _selectCurrency(currency),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appState.getLocalizedString('cancel')),
        ),
      ],
    );
      },
    );
  }
}

/// A compact currency selector button
class CurrencySelector extends StatelessWidget {
  final String selectedCurrency;
  final List<String> availableCurrencies;
  final ValueChanged<String> onCurrencySelected;
  final String label;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.availableCurrencies,
    required this.onCurrencySelected,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () => _showCurrencyPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                selectedCurrency,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCurrency,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CurrencyPicker(
        selectedCurrency: selectedCurrency,
        availableCurrencies: availableCurrencies,
        onCurrencySelected: onCurrencySelected,
        label: label,
      ),
    );
  }
}
