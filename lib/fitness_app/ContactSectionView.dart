import 'package:flutter/material.dart';

class ContactSectionView extends StatelessWidget {
  const ContactSectionView({
    Key? key,
    required this.animation,
    required this.animationController,
    this.onContactPressed,
  }) : super(key: key);

  final Animation<double> animation;
  final AnimationController animationController;
  final VoidCallback? onContactPressed;

  // Color palette
  static const Color _lightBlue = Color(0xFFE6F0FA);
  static const Color _darkBlue = Color(0xFF1E3A8A);
  static const Color _accentRed = Color(0xFFFF5252);
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF666666);
  static const Color _hintText = Color(0xFF999999);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0.0, 30 * (1.0 - animation.value)),
            child: GestureDetector(
              onTap: onContactPressed,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Colored bar indicator
                      Container(
                        width: 4,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _darkBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Main content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.emergency_rounded,
                                  color: _accentRed,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Emergency Setup',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _darkBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add emergency contacts to assist Alzheimer\'s '
                              'patients in case of disorientation or danger.',
                              style: TextStyle(
                                fontSize: 14,
                                color: _textPrimary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to configure',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _hintText,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: _textSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
