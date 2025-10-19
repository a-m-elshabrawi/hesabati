import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import '../widgets/currency_text.dart';
import '../screens/home_screen.dart';
import '../screens/accounts_screen.dart';
import '../screens/transfer_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/beneficiaries_screen.dart';
import '../screens/settings_screen.dart';
import '../features/fx_snapshot/ui/currency_rates_screen.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Drawer(
          child: Column(
            children: [
              // Header
              _buildHeader(context, appState),
              
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Main Navigation
                    _buildNavigationItem(
                      context,
                      appState,
                      Icons.home,
                      appState.getLocalizedString('home'),
                      () => _navigateAndClose(context, const HomeScreen()),
                    ),
                    _buildNavigationItem(
                      context,
                      appState,
                      Icons.account_balance_wallet,
                      appState.getLocalizedString('accounts'),
                      () => _navigateAndClose(context, const AccountsScreen()),
                    ),
                    _buildNavigationItem(
                      context,
                      appState,
                      Icons.swap_horiz,
                      appState.getLocalizedString('transfer'),
                      () => _navigateAndClose(context, const TransferScreen()),
                    ),
                    _buildNavigationItem(
                      context,
                      appState,
                      Icons.analytics,
                      appState.getLocalizedString('analytics'),
                      () => _navigateAndClose(context, const AnalyticsScreen()),
                    ),
                    _buildNavigationItem(
                      context,
                      appState,
                      Icons.people,
                      appState.getLocalizedString('beneficiaries'),
                      () => _navigateAndClose(context, const BeneficiariesScreen()),
                    ),
                    _buildNavigationItem(
                      context,
                      appState,
                      Icons.currency_exchange,
                      appState.getLocalizedString('currencyExchange'),
                      () => _navigateAndClose(context, const CurrencyRatesScreen()),
                    ),
                    _buildNavigationItem(
                      context,
                      appState,
                      Icons.settings,
                      appState.getLocalizedString('settings'),
                      () => _navigateAndClose(context, const SettingsScreen()),
                    ),
                    
                    const Divider(),
                    
                    // Add some bottom padding to create space
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              
              // Footer with elevated design
              _buildElevatedFooter(context, appState),
              
              // Additional spacing at the bottom
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // App Logo/Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF2563EB),
                size: 40,
              ),
            ),
            const SizedBox(height: 10),
            // App Name
            Text(
              'Hesabati',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNavigationItem(
    BuildContext context,
    AppState appState,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
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
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildElevatedFooter(BuildContext context, AppState appState) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Balance Summary Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Total Balance
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.getLocalizedString('totalBalance'),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          CurrencyText(
                            amount: appState.totalBalance,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Account Count
                Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${appState.accounts.length} ${appState.getLocalizedString('accounts')}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          
          // Logout Section
          _buildLogoutSection(context, appState),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, AppState appState) {
    return InkWell(
      onTap: () => _showLogoutDialog(context, appState),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              appState.getLocalizedString('logout'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appState.getLocalizedString('logout')),
          content: Text(appState.getLocalizedString('confirmLogout')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appState.getLocalizedString('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pop(context); // Close drawer
                appState.logout();
                // Navigate to splash screen
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(appState.getLocalizedString('logout')),
            ),
          ],
        );
      },
    );
  }

  void _navigateAndClose(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}