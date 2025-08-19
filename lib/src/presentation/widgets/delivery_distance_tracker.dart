import 'package:flutter/material.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/core/translations/translate.dart';

class DeliveryDistanceTracker extends StatelessWidget {
  final double distance;
  final bool isDelivered;

  const DeliveryDistanceTracker({
    Key? key,
    required this.distance,
    this.isDelivered = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.delivery_dining,
                color: AppColors.primaryColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDelivered 
                          ? Translate.get('delivered')
                          : Translate.get('onTheWay'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${distance.toStringAsFixed(0)} ${Translate.get('meters')} ${isDelivered ? Translate.get('completed') : Translate.get('away')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isDelivered) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _calculateProgress(),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
    );
  }

  double _calculateProgress() {
    // Assuming maximum delivery distance is 5000 meters
    const maxDistance = 500.0;
    return 1 - (distance.clamp(0, maxDistance) / maxDistance);
  }
}
