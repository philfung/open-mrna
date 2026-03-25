import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'providers/workflow_provider.dart';
import 'widgets/workflow_node.dart';
import 'models/workflow_data.dart';
import 'models/mock_data.dart';
import 'widgets/workflow_detail_view.dart';
import 'widgets/welcome_modal.dart';
import 'utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

const double MARGIN_VERTICAL_GROUP_NODES = 200.0;
const double MARGIN_VERTICAL_DATA_NODES = 30.0;
const double MARGIN_HORIZONTAL_BETWEEN_DATA_NODES = 40.0;
const double NODE_WIDTH = 600.0;
const String APP_VERSION = 'v1.0.0';

void main() {
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenVaxx',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        fontFamily: 'Inter',
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const WorkflowScreen(),
    );
  }
}

class WorkflowScreen extends ConsumerStatefulWidget {
  const WorkflowScreen({super.key});

  @override
  ConsumerState<WorkflowScreen> createState() => _WorkflowScreenState();
}

class _WorkflowScreenState extends ConsumerState<WorkflowScreen>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _animationController;
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _interactiveChildKey = GlobalKey();
  final Map<String, GlobalKey> _nodeKeys = {};
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    for (var node in initialNodes) {
      _nodeKeys[node.id] = GlobalKey();
    }

    // Initial focus on step 1
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusOnStep(1);
      _showWelcomeModal();
    });
  }

  void _showWelcomeModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const WelcomeModal(),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _focusOnStep(int stepId) {
    debugPrint('Focusing on step $stepId');
    final step = workflowSteps.firstWhere((s) => s.id == stepId);

    if (_canvasKey.currentContext == null) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _focusOnStep(stepId),
      );
      return;
    }

    final RenderBox interactiveChildBox =
        _interactiveChildKey.currentContext!.findRenderObject() as RenderBox;

    Rect? combinedRect;

    for (final nodeId in step.nodeIds) {
      final key = _nodeKeys[nodeId];
      if (key?.currentContext != null) {
        final RenderBox nodeBox =
            key!.currentContext!.findRenderObject() as RenderBox;
        final position = nodeBox.localToGlobal(
          Offset.zero,
          ancestor: interactiveChildBox,
        );
        final rect = position & nodeBox.size;
        if (combinedRect == null) {
          combinedRect = rect;
        } else {
          combinedRect = combinedRect.expandToInclude(rect);
        }
      }
    }

    if (combinedRect == null) return;

    final double x = combinedRect.center.dx;
    final double y = combinedRect.center.dy;

    final viewportSize = MediaQuery.of(context).size;
    final double detailPanelWidth = _getDetailPanelWidth(viewportSize.width);
    final double availableWidth = viewportSize.width - detailPanelWidth;

    // Calculate scale with some padding
    const double viewPadding = 32.0;

    // Use a slightly more robust scale calculation if the rect has size
    double scale = 1.0;
    if (combinedRect.width > 0 && combinedRect.height > 0) {
      final double scaleX =
          (availableWidth - viewPadding * 2) / combinedRect.width;
      final double scaleY =
          (viewportSize.height - viewPadding * 2) / combinedRect.height;
      scale = math.min(math.min(scaleX, scaleY), 1.0).clamp(0.8, 1.0);
    }

    final targetMatrix = Matrix4.identity()
      ..translate(availableWidth / 2, viewportSize.height / 2)
      ..scale(scale)
      ..translate(-x, -y);

    _animateToMatrix(targetMatrix);
  }

  double _getDetailPanelWidth(double screenWidth) {
    return math.min(screenWidth * 0.5, 450.0);
  }

  void _animateToMatrix(Matrix4 targetMatrix) {
    final startMatrix = _transformationController.value;
    final animation = Matrix4Tween(begin: startMatrix, end: targetMatrix)
        .animate(
          CurvedAnimation(
            parent: AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 800),
            )..forward(),
            curve: Curves.easeInOutCubic,
          ),
        );

    animation.addListener(() {
      _transformationController.value = animation.value;
    });
  }

  void _onNextPressed(WorkflowState state) {
    if (state.currentStepId < workflowSteps.length) {
      ref.read(workflowProvider.notifier).nextStep();
    }
  }

  void _onPrevPressed(WorkflowState state) {
    if (state.currentStepId > 1) {
      ref.read(workflowProvider.notifier).prevStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workflowProvider);
    final viewportSize = MediaQuery.of(context).size;

    // Handle auto-focus on step change
    ref.listen(workflowProvider.select((s) => s.currentStepId), (
      previous,
      next,
    ) {
      if (previous != next) {
        _focusOnStep(next);
      }
    });

    // Handle responsive re-centering on resize
    if (_lastSize != null && _lastSize != viewportSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusOnStep(state.currentStepId);
      });
    }
    _lastSize = viewportSize;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
              event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _onNextPressed(state);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _onPrevPressed(state);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            _buildHeader(state),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: _getDetailPanelWidth(
                      MediaQuery.of(context).size.width,
                    ),
                    child: const WorkflowDetailView(),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        // Dynamic Layout Canvas
                        InteractiveViewer(
                          transformationController: _transformationController,
                          constrained: false,
                          boundaryMargin: const EdgeInsets.symmetric(
                            horizontal: 2000,
                            vertical: 2000,
                          ),
                          minScale: 0.1,
                          maxScale: 2.5,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double detailPanelWidth =
                                  _getDetailPanelWidth(
                                    MediaQuery.of(context).size.width,
                                  );
                              final viewportWidth =
                                  MediaQuery.of(context).size.width -
                                  detailPanelWidth;
                              final canvasWidth = math.max(
                                1600.0,
                                viewportWidth,
                              );

                              return Container(
                                key: _interactiveChildKey,
                                padding: const EdgeInsets.fromLTRB(
                                  100,
                                  600,
                                  100,
                                  1200,
                                ),
                                width: canvasWidth,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: SizedBox(
                                    width: 1400, // Inner width
                                    child: Stack(
                                      key: _canvasKey,
                                      children: [
                                        // Edges Layer
                                        Positioned.fill(
                                          child: IgnorePointer(
                                            child: AnimatedBuilder(
                                              animation: _animationController,
                                              builder: (context, child) {
                                                return CustomPaint(
                                                  painter: DynamicEdgePainter(
                                                    edges: state.edges,
                                                    nodeKeys: _nodeKeys,
                                                    canvasKey: _canvasKey,
                                                    animationValue:
                                                        _animationController
                                                            .value,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        // Content Layer
                                        _buildWorkflowLayout(state),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // _buildBottomControls(step, state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowLayout(WorkflowState state) {
    final groupNodes = state.nodes
        .where((n) => n.type == NodeType.group)
        .toList();
    final Set<String> renderedNodeIds = {};

    return Column(
      children: [
        for (var group in groupNodes) ...[
          _buildGroupWidget(group, state, renderedNodeIds),
          const SizedBox(height: MARGIN_VERTICAL_GROUP_NODES),
        ],
      ],
    );
  }

  Widget _buildGroupWidget(
    WorkflowNodeData group,
    WorkflowState state,
    Set<String> renderedNodeIds,
  ) {
    final scale = getBoxScalingFactor(context);
    final children = state.nodes
        .where((n) => n.parentNode == group.id)
        .toList();
    final titleNode = children.firstWhere((n) => n.type == NodeType.title);
    final otherNodes = children.where((n) => n.type != NodeType.title).toList();

    return Container(
      key: _nodeKeys[group.id],
      padding: EdgeInsets.all(60 * scale),
      decoration: BoxDecoration(
        color: _getColor(group.color).withOpacity(0.03),
        borderRadius: BorderRadius.circular(48 * scale),
        border: Border.all(
          color: _getColor(group.color).withOpacity(0.2),
          width: 3 * scale,
        ),
      ),
      child: Column(
        children: [
          WorkflowNode(data: titleNode, key: _nodeKeys[titleNode.id]),
          SizedBox(height: 80 * scale),
          // We need to order the steps and their data nodes
          ..._buildStepsInGroup(otherNodes, state, renderedNodeIds, group.id),
        ],
      ),
    );
  }

  List<Widget> _buildStepsInGroup(
    List<WorkflowNodeData> nodes,
    WorkflowState state,
    Set<String> renderedNodeIds,
    String groupId,
  ) {
    final stepNodes = nodes.where((n) => n.type == NodeType.step).toList();
    stepNodes.sort((a, b) => a.id.compareTo(b.id));

    List<Widget> groupWidgets = [];

    // First, identify all data nodes in this group
    final groupDataNodes = nodes.where((n) => n.type == NodeType.data).toList();

    for (var step in stepNodes) {
      // Data nodes that are INBOUND to this step
      final inboundNodes = state.edges
          .where((e) => e.target == step.id)
          .map((e) => state.nodes.firstWhere((n) => n.id == e.source))
          .where(
            (n) =>
                n.type == NodeType.data &&
                n.parentNode == groupId &&
                !renderedNodeIds.contains(n.id),
          )
          .toList();

      if (inboundNodes.isNotEmpty) {
        groupWidgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < inboundNodes.length; i++) ...[
                WorkflowNode(
                  data: inboundNodes[i],
                  key: _nodeKeys[inboundNodes[i].id],
                ),
                if (i < inboundNodes.length - 1)
                  const SizedBox(width: MARGIN_HORIZONTAL_BETWEEN_DATA_NODES),
              ],
            ],
          ),
        );
        groupWidgets.add(const SizedBox(height: MARGIN_VERTICAL_DATA_NODES));
        for (var n in inboundNodes) {
          renderedNodeIds.add(n.id);
        }
      }

      // The step itseld
      groupWidgets.add(WorkflowNode(data: step, key: _nodeKeys[step.id]));
      renderedNodeIds.add(step.id);
      groupWidgets.add(const SizedBox(height: 40));
    }

    // Finally, any group data nodes that WERE NOT rendered yet (terminal outbounds)
    final terminalNodes = groupDataNodes
        .where((n) => !renderedNodeIds.contains(n.id))
        .toList();
    if (terminalNodes.isNotEmpty) {
      // Add margin before terminal nodes if there were steps
      if (groupWidgets.isNotEmpty)
        groupWidgets.insert(
          groupWidgets.length - 1,
          const SizedBox(height: MARGIN_VERTICAL_DATA_NODES),
        );

      groupWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < terminalNodes.length; i++) ...[
              WorkflowNode(
                data: terminalNodes[i],
                key: _nodeKeys[terminalNodes[i].id],
              ),
              if (i < terminalNodes.length - 1)
                const SizedBox(width: MARGIN_HORIZONTAL_BETWEEN_DATA_NODES),
            ],
          ],
        ),
      );
    }

    return groupWidgets;
  }

  Widget _buildHeader(WorkflowState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 100) return const SizedBox.shrink();
        final scale = getBoxScalingFactor(context);

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 12 * scale,
            horizontal: 32 * scale,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            border: Border(
              bottom: BorderSide(color: Color(0xFF2C2C2E), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _focusOnStep(1),
                      child: Text(
                        'OpenVaxx',
                        style: GoogleFonts.outfit(
                          fontSize: 32 * scale,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // GitHub Button
                  if (constraints.maxWidth > 350 * scale)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          final url = Uri.parse(
                            'https://github.com/philfung/openvaxx',
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * scale,
                            vertical: 8 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(20 * scale),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.github,
                                size: 16 * scale,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8 * scale),
                              Text(
                                APP_VERSION,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4 * scale),
              FittedBox(
                alignment: Alignment.centerLeft,
                child: Text(
                  'An open-source guide to producing a personalized mRNA cancer vaccine',
                  style: GoogleFonts.outfit(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColor(String? colorName) {
    switch (colorName) {
      case 'indigo':
        return const Color(0xFF6366F1);
      case 'rose':
        return const Color(0xFFE11D48);
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'slate':
        return const Color(0xFF64748B);
      case 'teal':
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFF6366F1);
    }
  }
}

class DynamicEdgePainter extends CustomPainter {
  final List<WorkflowEdgeData> edges;
  final Map<String, GlobalKey> nodeKeys;
  final GlobalKey canvasKey;
  final double animationValue;

  DynamicEdgePainter({
    required this.edges,
    required this.nodeKeys,
    required this.canvasKey,
    this.animationValue = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final arrowPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;

    for (final edge in edges) {
      final sourceKey = nodeKeys[edge.source];
      final targetKey = nodeKeys[edge.target];

      if (sourceKey?.currentContext == null ||
          targetKey?.currentContext == null ||
          canvasKey.currentContext == null)
        continue;

      final RenderBox sourceBox =
          sourceKey!.currentContext!.findRenderObject() as RenderBox;
      final RenderBox targetBox =
          targetKey!.currentContext!.findRenderObject() as RenderBox;
      final RenderBox canvasBox =
          canvasKey.currentContext!.findRenderObject() as RenderBox;

      final sourcePos = sourceBox.localToGlobal(
        Offset.zero,
        ancestor: canvasBox,
      );
      final targetPos = targetBox.localToGlobal(
        Offset.zero,
        ancestor: canvasBox,
      );

      Offset start = Offset(
        sourcePos.dx + sourceBox.size.width / 2,
        sourcePos.dy + sourceBox.size.height,
      );
      Offset end = Offset(
        targetPos.dx + targetBox.size.width / 2,
        targetPos.dy,
      );

      final path = Path();
      path.moveTo(start.dx, start.dy);
      final cp1 = Offset(start.dx, start.dy + (end.dy - start.dy) / 2);
      final cp2 = Offset(end.dx, end.dy - (end.dy - start.dy) / 2);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

      if (edge.dashed) {
        _drawDashedPath(canvas, path, paint);
      } else if (edge.animated) {
        _drawAnimatedPath(canvas, path, paint, animationValue);
      } else {
        canvas.drawPath(path, paint);
      }
      _drawArrowHead(canvas, end, arrowPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    double distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  void _drawAnimatedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double progress,
  ) {
    canvas.drawPath(path, paint..color = paint.color.withOpacity(0.3));
    final pulsePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final pathMetric in path.computeMetrics()) {
      final length = pathMetric.length;
      final start = (progress * length) % length;
      final end = (start + 20.0) % length;
      if (end > start) {
        canvas.drawPath(pathMetric.extractPath(start, end), pulsePaint);
      } else {
        canvas.drawPath(pathMetric.extractPath(start, length), pulsePaint);
        canvas.drawPath(pathMetric.extractPath(0, end), pulsePaint);
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset position, Paint paint) {
    final path = Path();
    path.moveTo(position.dx, position.dy);
    path.lineTo(position.dx - 6, position.dy - 10);
    path.lineTo(position.dx + 6, position.dy - 10);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DynamicEdgePainter oldDelegate) => true;
}
