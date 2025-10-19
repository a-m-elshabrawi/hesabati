# Hesabati - One-View Finance

A comprehensive fintech dashboard Flutter app that lets users view and manage money across multiple banks in one place, including regular accounts, credit cards, children/beneficiary cards, and real-time foreign exchange rates.

## Features

### 🏠 Home Dashboard
- **Total Balance Overview**: View your total balance (excluding credit debt)
- **Account Carousel**: Horizontal scrolling through all your accounts
- **Quick Actions**: Easy access to view accounts, transfer money, analytics, and manage beneficiaries

### 💳 Account Management
- **Multiple Account Types**: Support for bank accounts, credit cards, and child cards
- **Add/Edit/Delete**: Full CRUD operations for accounts
- **Account Details**: View balance, transactions, and spending limits
- **Smart Validation**: Prevents deletion of the last account

### 💸 Money Transfers
- **Inter-Account Transfers**: Transfer money between your own accounts
- **Real-time Validation**: Check for sufficient funds and valid amounts
- **Biometric Authentication**: Fake biometric/2FA confirmation animations
- **Transfer History**: Complete transaction records

### 💰 Add Funds
- **Deposit Money**: Add funds to any account with custom descriptions
- **Account Selection**: Choose which account to add funds to
- **Amount Validation**: Real-time validation of deposit amounts
- **Transaction Recording**: Automatically creates income transactions

### 📝 Manual Transaction Entry
- **Custom Transactions**: Add manual transactions to any account
- **Category Selection**: Choose from predefined spending categories
- **Amount & Description**: Full control over transaction details
- **Real-time Updates**: Immediate reflection in account balances

### 👨‍👩‍👧‍👦 Child/Beneficiary Management
- **Spending Limits**: Set and adjust spending limits for child cards
- **Progress Tracking**: Visual progress bars showing used vs. limit
- **Notification Controls**: Toggle notifications per child
- **Real-time Updates**: Immediate reflection of limit changes

### 📊 Analytics
- **Spending by Category**: Visual breakdown of expenses
- **Category Icons**: Intuitive icons for different spending categories
- **Percentage Analysis**: See what percentage of total spending each category represents

### 💱 Foreign Exchange (FX) Rates
- **Real-time Exchange Rates**: Live currency conversion rates from snapshot data
- **Multi-Currency Support**: Support for 150+ currencies with ISO 4217 standards
- **Currency Converter**: Interactive converter with amount input and real-time calculation
- **Rate History**: Snapshot-based exchange rates with capture timestamps
- **Currency Picker**: Easy selection of source and target currencies
- **KWD Base Rates**: All rates calculated against Kuwaiti Dinar (KWD)

### ⚙️ Settings & Customization
- **Dark/Light Theme**: Toggle between themes
- **Language Support**: English and Arabic with full RTL support
- **Security Settings**: Biometric and two-factor authentication toggles
- **Currency**: KWD (Kuwaiti Dinar) throughout the app

### 🔐 Security Features
- **Demo Authentication**: Visual login screen (no real backend)
- **User Registration**: Create new accounts with clean slate
- **Biometric Simulation**: Fake biometric authentication for transfers
- **2FA Simulation**: Two-factor authentication animations

## Technical Features

### 🎨 UI/UX
- **Material Design 3**: Modern, clean interface
- **Blue Theme**: Professional fintech color scheme
- **Responsive Design**: Works on various screen sizes
- **Micro-interactions**: Subtle animations and transitions
- **Accessibility**: Proper contrast and text sizing

### 🌍 Internationalization
- **English & Arabic**: Full language support
- **RTL Layout**: Proper right-to-left layout for Arabic
- **Localized Currency**: KWD formatting with proper symbols
- **Cultural Adaptation**: Appropriate text and layout for both languages

### 📱 State Management
- **Provider Pattern**: Clean state management
- **Mock Data**: Realistic sample data for demonstration
- **Real-time Updates**: Immediate UI updates on data changes

## Getting Started

### Prerequisites
- Flutter SDK (3.2.3 or higher)
- Dart SDK (>=3.2.3 <4.0.0)
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Key Dependencies
- **flutter_localizations**: Internationalization support
- **google_fonts**: Custom typography
- **provider**: State management
- **intl**: Date and number formatting
- **flutter_animate**: Smooth animations
- **flutter_dynamic_icon**: Dynamic app icon support
- **flutter_launcher_icons**: App icon generation

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd final_project_unicode
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### App Icon Setup

The app includes a custom wallet-themed icon. To set up the app icon:

1. **Use the provided setup script**:
   ```bash
   chmod +x setup_app_icon.sh
   ./setup_app_icon.sh
   ```

2. **Or manually configure**:
   - See `APP_ICON_GUIDE.md` for detailed instructions
   - Use `flutter_launcher_icons` package for automatic generation
   - Icon design: Wallet icon on white background with blue accent

3. **Generate icons**:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Demo Credentials
- **Email**: user@example.com
- **Password**: password123

### New User Registration
- Create a new account with clean slate (no existing data)
- Full name, email, phone, and password required
- Automatic navigation to home screen after registration

## App Structure

```
lib/
├── constants/
│   ├── app_colors.dart      # Color definitions
│   ├── app_strings.dart     # Localized strings
│   └── app_theme.dart       # Theme configuration
├── features/
│   └── fx_snapshot/         # Foreign Exchange features
│       ├── data/
│       │   ├── iso4217_meta.dart    # Currency metadata
│       │   └── snapshot_loader.dart # FX data loader
│       ├── domain/
│       │   ├── converter.dart       # Currency conversion logic
│       │   └── models.dart          # FX data models
│       ├── ui/
│       │   ├── currency_picker.dart # Currency selection widget
│       │   └── currency_rates_screen.dart # FX rates screen
│       └── util/
│           └── formatting.dart      # Currency formatting utilities
├── models/
│   ├── account.dart         # Account data model
│   └── transaction.dart     # Transaction data model
├── providers/
│   └── app_state.dart       # Main app state management
├── screens/
│   ├── splash_screen.dart   # App splash screen
│   ├── login_screen.dart    # Login screen
│   ├── register_screen.dart # User registration
│   ├── home_screen.dart     # Main dashboard
│   ├── accounts_screen.dart # Account list
│   ├── account_details_screen.dart # Account details
│   ├── account_form_screen.dart # Add/edit accounts
│   ├── transfer_screen.dart # Money transfer
│   ├── add_funds_screen.dart # Add funds to accounts
│   ├── add_transaction_screen.dart # Manual transaction entry
│   ├── analytics_screen.dart # Spending analytics
│   ├── beneficiaries_screen.dart # Child card management
│   ├── settings_screen.dart # App settings
│   ├── transaction_details_screen.dart # Transaction details
│   └── two_factor_auth_screen.dart # 2FA authentication
├── utils/
│   └── number_formatter.dart # Number formatting utilities
├── widgets/
│   ├── account_card.dart    # Reusable account card
│   ├── bank_logo_widget.dart # Bank logo display
│   ├── currency_text.dart   # Currency formatting widget
│   └── navigation_drawer.dart # App navigation drawer
└── main.dart               # App entry point
```

## Demo Walkthrough

### 1. Authentication
- **Login**: Sign in with demo credentials (user@example.com / password123)
- **Register**: Create a new account with clean slate
- Toggle biometric authentication if desired

### 2. Home Dashboard
- View total balance and account carousel
- Use quick actions to navigate to different sections

### 3. Account Management
- Add new accounts (bank, credit, or child)
- Edit existing accounts
- Delete accounts (with validation)

### 4. Money Transfers
- Select from and to accounts
- Enter amount and description
- Experience biometric authentication simulation
- View transfer success and updated balances

### 5. Add Funds
- Navigate to Add Funds from account details or home screen
- Select target account for deposit
- Enter amount and custom description
- Funds are automatically added as income transactions

### 6. Manual Transactions
- Add custom transactions to any account
- Select spending category and amount
- Add detailed descriptions
- Transactions immediately reflect in account balances

### 7. Child Card Management
- View child cards with spending limits
- Adjust spending limits using sliders
- Toggle notifications per child
- Monitor spending progress

### 8. Analytics
- View spending breakdown by category
- See percentages and amounts
- Analyze spending patterns

### 9. Foreign Exchange Rates
- View real-time currency exchange rates
- Use the currency converter to calculate amounts
- Select from 150+ supported currencies
- See rates captured from snapshot data

### 10. Settings
- Toggle between light and dark themes
- Switch between English and Arabic
- Configure security settings
- View app information

## Mock Data

The app includes realistic mock data:
- **5 Sample Accounts**: Main bank, credit card, savings, and 2 child cards
- **7 Sample Transactions**: Various categories and amounts
- **Realistic Balances**: Proper KWD amounts and spending limits
- **150+ Currency Rates**: Real exchange rates snapshot from October 2025
- **ISO 4217 Metadata**: Complete currency information and formatting rules
- **New User Experience**: Clean slate for registered users (no pre-existing data)

## Features in Detail

### Account Types
- **Bank Account**: Regular checking/savings accounts
- **Credit Card**: Credit cards with spending limits
- **Child Card**: Managed cards for children with parental controls

### Transaction Categories
- Food, Transportation, Shopping, Entertainment
- Utilities, Healthcare, Education, Travel
- Salary, Transfer, Other

### Security Features
- **Biometric Authentication**: Simulated fingerprint/face recognition
- **Two-Factor Authentication**: Simulated 2FA for transfers
- **Input Validation**: Comprehensive form validation
- **Error Handling**: User-friendly error messages

## Technical Implementation

### State Management
- Uses Provider pattern for clean state management
- Centralized AppState class handles all app data
- Real-time UI updates on state changes
- Reactive UI with Consumer widgets

### Localization
- Custom localization system with English/Arabic support
- RTL layout support for Arabic
- Localized currency formatting
- Dynamic text direction switching

### Theme System
- Light and dark theme support
- Consistent blue color scheme (#1E40AF primary)
- Material Design 3 components
- Google Fonts integration for typography

### Data Models
- Clean, immutable data models
- Proper type safety and validation
- Efficient data operations
- JSON serialization support

### Foreign Exchange Implementation
- **Snapshot-based Data**: Pre-loaded exchange rates from JSON
- **ISO 4217 Compliance**: Standard currency codes and metadata
- **Real-time Conversion**: Instant currency calculations
- **Modular Architecture**: Clean separation of data, domain, and UI layers
- **Error Handling**: Graceful handling of missing rates or invalid inputs

### Architecture Patterns
- **Feature-based Structure**: Organized by business features
- **Clean Architecture**: Separation of concerns with data/domain/ui layers
- **Provider Pattern**: Reactive state management
- **Widget Composition**: Reusable UI components

## Recent Updates

### Version 1.0.0+1
- **User Registration**: Added complete user registration flow
- **Add Funds Feature**: Deposit money to any account with custom descriptions
- **Manual Transaction Entry**: Add custom transactions with category selection
- **Enhanced Navigation**: Improved screen flow and user experience
- **Clean Slate Registration**: New users start with empty state

## Future Enhancements

Potential features for future versions:
- Real backend integration with live API
- Push notifications for transactions and alerts
- Advanced analytics with interactive charts
- Budget planning and goal setting features
- Export functionality (PDF, CSV)
- Real-time exchange rate updates
- Real biometric authentication integration
- Multi-language support expansion
- Offline mode with data synchronization
- Advanced security features (PIN, pattern lock)

## Contributing

This is a demo project for educational purposes. Feel free to:
- Fork the repository
- Submit issues and feature requests
- Create pull requests for improvements

## License

This project is for educational purposes. All data is mock data and no real financial transactions are processed.

## Support

For questions or support, please refer to the Flutter documentation or create an issue in the repository.
