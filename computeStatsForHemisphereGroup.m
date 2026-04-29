function stats_glme = computeStatsForHemisphereGroup(data_T,event_type)
%Get the column names
col_names = data_T.Properties.VariableNames;

%Define the column rate name for the given event type
event_count_col_name = [event_type,'_count'];

%Determine which column to pull event rates from
count_col_idx = find(strcmp(event_count_col_name,col_names));

%% Convert table values from cells to matrices

data_T.Days_since_stroke = cell2mat(data_T.Days_since_stroke);
data_T.(event_count_col_name) = cell2mat(data_T.(event_count_col_name));
data_T.Duration_in_sec = cell2mat(data_T.Duration_in_sec);
data_T.Hour = str2double(data_T.Hour);

%% Split tables into hemisphere group

%Seperate the data table by experimental group
stroke_T = data_T(1:394,:);
rb_T = data_T(395:440,:);
saline_T = data_T(441:end,:);

%Seperate stroke table into stroke and nonstroke hemispheres
stroke_hemi_T = stroke_T(strcmp(stroke_T.Group,'stroke'),:);
nonstroke_hemi_T = stroke_T(strcmp(stroke_T.Group,'nonstroke'),:);

%% Stack tables for GLMEs

%non-stroke vs Stroke
nonstroke_stroke_T = [nonstroke_hemi_T;stroke_hemi_T];

%saline vs stroke
saline_stroke_T = [saline_T;stroke_hemi_T];

%non-stroke vs saline
nonstroke_saline_T = [nonstroke_hemi_T;saline_T];

%RB vs stroke
RB_stroke_T = [rb_T;stroke_hemi_T];

%non-stroke vs RB
nonstroke_RB_T = [nonstroke_hemi_T;rb_T];

%RB vs saline
RB_saline_T = [rb_T;saline_T];

%% Fit GLMEs and extract stats

%non-stroke vs Stroke
nonstroke_stroke_glme = fitglme(nonstroke_stroke_T,[event_count_col_name,' ~ 1 + Group + Days_since_stroke + Hour + (1|Mouse_ID)'],'Distribution','Poisson','Weights',round(nonstroke_stroke_T.Duration_in_sec),'DispersionFlag',true,'Link','log');
nonstroke_stroke_glme_stats_T = summaryStatsGLME(nonstroke_stroke_glme);

%saline vs stroke
saline_stroke_glme = fitglme(saline_stroke_T,[event_count_col_name,' ~ 1 + Group + Days_since_stroke + Hour + (1|Mouse_ID)'],'Distribution','Poisson','Weights',round(saline_stroke_T.Duration_in_sec),'DispersionFlag',true);
stroke_saline_glme_stats_T = summaryStatsGLME(saline_stroke_glme);

%non-stroke vs saline
nonstroke_saline_glme = fitglme(nonstroke_saline_T,[event_count_col_name,' ~ 1 + Group + Days_since_stroke + Hour + (1|Mouse_ID)'],'Distribution','Poisson','Weights',round(nonstroke_saline_T.Duration_in_sec),'DispersionFlag',true);
nonstroke_saline_glme_stats_T = summaryStatsGLME(nonstroke_saline_glme);

%RB vs stroke
RB_stroke_glme = fitglme(RB_stroke_T,[event_count_col_name,' ~ 1 + Group + Days_since_stroke + Hour + (1|Mouse_ID)'],'Distribution','Poisson','Weights',round(RB_stroke_T.Duration_in_sec),'DispersionFlag',true);
stroke_RB_glme_stats_T = summaryStatsGLME(RB_stroke_glme);

%non-stroke vs RB
nonstroke_RB_glme = fitglme(nonstroke_RB_T,[event_count_col_name,' ~ 1 + Group + Days_since_stroke + Hour + (1|Mouse_ID)'],'Distribution','Poisson','Weights',round(nonstroke_RB_T.Duration_in_sec),'DispersionFlag',true);
nonstroke_RB_glme_stats_T = summaryStatsGLME(nonstroke_RB_glme);

%RB vs saline
RB_saline_glme = fitglme(RB_saline_T,[event_count_col_name,' ~ 1 + Group + Days_since_stroke + Hour + (1|Mouse_ID)'],'Distribution','Poisson','Weights',round(RB_saline_T.Duration_in_sec),'DispersionFlag',true);
RB_saline_glme_stats_T = summaryStatsGLME(RB_saline_glme);

%% Put everything into containers

%non-stroke vs Stroke
nonstroke_stroke.glme = nonstroke_stroke_glme;
nonstroke_stroke.glme_stats = nonstroke_stroke_glme_stats_T;

%saline vs stroke
saline_stroke.glme = saline_stroke_glme;
saline_stroke.glme_stats = stroke_saline_glme_stats_T;

%non-stroke vs saline
nonstroke_saline.glme = nonstroke_saline_glme;
nonstroke_saline.glme_stats = nonstroke_saline_glme_stats_T;

%RB vs stroke
RB_stroke.glme = RB_stroke_glme;
RB_stroke.glme_stats = stroke_RB_glme_stats_T;

%non-stroke vs RB
nonstroke_RB.glme = nonstroke_RB_glme;
nonstroke_RB.glme_stats = nonstroke_RB_glme_stats_T;

%RB vs saline
RB_saline.glme = RB_saline_glme;
RB_saline.glme_stats = RB_saline_glme_stats_T;


%%%%%%% put in return variable %%%%%%%
stats_glme.nonstroke_stroke = nonstroke_stroke;
stats_glme.saline_stroke = saline_stroke;
stats_glme.nonstroke_saline = nonstroke_saline;
stats_glme.RB_stroke = RB_stroke;
stats_glme.nonstroke_RB = nonstroke_RB;
stats_glme.RB_saline = RB_saline;

end