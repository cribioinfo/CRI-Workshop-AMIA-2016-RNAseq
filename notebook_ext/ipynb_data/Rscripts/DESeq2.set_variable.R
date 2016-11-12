##-- Set up R plot display options in notebook
options(jupyter.plot_mimetypes = "image/svg+xml") 
options(repr.plot.width = 6, repr.plot.height = 5)

print(paste0('Group 1 = ', group1))
print(paste0('Group 2 = ', group2))
comp <- paste0(group1, 'vs', group2, '.')
out.prefix <- paste0(out.dir, '/', caller,'/',cancer,'.',
                    gene.type, '.',comp, caller,'.txt')

