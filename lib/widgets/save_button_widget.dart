import 'package:flutter/material.dart';

class SaveButtonWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String buttonText;
  final String? loadingText;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final double borderRadius;
  final double elevation;
  final TextStyle? textStyle;

  const SaveButtonWidget({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.buttonText = 'Save',
    this.loadingText,
    this.backgroundColor = const Color(0xFF4285F4),
    this.foregroundColor = Colors.white,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 25,
    this.elevation = 0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: elevation,
        ),
        child: isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              buttonText,
              style: textStyle ?? const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
      ),
    );
  }
}