# AMIA 2016 Annual Symposium Workshop (WG13), Mining Large-scale Cancer Genomics Data Using Cloud-based Bioinformatics Approaches   
## RNAseq data analysis and clinical applications

**[Center for Research Informatics](http://cri.uchicago.edu/), University of Chicago**<br>
November 13, 2016<br>
8:30am-12:00pm<br>
**Instructor:** [Riyue Bao, Ph.D.](https://www.linkedin.com/in/riyuebao)<br>

### Overview

In this 3 hour session, participants will learn about the basics of RNAseq technologies & applications, and gain hands-on experience with analyzing real RNAseq and clinical data. All of this will be performed on Amazon's EC2 cloud environment.

### Format

Both the lectures and hands-on documentation were developed using [Jupyter](http://jupyter.org/) notebooks. The first section will provide you with a basic understanding of RNAseq experiments, clinical applications and experimental design suggestions. The second section will introduce you to the basic workflow of RNAseq data analysis utilizing automated pipelines. After these lectures we will move on to our hands-on activity which uses a Jupyter notebook with [R](https://irkernel.github.io/) to identify differentially expressed genes and pathways. In the last section, we will practice how to associate gene expression with patient's survival in ovarian cancer.

### Dataset

We have two datasets for the hands-on practice. For RNAseq analysis, our example data came from a [published paper](https://www.ncbi.nlm.nih.gov/pubmed/25499759) that explores *PRDM11* and lymphomagenesis. We will use the data from the *PRDM11* knockdown and wildtype samples. You are welcome to explore the full dataset on GEO ([GSE56065](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE56065)). For clinical associations, our example data are ~600 primary ovarian patients from The Cancer Genome Atlas (TCGA) on [GDC](https://gdc-portal.nci.nih.gov/). GDC hosts multiomics and clinical data of > 9,000 patients across > 40 cancer types for research use.

> Fog et al., 2015, Loss of PRDM11 promotes MYC-driven lymphomagenesis, Blood 125:1272-1281     
> The Cancer Genome Atlas Research Network, 2011, Integrated genomic analyses of ovarian carcinoma, Nature, 474:609–615

### File description

This repository contains the following items:
* `Run_RNAseq.tutorial.ipynb` - the main notebook for lecture and hands-on
* `Run_RNAseq.tutorial.rendered.ipynb` - same as above, but with all outputs & figures already rendered for browsing
* `notebook_ext/` - this directory contains the extended version of contents covered in the main notebook
* `pipeline/` - automated pipelines for RNAseq analysis

We will use `Run_RNAseq.tutorial.ipynb` for the workshop. If something goes wrong, the `Run_RNAseq.tutorial.rendered.ipynb` notebook can be used for visualization of the output. In addition, the extended notebooks in `notebook_ext` directory contains more information that you can browse on your own time. Lastly, the `pipeline` was designed to automate analysis from FastQ to read counts, with a quick-start tutorial and wiki documentation.

### Useful link

* [CRI-Workshop-AMIA-2016-ChIPseq](https://github.com/cribioinfo/CRI-Workshop-AMIA-2016-ChIPseq)

### License

These materials are licensed via [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html) with a copy available in this repository.
