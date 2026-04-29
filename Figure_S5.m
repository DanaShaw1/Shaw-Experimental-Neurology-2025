%Description: This script plots the difference in delta power between
%   stroke and non-stroke hemispheres across mice and runs stats. It is the
%   code for generating Figure S5 in Shaw et. al. 2025.
%
%Output:
%   results_T - a table of normality assessments and permutation test
%       p-values for each mouse

close all
clear
clc

%Add repo to path dynamically
script_dir = fileparts(mfilename('fullpath'));
addpath(genpath(script_dir));

%Load delta power table
load(fullfile(script_dir,'Data','delta_power_stroke_vs_nonstroke.mat'))

%% Concatenate delta power across time for each mouse

%Get the groups of mice
[mouse_num, mouse_ID] = findgroups(delta_T_summary.Mouse_ID);

%Define cells for the new table
Mouse_ID = cell(length(mouse_ID),1);
Stroke_Delta_Pow = cell(size(Mouse_ID));
Nonstroke_Delta_Pow = cell(size(Mouse_ID));
Delta_Difference = cell(size(Mouse_ID));

%Go through each mouse
for i = 1:length(mouse_ID)
    %Get the filtered table for mouse i
    mouse_idx = find(mouse_num == i);
    current_mouse_T = delta_T_summary(mouse_idx,:);
    
    %Get the stroke and non-stroke hemisphere tables
    stroke_T = current_mouse_T(strcmp(current_mouse_T.hemisphere,'stroke'),:);
    nonstroke_T = current_mouse_T(strcmp(current_mouse_T.hemisphere,'nonstroke'),:);

    %Put the ID of the mouse in the cell array
    Mouse_ID{i} = current_mouse_T.Mouse_ID{1};

    %Concatenate all of the delta power for each hemisphere across time
    Stroke_Delta_Pow{i} = horzcat(stroke_T.delta_pow{:});
    Nonstroke_Delta_Pow{i} = horzcat(nonstroke_T.delta_pow{:});

    %Calculate the difference in the log of the stroke and nonstroke delta
    Delta_Difference{i} = 10*(log10(Stroke_Delta_Pow{i}) - log10(Nonstroke_Delta_Pow{i}));
end

%Save concatenated data in a table
delta_concat_T = table(Mouse_ID,Stroke_Delta_Pow,Nonstroke_Delta_Pow,Delta_Difference);

%% Assess normality for each difference distribution

%Initialize variable to hold normality test results
Normality_Assessment_KS = cell(height(delta_concat_T),1);

%Add it to the table
delta_concat_T = [delta_concat_T,table(Normality_Assessment_KS)];

%Assess normality of difference in delta power distribution
for i = 1:size(Normality_Assessment_KS,1)
    % Kolmogorov-Smirnov Test
    [ks_test.h, ks_test.p,ks_test.ksstat,ks_test.cv] = kstest(delta_concat_T.Delta_Difference{i}, 'CDF', makedist('Normal', 'mu', mean(delta_concat_T.Delta_Difference{i}), 'sigma', std(delta_concat_T.Delta_Difference{i})));
    delta_concat_T.Normality_Assessment_KS{i} = ks_test;
end


%% Perform a nonparametric bootstrap test
%Determine whether there are significant differences in delta power between hemispheres

%Initialize
Perm_Proportions = cell(length(mouse_ID),1);

%Add these to the table
delta_concat_T = [delta_concat_T, table(Perm_Proportions)];

%Define number of iterations
iter = 1000;

%Go through each mouse
for i = 1:height(delta_concat_T)
    
    %Initialize a vriable to hold all of the proportions of diff > 0
    delta_perm_proportions = zeros(iter,1);
    
    %Go through all of the iterations
    for j = 1:iter
        %Randomly shuffle all deta power from both the path and control
        %hemispheres
        mixed_delta = [delta_concat_T.Stroke_Delta_Pow{i}, delta_concat_T.Nonstroke_Delta_Pow{i}];
        mixed_delta = mixed_delta(randperm(length(mixed_delta)));
        
        %Split shuffled data into "path" and "control"
        pseudo_stroke = mixed_delta(1:length(mixed_delta)/2);
        pseudo_nonstroke = mixed_delta(length(mixed_delta)/2 + 1:end);
        
        %Calculate the difference in the log of the control and pathological
        %delta
        pseudo_delta_diff = 10*(log10(pseudo_stroke) - log10(pseudo_nonstroke));
        
        %Save the proportion of data > 0
        delta_perm_proportions(j) = length(find(pseudo_delta_diff > 0))/length(pseudo_delta_diff);
    end
    
    %Add the permuted proportions to the table
    delta_concat_T.Perm_Proportions{i} = delta_perm_proportions;
end

%Initialize container for real mean and computed p-value
T_real = zeros(height(delta_concat_T),1);
p_perm = zeros(height(delta_concat_T),1);

%Compute the p-value for test statistic = proportion diff > 0
for i = 1:height(delta_concat_T)
    T_real(i) = length(find(delta_concat_T.Delta_Difference{i} > 0))/length(delta_concat_T.Delta_Difference{i});
    p_perm(i) = 1 - length(find(delta_concat_T.Perm_Proportions{i} < T_real(i)))/iter;
end

%Add these to the table
results_T = [delta_concat_T,table(T_real,p_perm)];

%% Plot the distributions of the difference in delta power between stroke and nonstroke hemispheres

%Initialize the figure
figure
tiledlayout(height(delta_concat_T),1)

%Go through each mouse and plot the distribution
for i = 1:height(delta_concat_T)
    nexttile
    hold on
    histogram(delta_concat_T.Delta_Difference{i},100,'Normalization','pdf');
    title(['mouse', ' ',num2str(i)])
    xline(0,'--k','LineWidth',1)
    xlim([-10,30])
    hold off
end

% Give common xlabel, ylabel and title to figure
han=axes(gcf,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';

ylabel(han,'Proportion of 5-second time windows');
xlabel('(delta power stroke)/(delta power nonstroke) [dB]')

%Set the dimensions of the figure
set(gcf,'position',[10,10,1000,700])