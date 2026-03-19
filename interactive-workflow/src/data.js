import { Database, Zap, Target, PenTool, Printer, Factory, Package, FlaskConical } from 'lucide-react';
import { MarkerType } from 'reactflow';

export const initialNodes = [
  // ... (nodes remain the same)
  // PART 1
  // PART 1 PARENT
  {
    id: 'Part1Group',
    type: 'group',
    data: { label: 'Part A: Upstream Digital Pipeline · Data → Blueprint' },
    position: { x: -300, y: -300 },
    style: {
      width: 1400,
      height: 2750,
      backgroundColor: 'rgba(99, 102, 241, 0.05)',
      border: '2px dashed #6366f1',
      borderRadius: '24px',
    },
  },
  {
    id: 'Title1',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 300, y: 100 },
    data: {
      type: 'title',
      title: 'Part A: Upstream Digital Pipeline',
      description: 'Data → Blueprint',
      color: 'indigo'
    },
  },
  {
    id: 'NodeIn1',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 525, y: 350 },
    data: {
      type: 'data',
      title: '🧬 Tumor biopsy & Normal blood',
      description: '• Normal DNA: ~30X WES<br/>• Tumor DNA: ~100X-500X WES<br/>• Tumor RNA: RNA-Seq (50M-100M reads)',
      color: 'blue'
    },
  },
  {
    id: 'Step1',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 300, y: 600 },
    data: {
      type: 'step',
      title: 'Step 1 · Reading the Blueprint',
      goal: 'Digitizing the Cells',
      description: 'The machine reads extracted DNA/RNA, turning biological chemistry into digital text.',
      hardware: 'Illumina NextSeq 2000 or Element AVITI',
      outsourced: 'Novogene, Azenta, Eurofins',
      cost: '~$1,000 / pt (In-House) or ~$2,500 (Outsourced)',
      color: 'rose',
      icon: Database
    },
  },
  {
    id: 'NodeIn2',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 300, y: 850 },
    data: {
      type: 'data',
      title: '📄 4 Patient genetic & HLA files',
      description: 'baseline-normal.fastq<br/>tumor-exome.fastq<br/>tumor-rna.fastq<br/>patient-hla.txt',
      color: 'blue'
    },
  },
  {
    id: 'NodeRef',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 750, y: 850 },
    data: {
      type: 'data',
      title: '🧬 Human Reference Genome (.fasta)',
      description: '(e.g. Human Genome Project)<br/>>chr1 NNNNNNNNNN...',
      color: 'slate'
    },
  },
  {
    id: 'Step2',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 300, y: 1100 },
    data: {
      type: 'step',
      title: 'Step 2 · Spotting the Typos',
      goal: 'Finding the Mutations',
      description: 'Aligns reads and mathematically subtracts healthy DNA from tumor DNA to isolate somatic mutations.',
      hardware: 'Software: GATK Mutect2',
      color: 'rose',
      icon: Zap
    },
  },
  {
    id: 'NodeIn3',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 300, y: 1350 },
    data: {
      type: 'data',
      title: '📄 2 Condensed mutation lists (.vcf)',
      description: 'somatic-variants.vcf<br/>filtered-variants.vcf',
      color: 'blue'
    },
  },
  {
    id: 'NodeHLA',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 750, y: 1350 },
    data: {
      type: 'data',
      title: '🔬 Patient HLA profile (.txt)',
      description: 'Immune system receptor map<br/>HLA-A*02:01, HLA-B*07:02...',
      color: 'blue'
    },
  },
  {
    id: 'Step3',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 300, y: 1600 },
    data: {
      type: 'step',
      title: 'Step 3 · Picking the Targets',
      goal: 'AI Neoantigen Prediction',
      description: 'Neural networks predict which mutations will most effectively trigger an immune response based on the patient HLA receptors.',
      hardware: 'Software: pVACseq running MHCflurry',
      color: 'rose',
      icon: Target
    },
  },
  {
    id: 'NodeIn4',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 525, y: 1850 },
    data: {
      type: 'data',
      title: '📊 Ranked leaderboard of targets (.tsv)',
      description: 'ranked-predictions.tsv<br/>Top predicted neoantigens',
      color: 'blue'
    },
  },
  {
    id: 'Step4',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 300, y: 2100 },
    data: {
      type: 'step',
      title: 'Step 4 · Writing the New Code',
      goal: 'Sequence Assembly',
      description: 'Strings targets together, adds structural instructions (5 Cap, Poly-A tail), and optimizes codons for stability.',
      hardware: 'Software: pVACvector + LinearDesign',
      color: 'rose',
      icon: PenTool
    },
  },
  {
    id: 'NodeIn5',
    type: 'workflowNode',
    parentNode: 'Part1Group',
    extent: 'parent',
    position: { x: 525, y: 2350 },
    data: {
      type: 'data',
      title: '📜 Optimized mRNA blueprint (.fasta)',
      description: 'vaccine-construct.fasta (Master sequence)',
      color: 'blue'
    },
  },

  // PART 2
  // PART 2 PARENT
  {
    id: 'Part2Group',
    type: 'group',
    data: { label: 'Part B: Downstream Physical Pipeline · Blueprint → Vial' },
    position: { x: -300, y: 2600 },
    style: {
      width: 1400,
      height: 2500,
      backgroundColor: 'rgba(20, 184, 166, 0.05)',
      border: '2px dashed #14b8a6',
      borderRadius: '24px',
    },
  },
  {
    id: 'Title2',
    type: 'workflowNode',
    parentNode: 'Part2Group',
    extent: 'parent',
    position: { x: 300, y: 100 },
    data: {
      type: 'title',
      title: 'Part B: Downstream Physical Pipeline',
      description: 'Blueprint → Vial',
      color: 'teal'
    },
  },
  {
    id: 'Step5',
    type: 'workflowNode',
    parentNode: 'Part2Group',
    extent: 'parent',
    position: { x: 300, y: 350 },
    data: {
      type: 'step',
      title: 'Step 5 · Printing the Master Copy',
      goal: 'DNA Synthesis',
      description: 'Gibson Assembly stitches oligonucleotides into a DNA plasmid, which is then linearized with enzymes.',
      hardware: 'Benchtop DNA Synthesizer (e.g., BioXp)',
      outsourced: 'Twist, IDT, GenScript, Azenta',
      cost: '~$600 / rxn (In-House) or ~$200-$900 (Outsourced)',
      color: 'teal',
      icon: Printer
    },
  },
  {
    id: 'NodeIn6',
    type: 'workflowNode',
    parentNode: 'Part2Group',
    extent: 'parent',
    position: { x: 300, y: 600 },
    data: {
      type: 'data',
      title: '📜 1.5 mL Purified linear DNA template',
      description: 'Yield: ~75 µg (at ~50 ng/µL)<br/>Stable at -20°C',
      color: 'teal'
    },
  },
  {
    id: 'NodeIVT',
    type: 'workflowNode',
    parentNode: 'Part2Group',
    extent: 'parent',
    position: { x: 750, y: 600 },
    data: {
      type: 'data',
      title: '⚗️ IVT Reagents',
      description: 'RNA Polymerase, N1-methylpseudouridine, CleanCap® AG',
      color: 'teal'
    },
  },
  {
    id: 'Step6',
    type: 'workflowNode',
    parentNode: 'Part2Group',
    extent: 'parent',
    position: { x: 300, y: 850 },
    data: {
      type: 'step',
      title: 'Step 6 · Mass Production',
      goal: 'Automated mRNA Synthesis',
      description: 'In Vitro Transcription (IVT) bioreactors read the DNA and print the corresponding mRNA strand.',
      hardware: 'NTxscribe System / BioXp',
      outsourced: 'TriLink, GenScript, BiCell Scientific',
      cost: '~$2,000 / rxn (In-House) or ~$1,000-$3,000 / mg',
      color: 'teal',
      icon: Factory
    },
  },
  {
    id: 'NodeIn7',
    type: 'workflowNode',
    parentNode: 'Part2Group',
    extent: 'parent',
    position: { x: 300, y: 1100 },
    data: {
      type: 'data',
      title: '💉 5.0 mL Highly pure mRNA',
      description: 'Yield: ~1.0 mg (at ~200 ng/µL)<br/>Stored at -80°C',
      color: 'teal'
    },
  },
  {
    id: 'NodeLipids',
    type: 'workflowNode',
    parentNode: 'Part2Group',
    extent: 'parent',
    position: { x: 750, y: 1100 },
    data: {
      type: 'data',
      title: '🧴 4-Lipid Cocktail',
      description: 'ALC-0315, PEG-Lipid, DSPC, Cholesterol',
      color: 'teal'
    },
  },
  {
    id: 'Step7',
    type: 'workflowNode',
    parentNode: 'Part2Group',
    extent: 'parent',
    position: { x: 300, y: 1350 },
    data: {
      type: 'step',
      title: 'Step 7 · Packaging for Delivery',
      goal: 'LNP Formulation',
      description: 'Microfluidic collisions force mRNA and lipids to self-assemble into nanoparticles.',
      hardware: 'Sunshine / NanoAssemblr Ignite',
      outsourced: 'VectorBuilder, Lonza, Vernal Biosciences',
      cost: '~$500 / rxn (In-House) or ~$2,000-$5,000 / batch',
      color: 'teal',
      icon: Package
    },
  },
  {
    id: 'NodeIn8',
    type: 'workflowNode',
    parentNode: 'Part2Group',
    extent: 'parent',
    position: { x: 525, y: 1600 },
    data: {
      type: 'data',
      title: '🧪 12 mL Raw mRNA-LNP mixture',
      description: 'Yield: ~0.9 mg encapsulated (>90% efficiency)<br/>Opalescent liquid',
      color: 'teal'
    },
  },
  {
    id: 'Step8',
    type: 'workflowNode',
    parentNode: 'Part2Group',
    extent: 'parent',
    position: { x: 300, y: 1850 },
    data: {
      type: 'step',
      title: 'Step 8 · Quality Check & Bottling',
      goal: 'QC & Finalization',
      description: 'DLS verifies 60-100nm particles and TFF washes out ethanol.',
      hardware: 'Stunner & TFF System',
      outsourced: 'CordenPharma, uBriGene, VectorBuilder',
      cost: '~$100 / rxn (In-House) or ~$1,000-$3,000 / batch',
      color: 'teal',
      icon: FlaskConical
    },
  },
  {
    id: 'NodeEnd',
    type: 'workflowNode',
    parentNode: 'Part2Group',
    extent: 'parent',
    position: { x: 525, y: 2100 },
    data: {
      type: 'data',
      title: '💊 10 x 1.0 mL Vaccine Vials',
      description: 'Concentration: ~100 µg/mL<br/>10 Doses ready for clinic',
      color: 'teal'
    },
  },
];

export const workflowSteps = [
  {
    id: 1,
    title: 'Reading the Blueprint',
    part: 'Part A: Upstream Digital Pipeline',
    nodes: ['Step1', 'NodeIn1', 'NodeIn2', 'NodeHLA']
  },
  {
    id: 2,
    title: 'Spotting the Typos',
    part: 'Part A: Upstream Digital Pipeline',
    nodes: ['Step2', 'NodeIn2', 'NodeRef', 'NodeIn3']
  },
  {
    id: 3,
    title: 'Picking the Targets',
    part: 'Part A: Upstream Digital Pipeline',
    nodes: ['Step3', 'NodeIn3', 'NodeHLA', 'NodeIn4']
  },
  {
    id: 4,
    title: 'Writing the New Code',
    part: 'Part A: Upstream Digital Pipeline',
    nodes: ['Step4', 'NodeIn4', 'NodeIn5']
  },
  {
    id: 5,
    title: 'Printing the Master Copy',
    part: 'Part B: Downstream Physical Pipeline',
    nodes: ['Step5', 'NodeIn5', 'NodeIn6']
  },
  {
    id: 6,
    title: 'Mass Production',
    part: 'Part B: Downstream Physical Pipeline',
    nodes: ['Step6', 'NodeIn6', 'NodeIVT', 'NodeIn7']
  },
  {
    id: 7,
    title: 'Packaging for Delivery',
    part: 'Part B: Downstream Physical Pipeline',
    nodes: ['Step7', 'NodeIn7', 'NodeLipids', 'NodeIn8']
  },
  {
    id: 8,
    title: 'Quality Check & Bottling',
    part: 'Part B: Downstream Physical Pipeline',
    nodes: ['Step8', 'NodeIn8', 'NodeEnd']
  }
];

export const initialEdges = [
  {
    id: 'e1-step1',
    source: 'NodeIn1',
    target: 'Step1',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'step1-e2',
    source: 'Step1',
    target: 'NodeIn2',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'e2-step2',
    source: 'NodeIn2',
    target: 'Step2',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'ref-step2',
    source: 'NodeRef',
    target: 'Step2',
    label: 'Reference',
    style: { strokeDasharray: '5 5' },
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'step2-e3',
    source: 'Step2',
    target: 'NodeIn3',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'step1-hla',
    source: 'Step1',
    target: 'NodeHLA',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'hla-step3',
    source: 'NodeHLA',
    target: 'Step3',
    style: { strokeDasharray: '5 5' },
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'e3-step3',
    source: 'NodeIn3',
    target: 'Step3',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'step3-e4',
    source: 'Step3',
    target: 'NodeIn4',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'e4-step4',
    source: 'NodeIn4',
    target: 'Step4',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'step4-e5',
    source: 'Step4',
    target: 'NodeIn5',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'e5-step5',
    source: 'NodeIn5',
    target: 'Step5',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'step5-e6',
    source: 'Step5',
    target: 'NodeIn6',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'ivt-step6',
    source: 'NodeIVT',
    target: 'Step6',
    style: { strokeDasharray: '5 5' },
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'e6-step6',
    source: 'NodeIn6',
    target: 'Step6',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'step6-e7',
    source: 'Step6',
    target: 'NodeIn7',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'lipids-step7',
    source: 'NodeLipids',
    target: 'Step7',
    style: { strokeDasharray: '5 5' },
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'e7-step7',
    source: 'NodeIn7',
    target: 'Step7',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'step7-e8',
    source: 'Step7',
    target: 'NodeIn8',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'e8-step8',
    source: 'NodeIn8',
    target: 'Step8',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
  {
    id: 'step8-end',
    source: 'Step8',
    target: 'NodeEnd',
    animated: true,
    markerEnd: { type: MarkerType.ArrowClosed, color: '#94a3b8' }
  },
];
