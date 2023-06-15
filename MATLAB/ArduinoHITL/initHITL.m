%% For Arduino HITL
clear all
global a
global s
global s_a
global s_e
global s_f
a = arduino;
s = servo(a,'D5')
s_a = servo(a,'D3')
s_e = servo(a,'D6')
s_f = servo(a,'D9')