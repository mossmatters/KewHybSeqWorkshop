# Introduction to Phylogenomic Analysis

## Preparing Gene Trees

In the workshop data folder, the Phylogenomics directory contains the result of a FastTree inference of 100 gene trees for . 

Download the dataset from here:

```
cd 
wget http://de.cyverse.org/dl/d/823BCECB-77F8-4311-A869-3BFDDFF50A90/species_tree_analysis.tar.gz
tar -zxf species_tree_analysis

```

### Gene tree file

Combine all of the gene tree files in the `fasttree` directory into one gene tree file:
`cd species_tree_analysis`

`cat fasttree/*.tre > genetrees.tre` 

## Summary Coalescent Methods

### ASTRAL-II

Download Astral by cloning its Github repository and building the software:

```
cd
git clone https://github.com/smirarab/ASTRAL.git
cd ASTRAL
bash make.sh
```


**The file you need to execute ASTRAL is now here: `~/ASTRAL/Astral/astral.4.10.12.jar`**

You can view the options for ASTRAL with: `java -jar ~/ASTRAL/Astral/astral.4.10.12.jar -h`

Run ASTRAL using the gene trees.

`cd ~/species_tree_analysis`

`java -jar ~/ASTRAL/Astral/astral.4.10.12.jar -i genetrees.tre -o astral.lpp.tre`


Open and view the ASTRAL trees using FigTree from the VCN Viewer. The support values are the Local Posterior Probability. 



### STRAW

The Species TRee Analysis Web Server (http://bioinformatics.publichealth.uga.edu/SpeciesTreeAnalysis/) is an online tool for running three summary coalescent methods: STAR, MP-EST, and NJst. 

Two of the STRAW methods (STAR and MP-EST) require rooted gene trees. We will root the gene trees using a script that automatically identifies the common ancestor of outgroup taxa.

First, make a directory for the rooted gene trees:

`mkdir rerooted`

`parallel "python reroot_trees.py fasttree/{}.fasttree.tre > rerooted/{}.rerooted.tre" :::: genelist.txt`

One or more of the gene trees may return an error such as `Cannot set myself as outgroup`. This is because the gene tree does not contain any outgroups, and can be ignored for now. Combine all of the re-rooted trees into one file:


`cat rerooted/* > rerooted_genetrees.tre`


Save the combined gene tree file onto your computer and open the STRAW website in your internet browser. Select one of the three analyses and enter the information requested to start the job. You will receive an e-mail when the job is finished, after which you can access the output files, including the species trees.


### Questions

Are there major topological differences between ASTRAL and the STRAW methods?

How do the support values differ?



## Assessing Support With Phyparts

As phylogenomic methods become more widely adopted across many groups of organisms, a trend is emerging: support values in phylogenomic analysis may be misleading. Bootstrap support will not show the level of discordance present in the gene trees. Consider the following cases for a node receiving maximal ASTRAL support:

* The clade is also supported by gene trees from 235 of 333 loci.
* The clade is supported by 50 loci, and an additional 45 loci have an alternative arrangement.
* The clade is supported by just 10 loci, but the other loci do not have a common alternative pattern.

How would your interpretation of this clade change based on this information?

One method for assessing the level of discordance among loci is bipartition analysis. Stephen Smith and colleagues wrote a java package to conduct this analysis called phyparts (). Typically, bipartition analysis is conducted with trees that all share the same taxa (i.e. bootstrap or posterior trees). Phyparts is able to conduct bipartition analysis with a non-overlapping set of taxa across gene trees. 

**Phyparts is located at: `/usr/local/phyparts/target/phyparts-0.0.1-SNAPSHOT-jar-with-dependencies.jar`**

Phyparts requires rooted gene trees and a rooted species tree. We will use the rooted gene trees from the STRAW section above. Re-root the ASTRAL species tree with the same python script:

`cd ~/species_tree_analysis/`

`python reroot_trees.py astral.lpp.tre > astral.lpp.rerooted.tre`

Run Phyparts, using the directory of rerooted gene trees:

```
java -jar \
/usr/local/phyparts/target/phyparts-0.0.1-SNAPSHOT-jar-with-dependencies.jar \
-d rerooted \
-m astral.lpp.rerooted.tre \
-a 1 \
-v \
-o phyparts33 \
```

This will take a minute, and output a lot of files to the current directory. For each node on the phylogeny:

* `phyparts33.concord.node.XX`
* `phyparts33.conflict.node.XX`

These are text files containing the names of genes that are either concordant or in conflict with the species tree.

* `phyparts33.concon.tre`

A tree file containing the species tree with four different branch labels:

- The number of concordant genes
- The number of conflicting genes
- Internode Conflict Analysis score
- Internode Conflict Analysis score (adjusted)

* `phyparts33.hist`
A file listing each node on the phylogeny and the number of gene trees that have concordant and conflicting bipartitions.

* `phyparts33.hist.alts`

A list of every alternative bipartition found for every node.

* `phyparts33.node.key`

A file that translates nodes on the species tree into a node number used internally by Phyparts.

#### Phyparts PieCharts

The `phyparts33.concon.tre` output by Phyparts does not tell the whole story of the conflict among the gene trees. In their paper describing Phyparts, Smith et al. use pie charts on the phylogeny to summarize conflict:

<img src="https://static-content.springer.com/image/art%3A10.1186%2Fs12862-015-0423-0/MediaObjects/12862_2015_423_Fig2_HTML.gif" alt="smith_pies">

Each pie chart has four colors:

* Blue: Concordant gene trees
* Green: Most common conflicting bipartition
* Red: Other conflicting bipartitions
* Gray: Gene trees with no information (missing or unresolved)

For each node it is easy to tell at a glance whether there is a lot of intergenic conflict, and whether there is one dominant minority bipartition.

The script `phypartspiecharts.py` will use Phyparts output to plot the piecharts on a given species tree, and save it as a `.svg` image. **The script must be run from the Terminal inside the VNC Viewer**

The three required arguments for the script are:

* The name of the species tree
* The prefix of the phyparts output files
* The number of genes in the phyparts analysis.

To run the script:

The workshop organizers forgot to install one python package, so run this first:

`conda install -y matplotlib`

`python ~/species_tree_analysis/phypartspiecharts.py astral.lpp.rerooted.tre phyparts33 100`

This will generate a file `pies.svg` which you can view using `eog` in the VNC Viewer Terminal:

`eog pies.svg`

#### Questions

* What portions of the tree have a lot of concordance? 

* Does the conflict seem to be constricted to the tips of the tree?

* Are there any nodes with a significant minority bipartition (green)?

#### Exercise

Our run of Phyparts used the collapsed You can also run phyparts with the collapsed gene trees, meaning it is summarizing gene tree bipartitions with at least 33% bootstrap support. How would it be different if only *strongly* supported branches were included in the phyparts analysis? **Repeat the phyparts  analysis using the `-s` flag to increase the support level (e.g. `-s 0.7`).** Be sure to use a different name for the `-o` flag as well. Finally, re-run `phypartspiecharts.py`. How do the results compare to the initial phyparts analysis?

## Further Reading

Shaw, T. I., Ruan, Z., Glenn, T. C., & Liu, L. (2013). STRAW: Species TRee Analysis Web server. Nucleic Acids Research, 41(W1), W238–W241. doi:10.1093/nar/gkt377

Mirarab, S., & Warnow, T. (2015). ASTRAL-II: coalescent-based species tree estimation with many hundreds of taxa and thousands of genes. Bioinformatics, 31(12), i44–i52. doi:10.1093/bioinformatics/btv234

Smith, S. A., Moore, M. J., Brown, J. W., & Yang, Y. (2015). Analysis of phylogenomic datasets reveals conflict, concordance, and gene duplications with examples from animals and plants. BMC Evolutionary Biology, 15(1). doi:10.1186/s12862-015-0423-0

Sayyari, E., & Mirarab, S. (2016). Fast Coalescent-Based Computation of Local Branch Support from Quartet Frequencies. Molecular Biology and Evolution, 33(7), 1654–1668. doi:10.1093/molbev/msw079