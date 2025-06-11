import 'package:flutter/material.dart';

const int mobileMaxWidth = 600;
const int tabletMaxWidth = 1200;

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileMaxWidth) {
          return mobileBody;
        } else if (constraints.maxWidth < tabletMaxWidth) {
          return tabletBody ?? mobileBody;
        } else {
          return desktopBody ?? tabletBody ?? mobileBody;
        }
      },
    );
  }
} 