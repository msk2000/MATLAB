%Use this function to rotate every vertex of the imported STL 
%through the 3 axis
function vpoints=rotate(vpoints,phi,theta,psi)

  % We are using a right hand rotation. Use appropriate rotation matrices
  % here. See details: https://mathworld.wolfram.com/RotationMatrix.html
  RollMat = [1 0 0; 0 cos(phi) sin(phi); 0 -sin(phi) cos(phi)];
  PitchMat = [cos(theta) 0 -sin(theta); 0 1 0; sin(theta) 0 cos(theta)];
  YawMat = [cos(psi) sin(psi) 0; -sin(psi) cos(psi) 0; 0 0 1];
  %Make your rotation matrix
  R = RollMat*PitchMat*YawMat;  
  % Make it right-handed 
  R = R';

  % Simply multiply vpoints with the above Rotation Matrix (R)
  vpoints = R*vpoints;
  
end