### ATV
## On variability in local field potentials

# Variability–Power Simulation (MATLAB)

This repository contains a documented MATLAB implementation to simulate trialwise time series with two temporal regimes—an initial high-variability window (0–500 ms) followed by a low-variability window (500–1500 ms)—across multiple subjects and trials. It computes per-subject power and variability (as defined below) within the low-variability window and examines their correlation across subjects. The code also reproduces example plots (overlaid trials, time-varying across-trial variability) and a correlation scatter with a regression line for each simulation condition.

Reproducibility: The main script sets a fixed random seed (rng(42)), so results are deterministic unless you change it.
Requirements: MATLAB R2019b or newer (earlier versions may work). No toolbox dependencies; the regression line uses polyfit/polyval (base MATLAB).

Simulates numSubjects × numTrials time series at 1 kHz for 1.5 s per trial.
Five simulation conditions control how the low/high-variability periods are generated:
Half-STD: low-variability std = 2; high-variability std = 4 (low has half the high std).
Double-STD: low-variability std = 8; high-variability std = 4 (low has double the high std).
Rand+Fix (5:5): low = 50% fixed term + 50% random; high = average of two random draws.
Rand+Fix (8:2): low = 80% random + 20% fixed; high = 80% random + 20% random (weighted).
Rand+Fix (9:1): low = 90% random + 10% fixed; high = 90% random + 10% random (weighted).
All conditions use a per-subject scale factor to vary amplitudes between subjects.

Getting started
# Clone this repository
git clone https://github.com/<your-username>/variability-power-simulation.git
cd variability-power-simulation/src

# Run in MATLAB
simulate_variability_power
samplingRate (default 1000 Hz)
trialDurationSec (1.5 s)
numTrials (100)
numSubjects (20)
highVarDurationSec (0.5 s)
lowVarDurationSec (1.0 s)
randomSeed (42)

Citation:
doi: https://doi.org/10.1101/2025.03.27.645661
