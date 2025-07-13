import 'package:flutter/material.dart';
import 'package:stadium_food/src/data/models/order_status.dart';
import 'package:stadium_food/src/core/constants/colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';

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
            'Order received',
            orderTime != null ? _formatTime(orderTime!) : '',
            isFirst: true,
          ),
          _buildTimelineItem(
            context,
            OrderStatus.preparing,
            'Preparing',
            orderTime != null ? _formatTime(orderTime!.add(const Duration(minutes: 10))) : '',
          ),
          _buildTimelineItem(
            context,
            OrderStatus.delivering,
            'On the way',
            orderTime != null ? _formatTime(orderTime!.add(const Duration(minutes: 20))) : '',
            showTrackingButton: false,
          ),
          _buildTimelineItem(
            context,
            OrderStatus.delivered,
            'Delivered',
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
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.blue : Colors.grey[200],
                    border: Border.all(
                      color: isCompleted ? Colors.blue : Colors.grey[300]!,
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
                      color: isCompleted ? Colors.blue : Colors.grey[300],
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
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[600],
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
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TRACKING',
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
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _calculateRemainingTime(DateTime deliveryTime) {
    final now = DateTime.now();
    final difference = deliveryTime.difference(now);
    return '${difference.inMinutes} min';
  }
}
