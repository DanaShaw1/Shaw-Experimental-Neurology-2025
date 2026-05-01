%Description: Generates plots and stats for Figure S3 and table S3 from 
%   Shaw et. al. 2025
%
%Output:
%   - XXXX_mdl - the linear model fit to the data, contains p-values and
%       R^2 values used in Tabl S3

close all
clear
clc

%Add repo to path dynamically
script_dir = fileparts(mfilename('fullpath'));
addpath(genpath(script_dir));

%% Load in IHC area data and biomarker data

%Load IHC data -- only contains stroke hemisphere
load(fullfile(script_dir,'Data','Lesion_IHC_table.mat'))

%Load in the summarized IHC and biomarker rate table
load(fullfile(script_dir,'Data','avg_stroke_rates_table.mat'));

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

%% Add biomarker rates to the table

volume_T = [volume_T, avg_rates_T(:,3:5)];

%% Plot the lesion volume vs biomarker rate (Figure S3)

spike_mdl = plotLesionVolumeVsBiomarkerRate(volume_T,'Spike');
ripple_mdl = plotLesionVolumeVsBiomarkerRate(volume_T,'Ripple');
SR_mdl = plotLesionVolumeVsBiomarkerRate(volume_T,'SR');