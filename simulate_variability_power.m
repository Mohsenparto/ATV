

# src/simulate\_variability\_power.m

%% simulate_variability_power.m
% Simulation of trialwise signals with two variability regimes
% and correlation analysis between per-subject power and variability.
%
% Author: moh3enparto@gmail.com>
% License: MIT
%
% Usage:
%   - Open this file in MATLAB and run.
%   - Adjust the parameters in the CONFIG section below as needed.
%
% Notes:
%   - No toolbox dependencies. Uses base MATLAB only.
%   - Reproducible due to fixed RNG seed (change `randomSeed` to vary runs).

%% HOUSEKEEPING
clear; clc; close all;
set(groot, 'defaultAxesTickDir', 'out');
set(groot, 'defaultAxesTickDirMode', 'manual');

%% CONFIG
samplingRate        = 1000;    % Hz
trialDurationSec    = 1.5;     % seconds (0.5 s high-var + 1.0 s low-var)
numTrials           = 100;     % trials per subject
numSubjects         = 20;      % number of subjects
highVarDurationSec  = 0.5;     % seconds
lowVarDurationSec   = 1.0;     % seconds
randomSeed          = 42;      % RNG seed for reproducibility
saveFigures         = false;   % set true to save PNGs into ../figures/
figuresDir          = fullfile(fileparts(mfilename('fullpath')), '..', 'figures');

% High-variability base (shared across conditions)
muHigh   = 0;   % mean of high-variability segment
stdHigh  = 4;   % std of high-variability segment

% Define which conditions to run (1–5). See README for details.
conditions = 1:5;

%% DERIVED VALUES
rng(randomSeed);
numSamples = round(trialDurationSec * samplingRate);
timeSec    = (0:numSamples-1) / samplingRate;
idxHigh    = find(timeSec <= highVarDurationSec);
idxLow     = find(timeSec >  highVarDurationSec & ...
                     timeSec <= highVarDurationSec + lowVarDurationSec);

if saveFigures && ~exist(figuresDir, 'dir')
    mkdir(figuresDir);
end

%% COLORS for overlay figure
condColors = lines(numel(conditions));
overlayLines = gobjects(0);
overlayLegend = {};

%% MAIN LOOP OVER CONDITIONS
for cond = conditions
    % Container for all subjects in this condition
    subjTrials = cell(numSubjects, 1);

    for s = 1:numSubjects
        % Per-subject amplitude scale (adds inter-subject variability)
        subjectScale = stdHigh * rand(1) + muHigh;  % uniform in [muHigh, muHigh+stdHigh]

        % Preallocate trials (numTrials × numSamples)
        trials = zeros(numTrials, numSamples);

        fixedTerm = [];  % will be defined on first trial (low window only)

        for tr = 1:numTrials
            if tr == 1
                % Fixed term realized once per subject and reused in low window
                fixedTerm = stdHigh .* subjectScale .* randn(1, numel(idxLow)) + muHigh;
            end

            switch cond
                case 1  % Half-STD in low window (stdLow = 2)
                    muLow  = muHigh; stdLow = 2;
                    trials(tr, idxLow)  = stdLow  * subjectScale .* randn(1, numel(idxLow))  + muLow;
                    trials(tr, idxHigh) = stdHigh * subjectScale .* randn(1, numel(idxHigh)) + muHigh;

                case 2  % Double-STD in low window (stdLow = 8)
                    muLow  = muHigh; stdLow = 8;
                    trials(tr, idxLow)  = stdLow  * subjectScale .* randn(1, numel(idxLow))  + muLow;
                    trials(tr, idxHigh) = stdHigh * subjectScale .* randn(1, numel(idxHigh)) + muHigh;

                case 3  % Rand+Fix (5:5) in low; high = avg of two random draws
                    muLow = 0; stdLow = 4;
                    trials(tr, idxLow)  = (5*fixedTerm + 5*stdLow*subjectScale.*randn(1, numel(idxLow))  + muLow) / 10;
                    trials(tr, idxHigh) = (5*stdHigh*subjectScale.*randn(1, numel(idxHigh)) + ...
                                           5*stdHigh*subjectScale.*randn(1, numel(idxHigh))) / 10;

                case 4  % Rand+Fix (8:2) in low; high = weighted mix of random draws
                    muLow = 0; stdLow = 4;
                    trials(tr, idxLow)  = (2*fixedTerm + 8*stdLow *subjectScale.*randn(1, numel(idxLow))  + muLow) / 10;
                    trials(tr, idxHigh) = (2*stdHigh*subjectScale.*randn(1, numel(idxHigh)) + ...
                                           8*stdHigh*subjectScale.*randn(1, numel(idxHigh))) / 10;

                case 5  % Rand+Fix (9:1) in low; high = 90% random + 10% random (weighted)
                    muLow = 0; stdLow = 4;
                    trials(tr, idxLow)  = (1*fixedTerm + 9*stdLow *subjectScale.*randn(1, numel(idxLow))  + muLow) / 10;
                    trials(tr, idxHigh) = (1*stdHigh*subjectScale.*randn(1, numel(idxHigh)) + muHigh + ...
                                           9*stdHigh*subjectScale.*randn(1, numel(idxHigh)) + muHigh) / 10;

                otherwise
                    error('Unknown condition: %d', cond);
            end
        end

        subjTrials{s} = trials;

        % Example plots for the first subject in each condition
        if s == 1
            fh = figure('Name', sprintf('Condition %d — Subject 1', cond), 'Color', 'w');
            % (1) Overlaid trials
            subplot(2, 2, 1);
            plot(timeSec, trials.', 'LineWidth', 0.5);
            xlabel('Time (s)'); ylabel('Amplitude'); box off; axis square; title('Trials (overlaid)');
            xline(highVarDurationSec, ':');

            % (2) Across-trial variability (variance across trials at each time point)
            subplot(2, 2, 3);
            ttv = var(trials, 1, 1);  % variance across trials (dim 1)
            plot(timeSec, ttv, 'LineWidth', 1.25);
            xlabel('Time (s)'); ylabel('TTV'); box off; axis square; title('Across-trial variability');
            xline(highVarDurationSec, ':');

            if saveFigures
                save_png(fh, fullfile(figuresDir, sprintf('cond%d_subject1_examples.png', cond)));
            end
        end
    end

    %% Compute per-subject metrics in low-variability window
    powerVals = zeros(numSubjects, 1);
    varVals   = zeros(numSubjects, 1);

    for s = 1:numSubjects
        Y = subjTrials{s}(:, idxLow); % trials × time (low window)
        % Variability: average across time of across-trial variance at each time point
        varVals(s)   = mean( var(Y, 0, 1), 2 );
        % Power: average across trials of within-trial variance across time (demeaned per trial)
        Ydemean      = Y - mean(Y, 2);
        trialVar     = var(Ydemean, 0, 2); % per-trial variance across time
        powerVals(s) = mean(trialVar);
    end

    %% Correlation + regression (base MATLAB)
    [rVal, pVal] = corr(powerVals, varVals, 'type', 'Pearson');
    coeff = polyfit(powerVals, varVals, 1); % slope & intercept
    xfit  = linspace(min(powerVals), max(powerVals), 100).';
    yfit  = polyval(coeff, xfit);

    fh2 = figure('Name', sprintf('Condition %d — Power vs Variability', cond), 'Color', 'w');
    scatter(powerVals, varVals, 36, 'filled'); hold on;
    plot(xfit, yfit, 'LineWidth', 2);
    xlabel('Power (a.u.)'); ylabel('Variability (a.u.)'); box off; axis square; grid on;
    title(sprintf('r = %.3f, p = %.3g', rVal, pVal));
    % Identity line for reference
    lims = [0, max([xlim, ylim])];
    plot(lims, lims, '-', 'LineWidth', 1);
    xlim(lims); ylim(lims);

    if saveFigures
        save_png(fh2, fullfile(figuresDir, sprintf('cond%d_power_vs_variability.png', cond)));
    end

    % For the grand overlay figure, show fitted lines for selected conditions (1 and 3)
    if ismember(cond, [1 3])
        figure(100); set(gcf, 'Color', 'w'); hold on;
        L = plot(xfit, yfit, 'LineWidth', 2, 'Color', condColors(cond, :));
        overlayLines(end+1) = L; %#ok<SAGROW>
        switch cond
            case 1, overlayLegend{end+1} = 'Half-STD (cond 1)';
            case 3, overlayLegend{end+1} = 'Rand+Fix 5:5 (cond 3)';
        end
        xlabel('Power (a.u.)'); ylabel('Variability (a.u.)'); box off; axis square; grid on;
    end
end

if ~isempty(overlayLines)
    figure(100);
    legend(overlayLines, overlayLegend, 'Location', 'best');
    title('Fitted lines overlay');
    if saveFigures
        save_png(gcf, fullfile(figuresDir, 'overlay_fitted_lines.png'));
    end
end

%% Helper: safe PNG export (works across MATLAB versions)
function save_png(figHandle, outPath)
    try
        exportgraphics(figHandle, outPath, 'Resolution', 300);
    catch
        % Fallback for older MATLAB without exportgraphics
        print(figHandle, outPath, '-dpng', '-r300');
    end
end
```

---

# .gitignore (recommended)

```gitignore
# MATLAB
*.asv
*.autosave
*.mex*
*~
*.mat
*.fig
*.slprj/
.DS_Store
# OS artifacts
Thumbs.db
```
