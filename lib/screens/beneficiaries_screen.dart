import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import '../widgets/currency_text.dart';
import '../widgets/navigation_drawer.dart';
import 'account_details_screen.dart';

class BeneficiariesScreen extends StatelessWidget {
  const BeneficiariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final childAccounts = appState.childAccounts;
        
        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(appState.getLocalizedString('beneficiaries')),
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
          body: childAccounts.isEmpty
              ? _buildEmptyState(context, appState)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: childAccounts.length,
                  itemBuilder: (context, index) {
                    final account = childAccounts[index];
                    return _buildChildCard(context, appState, account);
                  },
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
              Icons.people_outline,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              appState.getLocalizedString('noChildCardsYet'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              appState.getLocalizedString('addChildCardsDescription'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, AppState appState, Account account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountDetailsScreen(account: account),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name at left and notifications label + toggle grouped at right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          account.maskedNumber,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            appState.getLocalizedString('notifications'),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Switch(
                        value: account.notificationsEnabled,
                        onChanged: (value) {
                          appState.toggleChildNotifications(account.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value 
                                    ? appState.getLocalizedString('notificationsEnabled')
                                    : appState.getLocalizedString('notificationsDisabled'),
                              ),
                              backgroundColor: value ? AppColors.success : AppColors.warning,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        activeTrackColor: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appState.getLocalizedString('currentBalance'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  CurrencyText(
                    amount: account.balance,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    forceColor: account.type == AccountType.child ? AppColors.income : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Spending Limit Section
              _buildSpendingLimitSection(context, appState, account),
              const SizedBox(height: 16),
              
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appState.getLocalizedString('usedAmount'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      CurrencyText(
                        amount: account.usedAmount ?? 0,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: account.progressPercentage.clamp(0.0, 1.0),
                    backgroundColor: AppColors.progressBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      account.progressPercentage >= 1.0 
                          ? AppColors.error 
                          : account.progressPercentage > 0.8 
                              ? AppColors.warning 
                              : AppColors.progressFill,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingLimitSection(BuildContext context, AppState appState, Account account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              appState.getLocalizedString('spendingLimit'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            CurrencyText(
              amount: account.spendingLimit ?? 0,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Spending Limit Slider
        Row(
          children: [
            Expanded(
              child: Slider(
                value: (account.spendingLimit ?? 0).clamp(0.0, 1000.0),
                min: 0.0,
                max: 1000.0,
                divisions: 100,
                activeColor: AppColors.primaryBlue,
                inactiveColor: AppColors.progressBackground,
                onChanged: (value) {
                  appState.updateChildSpendingLimit(account.id, value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Text(
                (account.spendingLimit ?? 0) == 0 
                    ? appState.getLocalizedString('noLimit')
                    : '${(account.spendingLimit ?? 0).toInt()} ${appState.getLocalizedString('currency')}',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
