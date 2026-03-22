import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workflow_data.dart';
import '../models/mock_data.dart';

class WorkflowState {
  final int currentStepId;
  final List<WorkflowNodeData> nodes;
  final List<WorkflowEdgeData> edges;

  WorkflowState({
    required this.currentStepId,
    required this.nodes,
    required this.edges,
  });

  WorkflowStep get currentStep => workflowSteps.firstWhere((s) => s.id == currentStepId);

  WorkflowState copyWith({int? currentStepId}) {
    return WorkflowState(
      currentStepId: currentStepId ?? this.currentStepId,
      nodes: nodes,
      edges: edges,
    );
  }
}

class WorkflowNotifier extends Notifier<WorkflowState> {
  @override
  WorkflowState build() {
    return WorkflowState(
      currentStepId: 1,
      nodes: initialNodes,
      edges: initialEdges,
    );
  }

  void nextStep() {
    if (state.currentStepId < workflowSteps.length) {
      state = state.copyWith(currentStepId: state.currentStepId + 1);
    }
  }

  void prevStep() {
    if (state.currentStepId > 1) {
      state = state.copyWith(currentStepId: state.currentStepId - 1);
    }
  }

  void resetStep() {
    state = state.copyWith(currentStepId: 1);
  }
}

final workflowProvider = NotifierProvider<WorkflowNotifier, WorkflowState>(() {
  return WorkflowNotifier();
});
