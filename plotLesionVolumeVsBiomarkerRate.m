function mdl = plotLesionVolumeVsBiomarkerRate(volume_T,event_type)
%Define the column rate name for the given event type
event_rate_col_name = ['Avg_',event_type,'_Rate'];

%% Fit model to data

%Fit linear model to data --> convert volume to mm^3
mdl = fitlm(cell2mat(volume_T.Lesion_Volume_um) * 1e-9,cell2mat(volume_T.(event_rate_col_name)));

%% Set up for plotting

%Define color array
stroke_colors = {[170,68,153];[221,204,119];[17,119,51];[68,170,153];[136,204,238];[51,34,136]};

%Convert 0-255 color RGB values to 0-1 RGB values
for i = 1:length(stroke_colors)
    stroke_colors{i}(1) = stroke_colors{i}(1)/255;
    stroke_colors{i}(2) = stroke_colors{i}(2)/255;
    stroke_colors{i}(3) = stroke_colors{i}(3)/255;
end

%% Plot data

%Plot volume of lesion vs biomarker rate
figure
hold on
plot(mdl)
xlabel('Infarct volume [mm^3]')
ylabel(['Infarct rate [',event_type,'s/min]'])
title(['Infarct volume vs average ',event_type,' rate'])

%Plot the scatter by mouse ID
gscatter(cell2mat(volume_T.Lesion_Volume_um) * 1e-9,cell2mat(volume_T.(event_rate_col_name)),volume_T.Mouse_ID,cell2mat(stroke_colors),'.',30);

end