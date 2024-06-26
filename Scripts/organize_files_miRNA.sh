#!/bin/bash


# ===============================================
# Create Directories
# ================================================

FASTQ_Raw=FASTQ_Raw && mkdir -p "${FASTQ_Raw}"
Mapping_files=Mapping_files && mkdir -p "${Mapping_files}"
Metrics=Metrics && mkdir -p "${Metrics}"
COUNTS=COUNTS && mkdir -p "${COUNTS}"

mv ./*fastq.gz "${FASTQ_Raw}"	# Move Raw fastq files

mv *_S*/*expressed*	"${COUNTS}"
mv *_S*/*RawCounts* "${COUNTS}"	# 3 col table #miRNA/precursor/read_count from expressed file

mv *_S*/*.arf "${Mapping_files}"
mv *_S*/*.fa "${Mapping_files}"
mv *_S*/*_expression_analyses "${Mapping_files}"

mv *_S*/QC_AdapterRemoval/* "${Metrics}"
mv *_S*/QC_FASTQC/* "${Metrics}"
mv *_S*/QC_fastq_Screen/* "${Metrics}"
mv *_S*/QC_mirtrace/* "${Metrics}"

rm -r *_S*/QC_AdapterRemoval
rm -r *_S*/QC_FASTQC
rm -r *_S*/QC_fastq_Screen
rm -r *_S*/QC_mirtrace

cd ${Mapping_files}
LOGS=LOGS && mkdir -p "${LOGS}"
mv ../*_S* "${LOGS}"
cd ..

chmod 770 ./*
chmod 770 ./*/*
chmod 770 ./*/*/*

cd ${Metrics}

QC_AdapterRemoval=QC_AdapterRemoval && mkdir -p "${QC_AdapterRemoval}"
QC_FASTQC=QC_FASTQC && mkdir -p "${QC_FASTQC}"
QC_fastq_Screen=QC_fastq_Screen && mkdir -p "${QC_fastq_Screen}"
QC_mirtrace=QC_mirtrace && mkdir -p "${QC_mirtrace}"

mv *.discarded.gz "${QC_AdapterRemoval}" # discarded FASTQ reads by AdapterRemoval
mv *.truncated.gz "${QC_AdapterRemoval}" # trimmed FASTQ reads #  # .singleton. containing reads where one mate was discarded by AdapterRemoval
mv *.settings "${QC_AdapterRemoval}" # settings and summary statistics by AdapterRemoval
mv *fastqc* "${QC_FASTQC}" # QC file "fastqc" on fastq file before alignment
mv *screen* "${QC_fastq_Screen}" # QC file "fastq_screen" on fastq file before alignment
mv *_S* "${QC_mirtrace}" # QC files "miRtrace" on fastq file before alignment

chmod 770 ./*
chmod 770 ./*/*
chmod 770 ./*/*/*

echo "Done!"
