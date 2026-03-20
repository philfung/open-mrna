import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

IconData? getLucideIcon(String? name) {
  switch (name) {
    case 'database':
      return LucideIcons.database;
    case 'zap':
      return LucideIcons.zap;
    case 'target':
      return LucideIcons.target;
    case 'pen-tool':
      return LucideIcons.penTool;
    case 'printer':
      return LucideIcons.printer;
    case 'factory':
      return LucideIcons.factory;
    case 'package':
      return LucideIcons.package;
    case 'flask-conical':
      return LucideIcons.flaskConical;
    default:
      return null;
  }
}
