# Introduction to Phylogenomic Analysis

## Preparing Gene Trees

In the workshop data folder, the Phylogenomics directory contains the result of a RAxML inference of XXX gene trees for XXX. Each RAxML tree in the `bestTree` directory has a corresponding file in the `bootstrap` directory, which contains 200 bootstrap replicates for that gene.

### Collapsing Gene Trees

Many methods have been developed to incorporate the multispecies coalescent into phylogenetic inference. Some methods, such as BEST (which relies on Mr. Bayes) and *BEAST (which relies on BEAST) allow the direct estimate of species trees from alignments. However, these methods are computationally intensive and impractical to run on large datasets containing many hundreds of loci.

Summary coalescent methods are fast methods of estimating species trees from gene trees while remaining consistent under the multi-species coalescent. Because the input to these methods are gene trees, some error is introduced if the gene tree cannot be determined accurately. Summary coalescent methods do not typically account for gene tree support, and will treat a maximally supported clade with the same weight as a poorly supported clade.

In their 2016 paper "Fast Coalescent-Based Computation of Local Branch Support from Quartet Frequencies", Sayaari and Mirarab suggest using gene trees that are not fully resolved. In their paper they use gene trees where branches receiving less than 33% bootstrap support have been collapsed. 

Here, we will use sumtrees.py, part of the Dendropy python package (https://www.dendropy.org/) to read the RAxML best tree and bootstrap replicates to produce a collapsed gene tree.

First, create a directory for the collapsed gene trees: `mkdir collapsed`

```
parallel sumtrees.py \
--replace bootstrap/RAxML_bootstrap.{}.tre \
-f 0.33 \
-F newick \
--suppress-annotations \
-o collapsed/RAxML_collapsed.{}.tre \
-i newick \
-t bestTree/RAxML_bestTree.{}.tre \
:::: genelist.txt`
```


Unfortunately, sumtrees.py also adds some characters that are not desirable and will cause errors when running ASTRAL. To get rid of these characters, enter the `collapsed` directory and run these commands:

```
parallel "sed -i 's/\[&U\] //g' RAxML_collapsed.{}.tre" :::: ../genelist.txt
parallel "sed -i \"s/'//g\" RAxML_collapsed.{}.tre" :::: ../genelist.txt
```

### Gene tree file

Combine all of the gene tree files in the `collapsed` directory into one gene tree file:

`cat collapsed/*.tre > collapsed_genetrees.tre` 

For comparison, also create a file with uncollapsed gene trees:

`cat bestTree/*.tre > raxml_genetrees.tre`


## Summary Coalescent Methods

### ASTRAL-II

**On the Atmosphere instance, ASTRAL is located here: `/usr/local/ASTRAL/Astral/astral.4.10.12.jar`**

You can view the options for ASTRAL with: `java -jar /usr/local/ASTRAL/Astral/astral.4.10.12.jar -h`

Run ASTRAL using the collapsed gene trees and the uncollapsed RAxML gene trees.

`java -jar /usr/local/ASTRAL/Astral/astral.4.10.12.jar -i collapsed_genetrees.tre -o astral.collapsed.lpp.tre`

`java -jar /usr/local/ASTRAL/Astral/astral.4.10.12.jar -i raxml_genetrees.tre -o astral.raxml.lpp.tre`

Open and view the ASTRAL trees using FigTree from the VCN Viewer. The support values are the Local Posterior Probability. 



### STRAW

The Species TRee Analysis Web Server (http://bioinformatics.publichealth.uga.edu/SpeciesTreeAnalysis/) is an online tool for running three summary coalescent methods: STAR, MP-EST, and NJst. 

Two of the STRAW methods (STAR and MP-EST) require rooted gene trees. We will root the gene trees using a script that automatically identifies the common ancestor of outgroup taxa.

First, make a directory for the rooted gene trees:

`mkdir rooted`

`parallel "python ~/path/to/workshop_data/reroot_trees.py collapsed/RAxML_collapsed.{}.tre > rerooted/RAxML_collapsed.rerooted.{}.tre" :::: genelist.txt`


Save the combined gene tree file onto your computer and open the STRAW website in your internet browser. Select one of the three analyses and enter the information requested to start the job. You will receive an e-mail when the job is finished, after which you can access the output files, including the species trees.


### Questions

Are there major topological differences between ASTRAL and the STRAW methods?
How do the topologies differ between the collapsed and uncollapsed gene trees? 
How do the support values differ?

## Assessing Support

### Local Posterior Probability and Multilocus Bootstrap

The support values that ASTRAL outputs by default is the Local Posterior Probability (LPP). This support measure derives from how ASTRAL breaks the species tree into quartets-- unrooted species trees with four tips. Each quartet can have three possible arrangements. The LPP represents the probability of the quartet in the ASTRAL tree, compared to the other two alternatives. It is important to note that the probability is "local", and will not account for long-distance rearrangements of the tree. For example, if a species is in Clade A in 50% of gene trees and in Clade B in another 50% of gene trees, it likely will not affect the probability of monophyly of either Clade A or Clade B.

An alternative method of support, the Multi-Locus Bootstrap (MLBS), incorporates uncertainty in gene tree estimation. In addition to maximum likelihood gene trees, you also supply a set of single-gene bootstrap trees (or posterior trees from a Bayesian analysis) for each gene. ASTRAL calculates a maximum-quartet tree by sampling one tree from this file for each gene. ASTRAL will calculate the maximum quartet tree from the maximum likelihood gene trees as before, and the support from the bootstrap trees will be mapped onto the ASTRAL tree.  

To run MLBS, create a file where each line is the path to the bootstrap trees for the genes. It is important to have the same order as the collapsed gene trees in the section above:

`ls bootstrap/* > bootstrap_filenames.txt`

```
java -jar /usr/local/ASTRAL/Astral/astral.4.10.12.jar \
-i raxml_genetrees.tre \
-o astral.raxml.mlbs.tre \
-b bootstrap_filenames.txt
```

This takes some time, so the ASTRAL MLBS tree can be found in the Phylogenomics directory in the workshop data. Open this tree using FigTree in the VCN Viewer. How does the MLBS compare to the LPP?


### Phyparts

As phylogenomic methods become more widely adopted across many groups of organisms, a trend is emerging: support values in phylogenomic analysis may be misleading. Bootstrap support will not show the level of discordance present in the gene trees. Consider the following cases for a node receiving maximal ASTRAL support:

* The clade is also supported by gene trees from 235 of 333 loci.
* The clade is supported by 50 loci, and an additional 45 loci have an alternative arrangement.
* The clade is supported by just 10 loci, but the other loci do not have a common alternative pattern.

How would your interpretation of this clade change based on this information?

One method for assessing the level of discordance among loci is bipartition analysis. Stephen Smith and colleagues wrote a java package to conduct this analysis called phyparts (). Typically, bipartition analysis is conducted with trees that all share the same taxa (i.e. bootstrap or posterior trees). Phyparts is able to conduct bipartition analysis with a non-overlapping set of taxa across gene trees. 

**Phyparts is located at: `/usr/local/phyparts/target/phyparts-0.0.1-SNAPSHOT-jar-with-dependencies.jar`**

Phyparts requires rooted gene trees and a rooted species tree. We will use the rooted gene trees from the STRAW section above. Re-root the ASTRAL species tree with the same python script:

`python ~/path/to/workshop_data/reroot_trees.py astral.collapsed.lpp.tre > astral.collapsed.lpp.rerooted.tre`

Run Phyparts, using the directory of rerooted gene trees:

```
java -jar \
/usr/local/phyparts/target/phyparts-0.0.1-SNAPSHOT-jar-with-dependencies.jar \
-d rerooted \
-m astral.collapsed.lpp.rerooted.tre \
-a 1 \
-v \
-o phyparts33 \
```

This will take a few minutes, and output a lot of files to the current directory. For each node on the phylogeny:

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

`python /path/to/workshop_files/phypartspiecharts.py astral.collapsed.lpp.tre phyparts33 258`

This will generate a file `out.svg` which you can view using `eog` in the VNC Viewer Terminal:

`eog out.svg`

#### Exercise

Our run of Phyparts used the collapsed You can also run phyparts with the collapsed gene trees, meaning it is summarizing gene tree bipartitions with at least 33% bootstrap support. How would it be different if only *strongly* supported branches were included in the phyparts analysis? **Repeat the phyparts  analysis using the `-s` flag to increase the support level (e.g. `-s 0.7`).** Be sure to use a different name for the `-o` flag as well. How do the results compare to the initial phyparts analysis?

## Further Reading

Shaw, T. I., Ruan, Z., Glenn, T. C., & Liu, L. (2013). STRAW: Species TRee Analysis Web server. Nucleic Acids Research, 41(W1), W238–W241. doi:10.1093/nar/gkt377

Mirarab, S., & Warnow, T. (2015). ASTRAL-II: coalescent-based species tree estimation with many hundreds of taxa and thousands of genes. Bioinformatics, 31(12), i44–i52. doi:10.1093/bioinformatics/btv234

Smith, S. A., Moore, M. J., Brown, J. W., & Yang, Y. (2015). Analysis of phylogenomic datasets reveals conflict, concordance, and gene duplications with examples from animals and plants. BMC Evolutionary Biology, 15(1). doi:10.1186/s12862-015-0423-0

Sayyari, E., & Mirarab, S. (2016). Fast Coalescent-Based Computation of Local Branch Support from Quartet Frequencies. Molecular Biology and Evolution, 33(7), 1654–1668. doi:10.1093/molbev/msw079