%Pyramid code
%Author: Mahmud Safat Khan
clear all


% Physical location of the vertices on the graph
V = [1 1 0; 1 -1 0; -1 -1 0; -1 1 0; 0 0 -3];
% Defining the 5 surfaces/faces based on the vertices
F = [1 2 3; 1 4 3;1 2 5; 2 3 5; 3 4 5; 4 1 5];

% colors
red = [1 0 0];
green = [0 1 0];
blue = [0 0 1];
yellow = [1 1 0];
colors = [green; green; green;yellow;red;blue];

%for graph
title('Pyramid')
xlabel('x') %label for the x-axis
ylabel('y') %label for the y-axis
zlabel('-z') %label for the z-axis
view(50,20)  % initial the vieew angle for figure
axis([-3 3,-3 3,-4 4]); % axis limiters for x y & z
grid minor % 

%This is where it all is put together into one 3D object
patch('Vertices',V,'Faces',F,'FaceVertexCData', colors,'FaceColor','flat')

