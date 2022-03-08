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
y = GSE34018$y
y[1:5, 1:5]

metadata = GSE34018$metadata
metadata

## ----fit----------------------------------------------------------------------
fit = getModelFit(y, metadata, nKnots = 3L, condColname = 'cond')
fit = getPosteriorFit(fit)

## ----rhythm_stats-------------------------------------------------------------
rhyStats = getRhythmStats(fit)
print(rhyStats, nrows = 10L)

## ----diff_rhythm_stats--------------------------------------------------------
diffRhyStats = getDiffRhythmStats(fit, rhyStats)
print(diffRhyStats, nrows = 10L)

## ----plot_stats, fig.width = 4, fig.height = 4--------------------------------
print(diffRhyStats[order(diff_peak_trough_amp)], nrows = 10L)

ggplot(diffRhyStats) +
  geom_point(aes(x = diff_mesor, y = diff_peak_trough_amp), alpha = 0.2) +
  labs(x = bquote(Delta*'mesor (norm.)'), y = bquote(Delta*'amplitude (norm.)'))

## ----expected_meas------------------------------------------------------------
genes = data.table(
  id = c('13170', '12686', '26897'),
  symbol = c('Dbp', 'Elovl3', 'Acot1'))

measFit = getExpectedMeas(fit, times = seq(0, 24, 0.5), features = genes$id)
measFit[genes, symbol := i.symbol, on = .(feature = id)]
print(measFit, nrows = 10L)

## ----plot_timecourse, fig.width = 7, fig.height = 2.75------------------------
measObs = mergeMeasMeta(y, metadata, features = genes$id)
measObs[genes, symbol := i.symbol, on = .(feature = id)]
print(measObs, nrows = 10L)

ggplot() +
  facet_wrap(vars(symbol), scales = 'free_y', nrow = 1) +
  geom_line(aes(x = time, y = value, color = cond), data = measFit) +
  geom_point(aes(x = time %% 24, y = meas, color = cond, shape = cond),
             size = 1.5, data = measObs) +
  labs(x = 'Zeitgeber time (h)', y = 'Expression (norm.)',
       color = 'Condition', shape = 'Condition') +
  scale_x_continuous(breaks = seq(0, 24, 4)) +
  scale_color_brewer(palette = 'Dark2') +
  scale_shape_manual(values = c(21, 23)) +
  theme(legend.position = 'bottom')

