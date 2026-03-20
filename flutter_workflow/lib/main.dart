import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'providers/workflow_provider.dart';
import 'widgets/workflow_node.dart';
import 'widgets/workflow_node.dart';
import 'models/workflow_data.dart';
import 'models/mock_data.dart';

const double MARGIN_VERTICAL_GROUP_NODES = 200.0;
const double MARGIN_VERTICAL_DATA_NODES = 60.0;
const double MARGIN_HORIZONTAL_BETWEEN_DATA_NODES = 40.0;
const double NODE_WIDTH = 400.0;

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenVaxx Workflow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
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

class _WorkflowScreenState extends ConsumerState<WorkflowScreen> with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  final Map<String, GlobalKey> _nodeKeys = {};
  final GlobalKey _canvasKey = GlobalKey();

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

    // Initial focus with a longer delay to ensure layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _focusOnStep(1);
      });
    });
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
    final activeStepNodeId = step.nodeIds.firstWhere((id) => id.startsWith('Step'));
    
    final key = _nodeKeys[activeStepNodeId];
    if (key == null || key.currentContext == null || _canvasKey.currentContext == null) {
       Future.delayed(const Duration(milliseconds: 100), () => _focusOnStep(stepId));
       return;
    }

    final RenderBox nodeBox = key.currentContext!.findRenderObject() as RenderBox;
    final RenderBox canvasBox = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    
    // Position of node relative to the canvas stack
    final positionInCanvas = nodeBox.localToGlobal(Offset.zero, ancestor: canvasBox);
    final size = nodeBox.size;

    // Position of node relative to the InteractiveViewer's child (Container)
    // The Container has padding (100, 600, 100, 1200)
    final double paddingLeft = 100.0;
    final double paddingTop = 600.0;
    
    final double x = positionInCanvas.dx + paddingLeft;
    final double y = positionInCanvas.dy + paddingTop;

    final viewportSize = MediaQuery.of(context).size;
    final double scale = 1.0;
    
    final targetMatrix = Matrix4.identity()
      ..translate(viewportSize.width / 2, viewportSize.height / 2)
      ..scale(scale)
      ..translate(-x - size.width / 2, -y - size.height / 2);

    _animateToMatrix(targetMatrix);
  }

  void _animateToMatrix(Matrix4 targetMatrix) {
    final startMatrix = _transformationController.value;
    final animation = Matrix4Tween(begin: startMatrix, end: targetMatrix).animate(
      CurvedAnimation(parent: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      )..forward(), curve: Curves.easeInOutCubic),
    );

    animation.addListener(() {
      _transformationController.value = animation.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workflowProvider);
    final step = state.currentStep;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Dynamic Layout Canvas
          InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            minScale: 0.1,
            maxScale: 2.5,
            child: Container(
              padding: const EdgeInsets.fromLTRB(100, 600, 100, 1200),
              width: 1400, // Constrain width based on NODE_WIDTH and margins
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
                               animationValue: _animationController.value,
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

          // Header & Controls (Same as before)
          _buildHeader(),
          _buildBottomControls(step, state),
        ],
      ),
    );
  }

  Widget _buildWorkflowLayout(WorkflowState state) {
    final groupNodes = state.nodes.where((n) => n.type == NodeType.group).toList();
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

  Widget _buildGroupWidget(WorkflowNodeData group, WorkflowState state, Set<String> renderedNodeIds) {
    final children = state.nodes.where((n) => n.parentNode == group.id).toList();
    final titleNode = children.firstWhere((n) => n.type == NodeType.title);
    final otherNodes = children.where((n) => n.type != NodeType.title).toList();

    return Container(
      key: _nodeKeys[group.id],
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: _getColor(group.color).withOpacity(0.03),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: _getColor(group.color).withOpacity(0.2), width: 3),
      ),
      child: Column(
        children: [
          WorkflowNode(data: titleNode, key: _nodeKeys[titleNode.id]),
          const SizedBox(height: 80),
          // We need to order the steps and their data nodes
          ..._buildStepsInGroup(otherNodes, state, renderedNodeIds),
        ],
      ),
    );
  }

  List<Widget> _buildStepsInGroup(List<WorkflowNodeData> nodes, WorkflowState state, Set<String> renderedNodeIds) {
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
          .where((n) => n.type == NodeType.data && !renderedNodeIds.contains(n.id))
          .toList();

      if (inboundNodes.isNotEmpty) {
        groupWidgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < inboundNodes.length; i++) ...[
                WorkflowNode(data: inboundNodes[i], key: _nodeKeys[inboundNodes[i].id]),
                if (i < inboundNodes.length - 1) const SizedBox(width: MARGIN_HORIZONTAL_BETWEEN_DATA_NODES),
              ],
            ],
          ),
        );
        groupWidgets.add(const SizedBox(height: MARGIN_VERTICAL_DATA_NODES));
        for (var n in inboundNodes) { renderedNodeIds.add(n.id); }
      }

      // The step itseld
      groupWidgets.add(WorkflowNode(data: step, key: _nodeKeys[step.id]));
      renderedNodeIds.add(step.id);
      groupWidgets.add(const SizedBox(height: 100));
    }

    // Finally, any group data nodes that WERE NOT rendered yet (terminal outbounds)
    final terminalNodes = groupDataNodes.where((n) => !renderedNodeIds.contains(n.id)).toList();
    if (terminalNodes.isNotEmpty) {
      // Add margin before terminal nodes if there were steps
      if (groupWidgets.isNotEmpty) groupWidgets.insert(groupWidgets.length - 1, const SizedBox(height: MARGIN_VERTICAL_DATA_NODES));
      
      groupWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < terminalNodes.length; i++) ...[
              WorkflowNode(data: terminalNodes[i], key: _nodeKeys[terminalNodes[i].id]),
              if (i < terminalNodes.length - 1) const SizedBox(width: MARGIN_HORIZONTAL_BETWEEN_DATA_NODES),
            ],
          ],
        ),
      );
    }

    return groupWidgets;
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('OpenVaxx: DIY mRNA Vaccine Workflow', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(20)), child: Text('v1.2.0', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(WorkflowStep step, WorkflowState state) {
    return Positioned(
      bottom: 40, left: 0, right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 10))]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.part, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
                  const SizedBox(height: 4),
                  Text('Step ${step.id} of ${workflowSteps.length}', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8))),
                  const SizedBox(height: 4),
                  Text(step.title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                ],
              ),
              const SizedBox(width: 48),
              Row(
                children: [
                  _buildNavButton(icon: LucideIcons.chevronLeft, label: 'Prev', onPressed: state.currentStepId > 1 ? () { 
                    ref.read(workflowProvider.notifier).prevStep(); 
                    Future.microtask(() => _focusOnStep(state.currentStepId - 1));
                  } : null),
                  const SizedBox(width: 16),
                  _buildNavButton(icon: LucideIcons.chevronRight, label: 'Next', isPrimary: true, onPressed: state.currentStepId < workflowSteps.length ? () { 
                    ref.read(workflowProvider.notifier).nextStep(); 
                    Future.microtask(() => _focusOnStep(state.currentStepId + 1));
                  } : null),
                  const SizedBox(width: 16),
                  _buildNavButton(icon: LucideIcons.maximize, label: '', onPressed: () { _focusOnStep(state.currentStepId); }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required String label, VoidCallback? onPressed, bool isPrimary = false}) {
    final isDisabled = onPressed == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed, borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: label.isEmpty ? 12 : 20, vertical: 12),
          decoration: BoxDecoration(color: isPrimary ? (isDisabled ? const Color(0xFF6366F1).withOpacity(0.5) : const Color(0xFF6366F1)) : Colors.transparent, borderRadius: BorderRadius.circular(16), border: isPrimary ? null : Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(children: [if (icon == LucideIcons.chevronLeft) Icon(icon, color: isPrimary ? Colors.white : (isDisabled ? Colors.grey : const Color(0xFF475569)), size: 20), if (label.isNotEmpty) ...[if (icon == LucideIcons.chevronLeft) const SizedBox(width: 8), Text(label, style: GoogleFonts.inter(color: isPrimary ? Colors.white : (isDisabled ? Colors.grey : const Color(0xFF475569)), fontWeight: FontWeight.bold)), if (icon == LucideIcons.chevronRight) const SizedBox(width: 8)], if (icon != LucideIcons.chevronLeft) Icon(icon, color: isPrimary ? Colors.white : (isDisabled ? Colors.grey : const Color(0xFF475569)), size: 20)]),
        ),
      ),
    );
  }

  Color _getColor(String? colorName) {
    switch (colorName) {
      case 'indigo': return const Color(0xFF6366F1);
      case 'rose': return const Color(0xFFE11D48);
      case 'blue': return const Color(0xFF3B82F6);
      case 'slate': return const Color(0xFF64748B);
      case 'teal': return const Color(0xFF14B8A6);
      default: return const Color(0xFF6366F1);
    }
  }
}

class DynamicEdgePainter extends CustomPainter {
  final List<WorkflowEdgeData> edges;
  final Map<String, GlobalKey> nodeKeys;
  final GlobalKey canvasKey;
  final double animationValue;

  DynamicEdgePainter({required this.edges, required this.nodeKeys, required this.canvasKey, this.animationValue = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final arrowPaint = Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.fill;

    for (final edge in edges) {
      final sourceKey = nodeKeys[edge.source];
      final targetKey = nodeKeys[edge.target];

      if (sourceKey?.currentContext == null || targetKey?.currentContext == null || canvasKey.currentContext == null) continue;

      final RenderBox sourceBox = sourceKey!.currentContext!.findRenderObject() as RenderBox;
      final RenderBox targetBox = targetKey!.currentContext!.findRenderObject() as RenderBox;
      final RenderBox canvasBox = canvasKey.currentContext!.findRenderObject() as RenderBox;
      
      final sourcePos = sourceBox.localToGlobal(Offset.zero, ancestor: canvasBox);
      final targetPos = targetBox.localToGlobal(Offset.zero, ancestor: canvasBox);

      Offset start = Offset(sourcePos.dx + sourceBox.size.width / 2, sourcePos.dy + sourceBox.size.height);
      Offset end = Offset(targetPos.dx + targetBox.size.width / 2, targetPos.dy);

      final path = Path();
      path.moveTo(start.dx, start.dy);
      final cp1 = Offset(start.dx, start.dy + (end.dy - start.dy) / 2);
      final cp2 = Offset(end.dx, end.dy - (end.dy - start.dy) / 2);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

      if (edge.dashed) { _drawDashedPath(canvas, path, paint); }
      else if (edge.animated) { _drawAnimatedPath(canvas, path, paint, animationValue); }
      else { canvas.drawPath(path, paint); }
      _drawArrowHead(canvas, end, arrowPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0; const dashSpace = 4.0; double distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) { canvas.drawPath(pathMetric.extractPath(distance, distance + dashWidth), paint); distance += dashWidth + dashSpace; }
    }
  }

  void _drawAnimatedPath(Canvas canvas, Path path, Paint paint, double progress) {
    canvas.drawPath(path, paint..color = paint.color.withOpacity(0.3));
    final pulsePaint = Paint()..color = const Color(0xFF6366F1)..strokeWidth = 3.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    for (final pathMetric in path.computeMetrics()) {
      final length = pathMetric.length; final start = (progress * length) % length; final end = (start + 20.0) % length;
      if (end > start) { canvas.drawPath(pathMetric.extractPath(start, end), pulsePaint); }
      else { canvas.drawPath(pathMetric.extractPath(start, length), pulsePaint); canvas.drawPath(pathMetric.extractPath(0, end), pulsePaint); }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset position, Paint paint) {
    final path = Path();
    path.moveTo(position.dx, position.dy); path.lineTo(position.dx - 6, position.dy - 10); path.lineTo(position.dx + 6, position.dy - 10); path.close();
    canvas.drawPath(path, paint);
  }

  @override bool shouldRepaint(covariant DynamicEdgePainter oldDelegate) => true; 
}
