import 'dart:ui';

import '../../core/translations/translate.dart';
import '../../presentation/utils/app_colors.dart';

enum OrderStatus {
  pending,
  preparing,
  delivering,
  delivered,
  canceled;

  @override
  String toString() {
    switch (this) {
      case OrderStatus.pending:
        return Translate.get('pending');
      case OrderStatus.preparing:
        return Translate.get('preparing');
      case OrderStatus.delivering:
        return Translate.get('delivering');
      case OrderStatus.delivered:
        return Translate.get('delivered');
      case OrderStatus.canceled:
        return Translate.get('cancelled');
      default:
        return Translate.get('pending');
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.pendingColor;
      case OrderStatus.preparing:
        return AppColors.preparingColor;
      case OrderStatus.delivering:
        return AppColors.deliveringColor;
      case OrderStatus.delivered:
        return AppColors.deliveredColor;
      case OrderStatus.canceled:
        return AppColors.canceledColor;
      default:
        return AppColors.pendingColor;
    }
  }
}
