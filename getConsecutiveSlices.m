function lesion_slices = getConsecutiveSlices(lesion_T)
%Get the slice IDs and convert them to numbers
slice_id = str2double(lesion_T.Slice_ID);

%%
% Step 1: Find breaks in consecutiveness
diffs = diff(slice_id);
break_points = [0, find(diffs > 1), length(slice_id)];

% Step 2: Loop through each contiguous block and compute volume estimate
%   for selecting indices
maxVolume = 0;
lesion_slices = [];

for i = 1:length(break_points)-1
    startIdx = break_points(i) + 1;
    endIdx   = break_points(i+1);
    
    thisBlockIdx = slice_id(startIdx:endIdx);
    thisBlockArea = cell2mat(lesion_T.Lesion_Area_um(startIdx:endIdx));
    thisVolume = sum(thisBlockArea);
    
    if thisVolume > maxVolume
        maxVolume = thisVolume;
        lesion_slices = thisBlockIdx;
    end
end


end