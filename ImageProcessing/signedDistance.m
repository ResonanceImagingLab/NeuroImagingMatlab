function signedDis = signedDistance(img)

% Takes an input image and outputs a signed distance (level set) map.
% This isn't going to be pretty, but it was made to work with matlabs
% algorithms already implemented.

% We maintain the convention that positive is inside, and negative is
% outside the object

% Christopher Rowley 2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if max(img(:)) > 1 || min(img(:)) < 0
    error( "Input must contain only 0 and 1")
end

% Use bwdist to compute distance. Issue is that it only calculates exterior
% distance. Generate an inverse binary map and compute distance on both.

imgIn = double(~img);

dout = bwdist(img);
din = bwdist(imgIn);

signedDis = zeros(size(img));
signedDis(img == 0) = -1* dout(img == 0);
signedDis(imgIn == 0) = din(imgIn == 0);

end