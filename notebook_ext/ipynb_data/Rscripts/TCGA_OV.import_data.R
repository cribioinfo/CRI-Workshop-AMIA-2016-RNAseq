separator <- '========================================'

##-- Set up working directory
work.dir <- '.'
setwd(work.dir)

##-- Input/Output directories
in.dir <- 'notebook_ext/ipynb_data/input'
out.dir <- 'notebook_ext/ipynb_data/output/tcga_ov'

##-- Input/Output files
expr.file <- paste0('TCGA_', cancer, '.mirna_expression.tsv')
clinical.file <- paste0('TCGA_', cancer, '.clinical.tsv')

##-- Print analysis info
print(paste0('Cancer = ', cancer))
print(paste0('Expression file = ', expr.file))
print(paste0('Clinical file  = ', clinical.file))

##-- Read files
expr <- read.delim(paste0(in.dir,'/',expr.file), 
                       header = TRUE, stringsAsFactors = FALSE)
clinical <- read.delim(paste0(in.dir,'/',clinical.file), 
                           header = TRUE, stringsAsFactors = FALSE)
clinical <- na.omit(clinical)
print(paste0('Patients with complete clinical = ', nrow(clinical)-1))
print(paste0('Patients with gene expression = ', ncol(expr)-1))
print(paste0('Overlap = ', length(intersect(clinical$sample, 
                                      colnames(expr)))))
print(separator)

print('Show the first three rows of clinical file:')
print(clinical[1:3,])

print(separator)

print('Show the first three rows and left five columns of expression file:')
print(expr[1:3,1:5])

##-- Preprocess 
row.names(clinical) <- clinical[,1]
row.names(expr) <- expr[,1]
expr <- as.matrix(expr[,-1])

##-- median-centered normalization by gene (for NMF clustering only!)
expr.centered <- t(apply(expr,1,function(x){x-median(x)}))

##-- calculate variance: MAD
expr.var <- data.frame(mad = apply(expr.centered,1,mad))

##-- sort gene by MAD values (higher to lower) 
expr.var <- expr.var[rev(order(expr.var[,1])),,drop=FALSE]

# print(paste0('Calcuate and sort gene by Median absolute deviation (MAD):'))
# head(expr.var)

##-- select 150 most variable genes 
expr.var.top <- expr.var[1:gene.top.count,,drop=FALSE]
gene.top <- data.frame(gene = row.names(expr.var.top))

# print(paste0('Select top ', gene.top.count,' most variable genes'))
# print(expr.var.top[1:6,,drop=FALSE])

##-- subset expression matrix by genes and samples
expr.sub <- expr.centered[row.names(expr.centered) %in% 
                              gene.top$gene,colnames(expr.centered) %in% 
                              clinical$sample]

##-- make clinical samples consistent with expression 
clinical <- clinical[clinical$sample %in% 
                              colnames(expr.sub),]

##-- convert expression matrix to rank matrix (Important for NMF!)
##-- because no negative values are allowed in the matrix
expr.sub <- apply(expr.sub,2,rank) / gene.top.count

separator

print(paste0('Expression matrix ready for NMF clustering: ', 
       nrow(expr.sub), ' genes, ', 
       ncol(expr.sub), ' samples'))

print(separator)
