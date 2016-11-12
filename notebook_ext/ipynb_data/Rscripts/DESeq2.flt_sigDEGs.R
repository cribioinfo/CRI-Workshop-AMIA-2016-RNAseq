##-- Set up R plot display options in notebook
options(jupyter.plot_mimetypes = "image/svg+xml") 
options(repr.plot.width = 6, repr.plot.height = 5)

##-- DESeq2: remove nan values for the foldchange == NAN
before <- nrow(res)
res <- res[!is.na(res$foldChange) & ! is.na(res$padj),];
after <- nrow(res)
print(paste0('Genes removed = ', (before - after), 
             ' (fold change is NA)'))
print(paste0('Genes kept = ', after))
print(paste0('Filter DEGs by: fc, ', fc, ', fdr ', fdr))

##-- DESeq2: filter DEGs
res.flt <- res[(res$foldChange >= fc | res$foldChange <= -fc) & 
              res$padj < fdr,]
print(paste0('Genes non-significant = ', (after - nrow(res.flt)), 
             ' (fc, ', fc, ', fdr ', fdr, ')'))
print(paste0('Genes significant = ', nrow(res.flt)))

##-- DESeq2: peek into filtered gene list
res.flt[1:3,]
res.flt.print <- res.print[res.print$ENSEMBL %in% res.flt$id,]

##-- DESeq2: select those sig genes from normalized expression matrix
gene.select <- res.flt$id
data.plot <- assay(vsd)
data.plot <- data.plot[row.names(data.plot) %in% gene.select,,
                      drop = FALSE]

