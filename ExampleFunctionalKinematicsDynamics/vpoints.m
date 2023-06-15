% The inputs n,e & d provide the surge/sway/heave translational inputs to
% inform where in the 3D space the points of the vertices (vpoints) moved to. The
% following function handles that transformation
function vpoints = translate(vpoints,n,e,d)
% The n,e&d inputs are the amounts by which the vpoints need to move. That
% move is to be made from previous-vpoints to current-vpoints by updating
% it with the n,e&d inputs.

  vpoints = vpoints + repmat([n;e;d],1,size(vpoints,2));
  
end