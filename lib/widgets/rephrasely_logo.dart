import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class RephraselyLogo extends StatelessWidget {
  final double? size;
  final bool showText;
  final Color? textColor;
  final double? textSize;
  final bool animate;

  const RephraselyLogo({
    super.key,
    this.size,
    this.showText = false,
    this.textColor,
    this.textSize,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 120.0;

    Widget logoWidget = Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(logoSize * 0.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(logoSize * 0.2),
        child: Image.asset(
          AppAssets.logo,
          width: logoSize,
          height: logoSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback widget if logo image is not found
            return Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(logoSize * 0.2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Chat bubbles
                  Positioned(
                    left: logoSize * 0.15,
                    top: logoSize * 0.25,
                    child: Container(
                      width: logoSize * 0.3,
                      height: logoSize * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(logoSize * 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    right: logoSize * 0.15,
                    bottom: logoSize * 0.25,
                    child: Container(
                      width: logoSize * 0.25,
                      height: logoSize * 0.2,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9BCF53),
                        borderRadius: BorderRadius.circular(logoSize * 0.06),
                      ),
                    ),
                  ),
                  // Network/AI icon in center
                  Icon(
                    Icons.hub_outlined,
                    size: logoSize * 0.3,
                    color: Colors.white,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    if (animate) {
      logoWidget = TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1200),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: logoWidget,
      );
    }

    if (!showText) {
      return logoWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoWidget,
        SizedBox(height: logoSize * 0.15),
        Text(
          'REPHRASELY',
          style: AppTextStyles.heading1.copyWith(
            fontSize: textSize ?? 24,
            fontWeight: FontWeight.w800,
            color: textColor ?? AppColors.primary,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

class RephraselyIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const RephraselyIcon({super.key, this.size = 32.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logoIcon,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback icon if logo image is not found
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_fix_high_rounded,
            size: size * 0.6,
            color: color ?? Colors.white,
          ),
        );
      },
    );
  }
}
