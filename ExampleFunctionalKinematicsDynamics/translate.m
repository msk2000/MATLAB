% The inputs n,e & d provide the surge/sway/heave translational inputs to
% inform where in the 3D space the points of the vertices (vpoints) moved to. The
% following function handles that.
function vpoints = translate(vpoints,n,e,d)
% The n,e&d inputs are the amounts by which the vpoints need to move. That
% move is to be made from previous-vpoints to current-vpoints by updating
% it with the n,e&d inputs.
% For a given x y z input, we need to create a matrix that when added to
% the vpoints matrix will represent the new position. 
input = [n;e;d]; % These are the n e d values you input through the slx
% The dimensions must match so we use repmat
% (https://uk.mathworks.com/help/matlab/ref/repmat.html#d123e1164936) to
% create and match sizes. We can initialise a matrix based on "input" in a
% similar fashion as shown in the Mathworks examples. In the example a 3 by
% 2 matrix is created from a scaler number (10) by repmat(10,3,2). The
% vpoints matrix is 3x28830 size and so should the updatevpoints .
dim2 = size(vpoints,2); % This will give us the second dimension of vpoints
updatevpoints = repmat(input,1,dim2);
vpoints = vpoints + updatevpoints; % Just add them to get the current pos.


    
end