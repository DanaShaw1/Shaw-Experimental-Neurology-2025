%Description: Generates plots and stats for Figure S3 and table S3 from 
%   Shaw et. al. 2025

close all
clear
clc

close all
clear
clc

%Add repo to path dynamically
script_dir = fileparts(mfilename('fullpath'));
addpath(genpath(script_dir));

%% Load in IHC area data and biomarker data

%Load IHC data -- only contains stroke hemisphere
load(fullfile(script_dir,'Data','Lesion_IHC_table.mat'))

%Load in the biomarker detection table
load(fullfile(script_dir,'Data','All_Biomarker_detection_table.mat'));

% data_T = data_collapse_T;
%% Estimate volume of lesion

%Get the groups of mice
[mouse_num,mouse_id] = findgroups(ihc_T.Mouse_ID);

%Initialize variables to hold important information for a lesion volume
%   table
Mouse_ID = cell(length(mouse_id),1);
Hemisphere = cell(size(Mouse_ID));
Lesion_Volume_um = cell(size(Mouse_ID));

%Initialize the table
volume_T = table(Mouse_ID,Hemisphere,Lesion_Volume_um);

%Go through each mouse
for i = 1:length(mouse_id)
    %Get all entries for mouse i
    current_mouse_idx = find(mouse_num == i);
    current_mouse_T = ihc_T(current_mouse_idx,:);

    %Get only the NeuN entries
    current_mouse_T = current_mouse_T(strcmp('NeuN',current_mouse_T.Stain_ID),:);

    %Sort the table by slice ID
    current_mouse_T = sortrows(current_mouse_T,'Slice_ID');

    %Get the estimated volume of the lesion
    lesion_vol_um = estimateLesionVolume(current_mouse_T);

    %Assign all values to the new volume table
    volume_T.Mouse_ID{i} = current_mouse_T.Mouse_ID{1};
    volume_T.Hemisphere{i} = current_mouse_T.Hemisphere{1};
    volume_T.Lesion_Volume_um{i} = lesion_vol_um;
end

%% Get average biomarker rates per mouse

%Initialize columns for biomarker rates
Avg_Spike_Rate = cell(height(volume_T),1);
Avg_Ripple_Rate = cell(height(volume_T),1);
Avg_SR_Rate = cell(height(volume_T),1);

%Add them to the table
volume_T = [volume_T, table(Avg_Spike_Rate,Avg_Ripple_Rate,Avg_SR_Rate)];

%Go through each mouse
for i = 1:height(volume_T)
    %Get the current mouse ID
    mouse = volume_T.Mouse_ID{i};

    %Get all of the biomarker rates from the stroke hemisphere
    spike_rates = cell2mat(data_T{strcmp(data_T.Mouse_ID,mouse) & strcmp(data_T.Group,'stroke'),14});
    ripple_rates = cell2mat(data_T{strcmp(data_T.Mouse_ID,mouse) & strcmp(data_T.Group,'stroke'),17});
    SR_rates = cell2mat(data_T{strcmp(data_T.Mouse_ID,mouse) & strcmp(data_T.Group,'stroke'),20});

    %Get the average rate across sessions
    volume_T.Avg_Spike_Rate{i} = mean(spike_rates);
    volume_T.Avg_Ripple_Rate{i} = mean(ripple_rates);
    volume_T.Avg_SR_Rate{i} = mean(SR_rates);
end

%% Plot the lesion volume vs biomarker rate

spike_mdl = plotLesionVolumeVsBiomarkerRate(volume_T,'Spike');
ripple_mdl = plotLesionVolumeVsBiomarkerRate(volume_T,'Ripple');
SR_mdl = plotLesionVolumeVsBiomarkerRate(volume_T,'SR');