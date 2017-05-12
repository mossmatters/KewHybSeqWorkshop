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

**On the Atmosphere instance, ASTRAL is located here: `/usr/local/ASTRAL/Astral/astral-4.10.12.jar`**

You can view the options for ASTRAL with: `java -jar /usr/local/ASTRAL/Astral/astral-4.10.12.jar -h`

Run ASTRAL using the collapsed gene trees and the uncollapsed RAxML gene trees.

`java -jar /usr/local/ASTRAL/Astral/astral.4.10.2.jar -i collapsed_genetrees.tre -o astral.collapsed.lpp.tre`

`java -jar /usr/local/ASTRAL/Astral/astral.4.10.2.jar -i raxml_genetrees.tre -o astral.raxml.lpp.tre`

Open and view the ASTRAL trees using FigTree from the VCN Viewer. The support values are the Local Posterior Probability. 



### STRAW

Species TRee Analysis Web Server http://bioinformatics.publichealth.uga.edu/SpeciesTreeAnalysis/

### Questions

Are there major topological differences between ASTRAL and MP-EST?
How do the topologies differ between the collapsed and uncollapsed gene trees? 
How do the support values differ?




## Assessing Support

### Local Posterior Probability and Multilocus Bootstrap

### PhypartsPieCharts

## Further Reading

Shaw, T. I., Ruan, Z., Glenn, T. C., & Liu, L. (2013). STRAW: Species TRee Analysis Web server. Nucleic Acids Research, 41(W1), W238–W241. doi:10.1093/nar/gkt377

Mirarab, S., & Warnow, T. (2015). ASTRAL-II: coalescent-based species tree estimation with many hundreds of taxa and thousands of genes. Bioinformatics, 31(12), i44–i52. doi:10.1093/bioinformatics/btv234

Smith, S. A., Moore, M. J., Brown, J. W., & Yang, Y. (2015). Analysis of phylogenomic datasets reveals conflict, concordance, and gene duplications with examples from animals and plants. BMC Evolutionary Biology, 15(1). doi:10.1186/s12862-015-0423-0

Sayyari, E., & Mirarab, S. (2016). Fast Coalescent-Based Computation of Local Branch Support from Quartet Frequencies. Molecular Biology and Evolution, 33(7), 1654–1668. doi:10.1093/molbev/msw079