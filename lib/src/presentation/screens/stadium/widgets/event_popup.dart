import 'package:flutter/material.dart';

class _EventItem {
  final String title;
  final String subtitle;
  final String image;
  final Color color;

  const _EventItem({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.color,
  });
}

class EventPopup extends StatefulWidget {
  const EventPopup({super.key});

  @override
  State<EventPopup> createState() => _EventPopupState();
}

class _EventPopupState extends State<EventPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  final List<_EventItem> _events = [
    _EventItem(
      title: 'Welcome to Stadium Food!',
      subtitle: 'Your ultimate game-day companion',
      image: 'https://firebasestorage.googleapis.com/v0/b/fans-food-stf.firebasestorage.app/o/static-images%2Fslide1.jpg?alt=media&token=4f077b5b-424b-4155-8dec-c4f0c33d914e',
      color: const Color(0xFF4CAF50),
    ),
    _EventItem(
      title: 'Order From Your Seat',
      subtitle: 'No more missing the action',
      image: 'https://firebasestorage.googleapis.com/v0/b/fans-food-stf.firebasestorage.app/o/static-images%2Fslide1.jpg?alt=media&token=4f077b5b-424b-4155-8dec-c4f0c33d914e',
      color: const Color(0xFF4CAF50),
    ),
    _EventItem(
      title: 'Skip The Lines',
      subtitle: 'Food delivered to your seat',
      image: 'https://firebasestorage.googleapis.com/v0/b/fans-food-stf.firebasestorage.app/o/static-images%2Fslide1.jpg?alt=media&token=4f077b5b-424b-4155-8dec-c4f0c33d914e',
      color: const Color(0xFF4CAF50),
    ),
  ];
  int _currentEventIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
    _startEventAnimation();
  }

  void _startEventAnimation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentEventIndex = (_currentEventIndex + 1) % _events.length;
        });
        _startEventAnimation();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = _events[_currentEventIndex];
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(event.image),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: event.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              event.title,
                              key: ValueKey<String>(event.title),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: event.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              event.subtitle,
                              key: ValueKey<String>(event.subtitle),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _events.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentEventIndex
                          ? event.color
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: event.color.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Got it!',
                  style: TextStyle(
                    color: event.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
