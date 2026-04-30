%Description: Generates plots and stats for Figure 3 from Shaw et. al. 2025
%   and data for Table S2

close all
clear
clc

%Add repo to path dynamically
script_dir = fileparts(mfilename('fullpath'));
addpath(genpath(script_dir));

%Add path to violin plot code
addpath(fullfile(script_dir,'External_Code','Violin_plot'));

%% Load in data tables

%Load in the validation summary table
load(fullfile(script_dir,'Data','validation_rate_summary.mat'))

%Load in the collapsed biomarker detection table
load(fullfile(script_dir,'Data','All_Biomarker_collapsed_detection_table.mat'));

%% Violin plots for comparing validated rates between stroke and nonstroke hemispheres (Figure 3 A - C)

%Pull out just the validated rates from the table
validated_T = summary_T(strcmp(summary_T.Validation_status,'validated'),:);

%Plot validated rate violins and print stats
plotValidatedRateViolins(validated_T,'Spike');
plotValidatedRateViolins(validated_T,'Ripple');
plotValidatedRateViolins(validated_T,'SR');

%% ROC analysis - Unvalidated biomarker rates (Figure 3 D and Table S2)

%Pull out just the stroke mice from the collapsed data table
stroke_collapse_T = data_collapse_T(1:164,:);

%Run ROC analysis on validated rates
performROCAnalysis(stroke_collapse_T,'Spike')
performROCAnalysis(stroke_collapse_T,'Ripple')
performROCAnalysis(stroke_collapse_T,'SR')

%% ROC analysis - Validated biomarker rates (Figure 3 E and Table S2)

%Run ROC analysis on validated rates
performROCAnalysis(validated_T,'Spike')
performROCAnalysis(validated_T,'Ripple')
performROCAnalysis(validated_T,'SR')