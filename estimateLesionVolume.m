function lesion_vol_um = estimateLesionVolume(data_T)

%Get entries that have areas that are non-zero
temp_T = data_T(cell2mat(data_T.Lesion_Area_Pix) > 1,:);

%Get the consecutive slices of the largest lesion
lesion_slices = getConsecutiveSlices(temp_T);

%Get only the entries with the consecutive lesion slices with the maximum
%   area of damage
lesion_T = [];
for i = 1:length(lesion_slices)
    %Get the current slice id
    current_lesion_slice = lesion_slices(i);

    %Find the corresponding row in the table
    row_id = find(current_lesion_slice == str2double(temp_T.Slice_ID));

    %Add the row to the lesion table
    lesion_T = [lesion_T;temp_T(row_id,:)];
end

%% Estimate the volume of the lesion

%Assign some paramter values
slice_thickness = 50; %thickness of a slice in um
num_slice_between = 5; %number of slices between consecutive imaged slices

%Estimate volume
lesion_vol_um = calculateVolume(slice_thickness,num_slice_between,lesion_T);


end