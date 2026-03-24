import 'package:flutter/widgets.dart';

/// Calculates a scaling factor based on the current window width.
/// Returns a value between 0.5 and 1.0.
double getBoxScalingFactor(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double scale = 1.0;
  double maxWidth = 800;
  double minWidth = 400;
  double minScale = .5;
  if (width < minWidth) {
    scale = minScale;
  } else if (width > maxWidth) {
    scale = 1.0;
  } else {
    scale = minScale + (1.0 - minScale) * (width - minWidth) / (maxWidth - minWidth);
  }
  return scale;
}
