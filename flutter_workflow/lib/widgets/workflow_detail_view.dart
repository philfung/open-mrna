import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF2C2C2E),
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
          _buildHeader(currentStep, stepNode),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stepNode != null) ...[
                    _buildSectionTitle('GOAL'),
                    _buildStepGoal(stepNode.goal ?? ''),
                    const SizedBox(height: 16),
                    
                    _buildSectionTitle('PROCESS'),
                    _buildDescription(stepNode.description ?? ''),
                    const SizedBox(height: 16),
                    
                    if (stepNode.inputs != null && stepNode.inputs!.isNotEmpty) ...[
                      _buildSectionTitle('INPUTS'),
                      ...stepNode.inputs!.map((input) => _buildResourceItem(LucideIcons.arrowRightCircle, input, const Color(0xFF3B82F6))),
                      const SizedBox(height: 16),
                    ],
                    
                    if (stepNode.outputs != null && stepNode.outputs!.isNotEmpty) ...[
                      _buildSectionTitle('OUTPUTS'),
                      ...stepNode.outputs!.map((output) => _buildResourceItem(LucideIcons.checkCircle2, output, const Color(0xFF10B981))),
                      const SizedBox(height: 16),
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
                    
                  ] else if (currentStep.id == 1) ...[
                    _buildStepGoal('Procuring Biological Starting Material'),
                    const SizedBox(height: 16),
                    _buildDescription('Two key patient samples are required to initiate the personalized mRNA vaccine manufacturing process:'),
                    const SizedBox(height: 16),
                    _buildSectionTitle('REQUIRED SAMPLES'),
                    _buildImageResourceItem('lib/assets/icons/icon_tissue.png', 'Tumor Biopsy: Provides tumor DNA & RNA to identify cancer-specific somatic mutations (neoantigens) unique to the patient.'),
                    _buildImageResourceItem('lib/assets/icons/icon_blood.png', 'Normal Blood: Serves as a healthy genetic reference to filter out inherited (germline) mutations and isolate immune cells for HLA typing.'),
                  ] else if (currentStep.id == 10) ...[
                    _buildStepGoal('Final Vaccine Formulation'),
                    const SizedBox(height: 16),
                    _buildDescription('The personalized mRNA vaccine formulation encapsulated in lipid nanoparticles, quality verified and ready for clinical administration.'),
                  ] else ...[
                    _buildStepGoal('Overview of required inputs and baseline data.'),
                    const SizedBox(height: 16),
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

  Widget _buildHeader(WorkflowStep step, WorkflowNodeData? stepNode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF2C2C2E),
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
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  step.title,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              if (stepNode?.image != null) ...[
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    stepNode!.image!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
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
          color: Colors.grey[500],
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
        color: Colors.grey[300],
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
        color: Colors.grey[400],
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
                color: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageResourceItem(String imagePath, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, width: 20, height: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    if (label == 'Software') {
      return _buildSoftwareDetailRow(icon, label, value);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey[400]),
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
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoftwareDetailRow(IconData icon, String label, String value) {
    final Map<String, String> links = {
      'GATK Mutect2': 'https://github.com/broadinstitute/gatk',
      'pVACseq': 'https://github.com/griffithlab/pVACtools',
      'MHCflurry': 'https://github.com/openvax/mhcflurry',
      'pVACvector': 'https://github.com/griffithlab/pVACtools',
      'LinearDesign': 'https://github.com/LinearDesignSoftware/LinearDesign',
    };

    List<InlineSpan> spans = [];
    String remaining = value;

    while (remaining.isNotEmpty) {
      String? foundKey;
      int minIndex = remaining.length;

      for (var key in links.keys) {
        int index = remaining.indexOf(key);
        if (index != -1 && index < minIndex) {
          minIndex = index;
          foundKey = key;
        }
      }

      if (foundKey == null) {
        spans.add(TextSpan(text: remaining));
        break;
      }

      if (minIndex > 0) {
        spans.add(TextSpan(text: remaining.substring(0, minIndex)));
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                final url = Uri.parse(links[foundKey]!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Text(
                foundKey,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blueAccent,
                ),
              ),
            ),
          ),
        )
      );

      remaining = remaining.substring(minIndex + foundKey.length);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey[400]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    children: spans,
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
