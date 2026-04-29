%Description: Generates plots and stats for Figure S4 from Shaw et. al. 2025

close all
clear
clc

%Add repo to path dynamically
script_dir = fileparts(mfilename('fullpath'));
addpath(genpath(script_dir));

%% Load in the data table

%Load in the SR detection table
load(fullfile(script_dir,'Data','Spike_ripple_detection_table.mat'));

%Get only stroke hemisphere data
stroke_hemi_T = SR_data_T(strcmp(SR_data_T.Group,'stroke'),:);

%% Plot SR rate within a session over 6 hours for stroke hemispheres

%Find the mouse groups
[mouse_num, mouse_ID] = findgroups(stroke_hemi_T.Mouse_ID);

%Initialize a tiled layout figure
figure
tiledlayout(3,2)

%Go through each mouse
for i = 2:length(mouse_ID)
    %Get all entries for mouse i
    current_mouse_idx = find(mouse_num == i);
    mouse_T = stroke_hemi_T(current_mouse_idx,:);

    %Find unique values and their first occurrence
    [uniqueVals, firstIdx, allIdx] = unique(mouse_T.Datecode);

    % Count occurrences of each unique value
    occurrences = histc(allIdx, 1:numel(uniqueVals));

    % Find indices of non-unique values
    six_hour_idx = find(occurrences(allIdx) > 1);

    %Get the hours
    hours = (str2double(mouse_T.Hour(six_hour_idx)));

    %Get the rates
    rates = (cell2mat(mouse_T.SR_rate_min(six_hour_idx)));

    %Put the values in a table
    six_hour_T = table(hours,rates);    

    %Fit a linear model
    six_hour_mdl = fitlm(six_hour_T,'linear');

    %Test residuals 
    h_ttest = ttest(six_hour_mdl.Residuals.Pearson);

    %Get the formula
    if six_hour_mdl.Coefficients.Estimate(2) > 0
        formula = ['rates = ',num2str(six_hour_mdl.Coefficients.Estimate(1)),' + ',num2str(six_hour_mdl.Coefficients.Estimate(2)),' * hours']
    else
        formula = ['rates = ',num2str(six_hour_mdl.Coefficients.Estimate(1)),' - ',num2str(abs(six_hour_mdl.Coefficients.Estimate(2))),' * hours']
    end

    %Plot the model
    nexttile
    plot(six_hour_mdl)
    title(['mouse ',num2str(i),', p = ', num2str(six_hour_mdl.Coefficients.pValue(2)),', R^2 = ',num2str(six_hour_mdl.Rsquared.Ordinary)],'Interpreter','none')
    xlabel('hour')
    ylabel('SR rate [SRs/min])')
    xlim([1 6])

    ylims = ylim; % Get current y-axis limits
    ylim([0, ylims(2)]); % Set only the lower limit to 0, keeping the upper limit unchanged
end

%Set the dimensions of the figure
set(gcf,'position',[10,10,600,800])