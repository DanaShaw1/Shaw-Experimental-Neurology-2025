function stats_T = summaryStatsGLME(glme)
%Define a variable to hold the effect sizes and the 95% confidence
%intervals
effect_size = cell(glme.NumCoefficients - 1,1);
ci_lower = cell(glme.NumCoefficients - 1,1);
ci_upper = cell(glme.NumCoefficients - 1,1);

%Get the effect size and confidence interval of the effect size
for i = 1:length(effect_size)
    %Get the current beta
    beta = glme.Coefficients.Estimate(i + 1);

    %Get the current standard error
    se = glme.Coefficients.SE(i + 1);

    %Compute the effect size
    effect_size{i} = exp(beta);

    %Compute the lower and upper CI
    ci_lower{i} = exp(beta - 1.97*se);
    ci_upper{i} = exp(beta + 1.97*se);
end

%Put the ci lower and upper into one variable
ci = [ci_lower, ci_upper];

%Get the coefficient names
coefficient = glme.Coefficients.Name(2:end);

%Put the data into a table and print it
stats_T = table(coefficient,effect_size,ci_lower,ci_upper);
end