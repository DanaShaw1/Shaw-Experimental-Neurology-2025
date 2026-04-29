function plotViolinComparison(data_T,event_type,scale)

%Find the mouse groups
[mouse_num, mouse_ID] = findgroups(data_T.Mouse_ID);

%Define number of mice
num_mice = length(mouse_ID);

%Initialize the figure
figure
tiledlayout(1,num_mice)

%Go through each stroke mouse
for i = 1:num_mice
    %Get all entries for mouse i
    current_mouse_idx = find(mouse_num == i);
    current_mouse_T = data_T(current_mouse_idx,:);
    
    %Define which column to use for rate depending on the event
    if strcmp(event_type,'SR')
        %Get the rates
        rates = current_mouse_T.SR_rate_min;

        %Convert very low rates to a small number for log scale purposes
        rates(find(cell2mat(rates) <= 1e-10)) = {1e-3};

        %Define y limits
        ylim_vals = [0,3.5];
        ylim_vals_log = [-3,1];
        
    elseif strcmp(event_type,'Spike')
        %Get the rates
        rates = current_mouse_T.Spike_rate_min;

        %Convert very low rates to a small number for log scale purposes
        rates(find(cell2mat(rates) <= 1e-10)) = {1e-2};

        %Define y limits
        ylim_vals = [0,7];
        ylim_vals_log = [-2,1];

    elseif strcmp(event_type,'Ripple')
        %Get the rates
        rates = current_mouse_T.Ripple_rate_min;

        %Convert very low rates to a small number for log scale purposes
        rates(find(cell2mat(rates) <= 1e-10)) = {1e-1};

        %Define y limits
        ylim_vals = [0,10.5];
        ylim_vals_log = [-1,1.5];
    end
    
    %Plot the violin plot
    nexttile
    if strcmp(scale,'log') %Plot in log scale
        violinplot(log10(cell2mat(rates)),current_mouse_T.Group,'ViolinColor',[0 0 0],'ShowData',false);
        ylim(ylim_vals_log)
    else
        violinplot(cell2mat(rates),current_mouse_T.Group,'ViolinColor',[0 0 0],'ShowData',false);
        ylim(ylim_vals)
    end

    title(current_mouse_T.Mouse_ID{1})
    xlim([0.5,2.5])
    
    if i == 1
        if strcmp(scale,'log')
            ylabel([event_type,' rate [log(',event_type,'s/min)]'])
        else
            ylabel([event_type,' rate [',event_type,'s/min]'])
        end
    end
    
    %Get the hemisphere groups
    [hemi_num, hemi_ID] = findgroups(current_mouse_T.Group);
    
    %Plot the scatter on top
    hold on
    for j = 1:length(hemi_ID)
        %Get the current hemisphere
        current_hemi_idx = find(hemi_num == j);
        current_hemi_T = current_mouse_T(current_hemi_idx,:);
        
        %Define which column to use for rate depednding on the event
        if strcmp(event_type,'SR')
            %Get rates
            rates_hemi = current_hemi_T.SR_rate_min;

            %Convert very low rates to a small number for log scale purposes
            rates_hemi(find(cell2mat(rates_hemi) <= 1e-10)) = {1e-3};

        elseif strcmp(event_type,'Spike')
            %Get rates
            rates_hemi = current_hemi_T.Spike_rate_min;

            %Convert very low rates to a small number for log scale purposes
            rates_hemi(find(cell2mat(rates_hemi) <= 1e-10)) = {1e-2};

        elseif strcmp(event_type,'Ripple')
            %Get rates
            rates_hemi = current_hemi_T.Ripple_rate_min;

            %Convert very low rates to a small number for log scale purposes
            rates_hemi(find(cell2mat(rates_hemi) <= 1e-10)) = {1e-1};
        end        

        %Get the x-axis with jitter
        jitter = normrnd(0,0.12,size(rates_hemi));
        x_axis = zeros(size(rates_hemi)) + j + jitter;
        
        %Get the color of the points
        c = cell2mat(current_hemi_T.Days_since_stroke);
        
        %Plot the scatter plot for mouse i with colorbar by days since stroke
        if strcmp(scale,'log')
            scatter(x_axis, log10(cell2mat(rates_hemi)), [], c, 'filled')
        else
            scatter(x_axis, cell2mat(rates_hemi), [], c, 'filled')
        end
        
        %Add the colorbar
        cb = colorbar;
        colormap turbo
        
        %Label the color bar
        cb.Label.String = 'Days since stroke';
        caxis([10 170]);
        cb.Location = 'Manual';
       
        %Only display colorbar once
        if i ~= num_mice
            colorbar off
        end
    end
    
end

%Set the dimensions of the figure
set(gcf,'position',[10,10,1200,400])
end

