## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message = FALSE,
  fig.align = 'center',
  fig.retina = 2,
  eval = FALSE)

foreach::registerDoSEQ()

## -----------------------------------------------------------------------------
#  library('limorhyde2')
#  # txi = ?
#  # metadata = ?

## -----------------------------------------------------------------------------
#  keep = rowSums(edgeR::cpm(txi$counts) >= 0.5) / ncol(txi$counts) >= 0.75
#  
#  txiKeep = txi
#  for (name in c('counts', 'length')) {
#    txiKeep[[name]] = txi[[name]][keep, ]}

## -----------------------------------------------------------------------------
#  for (i in 1:nrow(txiKeep$counts)) {
#    idx = txiKeep$counts[i, ] > 0
#    txiKeep$counts[i, !idx] = min(txiKeep$counts[i, idx])}

## -----------------------------------------------------------------------------
#  y = edgeR::DGEList(txiKeep$counts)
#  y = edgeR::calcNormFactors(y)
#  
#  fit = getModelFit(y, metadata, ..., method = 'voom') # replace '...' as appropriate for your data

## -----------------------------------------------------------------------------
#  y = DESeq2::DESeqDataSetFromTximport(txiKeep, metadata, ~1)
#  
#  fit = getModelFit(y, metadata, ..., method = 'deseq2') # replace '...' as appropriate for your data

