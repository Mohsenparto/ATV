# ATV

## Variability–Power Simulation (MATLAB)

This repository contains a documented MATLAB implementation to simulate trialwise time series with two temporal regimes—an initial high-variability window (0–500 ms) followed by a low-variability window (500–1500 ms)—across multiple subjects and trials. It computes per-subject power and variability (as defined below) within the low-variability window and examines their correlation across subjects. The code also reproduces example plots (overlaid trials, time-varying across-trial variability) and a correlation scatter with a regression line for each simulation condition.

Reproducibility: The main script sets a fixed random seed (rng(42)), so results are deterministic unless you change it.
Requirements: MATLAB R2019b or newer (earlier versions may work). No toolbox dependencies; the regression line uses polyfit/polyval (base MATLAB).



## Citation
doi: https://doi.org/10.1101/2025.03.27.645661


# README.md

## Variability–Power Simulation (MATLAB)

This repository contains a clean, documented MATLAB implementation to simulate trialwise time series with two temporal regimes—an initial **high-variability** window (0–500 ms) followed by a **low-variability** window (500–1500 ms)—across multiple subjects and trials. It computes per-subject **power** and **variability** (as defined below) within the low-variability window and examines their correlation across subjects. The code also reproduces example plots (overlaid trials, time-varying across-trial variability) and a correlation scatter with regression line for each simulation condition.

> **Reproducibility:** The main script sets a fixed random seed (`rng(42)`), so results are deterministic unless you change it.

### What the script does

* Simulates `numSubjects × numTrials` time series at 1 kHz for 1.5 s per trial.
* Five simulation **conditions** control how the low/high-variability periods are generated:

  1. **Half-STD**: low-variability std = 2; high-variability std = 4 (low has half the high std).
  2. **Double-STD**: low-variability std = 8; high-variability std = 4 (low has double the high std).
  3. **Rand+Fix (5:5)**: low = 50% fixed term + 50% random; high = average of two random draws.
  4. **Rand+Fix (8:2)**: low = 80% random + 20% fixed; high = 80% random + 20% random (weighted).
  5. **Rand+Fix (9:1)**: low = 90% random + 10% fixed; high = 90% random + 10% random (weighted).

> All conditions use a per-subject scale factor to vary amplitudes between subjects.

### Definitions (computed per subject in the 500–1500 ms window)

* **Variability**: mean across time of the across-trial variance at each time point.
* **Power**: mean across trials of each trial’s variance across time (demeaned per trial), then averaged across trials and time.

### Requirements

* MATLAB R2019b or newer (earlier versions may work).
* No toolbox dependencies; the regression line uses `polyfit`/`polyval` (base MATLAB).

### Getting started

```bash
# Clone this repository
git clone https://github.com/<your-username>/variability-power-simulation.git
cd variability-power-simulation/src

# Run in MATLAB
simulate_variability_power
```

### Parameters (edit at top of `simulate_variability_power.m`)

* `samplingRate` (default 1000 Hz)
* `trialDurationSec` (1.5 s)
* `numTrials` (100)
* `numSubjects` (20)
* `highVarDurationSec` (0.5 s)
* `lowVarDurationSec` (1.0 s)
* `randomSeed` (42)
* `saveFigures` (false → set `true` to export to `../figures/`)

### Outputs

* For **subject 1** in each condition: overlaid trials and the time-resolved across-trial variability (TTV).
* For **all subjects** in each condition: scatter of **Power vs. Variability** with regression line, Pearson’s *r* and *p*.
* Optional: figures saved as PNGs in `figures/` if `saveFigures = true`.

### Repository structure

```
variability-power-simulation/
├─ README.md
├─ src/
│  └─ simulate_variability_power.m
├─ figures/            # created on first save (optional)
├─ .gitignore          # recommended patterns for MATLAB
└─ LICENSE             # MIT (or your choice)
```

### License

MIT License (recommended). You can switch to any OSI-approved license to match your needs.

### Citation

If you use this code, please cite the GitHub repository and the Zenodo DOI (once minted):

```
@software{your_name_YYYY_variability_power,
  author       = {Your Name},
  title        = {Variability–Power Simulation (MATLAB)},
  year         = {YYYY},
  publisher    = {Zenodo},
  version      = {v1.0.0},
  doi          = {10.5281/zenodo.XXXXXXX},
  url          = {https://doi.org/10.5281/zenodo.XXXXXXX}
}
 
