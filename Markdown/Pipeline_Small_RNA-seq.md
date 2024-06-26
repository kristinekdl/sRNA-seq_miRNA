sRNA-seq miRNA Alignment Pipeline
================
Victor Enrique Goitea
2024-06-26

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Output](#output)

# Overview

This bash script is designed for running miRNA alignment on a SLURM
cluster. The pipeline includes read alignment using miRDeep2/Bowtie and miRNA read counting with **quantifier.pl** from miRDeep2.

# Prerequisites

- SLURM scheduler
- Modules: AdapterRemoval, miRDeep2.
- Reference genomes (provided in /work/References)

# Usage

1.  **Modify SLURM Parameters (Optional):** Open the script
    (**se_align_rnaseq_miRNA.sh**) and modify SLURM parameters
    at the beginning of the file, such as account, output file, email
    notifications, nodes, memory, CPU cores, and runtime. Alternatively,
    you can modify these parameters on-the-fly when executing the
    script. The script is setup for the adapter **TGGAATTCTCGGGTGCCAAGG** of NEXTFLEX smallRNA prep kit. You can indicate a different adapter by editing the variable ${SMALL_RNA} in line 141.

2.  On UCloud, start a **Terminal Ubuntu** run:

    - Enable **Slurm cluster**
    - To process several samples consider requesting nodes \> 1
    - Set the modules path to **FGM \> Utilities \> App \> easybuild**

    ![](../Img/terminal_slurm.png)

    - Include the References folder **FGM \> References \> References**

    ![](../Img/terminal_folders.png)

    - Include your Scripts folder and the folder with the fastq.gz
      files.

    - **Notes:**

      - Match the job CPUs to the amounts requested in the script.
      - Make sure the scripts have executing permission. If not run:
        `chmod 700 script.sh`
      - If you modify the memory parameter in the script, specify 5-10%
        less than the memory available in the terminal run.
      - Although it is not necessary to enable **tmux**, it is a good
        practise to always do it.

3.  **Run the Script:** Submit the script to the SLURM cluster:

        sbatch -J <job_name> path_to/Scripts_folder/se_align_miRNA.sh -g <mm10|mm39|hg38> <input-R1_001.fastq.gz-file>

    **Required Arguments**

    - **-g:** specify the genome to use (mm10, mm39, or hg38). The miRNA references are based on **miRbase release 22.1**.
    - Replace **input-R1_001.fastq.gz-file** with the full path to your
      input FASTQ file (R1).

    **Optional Arguments**

    For several samples you can use a for loop:

        for i in *R1_001.fastq.gz; do sbatch -J <job_name> path_to/Scripts_folder/se_align_miRNA.sh -g <mm10|mm39|hg38> $i; sleep 1; done

4.  **Monitor Job:** You can monitor the job using the SLURM commands,
    such as `squeue`, `scontrol show job <job-id> `, and check the log files
    generated.

# Description

This script performs the following main tasks:

1.  **Adapter trimming:** removes the first and last 4 bases of the adapter-trimmed reads which contain random bases added during library prep. It will then remove all remaining sequences that have fewer than 10 bases. It is configure for adapter **TGGAATTCTCGGGTGCCAAGG** of NEXTFLEX smallRNA prep kit. You can indicate a different adapter by editing the variable ${SMALL_RNA} in line 141.

2.  **Alignment - miRDeep2/Bowtie:** it runs `mapper.pl` with optional arguments **-l 18** to indicate to discard reads shorter than 18 nts. It outputs processed reads to `file.processed.fa` and read mappings to `file.mapped.arf`

3.  **Read counting - miRDeep2:** it runs `quantifier.pl`. It runs with optional arguments **-l 18** to indicate to discard reads shorter than 18 nts. It outputs processed reads to `file.processed.fa` and read mappings to `file.mapped.arf`. It uses as references **precursor_miRNA** and **mature_miRNA**.

# Output

It output files **_miRNAs_expressed.txt**, **_expression.html**. Finally, it also outputs *_miRNA_RawCounts.txt* which is a subset of "_miRNAs_expressed.txt", containing just the fields miRNA (mature miRNA ID), precursor ID, and read counts.

## Output files reorganization (optional)

After running the script for all samples, each sample will have its own
folder with the basename <input-filename> (Main output directory). If
you prefer to organize your files by category, you can execute the
provided script **organize_files_miRNA.sh** in the terminal.

## Folder Structure:
    ├── FASTQ_Raw
    │   ├── *fastq.gz
    ├── Mapping files
    │   ├── *_expression_analyses
    │   ├── *.mapped.arf
    │   ├── *.processed.fa
    ├── Metrics
    │   ├── QC_FASTQC
    │   │   ├── *fastqc.html
    │   │   ├── *fastqc.zip
    │   ├── QC_fastq_Screen
    │   │   ├── *screen.html
    │   │   ├── *screen.txt
    │   ├── QC_FASTQ_AdapterRemoval
    │   │   ├── *settings
    │   │   ├── *truncated.gz
    │   │   ├── *discarded.gz
    │   ├── QC_mirtrace
    │   │   ├── SAMPLE_ID
    │   │   |   ├── mirtrace-report.html
    │   │   |   ├── mirtrace-results.json
    │   │   |   ├── mirtrace-stats-contamination_basic.tsv
    │   │   |   ├── mirtrace-stats-contamination_detailed.tsv
    │   │   |   ├── mirtrace-stats-length.tsv
    │   │   |   ├── mirtrace-stats-mirna-complexity.tsv
    │   │   |   ├── mirtrace-stats-phred.tsv
    │   │   |   ├── mirtrace-stats-qcstatus.tsv
    │   │   |   ├── mirtrace-stats-rnatype.tsv
    │   │   |   ├── qc_passed_reads.all.collapsed
    │   │   |   ├── qc_passed_reads.rnatype_unknown.collapsed
    ├── COUNTS
    │   ├── *_miRNAs_expressed.txt
    │   ├── *_miRNA_RawCounts.txt

## Creating a Matrix of RawCounts:

If you wish to create a Matrix of RawCounts for all samples, you can
follow these steps in the `COUNTS` folder:

1.  **Create Header:**

<!-- -->

    echo -e "miRNA\tprecursor" > header.txt
    for x in ./*RawCounts.txt; do basename $x _miRNA_RawCounts.txt; done | cut -c -4 >> header.txt
    cat header.txt | paste -s - > Matrix_Raw_counts.txt

2.  **Combine RawCounts:**

<!-- -->

    paste ./*RawCounts.txt | tail -n +2 | awk '{ for (i=4;i<=NF;i+=3) $i="" } { for (j=5;j<=NF;j+=3) $j="" } 1' | awk -v OFS="\t" '$1=$1'| tr -s '\t''\t' >> Matrix_Raw_counts.txt

This will create a Matrix_Raw_counts.txt file containing the combined
raw counts data from all samples in a tab separated fields **miRNA**, **precursor** and **read_count**.

# Create a Multiqc report:

If you wish to create a report of the collected metrics, run the
following in a ubuntu-terminal job with modules:

    # load multiQC
    module load MultiQC

    # Run multiqc in the directory with all the analysis folders:
    multiqc -e bowtie1 ./

**Notes:**
- Ensure that the necessary modules are available on your cluster.
- The script includes Slurm directives to specify resource requirements.
Review and customize the script based on your specific requirements.
- For additional information on individual tools and parameters, refer
to the documentation for miRDeep2.
