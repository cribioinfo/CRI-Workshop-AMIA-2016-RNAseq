out.prefix <- paste0(out.dir, '/', caller, '/',cancer,'.', 
                    gene.type, '.', caller)

##-- Set up R plot display options in notebook
options(jupyter.plot_mimetypes = "image/svg+xml") 
options(repr.plot.width = 6, repr.plot.height = 5)

##-- Process expression matrix
row.names(data.expr) <- data.expr$ENSEMBL
data.expr.proc <- data.expr[,-c(1:2)]
data.expr.proc <- data.expr.proc[,data.sample$Sample]
Group <- as.factor(data.sample$Group)

