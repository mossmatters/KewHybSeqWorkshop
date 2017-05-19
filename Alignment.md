# Preparing Files for Phylogenetics

## Learning Objectives

1. Identify common problems with phylogenetic analysis from HybSeq data
2. Apply the syntax for GNU Parallel, a tool for processing many files at once.
3. Generate in-frame nucleotide sequence alignments from the command line.
1. Analyze alignments using automated methods for alignment trimming and outlier sequence identification.

We realize a very broad array of phylogenetic tools and philosophies exists. 
In the interest of keeping things relatively straightforward, this section will focus on issues relating to the generation of phylogenetic trees from HybSeq data. 

## Example Data

This data contains sequences for 169 species of Onagraceae, with a focus on tribe Onagrae (evening primroses). The majority of sequences derive from HybSeq, but some sequences (identifiable by their 1KP taxon code) are from transcriptomes.

The full dataset contains 309 loci, but this subset contains 13 genes, including several loci with poorly recovered gene sequences.

The dataset includes unaligned, aligned, and trimmed data, so that each step of this tutorial may be made without worrying whether the previous steps have completed successfully.

```
wget http://de.cyverse.org/dl/d/EB365F90-B516-4EAF-B2A7-5605A135EA04/phylogenomics_examples.tar.gz
tar -zxf phylogenomics_examples.tar.gz
```



## GNU Parallel

![](https://www.gnu.org/software/parallel/logo-gray+black300.png)

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

`parallel "program -program_options {} > {}.out" :::: file_names.txt`

NOTE: You will probably see this warning:

```
Academic tradition requires you to cite works you base your article on.
When using programs that use GNU Parallel to process data for publication
please cite:

  O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
  ;login: The USENIX Magazine, February 2011:42-47.

This helps funding further development; AND IT WON'T COST YOU A CENT.
If you pay 10000 EUR you should feel free to use GNU Parallel without citing.

To silence the citation notice: run 'parallel --citation'.
```

As the workshop will likely not be able to cover the 10000 EUR for each attendee, it is better to just agree to citation.

```
(hybpiper) [username@127.0.0.1 FAA]$ parallel --citation
Academic tradition requires you to cite works you base your article on.
When using programs that use GNU Parallel to process data for publication
please cite:

@article{Tange2011a,
  title = {GNU Parallel - The Command-Line Power Tool},
  author = {O. Tange},
  address = {Frederiksberg, Denmark},
  journal = {;login: The USENIX Magazine},
  month = {Feb},
  number = {1},
  volume = {36},
  url = {http://www.gnu.org/s/parallel},
  year = {2011},
  pages = {42-47},
  doi = {10.5281/zenodo.16303}
}

(Feel free to use \nocite{Tange2011a})

This helps funding further development; AND IT WON'T COST YOU A CENT.
If you pay 10000 EUR you should feel free to use GNU Parallel without citing.

If you send a copy of your published article to tange@gnu.org, it will be
mentioned in the release notes of next version of GNU Parallel.



Type: 'will cite' and press enter.
> will cite

Thank you for your support. It is much appreciated. The citation
notice is now silenced.

```

As you become more familiar with GNU Parallel, you may also consider supporting the project by [purchasing a t-shirt](https://gnuparallel.threadless.com/designs/gnu-parallel).

### Exercise

For phylogenomics, it is useful to create two files: one that contains the names of samples (one per line) and one that contains the names of genes (one per line). 

Create a new directory that is separate from the one you downloaded, and copy the gene list into that new directory.


 ```
 cd
 mkdir phylogenomics_test
 cd phylogenomics_test
 cp ~/phylogenomics_examples/genelist_phylogenomics/genenames.txt genenames.txt
 ```

To practice constructing and using GNU Parallel commands, **use GNU parallel to copy the unaligned nucleotide and peptide files** into a new subdirectories within `~/phylogenomics_examples`:

```
mkdir FAA
mkdir FNA
parallel cp ../phylogenomics_examples/FAA/{}.FAA FAA/{}.FAA :::: genenames.txt
parallel cp ../phylogenomics_examples/FNA/{}.FNA FNA/{}.FNA :::: genenames.txt

```


## Peptide Sequence Alignment

### Preprocessing

MAFFT will replace all stop-codon asterisks (*) in the peptide alignment with gap characters. This will cause some of the downstream methods (`pal2nal.pl`) to fail, because the peptide and nucleotide alignments will no longer have a 3-to-1 ratio. To replace the asterisks we will use the Linux tool `sed`:

`sed -i 's/*/X/g' sequences.fasta`

Sed uses the `'s/find/replace/g'` syntax, so here we are replacing all asterisks with X. The `-i` flag indicates that the files are to be edited *in place* rather than output to a new file. To run this on all files, use GNU Parallel:

```
cd FAA
parallel sed -i 's/*/X/g' {}.FAA :::: ../genenames.txt
cd ..
```

#### MAFFT

MAFFT (http://mafft.cbrc.jp/alignment/software/) has become one of the most widely used methods for multiple sequence alignments, known for both speed and accuracy. Several recent additions have also made it desirable for adding sequences to existing alignments and for aligning very large (e.g. 100,000 sequences x 5,000 sites, or 20 sequences x 1,000,000 sites) datasets.

Some basic options for running MAFFT can be seen by executing: `mafft --help`:

```
(hybpiper) username@127.0.0.1$ mafft -h

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

`mkdir aligned`
`parallel --eta "mafft --localpair --maxiterate 1000 FAA/{}.FAA > aligned/{}.aligned.FAA" :::: genenames.txt`

The `--eta` option is for GNU Parallel and will estimate how much longer the loop will take to execute.

## In-Frame Nucleotide Alignment

pal2Nal.pl (http://www.bork.embl.de/pal2nal/) is a Perl script that takes a protein alignment and a set of corresponding nucleotide files and returns an in-frame nucleotide alignment. It is very fast, but also very unforgiving of mismatches between the nucleotide and amino acid alignments. 

`mkdir inframe`

`parallel "pal2nal.pl -output fasta aligned/{}.aligned.FAA FNA/{}.FNA > inframe/{}.inframe.FNA" :::: genenames.txt`

#### Questions

Using the VCN Viewer, open the nucleotide and peptide alignments.

* How do the alignments look? Are there highly ambiguous regions?
* Are there short sequences that appear to be misaligned to the rest?
* Can you find regions of the genes represented in only a few samples? 


## Trimming Alignments

`mkdir trimmed`

`parallel "trimal -gt 0.5 -in inframe/{}.inframe.FNA -out trimmed/{}.trimmed.FNA" :::: genenames.txt `

Although TrimAl has a method for creating in-frame alignments `--backtrans`, we prefer to use Pal2Nal because it will always result in trimmed alignments that preserve the 3-to-1 ratio of sites.


## Identifying Poorly Aligned Sequences

Phylogenetic inference relies on accurate sequence alignment. A few misaligned sequences in a few genes may influence the entire analysis, but manual verification of alignments of hundreds of genes is impractical. Some misaligned sequences can be identified by looking for long branches on gene trees. In this section we will use ETE3 to identify long branches automatically. The scripts included in this section will generate gene tree images that can be quickly scanned for outliers.

#### FastTree

FastTree (http://www.microbesonline.org/fasttree/) is a tree inference program that uses approximate pseudo-likelihood to calculate the phylogeny. Standard substition models, including GTR for nucleotides, are included. FastTree can handle hundreds of taxa for thousands of sites (even entire bacterial genomes).

To see the full options for FastTree:

`FastTree -h`

The alignments you have been working with so far have already been cleaned up, so we will compare them to sequences that have not yet been cleaned:

`mkdir fasttree_badseqs`
`parallel parallel "FastTree -gtr ~/phylogenomics_examples/bad_alignments/{}.badalignment.fasta > fasttree/{}.fasttree.tre" :::: genenames.txt`

To run FastTree in parallel on the cleaned nucleotide sequences:

`mkdir fasttree`
`parallel "FastTree -gtr trimmed/{}.trimmed.FNA > fasttree/{}.fasttree.tre" :::: genenames.txt`

#### Long branch detection with ETE3

The ETE3 Python Package (https://etetoolkit.org) is a highly customizable phylogenetics framework for processing, manipulating, and visualizing trees. Here we will be using functions in ETE3 for:

* Re-rooting a phylogenetic tree
* Identifying outlier branch lengths
* Saving tree images with outlier branches highlighted

There are several options in the script:

`python ~/phylogenomics_examples/brlen_outliers.py -h`

By default, the script will flag ingroup branches that are more than 25% of the total tree depth. This threshold is higher (50%) for outgroup branches (which are expected to be longer). A separate threshold may also be set for terminal branches.   

**NOTE** This script can only be run on a computer with a graphical interface. **You can run this script from the Terminal in the VCN Viewer.**

To run the script on all of the tree files:

`cd ~/phylogenomics_test/`

`mkdir png_bad`

`parallel --tag python ~/phylogenomics_examples/brlen_outliers.py fasttree_badseqs/{}.fasttree.tre --png png_bad/{}.fasttree.png --outgroups ~/phylogenomics_examples/outgroups.txt :::: genenames.txt`

This will generate a PNG file for each gene. The script will also print to the screen the identity of all clades with potential long branches. The `--tag` option of GNU parallel prints the name of the gene that the branches came from.


Repeat this now for	 the cleaned alignments:

`mkdir png_good`

`parallel --tag python ~/phylogenomics_examples/brlen_outliers.py fasttree/{}.fasttree.tre --png png_good/{}.fasttree.png --outgroups ~/phylogenomics_examples/outgroups.txt :::: genenames.txt`


To view a PNG file via VNC Viewer, use the command `eog` from the Terminal:

`eog png_good/geneName.fasttree.png`

Outgroup branches are colored blue, and outlier branches are in red.

For more information about the script, see: http://blog.mossmatters.net/detecting-branch-length-outliers/

