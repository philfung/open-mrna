import React, { useCallback, useState, useEffect } from 'react';
import ReactFlow, {
  addEdge,
  Background,
  Controls,
  MiniMap,
  useNodesState,
  useEdgesState,
  ReactFlowProvider,
  useReactFlow
} from 'reactflow';
import { ChevronLeft, ChevronRight, Maximize } from 'lucide-react';
import 'reactflow/dist/style.css';

import WorkflowNode from './components/WorkflowNode';
import GroupNode from './components/GroupNode';
import { initialNodes, initialEdges, workflowSteps } from './data';

const nodeTypes = {
  workflowNode: WorkflowNode,
  group: GroupNode,
};

const NavigationControls = ({ currentStep, onNext, onPrev, onReset }) => {
  const step = workflowSteps.find(s => s.id === currentStep);

  return (
    <div className="nav-controls">
      <div className="step-info">
        <span className="part-name">{step?.part}</span>
        <div className="step-meta">
          <span className="step-count">Step {currentStep} of {workflowSteps.length}</span>
        </div>
        <h4 className="step-name">{step?.title}</h4>
      </div>
      <div className="button-group">
        <button className="nav-btn" onClick={onPrev} disabled={currentStep === 1}>
          <ChevronLeft size={20} />
          Prev
        </button>
        <button className="nav-btn primary" onClick={onNext} disabled={currentStep === workflowSteps.length}>
          Next
          <ChevronRight size={20} />
        </button>
        <button className="nav-btn icon" onClick={onReset} title="Reset View">
          <Maximize size={18} />
        </button>
      </div>
    </div>
  );
};

const Flow = () => {
  const [nodes, setNodes, onNodesChange] = useNodesState(initialNodes);
  const [edges, setEdges, onEdgesChange] = useEdgesState(initialEdges);
  const [currentStep, setCurrentStep] = useState(1);
  const { fitView } = useReactFlow();

  const focusStep = useCallback((stepId) => {
    const step = workflowSteps.find(s => s.id === stepId);
    if (step) {
      fitView({ nodes: step.nodes.map(id => ({ id })), duration: 800, padding: 0.2 });
    }
  }, [fitView]);

  // Initial focus on Step 1
  useEffect(() => {
    const timer = setTimeout(() => focusStep(1), 500);
    return () => clearTimeout(timer);
  }, [focusStep]);

  const onNext = () => {
    const next = Math.min(currentStep + 1, workflowSteps.length);
    setCurrentStep(next);
    focusStep(next);
  };

  const onPrev = () => {
    const prev = Math.max(currentStep - 1, 1);
    setCurrentStep(prev);
    focusStep(prev);
  };

  const onReset = () => {
    fitView({ duration: 800 });
  };

  const onConnect = useCallback(
    (params) => setEdges((eds) => addEdge(params, eds)),
    [setEdges]
  );

  return (
    <div className="workflow-container">
      <ReactFlow
        nodes={nodes}
        edges={edges}
        onNodesChange={onNodesChange}
        onEdgesChange={onEdgesChange}
        onConnect={onConnect}
        nodeTypes={nodeTypes}
        fitView
        attributionPosition="bottom-right"
      >
        <Background color="#cbd5e1" gap={20} />
        <Controls />
        <MiniMap
          nodeColor={(n) => {
            if (n.data.type === 'title') return '#4f46e5';
            if (n.data.color === 'rose') return '#e11d48';
            if (n.data.color === 'teal') return '#0d9488';
            return '#94a3b8';
          }}
          maskColor="rgb(248, 250, 252, 0.7)"
        />
      </ReactFlow>

      <NavigationControls
        currentStep={currentStep}
        onNext={onNext}
        onPrev={onPrev}
        onReset={onReset}
      />
    </div>
  );
};

const App = () => {
  return (
    <div className="app-container">
      <header className="app-header">
        <h1>OpenVaxx: DIY mRNA Vaccine Workflow</h1>
        <div className="header-actions">
          <span className="badge">v1.2.0</span>
        </div>
      </header>

      <ReactFlowProvider>
        <Flow />
      </ReactFlowProvider>
    </div>
  );
};

export default App;
