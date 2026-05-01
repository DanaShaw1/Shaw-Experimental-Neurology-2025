function [lesion_vol_um] = calculateVolume(slice_thickness,num_slice_between,lesion_T)
%Get the number of consecutive slices
num_slice = height(lesion_T);

if num_slice > 0

    %Get the lesion areas and append 0 at the end --> add 0 at the end since
    %   lesion goes away after last slice with lesion
    areas_um = [cell2mat(lesion_T.Lesion_Area_um);0];

    %Initialize a container for storing all area values
    areas_all = zeros(num_slice,num_slice_between+1);

    %Go through each consecutive pair of values and get estimates of the area
    %   in the hidden slices
    for i = 1:length(areas_um)-1
        %Get the 1st and 2nd values
        val_1 = areas_um(i);
        val_2 = areas_um(i+1);

        %Assign the first value to the first entry in the area array
        areas_all(i,1) = val_1;

        %Generate an axis
        x_ax = [1,7];

        %Get the line coefficients between the two
        line = polyfit(x_ax,[val_1,val_2],1);

        %Extract the line coefficients
        m = line(1);
        b = line(2);

        %Define the intermediate x-axis values
        x_ax_inter = (2:6);

        %Initialize an array for storing estimated area values for the
        %   intermediate slices
        area_inter = zeros(size(x_ax_inter));

        %Estimate the intermediate area values
        for j = 1:length(area_inter)
            areas_all(i,j+1) = m * x_ax_inter(j) + b;
        end

    end

    %Calculate the estimated lesion volume for each slice
    slice_vol = areas_all .* slice_thickness;
    lesion_vol_um = sum(slice_vol,'all');
else
    %Lesion volume is 0 --> in case there is no recorded lesion area
    lesion_vol_um = 0;
end
end