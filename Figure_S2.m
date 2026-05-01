%Description: Generates plots for Figure S2 from Shaw et. al. 2025

close all
clear
clc

%Add repo to path dynamically
script_dir = fileparts(mfilename('fullpath'));
addpath(genpath(script_dir));

%Add path to violin plot code
addpath(fullfile(script_dir,'External_Code','Violin_plot'));

%% Load in collapsed and uncollapsed ripple detections

%All-ripple detections
load(fullfile(script_dir,'Data','All_Ripple_detection_table_full.mat'));

%Collapsed ripple detections
load(fullfile(script_dir,'Data','All_Ripple_collapsed_detection_table.mat'));

%% Violins (Figure S2 A)

%Plot Staba violin comparisons between stroke and non-stroke hemispehres
plotViolinComparison(data_collapse_T,'Staba_Ripple','log')

%% Plot by hemisphere w/linear regression (Figure S2 Bi)

%Perform a linear regression where Staba is independent (X) variable
mdl = fitlm(cell2mat(ripple_summary_all_T.Staba_Ripple_count),cell2mat(ripple_summary_all_T.Ripple_count));

%Define x-axis for mdl
x = (0:1300);

%Get the mdl y values
y = mdl.Coefficients{2,1} * x + mdl.Coefficients{1,1};

%Plot the data by stroke vs non-stroke
figure
gscatter(cell2mat(ripple_summary_all_T.Staba_Ripple_count),cell2mat(ripple_summary_all_T.Ripple_count),ripple_summary_all_T.Group,'br',[],10)
xlim([0,1300])
ylim([0,800])
xlabel('Staba ripple counts')
ylabel('Chu 2017 ripple counts')
title('Staba vs Chu 2017 ripple counts for each session')

%Plot the linear regression
hold on
plot(x,y,'k--','HandleVisibility','off')

%Display the r-squared value
text(100,700,['R^2 = ', num2str(mdl.Rsquared.Adjusted)])

%% Plot by mouse w/linear regression (Figure S2 Bii)

%Find the mouse groups
[mouse_num, mouse_ID] = findgroups(ripple_summary_all_T.Mouse_ID);

%Plot by mouse ID
figure
gscatter(cell2mat(ripple_summary_all_T.Staba_Ripple_count),cell2mat(ripple_summary_all_T.Ripple_count),mouse_num,[],[],10)
xlim([0,1300])
ylim([0,800])
xlabel('Staba ripple counts')
ylabel('Chu 2017 ripple counts')
title('Staba vs Chu 2017 ripple counts for each session')

%Plot the linear regression
hold on
plot(x,y,'k--','HandleVisibility','off')

%Display the r-squared value
text(100,700,['R^2 = ', num2str(mdl.Rsquared.Adjusted)])

%% ROC analysis (Figure S2 C)

%Run ROC analysis on detections from both ripple detectors
performROCAnalysis(data_collapse_T,'Staba_Ripple')
performROCAnalysis(data_collapse_T,'Ripple')
