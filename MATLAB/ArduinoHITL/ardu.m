function [aileron, elevator, rudder, flap] = ardu(uu)
% function [aileron, elevator, rudder] = ardu(aileron,elevator,rudder)
global s
global s_a
global s_e
global s_f

aileron = uu(1);
elevator = uu(2);
rudder = uu(3);
flap = uu(4);

%% For flap
center = 0.5
if flap == 0
    writePosition(s_f, center);
else
    writePosition(s_f,0.9);
end


%% For aileron

map = 2/0.7;
map_ail = aileron/map;
zero_pos = 0.55;

if map_ail == 0
    map_ail=zero_pos; % zero position of the servo
    writePosition(s_a,map_ail);
elseif map_ail<0
        map_ail=zero_pos+map_ail
        writePosition(s_a,map_ail);
else map_ail = zero_pos+map_ail
    writePosition(s_a,map_ail);
end
%% For elevator
map3 = 0.9/2;
map_elev = elevator*map3;
zero_pos3 = 0.5;

if elevator == 0
    map_elev = zero_pos3;
    writePosition(s_e,map_elev);
   
elseif elevator <0
        map_elev = zero_pos3 + map_elev;
        writePosition(s_e,map_elev);
else map_elev = zero_pos3 + map_elev;
   
    writePosition(s_e,map_elev);
end



%% For rudder

map2 = 1/2;
map_rud = rudder*map2;
zero_pos2 = 0.5;

if rudder == 0
    map_rud = zero_pos2;
    fprintf('map_rud')
    writePosition(s,map_rud);
   
elseif rudder <0
        map_rud = zero_pos2 + map_rud;
        fprintf('map_rud')
        writePosition(s,map_rud);
else map_rud = zero_pos2 + map_rud;
    fprintf('map_rud')
    writePosition(s,map_rud);
end
end