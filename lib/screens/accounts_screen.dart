import 'package:final_project_unicode/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/account_card.dart';
import '../widgets/navigation_drawer.dart';
import 'account_details_screen.dart';
import 'account_form_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(appState.getLocalizedString('accounts')),
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
          body: appState.accounts.isEmpty
              ? _buildEmptyState(context, appState)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appState.sortedAccounts.length,
                  itemBuilder: (context, index) {
                    final account = appState.sortedAccounts[index];
                    return AccountCard(
                      account: account,
                      showProgress: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountDetailsScreen(account: account),
                          ),
                        );
                      },
                      onLongPress: () {
                        appState.setMainAccount(account.id);
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountFormScreen(),
                ),
              );
            },
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.add, color: Colors.white),
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
}
