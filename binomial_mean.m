function binomial_mean = binomial_mean(proportion,n)
% Calculates mean and standard error of input vector

z = 1.96;
confidence_interval = z * (sqrt((1 / n) * (proportion * (1 - proportion))));
binomial_mean = [proportion confidence_interval];

end