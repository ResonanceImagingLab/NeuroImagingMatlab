function Image = makeSyntheticFLASHimg( T1, M0, TR, flipAngle, mask, b1)

% given a T1 and M0 map, create synthetic FLASH image based on TR and flip
% angle
%% provide flip angle in degrees


if isempty(mask)
    mask = ones(size(T1));
end

if isempty(b1)
    b1 = ones(size(T1));
end


%setup vectors
B1_vector = 0.005:0.025:1.9; % get B1 contour map style artifact in sat maps with higher increment

if (TR > 5) %working in seconds
    T1_vector = (0.5:0.015:5); 
else % assume milliseconds
    T1_vector = (0.5:0.015:5) *1000; 
end

SignalMatrix = zeros(length(B1_vector), length(T1_vector));


% calculate the lookup table
for i = 1:length(B1_vector)
    for j = 1:length(T1_vector)     
         SignalMatrix(i,j) = FLASH_solver(flipAngle, TR, B1_vector(i), T1_vector(j));
    end
end


%% Now fit the image using gridded interpolant
% matrix values (MTsat) are defined by vectors: B1, T1 and MTw signal
[b, t] = ndgrid(B1_vector, T1_vector);
F = griddedInterpolant(b ,t, SignalMatrix);

%% Turn the images into vectors then fit
q = find( (mask(:)>0));
b1_v = b1(q);
t1_v = T1(q);
m0_v = M0(q);

img = F(b1_v, t1_v);
img(isnan(img)) = 0;
img(isinf(img)) = 0;
img(img <0) = 0;

Image = zeros( size(T1));
Image(q) = img.* m0_v;





function Sig= FLASH_solver(flipAngle, TR, b1, T1)
    
    flip_a = (flipAngle*b1) * pi / 180; % correct for B1 and convert to radians
    x = cos(flip_a) ;
    y = exp(-TR/T1);
    
    % Solve for magnetization
    M = (1-y) ./ (1-x*y);
    
    % We read out the value M with sin(flip)
    Sig = sin(flip_a) * M;
