% GEOMETRY INFORMATION : Manipulate this section for your own design

function [V,F,colours] = Geometry

% This is where the location of the vertices are specified in the form of
% triplets.
load V.mat %loading the V matrix from the scaleddemorq9.m file
V = V'; %transposing it to match expected form

% If you however have your own geometry and the vertices information, you
% may load them in via:
% V = [triplet 1; triplet 2;....]'; % the triplets are the coordinates for
% the points

% define faces as a list of vertices numbered above
load F.mat %loading the F matrix from the scaleddemorq9.m file
F = F;

% If you have your own custom geometry, you can create the F matrix here in
% the format:

% F =[triplet;triplet;...so on and on]; % the number of triplets there
% depends on the number of faces your design makes from the vertices

% Color triplets from  https://uk.mathworks.com/help/matlab/ref/colorspec.html
yellow = [1 1 0];
magenta = [1 0 1];
cyan = [0 1 1];
red = [1 0 0];
green = [0 1 0];
blue = [0 0 1];
white = [1 1 1];
black = [0 0 0];

% With these triplets, we can create a matrix (size of F) containing the
% colour information for every face. I am going with just one colour so I do:

bs = ones(size(F)); % This is just to help the size of the colour matrix match the expected matrix size
colours = bs.*green;

%If you need specific color definition for every surface, you may follow
%the format:
%     colours = [...
%     green;...    % color corresponding to the first face
%     .
%     . so on and on
%     red;...     % color corresponding to the last face
%     ];
% This matrix needs to match the size of the F matrix. 
% If you want to play around with gradients and more complex colouring, look up vertexcdata https://uk.mathworks.com/help/matlab/ref/patch.html 
end
  