import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/workflow_provider.dart';
import '../models/workflow_data.dart';

class WorkflowDetailView extends ConsumerWidget {
  const WorkflowDetailView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workflowProvider);
    final currentStep = state.currentStep;
    
    // Find the primary step node for this workflow step
    WorkflowNodeData? stepNode;
    try {
      stepNode = state.nodes.firstWhere(
        (n) => n.type == NodeType.step && currentStep.nodeIds.contains(n.id),
      );
    } catch (_) {
      // Fallback if no step node is found
      stepNode = null;
    }

    return Container(
      width: 450,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(currentStep),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stepNode != null) ...[
                    _buildSectionTitle('GOAL'),
                    _buildStepGoal(stepNode.goal ?? ''),
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle('PROCESS'),
                    _buildDescription(stepNode.description ?? ''),
                    const SizedBox(height: 32),
                    
                    if (stepNode.inputs != null && stepNode.inputs!.isNotEmpty) ...[
                      _buildSectionTitle('INPUTS'),
                      ...stepNode.inputs!.map((input) => _buildResourceItem(LucideIcons.arrowRightCircle, input, const Color(0xFF3B82F6))),
                      const SizedBox(height: 32),
                    ],
                    
                    if (stepNode.outputs != null && stepNode.outputs!.isNotEmpty) ...[
                      _buildSectionTitle('OUTPUTS'),
                      ...stepNode.outputs!.map((output) => _buildResourceItem(LucideIcons.checkCircle2, output, const Color(0xFF10B981))),
                      const SizedBox(height: 32),
                    ],
                    
                    _buildSectionTitle('LOGISTICS'),
                    if (stepNode.hardware != null && stepNode.hardware != 'None')
                      _buildDetailRow(LucideIcons.microscope, 'Equipment', stepNode.hardware!),
                    if (stepNode.software != null && stepNode.software != 'None')
                      _buildDetailRow(LucideIcons.code, 'Software', stepNode.software!),
                    if (stepNode.cost != null)
                      _buildDetailRow(LucideIcons.dollarSign, 'Est. Cost', stepNode.cost!),
                    if (stepNode.fileFormat != null)
                      _buildDetailRow(LucideIcons.fileCode, 'Format', stepNode.fileFormat!),
                    
                  ] else ...[
                    // Default view if no step node (e.g. data-only steps)
                    _buildStepGoal('Overview of required inputs and baseline data.'),
                    const SizedBox(height: 32),
                    _buildDescription('This stage prepares the necessary patient samples and reference data required for the digital pipeline.'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(WorkflowStep step) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              step.part.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6366F1),
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.title,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildStepGoal(String goal) {
    return Text(
      goal,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF334155),
        height: 1.4,
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF64748B),
        height: 1.6,
      ),
    );
  }

  Widget _buildResourceItem(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
