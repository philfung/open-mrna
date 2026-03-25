import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

IconData? getLucideIcon(String? iconName) {
  if (iconName == null) return null;

  switch (iconName.toLowerCase()) {
    case 'syringe':
      return LucideIcons.syringe;
    case 'dna':
      return LucideIcons.dna;
    case 'microscope':
      return LucideIcons.microscope;
    case 'bar-chart':
      return LucideIcons.barChart;
    case 'file-text':
      return LucideIcons.fileText;
    case 'flask-conical':
      return LucideIcons.flaskConical;
    case 'test-tube':
      return LucideIcons.testTube;
    case 'pill':
      return LucideIcons.pill;
    case 'container':
      return LucideIcons.container;
    case 'scroll':
      return LucideIcons.scroll;
    case 'clipboard':
      return LucideIcons.clipboard;
    case 'search':
      return LucideIcons.search;
    case 'activity':
      return LucideIcons.activity;
    case 'beaker':
      return LucideIcons.beaker;
    case 'database':
      return LucideIcons.database;
    case 'layers':
      return LucideIcons.layers;
    case 'settings':
      return LucideIcons.settings;
    case 'help-circle':
      return LucideIcons.helpCircle;
    case 'info':
      return LucideIcons.info;
    case 'alert-circle':
      return LucideIcons.alertCircle;
    case 'check-circle':
      return LucideIcons.checkCircle;
    default:
      return null;
  }
}
