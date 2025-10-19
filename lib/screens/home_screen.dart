import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import '../widgets/account_card.dart';
import '../widgets/currency_text.dart';
import '../widgets/navigation_drawer.dart';
import 'accounts_screen.dart';
import 'transfer_screen.dart';
import 'add_funds_screen.dart';
import 'analytics_screen.dart';
import 'beneficiaries_screen.dart';
import 'account_form_screen.dart';
import 'account_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(appState.getLocalizedString('home')),
            automaticallyImplyLeading: false,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Balance Section
                _buildTotalBalanceSection(context, appState),
                const SizedBox(height: 24),
                
                // Accounts Carousel
                _buildAccountsCarousel(context, appState),
                const SizedBox(height: 32),
                
                // Quick Actions
                _buildQuickActions(context, appState),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalBalanceSection(BuildContext context, AppState appState) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appState.getLocalizedString('totalBalance'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            CurrencyText(
              amount: appState.totalBalance,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDebtTip(context, appState),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsCarousel(BuildContext context, AppState appState) {
    if (appState.accounts.isEmpty) {
      return _buildEmptyState(context, appState);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.getLocalizedString('accounts'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: appState.accounts.length,
            itemBuilder: (context, index) {
              final account = appState.accounts[index];
              return SizedBox(
                width: 280,
                child: AccountCard(
                  account: account,
                  isHomeScreen: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountDetailsScreen(account: account),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDebtTip(BuildContext context, AppState appState) {
    final totalDebt = appState.totalCreditDebt;
    if (totalDebt <= 0) return const SizedBox.shrink();

    final canClear = appState.totalBalance > totalDebt;
    if (!canClear) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Colors.yellowAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              appState.getLocalizedString('tip'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              appState.getLocalizedString('noAccountsYet'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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

  Widget _buildQuickActions(BuildContext context, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.getLocalizedString('quickActions'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildQuickActionCard(
              context,
              appState,
              Icons.account_balance_wallet,
              appState.getLocalizedString('viewAccounts'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountsScreen()),
              ),
            ),
            _buildQuickActionCard(
              context,
              appState,
              Icons.swap_horiz,
              appState.getLocalizedString('quickTransfer'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TransferScreen()),
              ),
            ),
            _buildQuickActionCard(
              context,
              appState,
              Icons.add_circle_outline,
              appState.getLocalizedString('addFunds'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddFundsScreen()),
              ),
            ),
            _buildQuickActionCard(
              context,
              appState,
              Icons.analytics,
              appState.getLocalizedString('viewAnalytics'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
              ),
            ),
            _buildQuickActionCard(
              context,
              appState,
              Icons.people,
              appState.getLocalizedString('manageBeneficiaries'),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BeneficiariesScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    AppState appState,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
