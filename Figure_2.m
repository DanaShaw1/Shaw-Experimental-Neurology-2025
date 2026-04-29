%Description: Generates plots and stats for Figure 2 from Shaw et. al. 2025
%
%Output:
%   - stats_ns_s_XXXX_T - summary table for non-stroke event rates compared
%       to stroke event rates using a paired wilcoxon signrank test -->
%       results from these outputs used in Table 1
%   - stats_glme_XXXX - struct with all GLME comparisons between different
%       hemisphere groups --> results from these outputs used in Table 2
%
%Note: To replicate p-values for Table 2, get p-value for associated
%    predictor variable in given GLME output and multiply by 6 (i.e., apply 
%    Bonferroni correction)

close all
clear
clc

%Add repo to path dynamically
script_dir = fileparts(mfilename('fullpath'));
addpath(genpath(script_dir));

%Add path to violin plot code
addpath(fullfile(script_dir,'External_Code','Violin_plot'));

%% Load in data tables

%Load in the biomarker detection table
load(fullfile(script_dir,'Data','All_Biomarker_detection_table.mat'));

%Load in the collapsed biomarker detection table
load(fullfile(script_dir,'Data','All_Biomarker_collapsed_detection_table.mat'));

%% Violin plots for within-mouse comparisons for stroke mice (Figure 2 A-C)

%Pull out just the stroke mice from the collapsed data table
stroke_collapse_T = data_collapse_T(1:164,:);

%Plot violin plots for each biomarker
plotViolinComparison(stroke_collapse_T,'Spike','log')
plotViolinComparison(stroke_collapse_T,'Ripple','log')
plotViolinComparison(stroke_collapse_T,'SR','log')

%% Stats for within-mouse comparisons for stroke mice (Table 1)

%Get wilcoxon sign-rank and summary stats
stats_ns_s_spike_T = getStrokeVsNonstrokeStats(stroke_collapse_T,'Spike');
stats_ns_s_ripple_T = getStrokeVsNonstrokeStats(stroke_collapse_T,'Ripple');
stats_ns_s_SR_T = getStrokeVsNonstrokeStats(stroke_collapse_T,'SR');

%% Violin plots for comparing different experimental groups (Figure 2 D-F)

%Plot the violins across experimental groups
plotViolinsByHemisphereGroup(data_T,'Spike')
plotViolinsByHemisphereGroup(data_T,'Ripple')
plotViolinsByHemisphereGroup(data_T,'SR')

%% Stats for comparing different experimental groups (Table 2)

stats_glme_spike = computeStatsForHemisphereGroup(data_T,'Spike');
stats_glme_ripple = computeStatsForHemisphereGroup(data_T,'Ripple');
stats_glme_SR = computeStatsForHemisphereGroup(data_T,'SR');
