function [new_row] = collapseRows(T)
%Get first row of table
new_row = T(1,:);

%Get the column names
col_names = new_row.Properties.VariableNames;

%Fix entries that need to be collapsed
new_row.Duration_in_sec = sum(cell2mat(T.Duration_in_sec));
new_row.Duration_in_min = sum(cell2mat(T.Duration_in_min));

%Check if columns have Spike info
if any(strcmp(col_names,'Spike_count'))
    %Spike data
    new_row.Spike_count = sum(cell2mat(T.Spike_count));
    new_row.Spike_rate_sec = new_row.Spike_count/new_row.Duration_in_sec;
    new_row.Spike_rate_min = new_row.Spike_count/new_row.Duration_in_min;
end

%Check if columns have Ripple info
if any(strcmp(col_names,'Ripple_count'))
    %Ripple data
    new_row.Ripple_count = sum(cell2mat(T.Ripple_count));
    new_row.Ripple_rate_sec = new_row.Ripple_count/new_row.Duration_in_sec;
    new_row.Ripple_rate_min = new_row.Ripple_count/new_row.Duration_in_min;
end

%Check if columns have Staba Ripple info
if any(strcmp(col_names,'Staba_Ripple_count'))
    %Ripple data
    new_row.Staba_Ripple_count = sum(cell2mat(T.Staba_Ripple_count));
    new_row.Staba_Ripple_rate_sec = new_row.Staba_Ripple_count/new_row.Duration_in_sec;
    new_row.Staba_Ripple_rate_min = new_row.Staba_Ripple_count/new_row.Duration_in_min;
end

%Check if columns have SR info
if any(strcmp(col_names,'SR_count'))
    %Spike ripple data
    new_row.SR_count = sum(cell2mat(T.SR_count));
    new_row.SR_rate_sec = new_row.SR_count/new_row.Duration_in_sec;
    new_row.SR_rate_min = new_row.SR_count/new_row.Duration_in_min;
end
end