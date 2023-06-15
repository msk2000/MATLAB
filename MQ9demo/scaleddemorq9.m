clear all
%This is the same code as demomq9 but scaled appropriately
% This is where we generate the V and F matrices from the STL file
[V, F, n, c, stltitle] = stlread('mq9.stl', false);
%Translation of 44 meters in the vertical axis and 5 in the
% y axis to align with the coordinate system
tryz = [0 -5 -44]; 
V = V + tryz;
s = 20/460;
V = s.*V;
%patch slim
[V, F]=patchslim(V, F)

% colors
green = [0 1 0];
colors = ones(size(F));
colors = colors.*green;
%graph
title('MQ-9')
xlabel('North') %label for the x-axis
ylabel('East') %label for the y-axis
zlabel('- Down') %label for the z-axis
view(30,50)  % initial the vieew angle for figure
axis([-30 40,-30 40,-30 40]); % axis limiters for x y & z
grid minor % 

%This is where the vertices are stitched to form the 3D rendering
patch('Vertices',V,'Faces',F,'FaceVertexCData', colors,'FaceColor','flat')