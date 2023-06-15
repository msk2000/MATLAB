%This is where carry out the plotting/drawing/rendering via the patch
%function. Use of handle in graphics is presented in Appendix C (Animation in
%Simulink) of Small Unmanned Aircraft Theory & Practice (Beard & McLain
%2012). The sample code has been adapted to fit this particular demo.
function handle = Render(V,F,colours,n,e,d,phi,theta,psi,handle)
% this uses the rotate.m file to rotate the geometry
% As shown in this example (http://planning.cs.uiuc.edu/node99.html),
% we first rotate and then translate
V = rotate(V, phi, theta, psi);
% this uses the translate.m file to translate the geometry
V = translate(V, n, e, d);  
% Axis transformation 
% The second row of R needs modification for this specific STL(mq9.stl)
% as we need to rotate about the z-axis. It is set to -1 0 0 instead of 1 0 0 for the 
% necessary rotation to match the MATLAB coordinate system.
%R = [1 0 0 ; 1 0 0; 0 0 1];
%V = R*V; % The V matrix transformed


% During the initialisation, the first drawing is made when the handle
% is empty (empty array passed to handle/see input argument for render in the
% if statement for t==0 set to []). 
if isempty(handle)
handle = patch('Vertices', V', 'Faces', F,'FaceVertexCData',colours,'FaceColor','flat');
% The rendering is done repeatedly for every step in time by simply changing
% the property of the 
else
set(handle,'Vertices',V','Faces',F);
grid on
drawnow
end
end

