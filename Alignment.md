# Preparing Files for Phylogenetics

## Learning Objectives

1. Identify common problems with phylogenetic analysis from HybSeq data
2. Apply the syntax for GNU Parallel, a tool for processing many files at once.
3. Generate in-frame nucleotide sequence alignments from the command line.
1. Analyze alignments using automated methods for alignment trimming and outlier sequence identification.

We realize a very broad array of phylogenetic tools and philosophies exists. 
In the interest of keeping things relatively straightforward, this section will focus on issues relating to the generation of phylogenetic trees from HybSeq data. 

## GNU Parallel

Each of the operations in this section, including file management, sequence alignment, and building initial gene trees, will have to be executed on multiple genes. In the test dataset there are only 13 genes, but a full HybSeq project likely has many hundreds of genes. How can we process each gene without entering commands manually?

One method is to use a loop to execute commands many times, as we did in the HybPiper tutorial. However, a loop will only execute commands *sequentially*. Many of the tasks in this section will use only one processor, but modern computers typically have several (a MacBook Pro has 8, for example). To use the machine efficiently, we need to execute commands in *parallel*. 

GNU parallel (https://www.gnu.org/software/parallel/) is a shell tool for executing jobs in parallel. A job can be a single command or a small script that has to be run for each of the lines in an input. GNU parallel makes sure output from the commands is the same output as you would get had you run the commands sequentially. You have already used GNU Parallel by running HybPiper. Within HybPiper, GNU Parallel handles the processing of gene assembly and exon extraction for many genes, while utilizing all of the processors on the computer.

The typical syntax of a GNU Parallel command is:

`parallel "program -program_options {} > {}.out" ::: file1 file2 file3`

In quotes is a command that you would normally run sequentially. Instead of naming the input files, the curly brackets `{}` indicate a place where parallel will substitute items. These items are indicated at the end following the triple-colon `:::`. The quotes allow the output of each iteration of the script to be output (piped) to a different file. Without the quotes, the output would all be piped to one file. 

The above command will execute three times in parallel:

`program -program_options file1 > file1.out`
`program -program_options file2 > file2.out`
`program -program_options file3 > file3.out`

As the number of iterations gets large, it is sometimes better to indicate the items in a file. This can be done by using four-colons instead:

``parallel "program -program_options {} > {}.out" :::: file_names.txt`

### Exercise

For phylogenomics, it is useful to create two files: one that contains the names of samples (one per line) and one that contains the names of genes (one per line). **Create a file containing the names of genes in the test dataset using a text editor:** `genenames.txt`

To practice constructing and using GNU Parallel commands, **try to rename all of the nucleotide files** created by `retrieve_sequences.py` to have a `.fasta` extension rather than a `.FNA` extension.


## Peptide Sequence Alignment

### Preprocessing

MAFFT will replace all stop-codon asterisks (*) in the peptide alignment with gap characters. This will cause some of the downstream methods (`pal2nal.pl`) to fail, because the peptide and nucleotide alignments will no longer have a 3-to-1 ratio. To replace the asterisks we will use the Linux tool `sed`:

`sed -i 's/*/X/g' sequences.fasta`

Sed uses the `'s/find/replace/g'` syntax, so here we are replacing all asterisks with X. The `-i` flag indicates that the files are to be edited *in place* rather than output to a new file. To run this on all files, use GNU Parallel:

`parallel sed -i 's/*/X/g' {}.FAA :::: genenames.txt`

#### MAFFT

MAFFT (http://mafft.cbrc.jp/alignment/software/) has become one of the most widely used methods for multiple sequence alignments, known for both speed and accuracy. Several recent additions have also made it desirable for adding sequences to existing alignments and for aligning very large (e.g. 100,000 sequences x 5,000 sites, or 20 sequences x 1,000,000 sites) datasets.

Some basic options for running MAFFT can be seen by executing: `mafft -h`:

```
(hybpiper) username@127.0.0.1$ mafft -h

/usr/local/bin/mafft: Cannot open -h.

------------------------------------------------------------------------------
  MAFFT v7.221 (2014/04/16)
  http://mafft.cbrc.jp/alignment/software/
  MBE 30:772-780 (2013), NAR 30:3059-3066 (2002)
------------------------------------------------------------------------------
High speed:
  % mafft in > out
  % mafft --retree 1 in > out (fast)

High accuracy (for <~200 sequences x <~2,000 aa/nt):
  % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok)
  % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out)
  % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out)

If unsure which option to use:
  % mafft --auto in > out

--op # :         Gap opening penalty, default: 1.53
--ep # :         Offset (works like gap extension penalty), default: 0.0
--maxiterate # : Maximum number of iterative refinement, default: 0
--clustalout :   Output: clustal format, default: fasta
--reorder :      Outorder: aligned, default: input order
--quiet :        Do not report progress
--thread # :     Number of threads (if unsure, --thread -1)
```

Additional flags for MAFFT can be found on their website: http://mafft.cbrc.jp/alignment/software/tips0.html.



In our experience, the default settings for MAFFT will inappropriately align short sequences. This can usually be resolved by using the `--localpair` flag to conduct more careful initial alignments, and increasing the `--maxiterate` to allow for more fine-tuning.

`parallel "mafft --localpair --maxiterate 1000 --preservecase {}.FAA > {}.aligned.FAA" :::: genenames.txt`

## In-Frame Nucleotide Alignment

pal2Nal.pl (http://www.bork.embl.de/pal2nal/) is a Perl script that takes a protein alignment and a set of corresponding nucleotide files and returns an in-frame nucleotide alignment. It is very fast, but also very unforgiving of mismatches between the nucleotide and amino acid alignments. 

`parallel "pal2nal.pl -output fasta {}.aligned.FAA {}.FNA > {}.inframe.FNA" :::: genenames.txt`

#### Questions

Using the VCN Viewer, open the nucleotide and peptide alignments.

* How do the alignments look? Are there highly ambiguous regions?
* Are there short sequences that appear to be misaligned to the rest?
* Can you find regions of the genes represented in only a few samples? 


## Trimming Alignments

`parallel "trimal -gt 0.5 -in {}.inframe.FNA -out {}.trimmed.FNA" :::: genenames.txt `

Although TrimAl has a method for creating in-frame alignments `--backtrans`, we prefer to use Pal2Nal because it will always result in trimmed alignments that preserve the 3-to-1 ratio of sites.


## Identifying Poorly Aligned Sequences

#### FastTree

#### Long branch detection with ETE3

