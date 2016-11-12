##-- DESeq2: sample correlation heatmap
sampleDists <- dist(t(assay(vsd)))
sampleDistMatrix <- as.matrix(sampleDists)
rownames(sampleDistMatrix) <- vsd$Sample
colnames(sampleDistMatrix) <- rownames(sampleDistMatrix)
heatmap.colors <- rev(cm.colors(32))[1:16]
pheatmap(sampleDistMatrix,
       clustering_distance_rows=sampleDists,
       clustering_distance_cols=sampleDists,
       col=heatmap.colors,
       main = 'Sample correlation heatmap')

