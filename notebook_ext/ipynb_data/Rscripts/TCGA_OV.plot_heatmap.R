
##-- Retrieve sample & gene clusters and add to clinical table
##-- retrieve the basis matrix and coef matrix 
expr.sub.nmf.w <- basis(expr.sub.nmf)
expr.sub.nmf.h <- coef(expr.sub.nmf)

##-- retrieve gene cluster
expr.sub.nmf.geneclr <- predict(expr.sub.nmf, 'features')
expr.sub.nmf.geneclr <- data.frame(gene = row.names(expr.sub.nmf.w), 
                                  cluster = expr.sub.nmf.geneclr)
row.names(expr.sub.nmf.geneclr) <- expr.sub.nmf.geneclr$gene
expr.sub.nmf.geneclr <- expr.sub.nmf.geneclr[
    order(expr.sub.nmf.geneclr$cluster),]
write.table(expr.sub.nmf.geneclr,
  file = paste0(out.dir,'/',expr.file,'.gene_clr.txt'),
  col.names = TRUE, row.names = FALSE, sep = '\t', quote = FALSE)
# print('Gene clusters ... ')
# print(table(expr.sub.nmf.geneclr$cluster))
# print(expr.sub.nmf.geneclr[1:3,])

##-- retrieve sample cluster
expr.sub.nmf.smclr <- predict(expr.sub.nmf)
expr.sub.nmf.smclr <- data.frame(sample = colnames(expr.sub.nmf.h), 
                                cluster = expr.sub.nmf.smclr)
row.names(expr.sub.nmf.smclr) <- expr.sub.nmf.smclr$sample
expr.sub.nmf.smclr <- expr.sub.nmf.smclr[
    order(expr.sub.nmf.smclr$cluster),]
write.table(clinical,
  file = paste0(out.dir,'/',clinical.file,'.sm_clr.txt'),
  col.names = TRUE, row.names = FALSE, sep = '\t', quote = FALSE)
# print('Sample clusters ... ')
# print(table(expr.sub.nmf.smclr$cluster))
# print(expr.sub.nmf.smclr[1:3,])

##-- add sample cluster to clinical table
clinical <- merge(clinical, expr.sub.nmf.smclr, by = 'sample')
clinical$cluster <- as.numeric(clinical$cluster)
clinical <- clinical[order(clinical$cluster),]
clinical$cluster <- as.character(clinical$cluster)

##-- Plot sample correlation and gene expression heatmaps
##-- prepare for plotting heatmaps
gene.counts <- data.frame(table(expr.sub.nmf.geneclr$cluster))
gene.colors <- c(rep('pink',gene.counts[1,2]),
                rep('purple',gene.counts[2,2]),
                rep('lightgreen',gene.counts[3,2]))
sample.counts <- data.frame(table(expr.sub.nmf.smclr$cluster))
sample.colors <- c(rep('red',sample.counts[1,2]),
                  rep('blue',sample.counts[2,2]),
                  rep('green',sample.counts[3,2]))

##-- calculate expression correlation between samples
expr.sub.srt <- expr.sub[,clinical$sample]
expr.sub.srt <- expr.sub.srt[row.names(expr.sub.srt) %in% 
                            expr.sub.nmf.geneclr$gene,]
expr.sub.srt <- expr.sub.srt[as.character(expr.sub.nmf.geneclr$gene),]
expr.sub.cor <- cor(expr.sub.srt)

##-- plot sample correlation heatmap
my.heatcol <- bluered(177) 
my.breaks <- sort(unique(c(seq(-1, -0.5, length.out=20),
                          seq(-0.5, 0.5, length.out=140),
                          seq(0.5, 1, length.out=20))))
centered <- t(scale(t(expr.sub.cor), scale=FALSE))
##-- skip in workshop!!
# png(file=paste0(out.dir,'/',expr.file,'.nmf.cor_heatmap.png'), width=800, height=800)
# heatmap <- heatmap.2(centered, 
#                     dendrogram='none', 
#                     Rowv=NULL,
#                     Colv=NULL,
#                     col=my.heatcol, 
#                     RowSideColors=sample.colors, 
#                     ColSideColors=sample.colors, 
#                     density.info='none', 
#                     trace='none', 
#                     key=TRUE, keysize=1.2, 
#                     labRow=FALSE,labCol=FALSE,
#                     xlab='Samples',ylab='Samples',
#                     main = 'Sample correlation heatmap')
# dev.off()

##-- plot gene expression heatmap
my.heatcol <- bluered(177) 
centered <- t(scale(t(expr.sub.srt), scale=FALSE)) 
##-- skip in workshop!!
# png(file=paste0(out.dir,'/',expr.file,'.nmf.gene_heatmap.png'), width=800, height=800)
# heatmap <- heatmap.2(centered, 
#                     dendrogram='none', 
#                     Rowv=NULL,
#                     Colv=NULL,
#                     col=my.heatcol, 
#                     RowSideColors=gene.colors, 
#                     ColSideColors=sample.colors, 
#                     density.info='none', 
#                     trace='none', 
#                     key=TRUE, keysize=1.2, 
#                     labRow=FALSE,labCol=FALSE,
#                     xlab='Samples',ylab='Genes',
#                     main = 'Gene expression heatmap')
# dev.off()

##-- directly view pre-generated heatmaps (workshop only)
display_png(file='notebook_ext/ipynb_data/assets/Figure22.2.png')