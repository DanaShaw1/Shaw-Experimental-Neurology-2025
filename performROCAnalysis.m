function performROCAnalysis(data_T,event_type)
%Get the column names
col_names = data_T.Properties.VariableNames;

%Define the column rate name for the given event type
event_rate_col_name = [event_type,'_rate_min'];

%Determine which column to pull event rates from
rate_col_idx = find(strcmp(event_rate_col_name,col_names));

%Get the non-stroke and stroke rates per min
ns_rates = cell2mat(data_T{strcmp(data_T.Group,'nonstroke'),rate_col_idx});
s_rates = cell2mat(data_T{strcmp(data_T.Group,'stroke'),rate_col_idx});

% ROC curve
labels = [repmat({'ns'}, [length(ns_rates), 1]); ...
    repmat({'s'}, [length(s_rates), 1])];

rates  = [ns_rates; s_rates];

mdl    = fitglm( rates,strcmp(labels, 's'),'Distribution','binomial','Link','logit');
scores = mdl.Fitted.Probability;

[X,Y,T,AUC,OPTROCPT] = perfcurve(labels,scores, 's');
figure
plot(X,Y)
hold on
plot(OPTROCPT(1), OPTROCPT(2), 'ko')
hold off
xlabel('False positive rate')
ylabel('True positive rate')
title([event_type,': ROC for Classification by Logistic Regression, AUC=' num2str(AUC,3)])
grid on

Threshold = T((X==OPTROCPT(1))&(Y==OPTROCPT(2)));
pass_threshold = find(scores >= Threshold);
rate_threshold = min(rates(pass_threshold));
fprintf([event_type,'\n'])
fprintf(['Rate at optimal operating point ' num2str(rate_threshold) '\n'])

model_prediction = zeros(size(rates));
model_prediction(pass_threshold) = 1;
TP = length(find(model_prediction == 1 &  strcmp(labels, 's')));
FP = length(find(model_prediction == 1 & ~strcmp(labels, 's')));
TN = length(find(model_prediction == 0 & ~strcmp(labels, 's')));
FN = length(find(model_prediction == 0 &  strcmp(labels, 's')));
sensitivity = TP / (TP + FN);
specificity = TN / (TN + FP);
PPV         = TP / (TP + FP);
NPV         = TN / (TN + FN);
fprintf(['Sen: ' num2str(sensitivity) ', Spec: ' num2str(specificity) ', PPV: ' num2str(PPV) ', NPV: ' num2str(NPV) '\n'])
text(0.1,0.3,['Sen: ' num2str(sensitivity) ', Spec: ' num2str(specificity) ', PPV: ' num2str(PPV) ', NPV: ' num2str(NPV),', Rate: ', num2str(rate_threshold)]);
fprintf('\n')

end