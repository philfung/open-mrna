import 'package:flutter/material.dart';

enum NodeType { step, data, title, group }

class WorkflowNodeData {
  final String id;
  final NodeType type;
  final String title;
  final String? description;
  final String? goal;
  final String? hardware;
  final String? software;
  final String? outsourced;
  final String? cost;
  final String? color;
  final String? iconName;
  final String? image;
  final List<String>? images;
  final String? parentNode;
  final Offset? position;
  final Size? size;
  final String? label;

  WorkflowNodeData({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.goal,
    this.hardware,
    this.software,
    this.outsourced,
    this.cost,
    this.color,
    this.iconName,
    this.image,
    this.images,
    this.parentNode,
    this.position,
    this.size,
    this.label,
  });
}

class WorkflowEdgeData {
  final String id;
  final String source;
  final String target;
  final bool animated;
  final String? label;
  final bool dashed;

  WorkflowEdgeData({
    required this.id,
    required this.source,
    required this.target,
    this.animated = false,
    this.label,
    this.dashed = false,
  });
}

class WorkflowStep {
  final int id;
  final String title;
  final String part;
  final List<String> nodeIds;

  WorkflowStep({
    required this.id,
    required this.title,
    required this.part,
    required this.nodeIds,
  });
}
