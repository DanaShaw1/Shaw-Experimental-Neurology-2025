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

%% Load in data table

%Load in the collapsed biomarker detection table
load(fullfile(script_dir,'Data','All_Biomarker_collapsed_detection_table.mat'));

%% ROC analysis - Unvalidated biomarker rates

%Pull out just the stroke mice from the collapsed data table
stroke_collapse_T = data_collapse_T(1:164,:);

performROCAnalysis(stroke_collapse_T,'Spike')
performROCAnalysis(stroke_collapse_T,'Ripple')
performROCAnalysis(stroke_collapse_T,'SR')