# Written by Elliot Gardner, Northwestern University

#wrapper for read calling variants with GATK

#usage: alignandcall.sh -f [read1] -r [read2] -e [reference] -s [samplename] -g [rungroup] -p ploidy -t [threads]

####IMPORTANT: EDIT THIS WITH THE LOCATION OF GATK AND PICARD:

gatkpath=/home/zerega/data/Elliot/bin/gatk/GenomeAnalysisTK.jar
picardpath=/home/zerega/data/Elliot/bin/picard-tools-2.4.1/picard.jar

while getopts ":f:r:e:s:g:p:t:" opt; do
  case $opt in
    f) f="$OPTARG"
    ;;
    r) r="$OPTARG"
    ;;
    e) e="$OPTARG"
    ;;
    s) s="$OPTARG"
    ;;
    g) g="$OPTARG"
    ;;
    p) p="$OPTARG"
    ;;
    t) t="$OPTARG"
    ;;
      esac
done

#align
bwa mem -t $t -M -R "@RG\tID:group$g\tSM:$s\tPL:illumina" $e $f $r | samtools view -b - | samtools sort - -o "$s"_sorted.bam

#mark duplicates
java -jar $picardpath MarkDuplicates \
   INPUT="$s"_sorted.bam \
   OUTPUT="$s"_dedup.bam \
   METRICS_FILE=metrics.txt \
   CREATE_INDEX=true \

#realign around indels
#step 1
java -jar $gatkpath \
    -T RealignerTargetCreator \
    -R $e \
    -I "$s"_dedup.bam \
    -o "$s"_realignertargetcreator.intervals \

##step2
java -Xmx8G -Djava.io.tmpdir=/tmp -jar $gatkpath \
    -T IndelRealigner \
    -R $e \
    -targetIntervals "$s"_realignertargetcreator.intervals \
    -I "$s"_dedup.bam \
    -o "$s"_realigned.bam \

#remove intermediate bam files
rm "$s"_sorted.bam
rm "$s"_dedup.bam

###call variants
java -jar $gatkpath \
-T HaplotypeCaller \
-R $e \
-I "$s"_realigned.bam \
--emitRefConfidence GVCF \
-variant_index_type LINEAR -variant_index_parameter 128000 \
-ploidy $p \
-nct $t \
-o "$s".g.vcf
