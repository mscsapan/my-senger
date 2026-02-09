import 'package:flutter/material.dart';

import '../../../utils/constraints.dart';
import '../../../utils/utils.dart';

/// Animated typing indicator bubble shown when other user is typing
class TypingIndicatorBubble extends StatefulWidget {
  const TypingIndicatorBubble({super.key});

  @override
  State<TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<TypingIndicatorBubble>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Create staggered animations for each dot
    _dotAnimations = List.generate(3, (index) {
      final startInterval = index * 0.2;
      final endInterval = startInterval + 0.5;

      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(
            begin: 0.0,
            end: -8.0,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: -8.0,
            end: 0.0,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 1,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            startInterval.clamp(0.0, 1.0),
            endInterval.clamp(0.0, 1.0),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Utils.symmetric(h: 12.0, v: 8.0),
      padding: Utils.symmetric(h: 16.0, v: 14.0),
      decoration: BoxDecoration(
        color: disableColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
          bottomLeft: Radius.circular(4.0),
          bottomRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return Transform.translate(
                offset: Offset(0, _dotAnimations[index].value),
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 4.0 : 0),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: grayColor.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Simpler inline typing indicator (dots only)
class InlineTypingIndicator extends StatefulWidget {
  const InlineTypingIndicator({super.key, this.color, this.dotSize = 6.0});

  final Color? color;
  final double dotSize;

  @override
  State<InlineTypingIndicator> createState() => _InlineTypingIndicatorState();
}

class _InlineTypingIndicatorState extends State<InlineTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? grayColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.25;
            final animValue = (_controller.value - delay) % 1.0;
            final opacity = (0.3 + (0.7 * _calculateOpacity(animValue))).clamp(
              0.3,
              1.0,
            );

            return Container(
              margin: EdgeInsets.only(right: index < 2 ? 3.0 : 0),
              width: widget.dotSize,
              height: widget.dotSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  double _calculateOpacity(double value) {
    // Create a pulse effect
    if (value < 0.5) {
      return value * 2;
    } else {
      return (1.0 - value) * 2;
    }
  }
}
