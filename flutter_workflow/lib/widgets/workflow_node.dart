import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/workflow_data.dart';
import '../utils/icon_mapper.dart';

class WorkflowNode extends StatelessWidget {
  final WorkflowNodeData data;

  const WorkflowNode({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    switch (data.type) {
      case NodeType.step:
        return _buildStepNode();
      case NodeType.data:
        return _buildDataNode();
      case NodeType.title:
        return _buildTitleNode();
      case NodeType.group:
        return _buildGroupNode();
    }
  }

  Widget _buildStepNode() {
    final color = _getColor(data.color);
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
              if (data.iconName != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(getLucideIcon(data.iconName), color: color, size: 24),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if (data.goal != null)
                      Text(
                        'Goal: ${data.goal}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.description ?? '',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          if (data.image != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.white,
                child: Image.asset(
                  data.image!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
          if (data.hardware != null || data.outsourced != null || data.cost != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            if (data.hardware != null) _buildFooterItem('Hardware', data.hardware!),
            if (data.outsourced != null) _buildFooterItem('Outsourced', data.outsourced!),
            if (data.cost != null) _buildFooterItem('Cost', data.cost!, isCost: true, color: color),
          ],
        ],
      ),
    );
  }

  Widget _buildDataNode() {
    final color = _getColor(data.color);
    return Container(
      width: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            (data.description ?? '').replaceAll('<br/>', '\n'),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleNode() {
    final color = _getColor(data.color);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          data.title,
          style: GoogleFonts.outfit(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.description ?? '',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupNode() {
    final color = _getColor(data.color);
    return Container(
      width: data.size?.width ?? 1400,
      height: data.size?.height ?? 2500,
      decoration: BoxDecoration(
        color: color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 3,
          style: BorderStyle.solid,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.label ?? '',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(String label, String value, {bool isCost = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF475569),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isCost ? FontWeight.bold : FontWeight.w500,
                color: isCost ? color : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
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
