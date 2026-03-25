import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:math';
import '../providers/workflow_provider.dart';
import '../models/workflow_data.dart';
import '../models/mock_data.dart';
import '../utils/ui_utils.dart';
import '../utils/analytics_utils.dart';
import 'nav_controls.dart';

class WorkflowDetailView extends ConsumerWidget {
  const WorkflowDetailView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workflowProvider);
    final currentStep = state.currentStep;
    final scale = getBoxScalingFactor(context);

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
          right: BorderSide(color: const Color(0xFF2C2C2E), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(currentStep, stepNode, scale),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 24 * scale,
                vertical: 20 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stepNode != null) ...[
                    _buildSectionTitle('GOAL', scale),
                    _buildStepGoal(context, stepNode.goal ?? '', scale),
                    SizedBox(height: 5 * scale),

                    _buildSectionTitle('PROCESS', scale),
                    _buildDescription(
                      context,
                      stepNode.description ?? '',
                      scale,
                    ),
                    SizedBox(height: 10 * scale),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isNarrow =
                            constraints.maxWidth < 340 * scale;

                        final textColumn = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('TOOLS AND EQUIPMENT', scale),
                            if (stepNode!.hardware != null &&
                                stepNode.hardware != 'None')
                              _buildDetailRow(
                                context,
                                LucideIcons.microscope,
                                'Lab Equipment',
                                stepNode.hardware!,
                                scale,
                              ),
                            if (stepNode.software != null &&
                                stepNode.software != 'None')
                              _buildDetailRow(
                                context,
                                LucideIcons.code,
                                'Software',
                                stepNode.software!,
                                scale,
                              ),
                            if (stepNode.outsourced != null &&
                                stepNode.outsourced != 'None')
                              _buildDetailRow(
                                context,
                                LucideIcons.externalLink,
                                'Outsourced Alternatives',
                                stepNode.outsourced!,
                                scale,
                              ),
                            if (stepNode.cost != null)
                              _buildDetailRow(
                                context,
                                LucideIcons.dollarSign,
                                'Est. Cost',
                                stepNode.cost!,
                                scale,
                              ),
                          ],
                        );

                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              textColumn,
                              if (stepNode.image != null) ...[
                                SizedBox(height: 10 * scale),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    8 * scale,
                                  ),
                                  child: Image.asset(
                                    stepNode.image!,
                                    width: double.infinity,
                                    height: 200 * scale,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: textColumn),
                            if (stepNode.image != null) ...[
                              SizedBox(width: 16 * scale),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8 * scale),
                                child: Image.asset(
                                  stepNode.image!,
                                  width: 120 * scale,
                                  height: 120 * scale,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 8 * scale),

                    if (stepNode.inputs != null &&
                        stepNode.inputs!.isNotEmpty) ...[
                      _buildSectionTitle('INPUTS', scale),
                      ...stepNode.inputs!.map(
                        (input) => _buildResourceItem(
                          context,
                          input,
                          scale,
                          isOutput: false,
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                    ],

                    if (stepNode.outputs != null &&
                        stepNode.outputs!.isNotEmpty) ...[
                      _buildSectionTitle('OUTPUTS', scale),
                      ...stepNode.outputs!.map(
                        (output) => _buildResourceItem(
                          context,
                          output,
                          scale,
                          isOutput: true,
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                    ],
                  ] else if (currentStep.id == 1) ...[
                    _buildStepGoal(
                      context,
                      'Obtain Biological Starting Material',
                      scale,
                    ),
                    SizedBox(height: 16 * scale),
                    _buildDescription(
                      context,
                      'Two patient samples are required to initiate the vaccine manufacturing process:',
                      scale,
                    ),
                    SizedBox(height: 16 * scale),
                    _buildSectionTitle('REQUIRED SAMPLES', scale),
                    _buildImageResourceItem(
                      context,
                      'lib/assets/icons/icon_tissue.png',
                      'Tumor Biopsy: Provides tumor DNA & RNA to identify cancer-specific somatic mutations (neoantigens) unique to the patient.',
                      scale,
                    ),
                    _buildImageResourceItem(
                      context,
                      'lib/assets/icons/icon_blood.png',
                      'Normal Blood: Serves as a healthy genetic reference to filter out inherited (germline) mutations and isolate immune cells for HLA typing.',
                      scale,
                    ),
                  ] else if (currentStep.id == 10) ...[
                    _buildStepGoal(context, 'Final Vaccine Formulation', scale),
                    SizedBox(height: 16 * scale),
                    _buildDescription(
                      context,
                      'The personalized mRNA vaccine formulation encapsulated in lipid nanoparticles.',
                      scale,
                    ),
                    SizedBox(height: 16 * scale),
                    _buildSectionTitle('FINAL PRODUCT', scale),
                    _buildImageResourceItem(
                      context,
                      'lib/assets/icons/icon_vaccine.png',
                      'Finished Vaccine: 10 doses of sterile, personalized mRNA-LNP formulation.',
                      scale,
                    ),
                  ] else ...[
                    _buildStepGoal(
                      context,
                      'Overview of required inputs and baseline data.',
                      scale,
                    ),
                    SizedBox(height: 16 * scale),
                    _buildDescription(
                      context,
                      'This stage prepares the necessary patient samples and reference data required for the digital pipeline.',
                      scale,
                    ),
                  ],
                ],
              ),
            ),
          ),
          _buildNavigationButtons(context, ref, state, scale),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    WidgetRef ref,
    WorkflowState state,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 20 * scale,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF2C2C2E), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.currentStepId > 1)
            NavigationArrow(
              icon: LucideIcons.chevronUp,
              onPressed: () {
                AnalyticsUtils.logEvent('prev_step_click', {
                  'from_id': state.currentStepId,
                });
                ref.read(workflowProvider.notifier).prevStep();
              },
              color: const Color(0xFF6366F1).withOpacity(0.15),
            )
          else
            const SizedBox.shrink(),
          if (state.currentStepId > 1 &&
              state.currentStepId < workflowSteps.length)
            SizedBox(width: 16 * scale),
          if (state.currentStepId < workflowSteps.length)
            NavigationArrow(
              icon: LucideIcons.chevronDown,
              onPressed: () {
                AnalyticsUtils.logEvent('next_step_click', {
                  'from_id': state.currentStepId,
                });
                ref.read(workflowProvider.notifier).nextStep();
              },
              isDown: true,
              label: 'Next Step',
              color: const Color(0xFF6366F1).withOpacity(0.3),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildHeader(
    WorkflowStep step,
    WorkflowNodeData? stepNode,
    double scale,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        5 * scale,
        24 * scale,
        5 * scale,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        border: Border(bottom: BorderSide(color: Color(0xFF2C2C2E), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 1 * scale,
              vertical: 2 * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6 * scale),
            ),
            child: Text(
              step.part.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6366F1),
                letterSpacing: 1.2 * scale,
              ),
            ),
          ),
          SizedBox(height: 6 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              step.title,
              style: GoogleFonts.outfit(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5 * scale),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 10 * scale,
          fontWeight: FontWeight.w800,
          color: Colors.grey[500],
          letterSpacing: 1.5 * scale,
        ),
      ),
    );
  }

  Widget _buildStepGoal(BuildContext context, String goal, double scale) {
    return Text(
      goal,
      style: GoogleFonts.inter(
        fontSize: min(MediaQuery.of(context).size.width * 0.05, 16 * scale),
        fontWeight: FontWeight.w600,
        color: Colors.grey[300],
        height: 1.4,
      ),
    );
  }

  Widget _buildDescription(
    BuildContext context,
    String description,
    double scale,
  ) {
    return MarkdownBody(
      data: description,
      styleSheet: _markdownStyle(
        context,
        GoogleFonts.inter(
          fontSize: 13 * scale,
          fontWeight: FontWeight.w400,
          color: Colors.grey[400],
          height: 1.6,
        ),
        scale,
      ),
      onTapLink: (text, href, title) async {
        if (href != null) {
          final url = Uri.parse(href);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        }
      },
    );
  }

  Widget _buildResourceItem(
    BuildContext context,
    WorkflowNodeInOut item,
    double scale, {
    required bool isOutput,
  }) {
    String imagePath = 'lib/assets/icons/${item.icon}';

    return Padding(
      padding: EdgeInsets.only(bottom: 10 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, width: 32 * scale, height: 32 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: MarkdownBody(
              data: item.text,
              styleSheet: _markdownStyle(
                context,
                GoogleFonts.inter(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[300],
                ),
                scale,
              ),
              onTapLink: (text, href, title) async {
                if (href != null) {
                  final url = Uri.parse(href);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageResourceItem(
    BuildContext context,
    String imagePath,
    String text,
    double scale,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, width: 48 * scale, height: 48 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: MarkdownBody(
              data: text,
              styleSheet: _markdownStyle(
                context,
                GoogleFonts.inter(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[300],
                ),
                scale,
              ),
              onTapLink: (text, href, title) async {
                if (href != null) {
                  final url = Uri.parse(href);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    double scale,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(icon, size: 16 * scale, color: Colors.grey[400]),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                MarkdownBody(
                  data: value,
                  styleSheet: _markdownStyle(
                    context,
                    GoogleFonts.inter(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    scale,
                  ),
                  onTapLink: (text, href, title) async {
                    if (href != null) {
                      final url = Uri.parse(href);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _markdownStyle(
    BuildContext context,
    TextStyle baseStyle,
    double scale,
  ) {
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: baseStyle,
      pPadding: EdgeInsets.zero,
      listBullet: baseStyle,
      listIndent: 20 * scale,
      blockSpacing: 8 * scale,
      a: baseStyle.copyWith(
        color: const Color(0xFFA5B4FC),
        decoration: TextDecoration.underline,
        decorationColor: const Color(0xFFA5B4FC).withOpacity(0.5),
      ),
    );
  }
}
