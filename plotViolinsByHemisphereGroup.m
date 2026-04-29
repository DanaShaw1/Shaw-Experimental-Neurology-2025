function plotViolinsByHemisphereGroup(data_T,event_type)
%Get the column names
col_names = data_T.Properties.VariableNames;

%Define the column rate name for the given event type
event_rate_col_name = [event_type,'_rate_min'];

%Determine which column to pull event rates from
rate_col_idx = find(strcmp(event_rate_col_name,col_names));

%% Get rates for each hemisphere group

%Seperate the data table by experimental group
stroke_T = data_T(1:394,:);
rb_T = data_T(395:440,:);
saline_T = data_T(441:end,:);

%Seperate stroke table into stroke and nonstroke hemispheres
stroke_hemi_T = stroke_T(strcmp(stroke_T.Group,'stroke'),:);
nonstroke_hemi_T = stroke_T(strcmp(stroke_T.Group,'nonstroke'),:);

%Get the rates
stroke_rates = cell2mat(stroke_hemi_T{:,rate_col_idx});
nonstroke_rates = cell2mat(nonstroke_hemi_T{:,rate_col_idx});
rb_rates = cell2mat(rb_T{:,rate_col_idx});
saline_rates = cell2mat(saline_T{:,rate_col_idx});

%% Prep for plotting
% Categories for x-axis labels
categories = {'Stroke','Nonstroke','RB sham','saline sham'};

%Compile all rates into a single array along with corresponding groups
rates_all = [stroke_rates;nonstroke_rates;rb_rates;saline_rates];
group_labels = [zeros(length(stroke_rates),1)+1;zeros(length(nonstroke_rates),1)+2; ... +
    zeros(length(rb_rates),1)+3;zeros(length(saline_rates),1)+4];

%Define color array
stroke_colors = {[136,34,85];[170,68,153];[221,204,119];[17,119,51];[68,170,153];[136,204,238];[51,34,136]};
rb_colors = {[134,15,4];[222,72,7];[255,198,112];[185,239,21]};
saline_colors = {[2,253,210];[67,115,250];[94,27,189]};

%Convert 0-255 color RGB values to 0-1 RGB values
for i = 1:length(stroke_colors)
    stroke_colors{i}(1) = stroke_colors{i}(1)/255;
    stroke_colors{i}(2) = stroke_colors{i}(2)/255;
    stroke_colors{i}(3) = stroke_colors{i}(3)/255;
end

for i = 1:length(rb_colors)
    rb_colors{i}(1) = rb_colors{i}(1)/255;
    rb_colors{i}(2) = rb_colors{i}(2)/255;
    rb_colors{i}(3) = rb_colors{i}(3)/255;
end

for i = 1:length(saline_colors)
    saline_colors{i}(1) = saline_colors{i}(1)/255;
    saline_colors{i}(2) = saline_colors{i}(2)/255;
    saline_colors{i}(3) = saline_colors{i}(3)/255;
end

%% Plot data

%Plot violins
figure
violinplot(rates_all,group_labels,'ViolinColor',[0 0 0],'ShowData',false);

%Plot the scatter on top
for i = 1:max(group_labels)
    %Get the rates
    current_rates = rates_all(find(group_labels == i));

    %Get the x-axis with jitter
    jitter = normrnd(0,0.08,size(current_rates));
    x_axis = zeros(size(current_rates)) + i + jitter;

    %Find the mouse groups and plot the scatter
    if i == 1 || i == 2
        [mouse_num, ~] = findgroups(stroke_hemi_T.Mouse_ID);

        %Plot the scatter with colors by mouse ID
        gscatter(x_axis, current_rates, mouse_num, cell2mat(stroke_colors))
    elseif i == 3
        [mouse_num, ~] = findgroups(rb_T.Mouse_ID);

        %Plot the scatter with colors by mouse ID
        gscatter(x_axis, current_rates, mouse_num, cell2mat(rb_colors))
    elseif i == 4
        [mouse_num, ~] = findgroups(saline_T.Mouse_ID);

        %Plot the scatter with colors by mouse ID
        gscatter(x_axis, current_rates, mouse_num, cell2mat(saline_colors))
    end

end

% Customize x-axis labels
xticks(1:4);       % Set x-axis ticks to correspond to data points
xticklabels(categories);      % Set the x-axis labels to the desired strings
xtickangle(15);

%Add plot labels
xlabel('Mouse group')
ylabel([event_type,' rate [',event_type,'s/min]'])

%Remove legend
legend('off')

%Set the dimensions of the figure
set(gcf,'position',[100,100,700,400])

end