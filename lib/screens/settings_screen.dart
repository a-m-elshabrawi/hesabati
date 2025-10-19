import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';
import '../widgets/navigation_drawer.dart';
import 'login_screen.dart';
import 'two_factor_auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          drawer: const AppNavigationDrawer(),
          appBar: AppBar(
            title: Text(appState.getLocalizedString('settings')),
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
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance Section
              _buildSectionHeader(context, appState.getLocalizedString('appearance')),
              _buildDarkThemeToggle(context, appState),
              _buildLogoPreferenceToggle(context, appState),
              const SizedBox(height: 24),
              
              // Language Section
              _buildSectionHeader(context, appState.getLocalizedString('language')),
              _buildLanguageSelector(context, appState),
              const SizedBox(height: 24),
              
              // Security Section
              _buildSectionHeader(context, appState.getLocalizedString('security')),
              _buildBiometricToggle(context, appState),
              _buildTwoFactorToggle(context, appState),
              if (appState.useTwoFactor) _buildTestTwoFactorButton(context, appState),
              const SizedBox(height: 24),
              
              // App Info Section
              _buildSectionHeader(context, appState.getLocalizedString('appInformation')),
              _buildAppInfo(context, appState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildDarkThemeToggle(BuildContext context, AppState appState) {
    return Card(
      child: SwitchListTile(
        title: Text(appState.getLocalizedString('darkTheme')),
        subtitle: Text(appState.getLocalizedString('toggleThemeDescription')),
        value: appState.isDarkMode,
        onChanged: (value) {
          appState.toggleDarkMode();
        },
        activeTrackColor: AppColors.primaryBlue,
        secondary: Icon(
          appState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildLogoPreferenceToggle(BuildContext context, AppState appState) {
    return Card(
      child: ListTile(
        leading: Icon(
          appState.useDarkLogo ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          color: AppColors.primaryBlue,
        ),
        title: Text(appState.getLocalizedString('appIconStyle')),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appState.useDarkLogo ? appState.getLocalizedString('darkLogoDescription') : appState.getLocalizedString('lightLogoDescription')),
            const SizedBox(height: 4),
            Text(
              appState.getLocalizedString('iconChangeNote'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: appState.useDarkLogo,
        onChanged: (value) async {
          // Check if device supports dynamic icons first
          final supportsIcons = await appState.supportsDynamicIcons;
          
          appState.toggleLogoPreference();
          
          // Show feedback to user
          if (context.mounted) {
            String message;
            if (supportsIcons) {
              message = appState.useDarkLogo 
                ? appState.getLocalizedString('switchedToDarkIcon')
                : appState.getLocalizedString('switchedToLightIcon');
            } else {
              message = appState.useDarkLogo 
                ? appState.getLocalizedString('switchedToDarkIconPreference')
                : appState.getLocalizedString('switchedToLightIconPreference');
            }
            
            final messenger = ScaffoldMessenger.of(context);
            messenger.showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 4),
                backgroundColor: AppColors.primaryBlue,
                action: SnackBarAction(
                  label: appState.getLocalizedString('ok'),
                  textColor: Colors.white,
                  onPressed: () {
                    messenger.hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
          activeTrackColor: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, AppState appState) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.language,
          color: AppColors.primaryBlue,
        ),
        title: Text(appState.getLocalizedString('language')),
        subtitle: Text(
          appState.isArabic ? appState.getLocalizedString('arabic') : appState.getLocalizedString('english'),
        ),
        trailing: DropdownButton<String>(
          value: appState.isArabic ? 'ar' : 'en',
          underline: const SizedBox(),
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Text(appState.getLocalizedString('english')),
            ),
            DropdownMenuItem(
              value: 'ar',
              child: Text(appState.getLocalizedString('arabic')),
            ),
          ],
          onChanged: (value) {
            if (value == 'ar' && !appState.isArabic) {
              appState.toggleLanguage();
            } else if (value == 'en' && appState.isArabic) {
              appState.toggleLanguage();
            }
          },
        ),
      ),
    );
  }

  Widget _buildBiometricToggle(BuildContext context, AppState appState) {
    return Card(
      child: SwitchListTile(
        title: Text(appState.getLocalizedString('biometricAuth')),
        subtitle: Text(appState.getLocalizedString('biometricDescription')),
        value: appState.useBiometric,
        onChanged: (value) {
          appState.toggleBiometric();
        },
        activeTrackColor: AppColors.primaryBlue,
        secondary: const Icon(
          Icons.fingerprint,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildTwoFactorToggle(BuildContext context, AppState appState) {
    return Card(
      child: SwitchListTile(
        title: Text(appState.getLocalizedString('twoFactorAuth')),
        subtitle: Text(appState.getLocalizedString('twoFactorDescription')),
        value: appState.useTwoFactor,
        onChanged: (value) {
          appState.toggleTwoFactor();
        },
        activeTrackColor: AppColors.primaryBlue,
        secondary: const Icon(
          Icons.security,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildTestTwoFactorButton(BuildContext context, AppState appState) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.security,
          color: AppColors.primaryBlue,
        ),
        title: Text(appState.getLocalizedString('testTwoFactorAuth')),
        subtitle: Text(appState.getLocalizedString('tryTwoFactorScreen')),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TwoFactorAuthScreen()),
          );
        },
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context, AppState appState) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: AppColors.primaryBlue,
            ),
            title: Text(appState.getLocalizedString('appVersion')),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(height: 1),
          // Logout
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: AppColors.primaryBlue,
            ),
            title: Text(appState.getLocalizedString('logout')),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(appState.getLocalizedString('logout')),
                  content: Text(appState.getLocalizedString('confirmLogout')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(appState.getLocalizedString('cancel')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(appState.getLocalizedString('logout')),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                appState.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.description,
              color: AppColors.primaryBlue,
            ),
            title: Text(appState.getLocalizedString('termsOfService')),
            onTap: () {
              _showTermsDialog(context, appState);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip,
              color: AppColors.primaryBlue,
            ),
            title: Text(appState.getLocalizedString('privacyPolicy')),
            onTap: () {
              _showPrivacyDialog(context, appState);
            },
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.getLocalizedString('termsOfService')),
        content: SingleChildScrollView(
          child: Text(
            appState.getLocalizedString('termsContent'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.getLocalizedString('close')),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appState.getLocalizedString('privacyPolicy')),
        content: SingleChildScrollView(
          child: Text(
            appState.getLocalizedString('privacyContent'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.getLocalizedString('close')),
          ),
        ],
      ),
    );
  }
}
