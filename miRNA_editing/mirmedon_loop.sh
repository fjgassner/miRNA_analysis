#!/bin/sh
sampleid=("0000" "4923" "5318" "5786" "5815_2" "6049" "6161_1" "6165" "6190" "6214" "6232" 
"6241_1" "6276" "6286" "6355_1" "6419" "6488" "6534" "6667" "6704" "6735-6" "6816_1" "6894" "8175"
"8213" "8409_1" "8541_1" "8714" "9098" "SRX3584005" "SRX3584009" "SRX3584014" "SRX3584018" "SRX3584022"
"SRX3584026" "SRX3584030" "SRX3584034" "SRX3584038" "SRX3584042" "SRX3584045" "SRX3584049" "SRX3584053"
"SRX3584057" "SRX3584061" "SRX3584065" "SRX3584069" "SRX3584074" "SRX3584078" "SRX3584082" "SRX3584086"
"SRX3584090" "SRX3584094")

for i in {0..51}
do
	cd ~/Documents/miRmedon/
	mkdir ${sampleid[i]}
	cp "fastqfiles/${sampleid[i]}"* ${sampleid[i]}/
	if [ $? -ne 0 ]; then
		continue
	fi
	cd ${sampleid[i]}
	unpigz *.gz
	fastqc *.fastq
	cd ~/Documents/programs/Trimmomatic-0.33
	java -jar trimmomatic-0.33.jar SE -phred33 \
	~/Documents/miRmedon/${sampleid[i]}"/"*.fastq ~/Documents/miRmedon/${sampleid[i]}/${sampleid[i]}.trimmed.fastq \
	ILLUMINACLIP:adapters/miRNA-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:17
	cd ~/Documents/miRmedon/${sampleid[i]}/
	fastqc *.trimmed.fastq
	head -4000000 *.trimmed.fastq > ${sampleid[i]}.trimmed.1mio.fastq
	python3 ~/Documents/programs/miRmedon/miRmedon.py \
	-f ~/Documents/miRmedon/${sampleid[i]}"/"*.trimmed.1mio.fastq -star ~/miniconda3/bin/STAR \
	-t 4 -samtools /usr/local/bin/samtools -mafft /usr/local/bin/mafft \
	-bowtie ~/Documents/programs/bowtie-1.2.2-macos-x86_64/bowtie \
	-G ~/Documents/reference/miRmedon/GRCh38.p12.genome \
	-T ~/Documents/reference/miRmedon/gencode.v31.transcripts
	
	#remove fastq files
	rm *.fastq
	
	#add ID to output files
	mv counts.txt ${sampleid[i]}.counts.txt
	mv editing_info.txt ${sampleid[i]}.editing_info.txt
	mv crt_counts.txt ${sampleid[i]}.crt_counts.txt
	
	#prepare for IGV
	samtools sort _Aligned.out.filt.final.bam -o ${sampleid[i]}.filt.final.sorted.bam
	samtools view -h *.sorted.bam | sed s/_[a-z]*[0-9]*//g > ${sampleid[i]}.filt.final.sorted.modified.sam
	samtools view -H *.sam > header
	uniq header > header.uniq
	samtools view *.sam > wo.header.sam
	cat header.uniq wo.header.sam > ${sampleid[i]}.filt.final.sorted.modified.uniqheader.sam
	samtools view -b ${sampleid[i]}.filt.final.sorted.modified.uniqheader.sam -o ${sampleid[i]}.filt.final.sorted.modified.uniqheader.bam
	samtools sort ${sampleid[i]}.filt.final.sorted.modified.uniqheader.bam -o ${sampleid[i]}.filt.final.sorted.modified.uniqheader.sorted.bam
	samtools index ${sampleid[i]}.filt.final.sorted.modified.uniqheader.sorted.bam
done