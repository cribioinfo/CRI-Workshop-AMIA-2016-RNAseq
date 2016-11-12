data.pca <- plotPCA(vsd, intgroup=c('Group'), returnData=TRUE)
percent.var <- round(100 * attr(data.pca, "percentVar"))
pca.colors <- c(KO = colors[1], WT = colors[2])
p1 <- ggplot(data.pca, aes(PC1, PC2, color = Group)) +
            geom_point(size = 5, shape = 17) +
            scale_colour_manual(values = pca.colors) + 
            xlab(paste0("PC1: ",percent.var[1],"% variance")) +
            ylab(paste0("PC2: ",percent.var[2],"% variance")) +
            ggtitle('Principle Component Analysis')
plot(p1)

