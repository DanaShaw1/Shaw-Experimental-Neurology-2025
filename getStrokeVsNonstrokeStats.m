function stats_T = getStrokeVsNonstrokeStats(data_T,event_type)
%Get the column names
col_names = data_T.Properties.VariableNames;

%Define the column rate name for the given event type
event_rate_col_name = [event_type,'_rate_min'];

%Determine which column to pull event rates from
rate_col_idx = find(strcmp(event_rate_col_name,col_names));

%Get mouse groups
[mouse_num, mouse_ID] = findgroups(data_T.Mouse_ID);

%Initialize variables for stats table
p_wilcoxon = zeros(length(mouse_ID),1);
ns_medians = zeros(length(mouse_ID),1);
s_medians = zeros(length(mouse_ID),1);
ns_IQR = zeros(length(mouse_ID),1);
s_IQR = zeros(length(mouse_ID),1);
ns_q1 = zeros(length(mouse_ID),1);
s_q1 = zeros(length(mouse_ID),1);
ns_q3 = zeros(length(mouse_ID),1);
s_q3 = zeros(length(mouse_ID),1);

%Go through each mouse
for i = 1:length(mouse_ID)
    %Get all entries for mouse i
    current_mouse_idx = find(mouse_num == i);
    current_mouse_T = data_T(current_mouse_idx,:);

    %Get the non-stroke and stroke rates per min
    ns_rates = cell2mat(current_mouse_T{strcmp(current_mouse_T.Group,'nonstroke'),rate_col_idx});
    s_rates = cell2mat(current_mouse_T{strcmp(current_mouse_T.Group,'stroke'),rate_col_idx});

    %Compute the Wilcoxon Signed Rank Test p-value
    p_wilcoxon(i) = signrank(ns_rates,s_rates);

    %Get the other descriptive statistics
    ns_medians(i) = median(ns_rates);
    s_medians(i) = median(s_rates);
    ns_IQR(i) = iqr(ns_rates);
    s_IQR(i) = iqr(s_rates);
    ns_q1(i) = prctile(ns_rates,25);
    s_q1(i) = prctile(s_rates,25);
    ns_q3(i) = prctile(ns_rates,75);
    s_q3(i) = prctile(s_rates,75);
end

%Put data into table
stats_T = table(ns_medians,ns_IQR,ns_q1,ns_q3,s_medians,s_IQR,s_q1,s_q3,p_wilcoxon);
end