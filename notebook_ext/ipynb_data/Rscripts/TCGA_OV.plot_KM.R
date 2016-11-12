##-- Set up R plot display options in notebook
options(jupyter.plot_mimetypes = "image/svg+xml") 
options(repr.plot.width = 5, repr.plot.height = 5)

##-- Plot KM
# pdf(file=paste0(out.dir,'/',clinical.file,'.sm_clr.KM_curve.pdf'), width=5, height=4)
plot(surv.fit, mark=4, col=c('#00CC00','#0000CC','#CC0000'), 
     lty=1, lwd=1.5,cex=0.8,cex.lab=1.5, cex.axis=1.5, cex.main=1,
     main='Kaplan-Meier survival curves for TCGA OV dataset',
     xlab='Days to Death', 
     ylab='Probability of Survival')
text(1500,0.08,  labels=paste0('cluster1 (n=',sample.counts[1,2],')'), 
     cex=1.2, col='#00CC00')
text(650,0.40, labels=paste0('cluster2\n(n=',sample.counts[2,2],')'), 
     cex=1.2, col='#0000CC')
text(2500,0.68, labels=paste0('cluster3 (n=',sample.counts[3,2],')'), 
     cex=1.2, col='#CC0000')
# dev.off()
