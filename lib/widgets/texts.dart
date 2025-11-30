import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAutoSizeText extends StatelessWidget {
  final bool isDark;
  final String text;
  final int? maxlines;
  final double fontSize;
  final Color lightTextColor;
  final Color darkTextColor;
  final FontWeight fontWeight;
  final bool? softWrap;
  final TextAlign? textAlign;
  final double? height;
  final double? textScaleFactor;
  final double? letterspacing;
  final TextDecoration? decoration;
  final dynamic? fontFamily;

  const CustomAutoSizeText({
    super.key,
    this.isDark = false,
    required this.text,
    this.maxlines,
    this.fontSize = 14,
    this.lightTextColor = Colors.black,
    this.darkTextColor = Colors.white,
    this.fontWeight = FontWeight.w500,
    this.softWrap,
    this.textAlign,
    this.height,
    this.textScaleFactor,
    this.letterspacing,
    this.decoration,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      maxLines: maxlines,
      maxFontSize: fontSize,
      minFontSize: fontSize,
      textScaleFactor: textScaleFactor,
      softWrap: softWrap,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: TextStyle(
          color: isDark ? darkTextColor : lightTextColor,
          fontWeight: fontWeight,
          letterSpacing: letterspacing,
          fontFamily: fontFamily,
          fontSize: fontSize.sp,
          height: height,
          decoration: decoration),
    );
  }
}

class SizeControlText extends StatelessWidget {
  final bool isDark;
  final String text;
  final int? maxLines;
  final double fontSize; // base font size
  final double maxAllowedFontSize; // maximum allowed scaled font size
  final Color lightTextColor;
  final Color darkTextColor;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final double? height;
  final double? letterSpacing;
  final String? fontFamily;

  const SizeControlText({
    super.key,
    this.isDark = false,
    required this.text,
    this.maxLines,
    this.fontSize = 14,
    this.maxAllowedFontSize = 16, // default max
    this.lightTextColor = Colors.black,
    this.darkTextColor = Colors.white,
    this.fontWeight = FontWeight.w500,
    this.textAlign,
    this.height,
    this.letterSpacing,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);

    // Scale and clamp the font size
    final scaledFontSize = (fontSize * textScale).clamp(
      fontSize,
      maxAllowedFontSize,
    );

    return AutoSizeText(
      text,
      maxFontSize: scaledFontSize,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: TextStyle(
        color: isDark ? darkTextColor : lightTextColor,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        fontFamily: fontFamily,
        fontSize: scaledFontSize,
        height: height,
      ),
    );
  }
}

class CustomAutoSizeText2 extends StatelessWidget {
  final bool isDark;
  final String text;
  final int? maxLines;
  final double fontSize; // base font size
  final double maxAllowedFontSize; // maximum scaled font size
  final Color lightTextColor;
  final Color darkTextColor;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final double? height;
  final double? letterSpacing;
  final TextDecoration? decoration;
  final String? fontFamily;

  const CustomAutoSizeText2({
    super.key,
    this.isDark = false,
    required this.text,
    this.maxLines,
    this.fontSize = 14,
    this.maxAllowedFontSize = 16,
    this.lightTextColor = Colors.black,
    this.darkTextColor = Colors.white,
    this.fontWeight = FontWeight.w500,
    this.textAlign,
    this.height,
    this.letterSpacing,
    this.decoration,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final deviceTextScale = MediaQuery.textScaleFactorOf(context);

    // Calculate a custom limited scale
    final customScale = (fontSize * deviceTextScale) / fontSize;
    final limitedScale = customScale > (maxAllowedFontSize / fontSize)
        ? (maxAllowedFontSize / fontSize)
        : customScale;

    return AutoSizeText(
      text,
      maxLines: maxLines,

      // minFontSize: fontSize,
      // maxFontSize: fontSize,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      textScaleFactor: limitedScale, // 🛑 fix: manually set text scale factor
      style: TextStyle(
        color: isDark ? darkTextColor : lightTextColor,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        decoration: decoration,
        fontFamily: fontFamily,
        fontSize: fontSize, // keep the original size
        height: height,
      ),
    );
  }
}

// You will replace CustomAutoSizeText2 with a standard Text widget
// in this example for simplicity, but you can integrate its logic
// back in if needed. We'll use a basic style for demonstration.

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final int charLimit;
  final Color textColor;
  final double textSize;
  final FontWeight textFontWeight;
  final int maxLines;
  final Color buttonColor;
  final double buttonTextSize;
  final FontWeight buttonTextFontWeight;

  const ExpandableTextWidget({
    super.key,
    required this.text,
    this.charLimit = 150, // Default character limit
    // Match your desired text style
    this.textColor = Colors.grey,
    this.textSize = 14,
    this.textFontWeight = FontWeight.w400,
    this.maxLines = 8,
    // Style for the "See More/Less" button
    this.buttonColor = Colors.blue, // A clear accent color
    this.buttonTextSize = 14,
    this.buttonTextFontWeight = FontWeight.bold,
  });

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  // 1. State variable to track if the text is expanded
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Check if the text is short enough to not need a button
    final bool isTooLong = widget.text.length > widget.charLimit;

    // 2. Determine the displayed text based on expansion state
    final String displayedText = _isExpanded || !isTooLong
        ? widget.text
        : widget.text.substring(0, widget.charLimit) + '... ';

    // 3. Determine the button text
    final String buttonText = _isExpanded ? ' See Less' : ' See More';

    return AutoSizeText.rich(
      TextSpan(
        children: <TextSpan>[
          // 1. The Main Text Span (Truncated)
          TextSpan(
            text: displayedText,
            style: TextStyle(
              color: widget.textColor,
              fontSize: widget.textSize.sp,
              fontWeight: widget.textFontWeight,
            ),
          ),

          // 2. The Button Text Span (Clickable only if isTooLong)
          if (isTooLong)
            TextSpan(
              text: buttonText,
              style: TextStyle(
                color: widget.buttonColor,
                fontSize: widget.buttonTextSize.sp,
                fontWeight: widget.buttonTextFontWeight,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
            ),
        ],
      ),
      maxFontSize: widget.textSize.sp,
      minFontSize: widget.textSize.sp,
    );
    // return Wrap(
    //   crossAxisAlignment: WrapCrossAlignment.start,
    //   children: <Widget>[
    //     // Display the text (truncated or full)
    //     CustomAutoSizeText2(
    //       text: displayedText,
    //       lightTextColor: widget.textColor,
    //       fontSize: widget.textSize,
    //       maxAllowedFontSize: widget.textSize,
    //       maxLines: widget.maxLines,
    //       fontWeight: widget.textFontWeight,
    //     ),

    //     // Display the button only if the text exceeds the limit
    //     if (isTooLong)
    //       GestureDetector(
    //         onTap: () {
    //           // 4. Toggle the state when the button is tapped
    //           setState(() {
    //             _isExpanded = !_isExpanded;
    //           });
    //         },
    //         child: CustomAutoSizeText2(
    //           text: buttonText,
    //           lightTextColor: widget.buttonColor,
    //           fontSize: widget.buttonTextSize,
    //           maxAllowedFontSize: widget.buttonTextSize,
    //           maxLines: 2,
    //           fontWeight: widget.buttonTextFontWeight,
    //         ),
    //       ),
    //   ],
    // );
  }
}
