%Description: This script collapses the biomarker detection table within
%   each session

close all
clear
clc

%Add repo to path dynamically
script_dir = fileparts(mfilename('fullpath'));
addpath(genpath(script_dir));

%Load in the biomarker detection table
load(fullfile(script_dir,'Data','All_Biomarker_detection_table.mat'));

%% Collapse table within session

%Find the mouse groups
[mouse_num, mouse_ID] = findgroups(data_T.Mouse_ID);

%Initialize collapsed table
data_collapse_T = data_T;
data_collapse_T(:,:) = [];

%Go through each mouse
for i = 1:length(mouse_ID)
    %Get all entries for mouse i
    current_mouse_idx = find(mouse_num == i);
    current_mouse_T = data_T(current_mouse_idx,:);

    %Find the datecode groups
    [datecode_num, datecode_ID] = findgroups(current_mouse_T.Datecode);

    %Go throuh each datecode
    for j = 1:length(datecode_ID)
        %Get all entries for datecode j
        current_datecode_idx = find(datecode_num == j);
        current_datecode_T = current_mouse_T(current_datecode_idx,:);

        %Find the hemisphere groups
        [hemi_num, hemi_ID] = findgroups(current_datecode_T.Hemisphere);

        %Go through each hemisphere
        for k = 1:length(hemi_ID)
            %Get all entries for hemisphere k
            current_hemi_idx = find(hemi_num == k);
            current_hemi_T = current_datecode_T(current_hemi_idx,:);

            %Check if the data needs to be collapsed
            if height(current_hemi_T) > 1
                new_row = collapseRows(current_hemi_T);
                data_collapse_T = [data_collapse_T; new_row];
            else
                data_collapse_T = [data_collapse_T; current_hemi_T];
            end
        end
    end
end

%Remove the Hour column from collapsed table
data_collapse_T.Hour = [];

%% Save the table

%Define the save name
save_name = fullfile(script_dir,'Data','All_Biomarker_collapsed_detection_table.mat');

%Save table
save(save_name,'data_collapse_T');