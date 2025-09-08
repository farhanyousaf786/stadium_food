import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/models/order_status.dart';
import 'package:stadium_food/src/core/constants/colors.dart';

class OrderStatusStepper extends StatelessWidget {
  final OrderStatus status;
  final DateTime? orderTime;
  final DateTime? deliveryTime;

  const OrderStatusStepper({
    super.key,
    required this.status,
    this.orderTime,
    this.deliveryTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _buildTimelineItem(
            context,
            OrderStatus.pending,
            Translate.get('orderReceived'),
            orderTime != null ? _formatTime(orderTime!) : '',
            isFirst: true,
          ),
          _buildTimelineItem(
            context,
            OrderStatus.preparing,
            Translate.get('preparing'),
            orderTime != null ? _formatTime(orderTime!.add(const Duration(minutes: 10))) : '',
          ),
          _buildTimelineItem(
            context,
            OrderStatus.delivering,
            Translate.get('onTheWay'),
            orderTime != null ? _formatTime(orderTime!.add(const Duration(minutes: 20))) : '',
            showTrackingButton: false,
          ),
          _buildTimelineItem(
            context,
            OrderStatus.delivered,
            Translate.get('delivered'),
            orderTime != null ? _formatTime(orderTime!.add(const Duration(minutes: 30))) : '',
            isLast: true,
          ),
        ],
      ),
    );
  }



  Widget _buildTimelineItem(
    BuildContext context,
    OrderStatus stepStatus,
    String label,
    String timeText,
    {bool isFirst = false,
    bool isLast = false,
    bool showTrackingButton = false,
  }) {
    final isCompleted = status.index >= stepStatus.index;

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.primaryDarkColor : Colors.grey[200],
                    border: Border.all(
                      color: isCompleted ? AppColors.primaryDarkColor : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconForStatus(stepStatus),
                      size: 14,
                      color: isCompleted ? Colors.white : Colors.grey[400],
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? AppColors.primaryDarkColor : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svg/ic_timer.svg",
                      colorFilter:  ColorFilter.mode(
                        Colors.grey[600]!,
                        BlendMode.srcIn,
                      ),

                    ),

                    const SizedBox(width: 4),
                    Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (showTrackingButton) ...[                  
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarkColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Translate.get('tracking'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
                if (!isLast)
                  const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.receipt;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.delivering:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check;
      default:
        return Icons.circle;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final day = time.day;
    final month = _getMonthName(time.month);
    final year = time.year;
    return '$hour:$minute AM, $day $month $year';
  }

  String _getMonthName(int month) {
    final months = [
      Translate.get('jan'), Translate.get('feb'), Translate.get('mar'),
      Translate.get('apr'), Translate.get('may'), Translate.get('jun'),
      Translate.get('jul'), Translate.get('aug'), Translate.get('sep'),
      Translate.get('oct'), Translate.get('nov'), Translate.get('dec')
    ];
    return months[month - 1];
  }

}
