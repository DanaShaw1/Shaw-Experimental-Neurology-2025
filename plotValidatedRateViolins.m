function plotValidatedRateViolins(data_T,event_type)
%Get the column names
col_names = data_T.Properties.VariableNames;

%Define the column rate name for the given event type
event_rate_col_name = [event_type,'_rate_min'];

%Determine which column to pull event rates from
rate_col_idx = find(strcmp(event_rate_col_name,col_names));

%% Prep for plotting

%Define the color array
colors = {[136,34,85],[170,68,153],[221,204,119],[17,119,51],[68,170,153],[136,204,238],[51,34,136]};

%Convert 0-255 color RGB values to 0-1 RGB values
for i = 1:length(colors)
    colors{i}(1) = colors{i}(1)/255;
    colors{i}(2) = colors{i}(2)/255;
    colors{i}(3) = colors{i}(3)/255;
end

%Get the stroke and nonstroke rates
rates_nonstroke = cell2mat(data_T{strcmp(data_T.Group,'nonstroke'),rate_col_idx});
rates_stroke = cell2mat(data_T{strcmp(data_T.Group,'stroke'),rate_col_idx});

%Define some jitter
jitter = normrnd(0,0.1,[7,1]);

%% Plot the violin

%Initialize figure
figure
hold on

%Plot violin
violinplot(cell2mat(data_T.(event_rate_col_name)),data_T.Group,'ViolinColor',[0 0 0],'ShowData',false);

%Plot the scatter
for i = 1:7
    scatter(1 + jitter(i),rates_nonstroke(i),'MarkerEdgeColor',colors{i},'MarkerFaceColor',colors{i})
    scatter(2 + jitter(i),rates_stroke(i),'MarkerEdgeColor',colors{i},'MarkerFaceColor',colors{i})
end

ylabel([event_type,' rate [',event_type,'s/min]'])

%Set the dimensions of the figure
set(gcf,'position',[100,100,250,300])

%% Print the stats results

%Get the p-value
p_val_wilcoxon_two_tails = signrank(rates_stroke,rates_nonstroke);

%Print results to command window
fprintf([event_type,' validate rates, stroke vs nonstroke:\np = ',num2str(p_val_wilcoxon_two_tails),'\n\n']);

end