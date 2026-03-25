import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/workflow_data.dart';
import '../utils/ui_utils.dart';

class WorkflowNode extends StatelessWidget {
  final WorkflowNodeData data;

  const WorkflowNode({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Widget node;
    switch (data.type) {
      case NodeType.step:
        node = _buildStepNode(context);
        break;
      case NodeType.data:
        node = _buildDataNode(context);
        break;
      case NodeType.title:
        node = _buildTitleNode(context);
        break;
      case NodeType.group:
        node = _buildGroupNode(context);
        break;
    }

    if (data.isHighlighted) {
      return _PulsingHighlight(child: node);
    }
    return node;
  }

  Widget _buildStepNode(BuildContext context) {
    final color = _getColor(data.color);
    final scale = getBoxScalingFactor(context);
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: (width / 2.0),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // if (data.iconName != null)
              //   Container(
              //     padding: const EdgeInsets.all(12),
              //     decoration: BoxDecoration(
              //       color: color.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Icon(getLucideIcon(data.iconName), color: color, size: 24),
              //   ),
              // const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MarkdownBody(
                      data: data.title,
                      styleSheet: _markdownStyle(
                        context,
                        GoogleFonts.outfit(
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onTapLink: (text, href, title) => _launchUrl(href),
                    ),
                    // if (data.goal != null) SizedBox(height: 10 * scale),
                    // if (data.goal != null)
                    //   MarkdownBody(
                    //     data: 'Goal: ${data.goal}',
                    //     styleSheet: _markdownStyle(
                    //       context,
                    //       GoogleFonts.inter(
                    //         fontSize: 14 * scale,
                    //         fontWeight: FontWeight.w600,
                    //         color: color,
                    //       ),
                    //     ),
                    //     onTapLink: (text, href, title) => _launchUrl(href),
                    //   ),
                  ],
                ),
              ),
            ],
          ),
          // SizedBox(height: (10 * scale)),
          // MarkdownBody(
          //   data: data.shortDescription ?? '',
          //   styleSheet: _markdownStyle(
          //     context,
          //     GoogleFonts.inter(
          //       fontSize: 15 * scale,
          //       color: Colors.grey[400],
          //       height: 1.5,
          //     ),
          //   ),
          //   onTapLink: (text, href, title) => _launchUrl(href),
          // ),
          if (data.image != null) ...[
            SizedBox(height: 16 * scale),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.white,
                child: Image.asset(
                  data.image!,
                  width: double.infinity,
                  height: 200 * scale,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200 * scale,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
          if (data.shortHardware != null ||
              data.shortSoftware != null ||
              data.outsourced != null ||
              data.cost != null) ...[
            SizedBox(height: 10 * scale),
            const Divider(),
            // SizedBox(height: 5 * scale),
            if (data.shortHardware != null)
              _buildFooterItem(context, 'Lab Equipment', data.shortHardware!),
            if (data.shortSoftware != null)
              _buildFooterItem(context, 'Software', data.shortSoftware!),
            // if (data.outsourced != null)
            //   _buildFooterItem(context, 'Outsourced', data.outsourced!),
            // if (data.cost != null)
            //   _buildFooterItem(
            //     context,
            //     'Cost',
            //     data.cost!,
            //     isCost: true,
            //     color: color,
            //   ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataNode(BuildContext context) {
    final color = _getColor(data.color);
    final scale = getBoxScalingFactor(context);
    double constraintWidth = data.size?.width ?? 450;
    constraintWidth *= scale;

    return Container(
      width: constraintWidth,
      constraints: BoxConstraints(maxWidth: constraintWidth),
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 16 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: data.title,
              styleSheet: _markdownStyle(
                context,
                GoogleFonts.outfit(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onTapLink: (text, href, title) => _launchUrl(href),
            ),
            if (data.description != null) SizedBox(height: 8 * scale),
            if (data.description != null)
              MarkdownBody(
                data: (data.description ?? '').replaceAll('<br/>', '  \n'),
                styleSheet: _markdownStyle(
                  context,
                  GoogleFonts.inter(
                    fontSize: 14 * scale,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
                onTapLink: (text, href, title) => _launchUrl(href),
              ),
            if (data.images != null && data.images!.isNotEmpty) ...[
              SizedBox(height: 16 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var imagePath in data.images!) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePath,
                        height: 80 * scale,
                        width: 80 * scale,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 80 * scale,
                          width: 80 * scale,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitleNode(BuildContext context) {
    final color = _getColor(data.color);
    final scale = getBoxScalingFactor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MarkdownBody(
          data: data.title,
          styleSheet: _markdownStyle(
            context,
            GoogleFonts.outfit(
              fontSize: (data.fontSize ?? 48) * scale,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -1 * scale,
            ),
          ),
          onTapLink: (text, href, title) => _launchUrl(href),
        ),
        SizedBox(height: 8 * scale),
        MarkdownBody(
          data: data.description ?? '',
          styleSheet: _markdownStyle(
            context,
            GoogleFonts.inter(
              fontSize: 24 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          onTapLink: (text, href, title) => _launchUrl(href),
        ),
      ],
    );
  }

  Widget _buildGroupNode(BuildContext context) {
    final color = _getColor(data.color);
    final scale = getBoxScalingFactor(context);
    return Container(
      width: (data.size?.width ?? 1400) * scale,
      height: (data.size?.height ?? 2500) * scale,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40 * scale),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 3 * scale,
          style: BorderStyle.solid,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 40 * scale,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
                child: MarkdownBody(
                  data: data.label ?? '',
                  styleSheet: _markdownStyle(
                    context,
                    GoogleFonts.outfit(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  onTapLink: (text, href, title) => _launchUrl(href),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(
    BuildContext context,
    String label,
    String value, {
    bool isCost = false,
    Color? color,
  }) {
    final scale = getBoxScalingFactor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: MarkdownBody(
        data: '**$label:** $value',
        styleSheet:
            _markdownStyle(
              context,
              GoogleFonts.inter(
                fontSize: 15 * scale,
                fontWeight: isCost ? FontWeight.bold : FontWeight.w500,
                color: isCost ? color : Colors.grey[400],
              ),
            ).copyWith(
              strong: GoogleFonts.inter(
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
            ),
        onTapLink: (text, href, title) => _launchUrl(href),
      ),
    );
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context, TextStyle baseStyle) {
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: baseStyle,
      pPadding: EdgeInsets.zero,
      listBullet: baseStyle,
      listIndent: 20,
      blockSpacing: 8,
      textAlign: WrapAlignment.start,
      a: baseStyle.copyWith(
        color: const Color(0xFFA5B4FC),
        decoration: TextDecoration.underline,
        decorationColor: const Color(0xFFA5B4FC).withOpacity(0.5),
      ),
    );
  }

  Future<void> _launchUrl(String? href) async {
    if (href != null) {
      final url = Uri.parse(href);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
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

class _PulsingHighlight extends StatefulWidget {
  final Widget child;
  const _PulsingHighlight({required this.child});

  @override
  State<_PulsingHighlight> createState() => _PulsingHighlightState();
}

class _PulsingHighlightState extends State<_PulsingHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(_animation.value * 0.7),
                blurRadius: 25,
                spreadRadius: 8,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
