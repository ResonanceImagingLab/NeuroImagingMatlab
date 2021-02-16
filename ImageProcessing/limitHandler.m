function output = limitHandler(input)

input(isinf(input)) = 0;
input(isnan(input)) = 0;
output = input;