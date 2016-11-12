##-- Set up R plot display options in notebook
options(jupyter.plot_mimetypes = "image/svg+xml") 
options(repr.plot.width = 10, repr.plot.height = 5)

genes.all <- res.print
genes.sig <- res.flt.print

##-- clusterProfiler: remove genes with fc / pvalue as NA
genes.all <- na.omit(genes.all)

##-- clusterProfiler: add EntrezID, fc and p-value
# keytypes(org.Hs.eg.db) 
genes.all.anno <- bitr(geneID   =  genes.all$SYMBOL, 
                      fromType = 'SYMBOL', 
                      toType   = c('ENTREZID'), 
                      OrgDb    = 'org.Hs.eg.db', 
                      drop     = TRUE)
genes.all.anno <- merge(genes.all.anno, genes.all, by = 'SYMBOL')
genes.all.anno <- genes.all.anno[
    which(! duplicated(genes.all.anno$ENTREZID)), ]
row.names(genes.all.anno) <- genes.all.anno$ENTREZID
genes.sig.anno <- genes.all.anno[genes.all.anno$SYMBOL %in% 
                                genes.sig$SYMBOL,]

