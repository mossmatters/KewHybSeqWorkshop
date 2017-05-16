# Selecting HybSeq Genes Using MarkerMiner


### Learning Objectives

* Use existing genomic/transcriptomic resources for probe design
* Run MarkerMiner from the command line
* Select single copy genes for HybSeq probe design using multiple orthologs per gene


## Introduction: HybSeq Probe Design

HybSeq is a method of targeted sequencing that focuses on capturing coding (exon) regions from high-throughput sequencing libraries. Because each fragment in a library may contain both exon and intron sequences, HybSeq offers the possibility of capturing a "splash zone" of intron regions. 

Targeted sequencing typically employs RNA probe sequences between 60 and 120 bp long. A reference sequence must be used for probe design, but probes can typically capture fragments with 10-15% sequence divergence. To maximize the chances that probes will capture target genes across a wider phylogenetic breadth, we recommend using multiple orthologs for each gene.

In this tutorial we will use Markerminer to explore the process of selecting low-copy nuclear genes for phylogenetic analysis.


## About MarkerMiner

Markerminer is a bioinformatics pipeline written by Srikar Chamala and colleagues to identify single copy genes by aligning transcriptome sequences to reference genomes. It is built for use with Angiosperms, but as we will see in this tutorial, it can be modified relatively easily for use with any reasonably well annotated genome.

Markerminer Website: https://bitbucket.org/srikarchamala/markerminer

Markerminer Publication: http://www.bioone.org/doi/full/10.3732/apps.1400115

**On the HybSeq_Kew_Workshop Atmosphere image, markerminer is located here**: `/usr/local/markerminer/`


## MarkerMiner Procedure

MarkerMiner identifies clusters of single-copy gene transcripts present in each user-provided transcriptome assembly by aligning and filtering transcripts against a user-selected reference proteome database using BLAST. Each transcript is searched against the reference proteome (BLASTX) and each peptide is searched against the transcripts (TBLASTN). MarkerMiner then generates a detailed tabular report of results for each putative orthogroup.

Next, MarkerMiner runs each of the single-copy gene clusters through a multiple sequence alignment (MSA) step using MAFFT and it outputs FASTA and Phylip files that users can use to assess phylogenetic utility (e.g. sequence variation) or, if appropriate, to conduct preliminary phylogenetic analyses.

Lastly, each of the single-copy gene MSAs are re-aligned with MAFFT (using the ‘--add’ functionality; Katoh and Frith 2012) profile alignment step using a user-selected coding reference sequence with intronic regions represented as Ns. Users can use MarkerMiner’s profile alignment output to identify putative splice junctions in the transcripts and to design primers or probes for targeted sequencing.

## Exploring MarkerMiner

Markerminer comes with prepared files for 15 angiosperm reference genomes. For each genome there are three important files:

1. **Protein sequences**: a FASTA file containing peptide sequences of all genes.
2. **Intron-masked gene region file**: a FASTA file with the same genes as above, but with introns identified and "hard-masked" using Ns.
3. **Single-copy gene list**: a text file containing the names of genes identified as either "strictly single copy" (orthogroup is single copy in all 17 angiosperm genomes) or "mostly single copy" (orthogroup duplicated in 1-3 species). [Reference: De Smet et al., 2013](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3581894/)

To view the genomic resources in Makerminer directory on Atmosphere:

```
(hybpiper) [username@127.0.0.1 markerminer_test]$ cd /usr/local/markerminer/Resources
(hybpiper) [username@127.0.0.1 Resources]$ ls
Alyrata    Bdistachyon  Fvesca  Mdomestica  Mtruncatula    Osativa       Rcommunis  Tcacao     Zmays
Athaliana  Cpapaya      Gmax    Mesculenta  organisms.tsv  Ptrichocarpa  Sbicolor   Vvinifera
(hybpiper) [username@127.0.0.1 Resources]$ ls Alyrata/
aly_CDS_IntronMasked.fa  proteome.aly.tfa_db.phr  proteome.aly.tfa_db.psq
proteome.aly.tfa         proteome.aly.tfa_db.pin  singleCopy_AL.txt
```

Use `less` to view the protein file `.tfa` and masked intron file `_CDS_Intron_Masked.fa` for one species. Note the strings of `NNNNN` in the Intron file. This "hard masking" will allow transcriptome sequences to easily align to the coding domain sequence (CDS) in the final stage of MarkerMiner. 

The identification of intron regions during probe design will help avoid wasting probes on sequences that would span splice junctions. Even though no probes will be designed for intorn regions, they will still be captured during HybSeq as part of the "splash zone," as we will see in the [HybPiper tutorial](HybPiper.md).

Let's see what percentage of `Arabidopsis lyrata` genes are marked as single copy. First, count the number of peptides in the proteome file:

`grep '>' Alyrata/proteome.aly.tfa | wc -l`

Next, count the number of lines in the single copy gene list:

`wc -l Alyrata/singleCopy_AL.txt`

Finally, what percentage of those genes are **strictly** single copy?

`grep "Strictly" Alyrata/singleCopy_AL.txt`

Compare the results of _A. lyrata_ to one of the other reference proteomes.




### Custom Genomes

Although it is beyond the scope of this tutorial, it is possible to add genomes to MarkerMiner. This will require creating the three files above, the most important of which is the Intron-masked gene region file. However, if a genome is reasonably well annotated with a Genome Feature Format (GFF) file, the procedure is relatively straightforward using bioinformatics tools such as [bedtools](http://bedtools.readthedocs.io/en/latest/). 

The MarkerMiner code also needs to be edited to reflect the new genome additions. A more thorough explanation of the process of adding a genome to MarkerMiner [can be found here](https://www.evernote.com/l/AX8KWvd6jGpK3qq1mhBErCgXfXhja9a1kTA).

## Running MarkerMiner on Cyverse

The test dataset for MarkerMiner is included with the software. To run the test dataset, first create a new directory, then copy the test data:

```
(hybpiper) [username@127.0.0.1 ~]$ mkdir ~/markerminer_test/
(hybpiper) [username@127.0.0.1 ~]$ cd markerminer_test/
(hybpiper) [username@127.0.0.1 markerminer_test]$ cp /usr/local/markerminer/Sample_Data/Sample_input/* .
(hybpiper) [username@127.0.0.1 markerminer_test]$ ls
DAT1-sample.fa  DAT2-sample.fasta  DAT3-sample.fasta  DAT4-sample.fasta
```
Each DAT file contains transcripts from a different species. The files are named beginning with a four-character code followed by a hyphen (e.g. `DAT3-`), and must end with `.fa` or `.fasta`. 

Next, view the options available when running MarkerMiner:

```
(hybpiper) [username@127.0.0.1 markerminer_test]$ /usr/local/markerminer/markerMiner.py -h
usage: markerMiner.py [-h] [-transcriptFilesDir TRANSCRIPTFILESDIR]
                      [-singleCopyReference {Athaliana,Ptrichocarpa,Fvesca,Tcacao,Gmax,Cpapaya,Sbicolor,Mesculenta,Mdomestica,Rcommunis,Mtruncatula,Osativa,Alyrata,Bdistachyon,Vvinifera,Zmays}]
                      [-minTranscriptLen MINTRANSCRIPTLEN]
                      [-minProteinCoverage MINPROTEINCOVERAGE]
                      [-minTranscriptCoverage MINTRANSCRIPTCOVERAGE]
                      [-minSimilarity MINSIMILARITY] [-cpus CPUS]
                      -outputDirPath OUTPUTDIRPATH [-email EMAIL]
                      [-sampleData] [-debug] [-overwrite]

MarkerMiner: Effectively discover single copy nuclear loci in flowering
plants, from user-provided angiosperm transcriptomes. Your are using
MarkerMiner version 1.2

optional arguments:
  -h, --help            show this help message and exit
  -transcriptFilesDir TRANSCRIPTFILESDIR
                        Absolute or complete path of the transcript files
                        fasta directory. Only files ending with '.fa' or
                        '.fasta' will be accepted. Also, all file names must
                        use the following naming convention: file names must
                        start with a four-letter species code followed by a
                        hyphen (e.g. 'DAT1-', 'DAT2-', 'DAT3-', etc. (default:
                        None)
  -singleCopyReference {Athaliana,Ptrichocarpa,Fvesca,Tcacao,Gmax,Cpapaya,Sbicolor,Mesculenta,Mdomestica,Rcommunis,Mtruncatula,Osativa,Alyrata,Bdistachyon,Vvinifera,Zmays}
                        Choose from the available single copy reference
                        datasets (default: Athaliana)
  -minTranscriptLen MINTRANSCRIPTLEN
                        min transcript length (default: 900)
  -minProteinCoverage MINPROTEINCOVERAGE
                        min percent of protein length aligned (default: 80)
  -minTranscriptCoverage MINTRANSCRIPTCOVERAGE
                        min percent of transcript length aligned (default: 70)
  -minSimilarity MINSIMILARITY
                        min similarity percent with which seqeunces are
                        aligned (default: 70)
  -cpus CPUS            cpus to be used (default: 4)
  -outputDirPath OUTPUTDIRPATH
                        Absolute or complete path of output directory
                        (default: .)
  -email EMAIL          Specify email address to be notified on job completion
                        (default: None)
  -sampleData           run pipeline on sample datasets (default: False)
  -debug                turn on debug mode (default: False)
  -overwrite            overwrite results if output folder exists (default:
                        False)
                        
```                       

The minimum requirement to run MarkerMiner is to specify `-transcriptFilesDir`, `-singleCopyReference`, and `-outputDirPath`. Four other parameters control how the results of BLAST searches will be filtered.

Examine the default parameter settings for `-minTranscriptLen`, `-minProteinCoverage`, `-minTranscriptCoverage`, and `-minSimilarity`. 

Why do you think each of these parameters were chosen, and what would happen if they were altered from their default settings (lower or higher)?

Run MarkerMiner with the default parameters. Note that the path to the input and output files must be an *absolute path*, not a *relative path*:

```
(hybpiper) [username@127.0.0.1 ~]$ /usr/local/markerminer/markerMiner.py \
-transcriptFilesDir ~/markerminer_test \
-singleCopyReference Athaliana \
-outputDirPath ~/markerminer_test_Athaliana
```
This should finish in approximately 2 minutes. You may see some errors from `tblastn`, but these are normal and have to do with ambiguity codes in the Athaliana protein translation. 

### Examining Markerminer Output

Uncompress the results:

```
(hybpiper) [username@127.0.0.1 ~]$ tar -zxf markerminer_test_Athaliana.tar.gz
(hybpiper) [username@127.0.0.1 ~]$ cd markerminer_test_Athaliana
(hybpiper) [username@127.0.0.1 markerminer_test_Athaliana]$ ls
BLAST                      MAFFT_NUC_ALIGN_FASTA        single_copy_genes.secondaryTranscripts.txt
input_transcriptomes.txt   MAFFT_NUC_ALIGN_PHY          single_copy_genes.txt
LENGTH_FILTERED_FASTA      markerminer_run_logfile.txt
MAFFT_ADD_REF_ALIGN_FASTA  NUC_FASTA
```

A brief tour of the directories and summary files created by MarkerMiner

* **BLAST**: Contains results of reciprocal BLAST searches (transcriptome --> genome and genome --> transcriptome)
* **input_transcriptomes.txt** A list of all the transcriptomes used in the MarkerMiner run. Useful for checking if the transcriptome files were labeled properly.
* **LENGTH_FILTERED_FASTA** Transcriptome files subset for genes that had the minimum length (specified by `-minTranscriptLen`, the default is 900bp).
* **MAFFT_ADD_REF_ALIGN_FASTA** The final output of MarkerMiner for probe design-- alignments between transcriptome sequences and the intron-masked gene region genome reference for each gene.
* **MAFFT_NUC_ALIGN_FASTA** Alignments among transcriptome sequences that each had BLAST hits to the same gene in the reference genome.
* **MAFFT_NUC_ALIGN_PHY** Same as above but in Phylip format.
* **markerminer_run_logfile.txt** A log of the Markerminer process.
* **NUC_FASTA** Unaligned transcripts from each transcriptome separated by homologous reference genome gene.
* **single_copy_genes.txt** A table listing each reference genome gene (rows) and homologous transcript IDs from each transcriptome (column). 
* **single_copy_genes.SecondaryTranscripts.txt** A list of alternative transcripts that had a BLAST hit to the same reference genome gene but were not chosen for the final alignment. These are typically splice forms, but could also be very recent paralogs.

In the VNC Viewer, open Alivew (Applications/Other). In the File menu of Aliview, navigate to the MarkerMiner output directory and open one of the alignments in `MAFFT_ADD_REF_ALIGN_FASTA`.

<img src=images/markerminer_aliview.png width="500">

#### Questions

* How many transcripts are aligned to the reference gene?
* Are the transcript sequences properly aligned to the reference gene?
* Do the intron/exon boundaries appear to be consistent?
* What is the affect of using different parameter settings?
* How would the results change if Alyrata was used instead of Athaliana?
