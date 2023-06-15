% Author Mahmud Safat Khan
% This is used to import geometry from STL file and display it in a 3D plot
clear all
% This is where we generate the V and F matrices from the STL file
[V, F, n, c, stltitle] = stlread('cessna.stl', false);

%Translation of 44 meters in the vertical axis and 5 in the
% y axis to align with the coordinate system
%tryz = [0 -5 -44]; 
%V = V + tryz;
% colors
green = [0 1 0];
colors = ones(size(F));
colors = colors.*green;
%graph
title('MQ-9')
xlabel('North') %label for the x-axis
ylabel('East') %label for the y-axis
zlabel('- Down') %label for the z-axis
view(35,45)  % initial the vieew angle for figure
axis([-800 800,-800 800,-800 800]); % axis limiters for x y & z
grid minor % 

%This is where the vertices are stitched to form the 3D rendering
patch('Vertices',V,'Faces',F,'FaceVertexCData', colors,'FaceColor','flat')
