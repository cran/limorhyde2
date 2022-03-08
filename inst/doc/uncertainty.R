## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message = FALSE,
  fig.align = 'center',
  fig.retina = 2)

## ----load_packages------------------------------------------------------------
library('cowplot')
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

## ----post_samps---------------------------------------------------------------
fit = getPosteriorSamples(fit, nPosteriorSamples = 50L)

## ----meas_samps---------------------------------------------------------------
genes = data.table(
  id = c('13170', '12686', '26897'),
  symbol = c('Dbp', 'Elovl3', 'Acot1'))
times = seq(0, 24, 0.5)

measFitSamps = getExpectedMeas(
  fit, times = times, fitType = 'posterior_samples', features = genes$id)
measFitSamps[genes, symbol := i.symbol, on = .(feature = id)]
print(measFitSamps, nrows = 10L)

## ----meas_ints----------------------------------------------------------------
measFitInts = getExpectedMeasIntervals(measFitSamps)
print(measFitInts, nrows = 10L)

## ----meas_mean----------------------------------------------------------------
measFitMean = getExpectedMeas(fit, times = times, features = genes$id)
measFitMean[genes, symbol := i.symbol, on = .(feature = id)]

## ----plot_timecourse_samps, fig.width = 7, fig.height = 5---------------------
timeBreaks = seq(0, 24, 4)
pal = 'Dark2'

p1 = ggplot(measFitSamps) +
  facet_wrap(vars(symbol), scales = 'fixed', nrow = 1) +
  geom_line(aes(x = time, y = value, color = cond,
                group = interaction(cond, posterior_sample)), alpha = 0.2) +
  labs(x = 'Circadian time (h)', y = 'Expression (norm.)', color = 'Condition') +
  scale_x_continuous(breaks = timeBreaks) +
  scale_color_brewer(palette = pal) +
  theme(legend.position = 'none')

p2 = ggplot() +
  facet_wrap(vars(symbol), scales = 'fixed', nrow = 1) +
  geom_ribbon(aes(x = time, ymin = lower, ymax = upper, fill = cond),
              alpha = 0.3, data = measFitInts) +
  geom_line(aes(x = time, y = value, color = cond), data = measFitMean) +
  labs(x = 'Circadian time (h)', y = 'Expression (norm.)', color = 'Condition',
       fill = 'Condition') +
  scale_x_continuous(breaks = timeBreaks) +
  scale_fill_brewer(palette = pal) +
  scale_color_brewer(palette = pal) +
  theme(legend.position = 'bottom')

plot_grid(p1, p2, ncol = 1, rel_heights = c(1, 1.25))

## ----stats_samps--------------------------------------------------------------
rhyStatsSamps = getRhythmStats(fit, features = genes$id, fitType = 'posterior_samples')
diffRhyStatsSamps = getDiffRhythmStats(fit, rhyStatsSamps)
diffRhyStatsSamps[genes, symbol := i.symbol, on = .(feature = id)]
print(diffRhyStatsSamps, nrows = 10L)

## ----plot_stats_samps, fig.width = 7, fig.height = 5--------------------------
p1 = ggplot(diffRhyStatsSamps) +
  facet_wrap(vars(symbol), nrow = 1) +
  geom_point(aes(x = diff_peak_trough_amp, y = diff_mesor), alpha = 0.2) +
  labs(x = bquote(Delta*'amplitude (norm.)'), y = bquote(Delta*'mesor (norm.)'))

p2 = ggplot(diffRhyStatsSamps) +
  facet_wrap(vars(symbol), nrow = 1) +
  geom_point(aes(x = diff_peak_trough_amp, y = diff_peak_phase), alpha = 0.2) +
  labs(x = bquote(Delta*'amplitude (norm.)'), y = bquote(Delta*'phase (h)'))

plot_grid(p1, p2, ncol = 1)

## ----stats_intervals----------------------------------------------------------
rhyStatsInts = getStatsIntervals(rhyStatsSamps)
print(rhyStatsInts, nrows = 10L)

diffRhyStatsInts = getStatsIntervals(diffRhyStatsSamps)
print(diffRhyStatsInts, nrows = 10L)

