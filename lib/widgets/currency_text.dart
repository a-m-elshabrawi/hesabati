import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../constants/app_colors.dart';

class CurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool showSign;
  final bool isPositive;
  final Color? forceColor;

  const CurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.showSign = false,
    this.isPositive = true,
    this.forceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isArabic = appState.isArabic;
        final formattedAmount = appState.formatCurrency(amount.abs());
        
        Color textColor;
        if (forceColor != null) {
          textColor = forceColor!;
        } else if (isPositive) {
          textColor = amount >= 0 ? AppColors.income : AppColors.expense;
        } else {
          textColor = amount < 0 ? AppColors.income : AppColors.expense;
        }

        String displayText;
        if (showSign) {
          final sign = amount >= 0 ? '+' : '-';
          displayText = isArabic ? '$formattedAmount $sign' : '$sign $formattedAmount';
        } else {
          displayText = formattedAmount;
        }

        return Text(
          displayText,
          style: style?.copyWith(color: textColor) ?? 
                 TextStyle(
                   color: textColor,
                   fontWeight: FontWeight.w600,
                 ),
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        );
      },
    );
  }
}
