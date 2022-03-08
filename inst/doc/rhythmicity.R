## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message = FALSE,
  fig.align = 'center',
  fig.retina = 2)

## ----load_packages------------------------------------------------------------
library('data.table')
library('ggplot2')
library('limorhyde2')
library('qs')

# doParallel::registerDoParallel() # register a parallel backend to minimize runtime
theme_set(theme_bw())

## ----load_data----------------------------------------------------------------
y = GSE54650$y
y[1:5, 1:5]

metadata = GSE54650$metadata
metadata

## ----model_fit----------------------------------------------------------------
fit = getModelFit(y, metadata)

## ----posterior_fit------------------------------------------------------------
fit = getPosteriorFit(fit)

## ----rhythm_stats-------------------------------------------------------------
rhyStats = getRhythmStats(fit)

## ----plot_stats, fig.width = 5, fig.height = 4--------------------------------
print(rhyStats[order(-peak_trough_amp)], nrows = 10L)

ggplot(rhyStats) +
  geom_point(aes(x = peak_phase, y = peak_trough_amp), alpha = 0.2) +
  xlab('Peak phase (h)') +
  ylab('Peak-to-trough amplitude (norm.)') +
  scale_x_continuous(breaks = seq(0, 24, 4))

## ----expected_meas------------------------------------------------------------
genes = data.table(
  id = c('13088', '13170', '13869'),
  symbol = c('Cyp2b10', 'Dbp', 'Erbb4'))

measFit = getExpectedMeas(fit, times = seq(0, 24, 0.5), features = genes$id)
measFit[genes, symbol := i.symbol, on = .(feature = id)]
print(measFit, nrows = 10L)

## ----plot_timecourse, fig.width = 7, fig.height = 2.25------------------------
measObs = mergeMeasMeta(y, metadata, features = genes$id)
measObs[genes, symbol := i.symbol, on = .(feature = id)]
print(measObs, nrows = 10L)

ggplot() +
  facet_wrap(vars(symbol), scales = 'free_y', nrow = 1) +
  geom_line(aes(x = time, y = value), data = measFit) +
  geom_point(aes(x = time %% 24, y = meas), shape = 21, size = 1.5,
             data = measObs) +
  labs(x = 'Circadian time (h)', y = 'Expression (norm.)') +
  scale_x_continuous(breaks = seq(0, 24, 4))

