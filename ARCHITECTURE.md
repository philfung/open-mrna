# System Architecture Diagram

This document contains the visual representation of the end-to-end mRNA cancer vaccine workflow.

```mermaid
%%{init: {'themeVariables': { 'fontSize': '16px', 'fontFamily': '-apple-system, BlinkMacSystemFont, Segoe UI, Inter, Roboto, Helvetica Neue, sans-serif' }}}%%
flowchart TD
    %% PART 1 %%
    Title1["<div style='font-size: 24px; font-weight: 700; min-width: 1100px; text-align: center; letter-spacing: -0.5px;'>📘 Part 1: Upstream Digital Pipeline · Data → Blueprint</div>"]
    %% Phase 1
    Title1 ~~~ NodeIn1
    NodeIn1(["<div style='font-size: 15px; font-weight: 600;'>🧬 Tumor biopsy & Normal blood</div><div style='font-size: 13px; opacity: 0.85;'>Normal DNA: ~30X WES<br>Tumor DNA: ~100X+ WES<br>Tumor RNA: RNA-Seq</div>"])
    NodeIn1 --> Phase1
    Phase1["<div style='font-size: 19px; font-weight: 700; color: #DC2626 !important; margin-bottom: 6px;'>Phase 1 · Reading the Blueprint</div><div style='font-size: 14px; color: #374151;'>The machine reads extracted DNA/RNA, turning biological chemistry into digital text.<br><b>Hardware:</b> Next-Generation Sequencer (e.g., Illumina NextSeq 2000 or Element AVITI, ~$300k)<br><b>Cost:</b> ~$1,000 / pt</div>"]
    Phase1 --> NodeIn2
    NodeIn2(["<div style='font-size: 15px; font-weight: 600;'>📄 Billions of patient genetic reads (.fastq)</div><div style='font-size: 13px; opacity: 0.85;'>@Machine_Read_ID_001<br>GATTTGG...</div>"])
    
    %% Phase 2
    NodeRef(["<div style='font-size: 15px; font-weight: 600;'>🧬 Human Reference Genome (.fasta)</div><div style='font-size: 13px; opacity: 0.85;'>(e.g. Human Genome Project)<br>>chr1 NNNNNNNNNN...</div>"])
    NodeIn2 --> Phase2
    NodeRef -.-> Phase2
    Phase2["<div style='font-size: 19px; font-weight: 700; color: #DC2626 !important; margin-bottom: 6px;'>Phase 2 · Spotting the Typos</div><div style='font-size: 14px; color: #374151;'>Aligns reads and mathematically subtracts healthy DNA from tumor DNA to isolate somatic mutations.<br><b>Software:</b> GATK Mutect2</div>"]
    Phase2 --> NodeIn3
    NodeIn3(["<div style='font-size: 15px; font-weight: 600;'>📄 Condensed list of mutations (.vcf)</div><div style='font-size: 13px; opacity: 0.85;'>#CHROM POS ID REF ALT...<br>chr7 14045313...</div>"])
    
    %% Phase 3
    NodeHLA(["<div style='font-size: 15px; font-weight: 600;'>🔬 Patient HLA profile (.txt)</div><div style='font-size: 13px; opacity: 0.85;'>Immune system receptor map<br>HLA-A*02:01, HLA-B*07:02...</div>"])
    Phase1 --> NodeHLA
    NodeHLA -.-> Phase3
    NodeIn3 --> Phase3
    Phase3["<div style='font-size: 19px; font-weight: 700; color: #DC2626 !important; margin-bottom: 6px;'>Phase 3 · Picking the Targets</div><div style='font-size: 14px; color: #374151;'>Neural networks predict which mutations will most effectively trigger an immune response based on the patient's HLA receptors.<br><b>Software:</b> pVACseq running MHCflurry neural networks</div>"]
    Phase3 --> NodeIn4
    NodeIn4(["<div style='font-size: 15px; font-weight: 600;'>📊 Ranked leaderboard of targets (.tsv)</div><div style='font-size: 13px; opacity: 0.85;'>Target_Rank Peptide_Sequence...<br>1 YLLPAIVHI...</div>"])
    
    %% Phase 4
    NodeIn4 --> Phase4
    Phase4["<div style='font-size: 19px; font-weight: 700; color: #DC2626 !important; margin-bottom: 6px;'>Phase 4 · Writing the New Code</div><div style='font-size: 14px; color: #374151;'>Strings targets together, adds structural instructions (5' Cap, Poly-A tail), and optimizes codons for folding stability.<br><b>Software:</b> pVACvector + LinearDesign</div>"]
    
    %% PART 2 %%
    Title2["<div style='font-size: 24px; font-weight: 700; min-width: 1100px; text-align: center; letter-spacing: -0.5px;'>🧪 Part 2: Downstream Physical Pipeline · Blueprint → Vial</div>"]
    %% Phase 5
    Title2 ~~~ Phase5
    Phase4 --> Phase5
    Phase5["<div style='font-size: 19px; font-weight: 700; color: #DC2626 !important; margin-bottom: 6px;'>Phase 5 · Printing the Master Copy</div><div style='font-size: 14px; color: #374151;'>Automated Gibson Assembly stitches synthetic oligonucleotides into a complete DNA plasmid, which is then linearized with restriction enzymes.<br><b>Hardware:</b> Benchtop DNA Synthesizer (e.g., Telesis Bio BioXp, ~$100k)<br><b>Cost:</b> ~$600 / rxn</div>"]
    Phase5 --> NodeIn6
    NodeIn6(["<div style='font-size: 15px; font-weight: 600;'>🧫 Purified linear DNA template</div>"])
    
    %% Phase 6
    NodeIVT(["<div style='font-size: 15px; font-weight: 600;'>⚗️ IVT Reagents</div>"])
    NodeIVT -.-> Phase6
    NodeIn6 --> Phase6
    Phase6["<div style='font-size: 19px; font-weight: 700; color: #DC2626 !important; margin-bottom: 6px;'>Phase 6 · Mass Production</div><div style='font-size: 14px; color: #374151;'>Continuous-flow In Vitro Transcription (IVT) bioreactors read the DNA and print the corresponding mRNA strand.<br><b>Hardware:</b> NTxscribe System / Telesis Bio BioXp (~$250k / ~$100k)<br><b>Cost:</b> ~$2,000 / rxn</div>"]
    Phase6 --> NodeIn7
    NodeIn7(["<div style='font-size: 15px; font-weight: 600;'>💉 Highly pure, naked mRNA</div>"])
    
    %% Phase 7
    NodeLipids(["<div style='font-size: 15px; font-weight: 600;'>🧴 4-Lipid Cocktail</div>"])
    NodeLipids -.-> Phase7
    NodeIn7 --> Phase7
    Phase7["<div style='font-size: 19px; font-weight: 700; color: #DC2626 !important; margin-bottom: 6px;'>Phase 7 · Packaging for Delivery</div><div style='font-size: 14px; color: #374151;'>Precise microfluidic collisions force the negatively charged mRNA and positively charged lipids to self-assemble into nanoparticles.<br><b>Hardware:</b> Unchained Labs Sunshine / NanoAssemblr Ignite / Spark (~$150k / ~$150k)<br><b>Cost:</b> ~$500 / rxn</div>"]
    Phase7 --> NodeIn8
    NodeIn8(["<div style='font-size: 15px; font-weight: 600;'>🧪 Formulated mRNA-LNP mixture</div>"])
    
    %% Phase 8
    NodeIn8 --> Phase8
    Phase8["<div style='font-size: 19px; font-weight: 700; color: #DC2626 !important; margin-bottom: 6px;'>Phase 8 · Quality Check & Bottling</div><div style='font-size: 14px; color: #374151;'>Dynamic Light Scattering verifies particles are exactly 60-100nm and Tangential Flow Filtration washes out the toxic ethanol used during mixing.<br><b>Hardware:</b> Unchained Labs Stunner (~$80k) & TFF System<br><b>Cost:</b> ~$100 / rxn</div>"]
    Phase8 --> NodeEnd
    NodeEnd(["<div style='font-size: 15px; font-weight: 600;'>💊 Final Vaccine Vial</div>"])

    classDef phaseViolet fill:#F5F3FF,stroke:#8B5CF6,stroke-width:2px,text-align:left,color:#4C1D95;
    classDef phaseTeal fill:#F0FDFA,stroke:#14B8A6,stroke-width:2px,text-align:left,color:#134E4A;
    classDef dataViolet fill:#EDE9FE,stroke:#A78BFA,stroke-width:1.5px,color:#5B21B6;
    classDef dataTeal fill:#CCFBF1,stroke:#5EEAD4,stroke-width:1.5px,color:#0F766E;
    classDef titleViolet fill:#7C3AED,stroke:#6D28D9,stroke-width:2px,color:#FFFFFF;
    classDef titleTeal fill:#0D9488,stroke:#0F766E,stroke-width:2px,color:#FFFFFF;
    class Phase1,Phase2,Phase3,Phase4 phaseViolet;
    class Phase5,Phase6,Phase7,Phase8 phaseTeal;
    class NodeIn1,NodeIn2,NodeRef,NodeIn3,NodeHLA,NodeIn4 dataViolet;
    class NodeIn6,NodeIVT,NodeIn7,NodeLipids,NodeIn8,NodeEnd dataTeal;
    class Title1 titleViolet;
    class Title2 titleTeal;

    linkStyle default stroke:#94A3B8,stroke-width:2px
```
