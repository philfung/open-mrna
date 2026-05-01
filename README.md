[![Contributions](https://img.shields.io/badge/contributions-welcome-blue)](https://github.com/philfung/open-mrna/graphs/contributors)
[![Last Commit](https://img.shields.io/github/last-commit/philfung/open-mrna)]()
[![License: MIT](https://img.shields.io/badge/license-Apache%20License%202.0-blue)](https://opensource.org/license/apache-2.0)
[![Version](https://img.shields.io/badge/version-v0.5.0--beta-orange)](https://github.com/philfung/open-mrna/releases)

# 💉 Open-mRNA: A guide to producing a personalized mRNA cancer vaccine
From biopsy to syringe: this is an end-to-end overview on how to synthesize personalized mRNA cancer vaccine in a private lab.
Focuses on open-source, state-of-the-art software tools paired with "best-tool-for-the-job" benchtop lab equipment.

> [!CAUTION]
> **⚠️ RESEARCH & EDUCATION USE ONLY. NOT MEDICAL ADVICE.**
> This is a reference for educational purposes. Building mRNA vaccines involves severe biological hazards, requiring strict oversight and qualified personnel. The authors assume no liability for misuse.  Do not attempt any part of this workflow.

[**Try the Interactive Guide**](https://philfung.github.io/open-mrna/)

* **Contributing**: Open to contributors.
* **Feature Requests**: please open a Github issue.


<img height="500" alt="screenshot" src="https://github.com/user-attachments/assets/baf2de9a-8470-41b8-b4ef-289fb01f4763" />

# Table of Contents
- [System Architecture](#system-architecture)
- [Workflow, Part 1: Upstream Digital Pipeline ("Data to Blueprint")](#workflow-part-1-upstream-digital-pipeline-data-to-blueprint)
- [Workflow, Part 2: Downstream Physical Pipeline ("Blueprint to Vial")](#workflow-part-2-downstream-physical-pipeline-blueprint-to-vial)
- [Web App](#web-app)
- [Tips and Considerations](#tips-and-considerations)
- [Acknowledgements](#acknowledgements)

# System Architecture

This pipeline is divided into two continuous halves:
1. **Data to Blueprint:** Ingests raw sequencing data, utilizes neural networks to identify immunogenic targets, and compiles a stabilized digital mRNA sequence.
2. **Blueprint to Vial:** Converts the digital `.FASTA` sequence into physical DNA, automates In Vitro Transcription (IVT), and formulates the final LNP drug product.

---

# Workflow, Part 1: Upstream Digital Pipeline ("Data to Blueprint")

## Step 1: Reading the Blueprint
**Goal:** Convert samples into unorganized genetic code to establish a baseline and identify anomalies.
* **Hardware:** [Illumina NextSeq 2000](https://www.illumina.com/systems/sequencing-platforms/nextseq-1000-2000.html) or Element AVITI
* **Alt. (Outsourced):** Tempus, Personalis, CeGaT, Novogene
* **Est. Cost:** ~$300k fixed + ~$1k / pt (In-House) or ~$3k-$10k / pt (Outsourced Clinical)
* **Inputs:**
  * Tumor biopsy - at least 35mg in tissue (from immediate dry ice storage)
  * Normal blood (healthy baseline) - standard 4ml EDTA tube
* **Process:** The machine reads extracted DNA/RNA, turning biological chemistry into digital text.
* **Outputs:**
  1. `baseline-normal.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format)` - Normal blood Whole Exome Sequencing (~30X-50X) or Whole Genome Sequencing (WGS)
  2. `tumor-exome.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format)` - Tumor biopsy Whole Exome Sequencing (~100X-500X) or Whole Genome Sequencing (WGS)
  3. `tumor-rna.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format)` - Tumor biopsy RNA-Seq (~50M-100M reads).
  4. `tumor-rna-quantification.tsv` - Tumor gene expression levels. Made using [Salmon / Kallisto](https://learn.gencore.bio.nyu.edu/rna-seq-analysis/salmon-kallisto-rapid-transcript-quantification-for-rna-seq-data/) on the FASTQ file.
  5. `[patient-hla.txt](https://support.illumina.com/content/dam/illumina-support/help/BaseSpace_App_WGS_v6_OLH_15050955_03/Content/Source/Informatics/Apps/HLATypingFormat_appISCWGS.htm#)` - Patient HLA profile (MHC Class I & II typing). Made using [OptiType](https://github.com/nf-core/hlatyping) or [HLA-HD](https://github.com/TRON-Bioinformatics/tronflow-hla-hd) on baseline-normal.FASTQ
* **File Format:** `.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format) & .txt`

## Step 2: Spotting the Typos
**Goal:** Compare healthy code against tumor code to isolate cancers.
* **Hardware:** None
* **Software Pipeline:**
  1. **Alignment:** Map raw reads to the reference genome using [BWA-MEM](https://github.com/lh3/BWA).
  2. **Variant Calling (Ensemble):** Take the convergent results from multiple models to isolate somatic mutations:
     * [GATK Mutect2](https://github.com/broadinstitute/gatk) (Bayesian somatic model)
     * Google's [DeepSomatic](https://github.com/google/deepsomatic)
     * Illumina's [Strelka](https://github.com/illumina/strelka)
  3. **Annotation:** Add biological context to the identified mutations using [Ensembl VEP](https://github.com/Ensembl/ensembl-vep).
* **Inputs:** `baseline-normal.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format)`, `tumor-exome.[FASTQ](https://en.wikipedia.org/wiki/FASTQ_format)`, `Human Reference Genome (.[FASTA](https://en.wikipedia.org/wiki/FASTA_format))`
* **Process:** Aligns reads, mathematically subtracts healthy DNA from tumor DNA to isolate somatic mutations, and annotates the results.
* **Outputs:**
  1. `somatic-variants.[VCF](https://en.wikipedia.org/wiki/Variant_Call_Format)` - All raw mutation candidates
  2. `filtered-variants.[VCF](https://en.wikipedia.org/wiki/Variant_Call_Format)` - High-confidence, tumor-only mutations (annotated)
* **File Format:** `.[VCF](https://en.wikipedia.org/wiki/Variant_Call_Format)`

## Step 3: Picking the Targets
**Goal:** Use AI to predict which mutations the immune system will recognize as a threat.
* **Hardware:** None
* **Software:** Run [nextNEOpi](https://github.com/icbi-lab/nextNEOpi) (open-source neoantigen prediction pipeline) with 1 or more peptide-MHC binding prediction tools:
  1. [MHCflurry](https://github.com/openvax/mhcflurry) (open-source)
  2. [NetMHCpan](https://services.healthtech.dtu.dk/services/NetMHCpan-4.1/) (commercial) with [pVACSeq](https://pvactools.readthedocs.io/en/latest/pvacseq.html) 
* **Inputs:** `filtered-variants.[VCF](https://en.wikipedia.org/wiki/Variant_Call_Format)`, `[Patient HLA profile](https://support.illumina.com/content/dam/illumina-support/help/BaseSpace_App_WGS_v6_OLH_15050955_03/Content/Source/Informatics/Apps/HLATypingFormat_appISCWGS.htm#) (.txt)`, `tumor-rna-quantification.tsv` - Filter candidates by expression level
* **Process:** Neural networks predict which mutations will most effectively trigger an immune response based on the patient HLA receptors (or equivalent, such as DLA for dogs). Crucially, DNA-predicted targets must be validated against RNA sequencing data to confirm the mutations are actively being expressed by the tumor. Only epitopes with confirmed RNA expression are retained as candidates.
* **Outputs:** `[ranked-predictions.tsv](https://pvactools.readthedocs.io/en/7.0.0_docs/pvacseq/output_files.html)` - Leaderboard of best targets
* **File Format:** `.tsv`

## Step 4: Writing the New Code
**Goal:** Compile the top predicted targets into a printable digital blueprint.
* **Hardware:** None
* **Software:** 
  1. Generate protein string: [NeoDesign](https://github.com/HuangLab-Fudan/neoDesign), [pVACvector](https://github.com/griffithlab/pVACtools), or use an advanced LLM (e.g., Gemini / Grok)
  2. Generate multiple candidate mRNA sequences: [mRNAfold](https://github.com/maxhwardg/mRNAfold)
  3. Select best mRNA sequence: [mRNABERT](https://github.com/yyly6/mRNABERT)
* **Inputs:** Top targets from `[ranked-predictions.tsv](https://pvactools.readthedocs.io/en/7.0.0_docs/pvacseq/output_files.html)`
* **Process:** Organize the cancer markers into a safe, logical order and then translate those instructions into a highly stable genetic "recipe." (Advanced LLMs can be utilized here for heuristic refinement, selecting optimized linkers, and minimizing junctional immunogenicity.)
* **Outputs:** `[vaccine-construct.fa](https://en.wikipedia.org/wiki/FASTA_format)` - Master mRNA sequence
* **File Format:** `.fa`

---

# Workflow, Part 2: Downstream Physical Pipeline ("Blueprint to Vial")

## Step 5: Printing the Master Copy
**Goal:** Convert the digital blueprint back into a physical, readable linear DNA template.
* **Hardware:** Benchtop DNA Synthesizer (e.g., [Telesis Bio BioXp](https://telesisbio.com/products/bioxp-system/bioxp-3250-system/))
* **Alt. (Outsourced):** Twist, IDT, GenScript, Azenta
* **Est. Cost:** ~$100k fixed + ~$600 / rxn (In-House) or ~$200-$900 / rxn (Outsourced)
* **Inputs:**
  * `[vaccine-construct.fa](https://en.wikipedia.org/wiki/FASTA_format)` blueprint
  * Reagents - Oligonucleotides, BspQI restriction enzymes, AMPure XP purification beads (cell-free route) or competent *E. coli* cells, LB media, miniprep kit (plasmid route)
* **Process:** Two synthesis routes are available - choose one:
  1. **Cell-Free / Linear (recommended for speed):** The BioXp system prints the DNA template directly from the digital sequence.
  2. **Plasmid-Based (traditional):** Gibson Assembly stitches oligonucleotides into a DNA plasmid, which is then linearized with enzymes.
* **Outputs:** ~1.5 mL Purified linear DNA template (~75 ug)
* **File Format:** Liquid DNA

## Step 6: Creating the mRNA
**Goal:** Transcribe DNA into functional, immune-cloaked mRNA.
* **Hardware:** [Telesis Bio BioXp](https://telesisbio.com/products/bioxp-system/bioxp-3250-system/)
* **Alt. (Outsourced):** Integrated (Research & GMP): Lonza, Aldevron, TriLink | Specialists: Vernal Biosciences, VectorBuilder
* **Est. Cost:** ~$250k fixed + ~$2k / rxn (In-House) or ~$1k-$3k / rxn (Outsourced)
* **Inputs:**
  * ~1.5 mL Purified linear DNA template (~75 ug)
  * IVT Reagents (RNA Polymerase, N1-methylpseudouridine, CleanCap AG)
* **Process:** Automated In Vitro Transcription (IVT) systems synthesize the mRNA strand from the DNA template. The process includes:
  1. DNase I digestion to remove the template
  2. multi-stage purification (e.g., magnetic beads or HPLC) to isolate pure, functional mRNA.
* **Outputs:** ~5.0 mL Highly pure mRNA (~1.0 mg)
* **File Format:** Liquid mRNA

## Step 7: Packaging for Delivery
**Goal:** Wrap mRNA in a protective lipid nanoparticle to allow human cell entry.

> [!WARNING]
> **The Delivery System:** Calibrate microfluidic flow rates and lipid-to-mRNA ratios to ensure LNP sizes remain between 60-100nm, preventing degradation in the bloodstream.
* **Hardware:** [Unchained Labs Sunshine](https://www.unchainedlabs.com/sunshine/) / NanoAssemblr Ignite
* **Alt. (Outsourced):** Integrated (Research & GMP): Lonza, Aldevron, TriLink | Specialists: Vernal Biosciences, VectorBuilder
* **Est. Cost:** ~$150k fixed + ~$500 / rxn (In-House) or ~$2k-$5k / rxn (Outsourced)
* **Inputs:**
  * ~5.0 mL Highly pure mRNA (~1.0 mg)
  * 4-Lipid Cocktail (ALC-0315, PEG-Lipid, DSPC, Cholesterol)
* **Process:** Precise microfluidic collisions force the negatively charged mRNA and positively charged lipids to self-assemble into nanoparticles.
* **Outputs:** ~12 mL Raw mRNA-LNP mixture (~0.9 mg encapsulated)
* **File Format:** LNP Mixture

## Step 8: Quality Check and Bottling
**Goal:** Validate integrity, size, and concentration before finalizing for injection.

> [!CAUTION]
> **Sterility and Purity:** Manufacture final product in an ISO-certified "Clean Room" to minimize the risk of bacterial endotoxins and other contaminants.
* **Hardware:** [Unchained Labs Stunner](https://www.unchainedlabs.com/stunner/) & TFF System
* **Alt. (Outsourced):** Integrated (Research & GMP): Lonza, Aldevron, TriLink | Specialists: Vernal Biosciences, VectorBuilder
* **Est. Cost:** ~$100k fixed + ~$100 / rxn (In-House) or ~$1k-$3k / rxn (Outsourced)
* **Inputs:** ~12 mL Raw mRNA-LNP mixture
* **Process:** DLS verifies particles are exactly 60-100nm. TFF washes out ethanol.
* **Outputs:** 10 x 1.0 mL sterile glass vials (approx. 10 doses)
* **File Format:** Final Vaccine Product

---

# Web App

You can explore the system architecture interactively through our Flutter-based web app.

### Running it locally
The interactive workflow is a Vite-based application. To run it:

1.  **Navigate to the directory:**
    ```bash
    cd flutter_website
    ```
2.  **Install dependencies:**
    ```bash
    flutter build web
    ```
3.  **Start the development server:**
    ```bash
    flutter run -d chrome
    ```
4.  **Or, to build for production:**
    ```bash
    flutter build web --release --base-href "/open-mrna/" <--wasm>
    ```
    The website will be available in the build/web folder

---

# Tips and Considerations

### The Role of AI
An advanced LLM can be useful for orchestrating the bioinformatics workflow, debugging dependency conflicts, designing multimodal treatment protocols, and navigating ethics approvals.

### Protocol
The administration of a personalized mRNA vaccine is often part of a broader, multimodal treatment protocol designed to disable the cancer's defense mechanisms. For example, a treatment protocol with critical sequence and timing could include use of Tyrosine Kinase Inhibitors (TKIs) and PD-1 inhibitors.

# Related
* [Awesome mRNA Cancer Vaccine Research](https://github.com/philfung/awesome-mrna-cancer-vaccines)

# Acknowledgements

1. This is **heavily inspired** by [Paul S Conyngham's](https://x.com/paul_conyngham/status/2036940410363535823) valiant effort in developing a personalized mRNA vaccine for his dog, Rosie.

2. Thanks to the open-source and bioinformatics communities for these critical tools:
* **[BWA / BWA-MEM](https://github.com/lh3/BWA)**: The industry standard for sequence alignment.
* **[Ensembl VEP](https://github.com/Ensembl/ensembl-vep)**: For comprehensive variant annotation.
* **[GATK (Mutect2)](https://github.com/broadinstitute/gatk)**: The gold standard for variant calling and discovery.
* **[MHCflurry](https://github.com/openvax/mhcflurry)**: For open-source MHC class I binding predictions.
* **[NeoDesign](https://github.com/HuangLab-Fudan/neoDesign) / [mRNAfold](https://github.com/maxhwardg/mRNAfold) / [mRNABERT](https://github.com/yyly6/mRNABERT)**: For downstream mRNA sequence optimization and modeling.
* **[NetMHCpan](https://services.healthtech.dtu.dk/services/NetMHCpan-4.1/)**: For state-of-the-art peptide-MHC binding prediction.
* **[nextNEOpi](https://github.com/icbi-lab/nextNEOpi)**: For an integrated neoantigen prediction pipeline.
* **[OptiType](https://github.com/nf-core/hlatyping) / [HLA-HD](https://github.com/TRON-Bioinformatics/tronflow-hla-hd)**: For precision HLA typing.
* **[pVACseq / pVACtools](https://pvactools.readthedocs.io/en/latest/pvacseq.html)**: For streamlining neoantigen identification.
* **[Salmon / Kallisto](https://learn.gencore.bio.nyu.edu/rna-seq-analysis/salmon-kallisto-rapid-transcript-quantification-for-rna-seq-data/)**: For rapid transcript quantification.
* **[Strelka](https://github.com/illumina/strelka) / [DeepSomatic](https://github.com/google/deepsomatic)**: For high-accuracy somatic variant calling.

---

# License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
    


