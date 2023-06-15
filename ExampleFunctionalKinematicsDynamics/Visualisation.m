%This is the function we provide to Simulink to be used as the interpreted 
% Matlab function for the Visual6dof.slx. The following modified code has
% been adapted from Small Unmanned Aircraft Theory & Practice (Beard & McLain
%2012). 
function Visualisation(u,V,F,colours)

% We have 7 inputs (n,e,d,phi,theta,psi and t) to the interpreted matlab
% function in the slx (Visual6dof). 
n       = u(1);       % North position     
e       = u(2);       % East position
d       = u(3);       % Down Position      
phi      = u(4);       % roll angle         
theta    = u(5);       % pitch angle     
psi      = u(6);       % yaw angle      
t        = u(7);       % time

% Persistent variables used to make handle graphics persist between all
% the calls to the various functions. For the patch function:
persistent Vertices
persistent Faces
persistent facecolors
%For the graphics from render.m
persistent render_handle

% This only applies to the initialisation when the simulation time is
% zero and the rendering and Vertices, Faces and facecolors are
% initialised. 
if t==0
figure,
[Vertices,Faces,facecolors] = Geometry;
render_handle = Render(Vertices,Faces,facecolors,n,e,d,phi,theta,psi,[]);
% Axix, labels and grid details for the visuals
title('MQ-9')
xlabel('East')
ylabel('North')
zlabel('-Down')
view(35,45)  % this sets the azimuth and elevation of the view (https://uk.mathworks.com/help/matlab/ref/view.html) 
axis([-3 3,-3 3,-3 3]); % define it based on your geometry and requirements
grid minor
 hold on

% Beyond the initialisation period, we just call the following function
% to keep updating the visuals for every simulation step
else 
    Render(Vertices,Faces,facecolors,n,e,d,phi,theta,psi,render_handle);
    end
end

  





  




