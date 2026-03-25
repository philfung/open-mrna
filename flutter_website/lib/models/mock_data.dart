import 'package:flutter/material.dart';
import 'workflow_data.dart';

final List<WorkflowNodeData> initialNodes = [
  // PART 1
  WorkflowNodeData(
    id: 'Part1Group',
    type: NodeType.group,
    title: 'Part A: Upstream Digital Pipeline · Data → Blueprint',
    label: 'Part A: Upstream Digital Pipeline · Data → Blueprint',
    color: 'indigo',
  ),
  WorkflowNodeData(
    id: 'Title1',
    type: NodeType.title,
    title: 'Part A: Upstream Digital Pipeline',
    description: 'Data → Blueprint',
    parentNode: 'Part1Group',
    fontSize: 30,
    color: 'indigo',
  ),
  WorkflowNodeData(
    id: 'NodeIn1A',
    type: NodeType.data,
    title: 'Patient tumor biopsy sample',
    description:
        'Provides tumor DNA & RNA to identify cancer-specific mutations.',
    parentNode: 'Part1Group',
    color: 'blue',
    images: ['lib/assets/icons/icon_tissue.png'],
    isHighlighted: false,
    size: const Size(180, 0),
  ),
  WorkflowNodeData(
    id: 'NodeIn1B',
    type: NodeType.data,
    title: 'Patient normal blood sample',
    description:
        'Provides a healthy genetic reference to filter out inherited mutations.',
    parentNode: 'Part1Group',
    color: 'blue',
    images: ['lib/assets/icons/icon_blood.png'],
    isHighlighted: false,
    size: const Size(180, 0),
  ),
  WorkflowNodeData(
    id: 'Step1',
    type: NodeType.step,
    title: 'Step 1 · Reading the Blueprint',
    goal: 'Digitizing the Cells',
    description:
        'The machine reads extracted DNA/RNA, turning biological chemistry into digital text.',
    hardware:
        '[Illumina NextSeq 2000](https://www.illumina.com/systems/sequencing-platforms/nextseq-1000-2000.html) or Element AVITI',
    outsourced: 'Novogene, Azenta, Eurofins',
    cost: '~\$300k fixed + ~\$1k / pt (In-House) or ~\$2.5k / pt (Outsourced)',
    parentNode: 'Part1Group',
    color: 'rose',
    iconName: 'database',
    image: 'lib/assets/hardware/illumina_nextseq.png',
    inputs: [
      WorkflowNodeInOut(
        'Tumor biopsy - at least 35mg in tissue',
        'icon_tissue.png',
      ),
      WorkflowNodeInOut(
        'Normal blood (healthy baseline) - standard 4ml EDTA tube',
        'icon_blood.png',
      ),
    ],
    outputs: [
      WorkflowNodeInOut(
        'baseline-normal.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format)  — Normal blood Whole Exome Sequencing (~30X–50X)',
        'icon_file.png',
      ),
      WorkflowNodeInOut(
        'tumor-exome.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format) — Tumor biopsy Whole Exome Sequencing (~100X–500X)',
        'icon_file.png',
      ),
      WorkflowNodeInOut(
        'tumor-rna.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format) — Tumor biopsy RNA-Seq (~50M–100M reads).  Used in Step 3 for expression-level filtering within pVACseq.',
        'icon_file.png',
      ),
      WorkflowNodeInOut(
        '[patient-hla.txt](https://support.illumina.com/content/dam/illumina-support/help/BaseSpace_App_WGS_v6_OLH_15050955_03/Content/Source/Informatics/Apps/HLATypingFormat_appISCWGS.htm#) — Patient HLA profile (MHC Class I & II typing), derived computationally from baseline-normal.FASTQ using tools such as OptiType or HLA-HD',
        'icon_file.png',
      ),
    ],
    fileFormat: '.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format) & .txt',
  ),
  WorkflowNodeData(
    id: 'NodeIn2',
    type: NodeType.data,
    title: '📄 Genetic files from patient samples',
    description:
        '1. baseline-normal.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format  ) — Normal blood Whole Exome Sequencing (~30X–50X)  \n2. tumor-exome.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format) — Tumor biopsy Whole Exome Sequencing (~100X–500X)  \n3. tumor-rna.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format) — Tumor biopsy RNA-Seq (~50M–100M reads)  \n4. [patient-hla.txt](https://support.illumina.com/content/dam/illumina-support/help/BaseSpace_App_WGS_v6_OLH_15050955_03/Content/Source/Informatics/Apps/HLATypingFormat_appISCWGS.htm#) — Patient HLA profile (MHC Class I & II typing), derived computationally from baseline-normal.FASTQ',
    parentNode: 'Part1Group',
    color: 'blue',
  ),
  WorkflowNodeData(
    id: 'NodeRef',
    type: NodeType.data,
    title:
        '🧬 Human Reference Genome (.[FASTA](https://en.wikipedia.org/wiki/FASTA_format))',
    description: '(e.g. Human Genome Project)  \nchr1 NNNNNNNNNN...',
    parentNode: 'Part1Group',
    color: 'slate',
  ),
  WorkflowNodeData(
    id: 'Step2',
    type: NodeType.step,
    title: 'Step 2 · Spotting the Typos',
    goal: 'Finding the Mutations',
    description:
        'Aligns reads and mathematically subtracts healthy DNA from tumor DNA to isolate somatic mutations.',
    hardware: 'None',
    software:
        '[GATK Mutect2](https://github.com/broadinstitute/gatk) (open-source Genome Analysis Toolkit)',
    parentNode: 'Part1Group',
    color: 'rose',
    iconName: 'zap',
    image: 'lib/assets/icons/icon_ai_script.png',
    inputs: [
      WorkflowNodeInOut(
        '2 patient .FASTQ files (baseline-normal, tumor-exome)',
        'icon_file.png',
      ),
      WorkflowNodeInOut(
        'Human Reference Genome (.[FASTA](https://en.wikipedia.org/wiki/FASTA_format))',
        'icon_file.png',
      ),
    ],
    outputs: [
      WorkflowNodeInOut(
        'somatic-variants.[VCF](https://en.wikipedia.org/wiki/Variant_Call_Format) — All raw mutation candidates',
        'icon_file.png',
      ),
      WorkflowNodeInOut(
        'filtered-variants.[VCF](https://en.wikipedia.org/wiki/Variant_Call_Format) — High-confidence, tumor-only mutations',
        'icon_file.png',
      ),
    ],
    fileFormat: '.[VCF](https://en.wikipedia.org/wiki/Variant_Call_Format)',
  ),
  WorkflowNodeData(
    id: 'NodeIn3',
    type: NodeType.data,
    title:
        '📄 2 Condensed mutation lists (.[VCF](https://en.wikipedia.org/wiki/Variant_Call_Format))',
    description:
        'somatic-variants.[VCF](https://en.wikipedia.org/wiki/Variant_Call_Format)  \nfiltered-variants.[VCF](https://en.wikipedia.org/wiki/Variant_Call_Format)',
    parentNode: 'Part1Group',
    color: 'blue',
    size: const Size(160, 0),
  ),
  WorkflowNodeData(
    id: 'NodeHLA',
    type: NodeType.data,
    title:
        '🔬 [Patient HLA profile](https://support.illumina.com/content/dam/illumina-support/help/BaseSpace_App_WGS_v6_OLH_15050955_03/Content/Source/Informatics/Apps/HLATypingFormat_appISCWGS.htm#) (.txt)',
    description: 'Immune system receptor map  \nHLA-A*02:01, HLA-B*07:02...',
    parentNode: 'Part1Group',
    color: 'blue',
    size: const Size(160, 0),
  ),
  WorkflowNodeData(
    id: 'NodeTumorRNAFastQ',
    type: NodeType.data,
    title:
        '📄  Tumor biopsy RNA-Seq.([FASTQ](https://en.wikipedia.org/wiki/FASTQ_format))',
    description:
        'tumor-rna.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format).',
    parentNode: 'Part1Group',
    color: 'blue',
    size: const Size(160, 0),
  ),
  WorkflowNodeData(
    id: 'Step3',
    type: NodeType.step,
    title: 'Step 3 · Picking the Targets',
    goal: 'AI Neoantigen Prediction',
    description:
        'Neural networks predict which mutations will most effectively trigger an immune response based on the patient HLA receptors. pVACseq also uses tumor-rna.FASTQ to filter candidate neoantigens by their actual expression levels in the tumor.',
    hardware: 'None',
    software:
        '[pVACseq](https://github.com/griffithlab/pVACtools) (open-source cancer immunotherapy suite) running [MHCflurry](https://github.com/openvax/mhcflurry) (open-source peptide-MHC binding prediction)',
    parentNode: 'Part1Group',
    color: 'rose',
    iconName: 'target',
    image: 'lib/assets/icons/icon_ai_script.png',
    inputs: [
      WorkflowNodeInOut(
        'filtered-variants.[VCF](https://en.wikipedia.org/wiki/Variant_Call_Format)',
        'icon_file.png',
      ),
      WorkflowNodeInOut(
        '[Patient HLA profile](https://support.illumina.com/content/dam/illumina-support/help/BaseSpace_App_WGS_v6_OLH_15050955_03/Content/Source/Informatics/Apps/HLATypingFormat_appISCWGS.htm#) (.txt)',
        'icon_file.png',
      ),
      WorkflowNodeInOut(
        'tumor-rna.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format) - used by pVACseq to filter candidates by expression level',
        'icon_file.png',
      ),
    ],
    outputs: [
      WorkflowNodeInOut(
        '[ranked-predictions.tsv](https://pvactools.readthedocs.io/en/7.0.0_docs/pvacseq/output_files.html) — Leaderboard of best targets',
        'icon_file.png',
      ),
    ],
    fileFormat: '.tsv',
  ),
  WorkflowNodeData(
    id: 'NodeIn4',
    type: NodeType.data,
    title: '📊 Ranked leaderboard of targets (.tsv)',
    description:
        '[ranked-predictions.tsv](https://pvactools.readthedocs.io/en/7.0.0_docs/pvacseq/output_files.html)  \nTop predicted neoantigens',
    parentNode: 'Part1Group',
    color: 'blue',
  ),
  WorkflowNodeData(
    id: 'Step4',
    type: NodeType.step,
    title: 'Step 4 · Writing the New Code',
    goal: 'Sequence Assembly',
    description:
        'Organize the cancer markers into a safe, logical order and then translate those instructions into a highly stable genetic "recipe."',
    hardware: 'None',
    software:
        '[pVACvector](https://github.com/griffithlab/pVACtools) (open-source cancer immunotherapy suite)+ [LinearDesign](https://github.com/LinearDesignSoftware/LinearDesign) (open source mRNA design algorithm)',
    parentNode: 'Part1Group',
    color: 'rose',
    iconName: 'pen-tool',
    image: 'lib/assets/icons/icon_ai_script.png',
    inputs: [
      WorkflowNodeInOut(
        'Top targets from [ranked-predictions.tsv](https://pvactools.readthedocs.io/en/7.0.0_docs/pvacseq/output_files.html)',
        'icon_file.png',
      ),
    ],
    outputs: [
      WorkflowNodeInOut(
        '[vaccine-construct.fa](https://en.wikipedia.org/wiki/FASTA_format) — Master mRNA sequence',
        'icon_file.png',
      ),
    ],
    fileFormat: '.fa',
  ),
  WorkflowNodeData(
    id: 'NodeIn5',
    type: NodeType.data,
    title: '📜 Optimized mRNA blueprint (.fa)',
    description:
        '[vaccine-construct.fa](https://en.wikipedia.org/wiki/FASTA_format) (Master sequence)',
    parentNode: 'Part1Group',
    color: 'blue',
  ),

  // PART 2
  WorkflowNodeData(
    id: 'Part2Group',
    type: NodeType.group,
    title: 'Part B: Downstream Physical Pipeline · Blueprint → Vial',
    label: 'Part B: Downstream Physical Pipeline · Blueprint → Vial',
    color: 'teal',
  ),
  WorkflowNodeData(
    id: 'Title2',
    type: NodeType.title,
    title: 'Part B: Downstream Physical Pipeline',
    description: 'Blueprint → Vial',
    parentNode: 'Part2Group',
    fontSize: 30,
    color: 'teal',
  ),
  WorkflowNodeData(
    id: 'Step5',
    type: NodeType.step,
    title: 'Step 5 · Printing the Master Copy',
    goal: 'DNA Synthesis',
    description:
        'Two synthesis routes are available — choose one: \n1. **Cell-Free / Linear (recommended for speed):** The BioXp system prints the DNA template directly from the digital sequence. \n2. **Plasmid-Based (traditional):** Gibson Assembly stitches oligonucleotides into a DNA plasmid, which is then linearized with enzymes.',
    hardware:
        'Benchtop DNA Synthesizer (e.g., [Telesis Bio BioXp](https://telesisbio.com/products/bioxp-systems/))',
    outsourced: 'Twist, IDT, GenScript, Azenta',
    cost:
        '~\$100k fixed + ~\$600 / rxn (In-House) or ~\$200-\$900 / rxn (Outsourced)',
    parentNode: 'Part2Group',
    color: 'teal',
    iconName: 'printer',
    image: 'lib/assets/hardware/bioxp.png',
    inputs: [
      WorkflowNodeInOut(
        '[vaccine-construct.fa](https://en.wikipedia.org/wiki/FASTA_format) blueprint',
        'icon_file.png',
      ),
      WorkflowNodeInOut(
        'Reagents — Oligonucleotides, BspQI restriction enzymes, AMPure XP purification beads (cell-free route) or competent *E. coli* cells, LB media, miniprep kit (plasmid route)',
        'icon_12ml.png',
      ),
    ],
    outputs: [
      WorkflowNodeInOut(
        '~1.5 mL Purified linear DNA template (~75 µg)',
        'icon_dna.png',
      ),
    ],
    fileFormat: 'Liquid DNA',
  ),
  WorkflowNodeData(
    id: 'NodeIn6',
    type: NodeType.data,
    title: '📜 1.5 mL Purified linear DNA template',
    description: 'Yield: ~75 µg (at ~50 ng/µL)  \nStable at -20°C',
    parentNode: 'Part2Group',
    color: 'teal',
    images: ['lib/assets/icons/icon_dna.png'],
  ),
  WorkflowNodeData(
    id: 'NodeIVT',
    type: NodeType.data,
    title: '⚗️ IVT Reagents',
    description: 'RNA Polymerase, N1-methylpseudouridine, CleanCap® AG',
    parentNode: 'Part2Group',
    color: 'teal',
  ),
  WorkflowNodeData(
    id: 'Step6',
    type: NodeType.step,
    title: 'Step 6 · Creating the mRNA',
    goal: 'Automated mRNA Synthesis',
    description:
        'Continuous-flow In Vitro Transcription (IVT) bioreactors read the DNA and print the corresponding mRNA strand. After transcription, two cleanup steps:  \n1. **DNase I digest** — Degrades the remaining DNA template.  \n2. **mRNA purification** — Removes enzymes, free nucleotides, and abortive transcripts via precip. (LiCL) or column (e.g., silica column or HPLC).',
    hardware:
        '[Telesis Bio BioXp](https://telesisbio.com/products/bioxp-systems/)',
    outsourced: 'TriLink, GenScript, BiCell Scientific',
    cost:
        '~\$250k fixed + ~\$2k / rxn (In-House) or ~\$1k-\$3k / rxn (Outsourced)',
    parentNode: 'Part2Group',
    color: 'teal',
    iconName: 'factory',
    image: 'lib/assets/hardware/bioxp.png',
    inputs: [
      WorkflowNodeInOut(
        '~1.5 mL Purified linear DNA template (~75 µg)',
        'icon_dna.png',
      ),
      WorkflowNodeInOut('IVT Reagents', 'icon_5ml_dna.png'),
    ],
    outputs: [
      WorkflowNodeInOut('~5.0 mL Highly pure mRNA (~1.0 mg)', 'icon_mrna.png'),
    ],
    fileFormat: 'Liquid mRNA',
  ),
  WorkflowNodeData(
    id: 'NodeIn7',
    type: NodeType.data,
    title: '💉 5.0 mL Highly pure mRNA',
    description: 'Yield: ~1.0 mg (at ~200 ng/µL)  \nStored at -80°C',
    parentNode: 'Part2Group',
    color: 'teal',
    images: ['lib/assets/icons/icon_5ml_dna.png'],
  ),
  WorkflowNodeData(
    id: 'NodeLipids',
    type: NodeType.data,
    title: '🧴 4-Lipid Cocktail',
    description: 'ALC-0315, PEG-Lipid, DSPC, Cholesterol',
    parentNode: 'Part2Group',
    color: 'teal',
  ),
  WorkflowNodeData(
    id: 'Step7',
    type: NodeType.step,
    title: 'Step 7 · Packaging for Delivery',
    goal: 'LNP Formulation',
    description:
        'Microfluidic collisions force mRNA and lipids to self-assemble into nanoparticles.',
    hardware:
        '[Unchained Labs Sunshine](https://www.unchainedlabs.com/sunshine/) / NanoAssemblr Ignite',
    outsourced: 'VectorBuilder, Lonza, Vernal Biosciences',
    cost:
        '~\$150k fixed + ~\$500 / rxn (In-House) or ~\$2k-\$5k / rxn (Outsourced)',
    parentNode: 'Part2Group',
    color: 'teal',
    iconName: 'package',
    image: 'lib/assets/hardware/unchained_sunshine.png',
    inputs: [
      WorkflowNodeInOut('~5.0 mL Highly pure mRNA (~1.0 mg)', 'icon_mrna.png'),
      WorkflowNodeInOut('4-Lipid Cocktail', 'icon_12ml.png'),
    ],
    outputs: [
      WorkflowNodeInOut(
        '~12 mL Raw mRNA-LNP mixture (~0.9 mg encapsulated)',
        'icon_12ml.png',
      ),
    ],
    fileFormat: 'LNP Mixture',
  ),
  WorkflowNodeData(
    id: 'NodeIn8',
    type: NodeType.data,
    title: '🧪 12 mL Raw mRNA-LNP mixture',
    description:
        'Yield: ~0.9 mg encapsulated (>90% efficiency)  \nOpalescent liquid',
    parentNode: 'Part2Group',
    color: 'teal',
    images: ['lib/assets/icons/icon_12ml.png'],
  ),
  WorkflowNodeData(
    id: 'Step8',
    type: NodeType.step,
    title: 'Step 8 · Quality Check & Bottling',
    goal: 'QC & Finalization',
    description: 'DLS verifies 60-100nm particles and TFF washes out ethanol.',
    hardware:
        '[Unchained Labs Stunner](https://www.unchainedlabs.com/stunner/) & TFF System',
    outsourced: 'CordenPharma, uBriGene, VectorBuilder',
    cost:
        '~\$100k fixed + ~\$100 / rxn (In-House) or ~\$1k-\$3k / rxn (Outsourced)',
    parentNode: 'Part2Group',
    color: 'teal',
    iconName: 'flask-conical',
    image: 'lib/assets/hardware/unchained_stunner.png',
    inputs: [WorkflowNodeInOut('~12 mL Raw mRNA-LNP mixture', 'icon_12ml.png')],
    outputs: [
      WorkflowNodeInOut(
        '10 x 1.0 mL sterile glass vials (approx. 10 doses)',
        'icon_vaccine.png',
      ),
    ],
    fileFormat: 'Final Vaccine Product',
  ),
  WorkflowNodeData(
    id: 'NodeEnd',
    type: NodeType.data,
    title: '💊 10 x 1.0 mL Vaccine Vials',
    description: 'Concentration: ~100 µg/mL  \n10 Doses',
    parentNode: 'Part2Group',
    color: 'teal',
    images: ['lib/assets/icons/icon_vaccine.png'],
    isHighlighted: false,
  ),
];

final List<WorkflowEdgeData> initialEdges = [
  WorkflowEdgeData(
    id: 'e1a-step1',
    source: 'NodeIn1A',
    target: 'Step1',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'e1b-step1',
    source: 'NodeIn1B',
    target: 'Step1',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'step1-e2',
    source: 'Step1',
    target: 'NodeIn2',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'e2-step2',
    source: 'NodeIn2',
    target: 'Step2',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'ref-step2',
    source: 'NodeRef',
    target: 'Step2',
    dashed: true,
    label: 'Reference',
  ),
  WorkflowEdgeData(
    id: 'step2-e3',
    source: 'Step2',
    target: 'NodeIn3',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'hla-step3',
    source: 'NodeHLA',
    target: 'Step3',
    dashed: true,
  ),
  WorkflowEdgeData(
    id: 'e3-step3',
    source: 'NodeIn3',
    target: 'Step3',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'tumor-rna-step3',
    source: 'NodeTumorRNAFastQ',
    target: 'Step3',
    dashed: true,
  ),
  WorkflowEdgeData(
    id: 'step3-e4',
    source: 'Step3',
    target: 'NodeIn4',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'e4-step4',
    source: 'NodeIn4',
    target: 'Step4',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'step4-e5',
    source: 'Step4',
    target: 'NodeIn5',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'e5-step5',
    source: 'NodeIn5',
    target: 'Step5',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'step5-e6',
    source: 'Step5',
    target: 'NodeIn6',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'ivt-step6',
    source: 'NodeIVT',
    target: 'Step6',
    dashed: true,
  ),
  WorkflowEdgeData(
    id: 'e6-step6',
    source: 'NodeIn6',
    target: 'Step6',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'step6-e7',
    source: 'Step6',
    target: 'NodeIn7',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'lipids-step7',
    source: 'NodeLipids',
    target: 'Step7',
    dashed: true,
  ),
  WorkflowEdgeData(
    id: 'e7-step7',
    source: 'NodeIn7',
    target: 'Step7',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'step7-e8',
    source: 'Step7',
    target: 'NodeIn8',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'e8-step8',
    source: 'NodeIn8',
    target: 'Step8',
    animated: true,
  ),
  WorkflowEdgeData(
    id: 'step8-end',
    source: 'Step8',
    target: 'NodeEnd',
    animated: true,
  ),
];

final List<WorkflowStep> workflowSteps = [
  WorkflowStep(
    id: 1,
    title: 'Initial Step: Procure Patient Samples',
    part: 'Part A: Upstream Digital Pipeline',
    nodeIds: ['NodeIn1A', 'NodeIn1B'],
  ),
  WorkflowStep(
    id: 2,
    title: 'Step 1: Reading the Blueprint',
    part: 'Part A: Upstream Digital Pipeline',
    nodeIds: ['Step1', 'NodeIn1A', 'NodeIn1B', 'NodeIn2'],
  ),
  WorkflowStep(
    id: 3,
    title: 'Step 2: Spotting the Typos',
    part: 'Part A: Upstream Digital Pipeline',
    nodeIds: ['Step2', 'NodeIn2', 'NodeRef', 'NodeIn3'],
  ),
  WorkflowStep(
    id: 4,
    title: 'Step 3: Picking the Targets',
    part: 'Part A: Upstream Digital Pipeline',
    nodeIds: ['Step3', 'NodeIn3', 'NodeHLA', 'NodeIn4', 'NodeTumorRNAFastQ'],
  ),
  WorkflowStep(
    id: 5,
    title: 'Step 4: Writing the New Code',
    part: 'Part A: Upstream Digital Pipeline',
    nodeIds: ['Step4', 'NodeIn4', 'NodeIn5'],
  ),
  WorkflowStep(
    id: 6,
    title: 'Step 5: Printing the Master Copy',
    part: 'Part B: Downstream Physical Pipeline',
    nodeIds: ['Step5', 'NodeIn5', 'NodeIn6'],
  ),
  WorkflowStep(
    id: 7,
    title: 'Step 6: Creating the mRNA',
    part: 'Part B: Downstream Physical Pipeline',
    nodeIds: ['Step6', 'NodeIn6', 'NodeIVT', 'NodeIn7'],
  ),
  WorkflowStep(
    id: 8,
    title: 'Step 7: Packaging for Delivery',
    part: 'Part B: Downstream Physical Pipeline',
    nodeIds: ['Step7', 'NodeIn7', 'NodeLipids', 'NodeIn8'],
  ),
  WorkflowStep(
    id: 9,
    title: 'Step 8: Quality Check & Bottling',
    part: 'Part B: Downstream Physical Pipeline',
    nodeIds: ['Step8', 'NodeIn8', 'NodeEnd'],
  ),
  WorkflowStep(
    id: 10,
    title: 'Final Vaccine Product',
    part: 'Part B: Downstream Physical Pipeline',
    nodeIds: ['NodeEnd'],
  ),
];
