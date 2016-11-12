##-- DESeq2: add fold change (via anti-log log2FC)
res$foldChange <- NA
row_pos <- which(! is.na(res$log2FoldChange) & 
                res$log2FoldChange >= 0)
row_neg <- which(! is.na(res$log2FoldChange) & 
                res$log2FoldChange < 0)
res$foldChange[row_pos] <- 2^res$log2FoldChange[row_pos]
res$foldChange[row_neg] <- -2^((-1) * res$log2FoldChange[row_neg])
res <- data.frame(id = row.names(res), res)
# print(sum(res$foldChange == 0) == 0)

##-- DESeq2: add gene symbol back
res.print <- res
colnames(res.print)[1] <- 'ENSEMBL'
res.print <- merge(data.expr[,1:2], res.print, by = 'ENSEMBL')

res.print[1:3,]

