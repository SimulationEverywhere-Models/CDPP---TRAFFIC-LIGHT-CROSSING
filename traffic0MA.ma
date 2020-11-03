#include(traffic.inc)

[top]
components : light_controller
components : gen@Generator
components : traffic

%out : light_ab light_cd
%link : light_ab@light_controller light_ab
%link : light_cd@light_controller light_cd
link : light_ab@light_controller light@traffic

out : car_in
link : out@gen	car_in@traffic
link : out@gen car_in
%in : in
%link : in car_in@traffic
%link : in car_in

out : in_space
link : in_space@traffic in_space
link : in_space@traffic out_space@traffic

out : car_out
link : car_out@traffic car_out

[gen]
distribution : poisson
mean : 10
initial : 1
increment : 0	% all cars enter the lane with "stop" speed.


[traffic]
type : cell
height : 4
width : 20
delay : inertial
defaultDelayTime  : 1000
border : nowrapped
neighbors :                traffic(-3,0)
neighbors :                traffic(-2,0)
neighbors :                traffic(-1,0)
neighbors : traffic(0,-1)  traffic(0,0)  traffic(0,1) traffic(0,2) traffic(0,3)
neighbors :                traffic(1,0)
neighbors :                traffic(2,0)
neighbors :                traffic(3,0)
initialvalue : 0

initialrowvalue :  0      10101000100001001010 
initialrowvalue :  1      00000000000000000000 
initialrowvalue :  2      77777777777777777777 
initialrowvalue :  3      00000000000000000000

localTransition : traffic_rule

zone : time_plane_rule { (1,0)..(1,19) }
zone : general_plane_update_rule { (2,0)..(2,19) (3,0)..(3,19) }
zone : lane_beginning_rule { (0,0) }
zone : lane_end_rule1 { (0,19) }
zone : lane_end_rule2 { (0,18) }
zone : lane_end_rule3 { (0,17) }


in : light
link : light light@traffic(2,19)
portInTransition : light@traffic(2,19) light_change_rule

out : in_space
link : in_space@traffic(0,0) in_space

out : car_out
link : car_out@traffic(0,19) car_out

in : car_in
link : car_in car_in@traffic(0,0)
portInTransition : car_in@traffic(0,0) car_in_rule

in : out_space	% space indication from next lane/intersection
link : out_space out_space@traffic(3,19)
portInTransition : out_space@traffic(3,19) out_speed_change_rule



% NOTE:
% 0 - no car
% 1 - stop car		3s
% 2 - low speed car	2s
% 3 - middle speed car	1s
% 4 - hight speed car	0.5s
%
% Signal from light port
% 5 - GREEN
% 6 - YELLOW
% 7 - RED

[car_in_rule]
#macro(traffic_timing_rule)
%rule : 0	0	{ time < 0 }
rule : {portValue(thisPort)+send(in_space,0)} 0 { (0,0)=0 and portValue(thisPort)<=4 and portValue(thisPort)>=1}
rule : 1.03	10	{ (0,0)=1 and (0,1)=0}
rule : 2.02	10	{ (0,0)=2 and (0,1)=0}
rule : 3.01	10	{ (0,0)=3 and (0,1)=0}
rule : 4.005	10	{ (0,0)=4 and (0,1)=0}
%rule : {(0,0)}	0	{ t }


[light_change_rule]
rule : 5		0	{ portValue(thisPort)=5 }
rule : 6		0	{ portValue(thisPort)=6 }
rule : 7		0	{ portValue(thisPort)=7 }
rule : { (0,0) }	1000	{ t }


[out_speed_change_rule]
rule : 0		0	{ portValue(thisPort)=0 }
rule : 1		0	{ portValue(thisPort)=1 }
rule : 2		0	{ portValue(thisPort)=2 }
rule : 3		0	{ portValue(thisPort)=3 }
rule : 4		0	{ portValue(thisPort)=4 }
rule : { (0,0) }	1000	{ t }



[general_plane_update_rule]
%
% except the signal inject point, all other cells change 
% their states according to its neighbors
%
rule : { (0,0) } 0 { cellpos(1)=19 }
rule : { (0,1) } 0 { t }


[time_plane_rule]
%
% When its traffic cell neighbor change its state from x to x.xx, I start
% timing according to the value of traffic neighbor. when timeout occur,
% I change my state to non-zero to notify my traffic neighbor.
%
% When I'm wait for timeout, if my time neighbor changed, because I do not
% change my state,  cd++ will automatically continute my previous delay.
%
rule : 9  { round(fractional(10*(-1, 0))*100)*100 - 10} { fractional((-1, 0))!=0 }
%
% When my traffic neighbor got my notification, it should change its state
% from x.xxx to y, so I can get notification to return to zero state. When
% I change to zero state, my traffic neighbor can have chance to do its action
% after it changed to y state.
%
rule : 0  0 { t }



[lane_beginning_rule]
#macro(traffic_timing_rule)
%
% These rules are for wrapped border: When in red light, if any car exists
% at the end of lane, don't change my state to indicate that car move into
% my cell.
%
%rule : 0	1000	 { (2,0)=7 and (0,-1)=1 and (0,0)=0 }
%rule : 0	1000	 { (2,0)=7 and (0,-1)=2 and (0,0)=0 }
%rule : 0	1000	 { (2,0)=7 and (0,-1)=3 and (0,0)=0 }
%rule : 0	1000	 { (2,0)=7 and (0,-1)=4 and (0,0)=0 }
%
%
% these rules are for nowrapped border:
% 1> totally blocked case.
rule : {1.030}			10 { isUndefined((0,-1)) and (1,0)=0 and (0,0)=1 and trunc((0,1))=0}
rule : {2.020}                  10 { isUndefined((0,-1)) and (1,0)=0 and (0,0)=2 and trunc((0,1))=0}
rule : {3.010}                  10 { isUndefined((0,-1)) and (1,0)=0 and (0,0)=3 and trunc((0,1))=0}
rule : {4.005}                  10 { isUndefined((0,-1)) and (1,0)=0 and (0,0)=4 and trunc((0,1))=0}
% 2> one space case.
rule : {(0,0)+send(in_space, 1)} 0 { isUndefined((0,-1)) and (1,0)!=0 and (0,0)=0 and trunc((0,1))!=0}
% 3> two spaces case.
rule : {(0,0)+send(in_space, 2)} 0 { isUndefined((0,-1)) and (1,0)=0 and (0,0)=0 and (0,1)=0 and trunc((0,2))!=0 and fractional((0,2))!=0}
% 4> three spaces case.
rule : {(0,0)+send(in_space, 3)} 0 { isUndefined((0,-1)) and (1,0)=0 and (0,0)=0 and (0,1)=0 and (0,2)=0 and trunc((0,3))!=0 and fractional((0,3))!=0}
% 5> totally free case.
rule : {(0,0)+send(in_space, 4)} 0 { isUndefined((0,-1)) and (1,0)=0 and (0,0)=0 and (0,1)=0 and (0,2)=0 and trunc((0,3))=0}
%
%
#macro(normal_traffic_rule)


[lane_end_rule1]
%
%#macro(traffic_timing_rule)
rule : {(0,0)}				1000	{ fractional((0,0))!=0 and (1,0)=0 }
rule : {trunc(fractional((0,0))*10)}	0	{ fractional((0,0))!=0 and (1,0)!=0 }
%
% These are moving forward rules when yellow/red light.
% if cannot stop safely, do the same as green light.
%
rule : {(0,0)}			00	 { (2,0)!=5 and (0,0)=1 } % can stop safely, stop here
%
rule : {2.02+send(car_out, 1)}	10	 { (2,0)!=5 and (0,0)=2 and (3,0)=0 } % 0 space ahead, slowdown/crash? 
rule : {2.02+send(car_out, 1)}	10	 { (2,0)!=5 and (0,0)=2 and (3,0)=1 } % 1 space ahead, slow down
rule : {2.02+send(car_out, 2)}	10	 { (2,0)!=5 and (0,0)=2 and (3,0)=2 } % 2 space ahead, keep speed
rule : {2.02+send(car_out, 3)}	10	 { (2,0)!=5 and (0,0)=2 and (3,0)>2 } % 3 and more space ahead, speed up
%
rule : {3.01+send(car_out, 2)}	10	 { (2,0)!=5 and (0,0)=3 and (3,0)=0 } % 0 space ahead, slowdown/crash?
rule : {3.01+send(car_out, 2)}	10	 { (2,0)!=5 and (0,0)=3 and (3,0)<3 } % 1 or 2 space ahead, slow down
rule : {3.01+send(car_out, 3)}	10	 { (2,0)!=5 and (0,0)=3 and (3,0)=3 } % 3 space ahead, keep speed
rule : {3.01+send(car_out, 4)}	10	 { (2,0)!=5 and (0,0)=3 and (3,0)>3 } % 4 and more space ahead, speed up
%
rule : {4.005+send(car_out, 3)}	10	 { (2,0)!=5 and (0,0)=4 and (3,0)=0 } % 0 space ahead, slowdown/crash?
rule : {4.005+send(car_out, 3)}	10	 { (2,0)!=5 and (0,0)=4 and (3,0)<4 } % 1/2/3 space ahead, slow down
rule : {4.005+send(car_out, 4)}	10	 { (2,0)!=5 and (0,0)=4 and (3,0)>3 } % 4 and more space ahead, keep speed
%
% These are moving forward rules when green light 
%
rule : {(0,0)}			00	 { (0,0)=1 and (3,0)=0 } % 0 space ahead, stop here
rule : {1.03+send(car_out,1)}	10	 { (0,0)=1 and (3,0)=1 } % 1 space ahead, go head
rule : {1.03+send(car_out,2)}	10	 { (0,0)=1 and (3,0)>2 } % 2 and more space ahead, speed up
%
rule : {2.02+send(car_out,1)}	10	 { (0,0)=2 and (3,0)<2 } % 0/1 space ahead, slowdown/crash
rule : {2.02+send(car_out,2)}	10	 { (0,0)=2 and (3,0)=2 } % 2 space ahead, keep speed
rule : {2.02+send(car_out,3)}	10	 { (0,0)=2 and (3,0)>2 } % 3 and more space ahead, speed up
%
rule : {3.01+send(car_out,2)}	10	 { (0,0)=3 and (3,0)<3 } % 0/1/2 space ahead, slowdown/crash
rule : {3.01+send(car_out,3)}	10	 { (0,0)=3 and (3,0)=3 } % 3 space ahead, keep speed
rule : {3.01+send(car_out,4)}	10	 { (0,0)=3 and (3,0)>3 } % 4 and more space ahead, speed up
%
rule : {4.005+send(car_out,2)}	10	 { (0,0)=4 and (3,0)<4 } % 0/1/2/3 space ahead, slowdown/crash
rule : {4.005+send(car_out,3)}	10	 { (0,0)=4 and (3,0)>=4 } % 4 and more space ahead, keep speed
%
% These are moving_here rules for yellow/red light.
% if cannot stop safely, do the same as green light.
%
rule : 0.13	10	 { (2,0)!=5 and (0,-1)=1 and (0,0)=0 } % can stop safely
rule : 0.12	10	 { (2,0)!=5 and (0,-1)=2 and (0,0)=0 } % can stop safely
%rule : 0.12	10	 { (2,0)!=5 and (0,-1)=3 and (0,0)=0 } % cannot stop safely, do as green light.
%rule : 0.12	10	 { (2,0)!=5 and (0,-1)=4 and (0,0)=0 } % cannot stop safely, do as green light.
%
% These are moving_here rules for green light.
rule : 0.13	10	{(0,-1)=1 and (0,0)=0 and (3,0)=0 } % 1 space, keep speed
rule : 0.23	10	{(0,-1)=1 and (0,0)=0 and (3,0)>0 } % 2 and more space, speed up
%
rule : 0.12	10	{(0,-1)=2 and (0,0)=0 and (3,0)<1 } % 1 space, slow down
rule : 0.22	10	{(0,-1)=2 and (0,0)=0 and (3,0)=1 } % 2 space, keep speed
rule : 0.32	10	{(0,-1)=2 and (0,0)=0 and (3,0)>1 } % 3 and more space, speed up
%
rule : 0.21	10	{(0,-1)=3 and (0,0)=0 and (3,0)<2 } % 1/2 space, slow down
rule : 0.31	10	{(0,-1)=3 and (0,0)=0 and (3,0)=2 } % 3 space, keep speed
rule : 0.41	10	{(0,-1)=3 and (0,0)=0 and (3,0)>2 } % 4 and more space, speed up
%
rule : 0.305	10	{(0,-1)=4 and (0,0)=0 and (3,0)<3 } % 1/2/3 space, slow down
rule : 0.405	10	{(0,-1)=4 and (0,0)=0 and (3,0)>=3 } % 4 and more space, keep speed
%
rule : {(0,0)}	00	{ t }


[lane_end_rule2]
#macro(traffic_timing_rule)
%
%
%
rule : 0.22	10	 { (2,0)!=5 and (0,-1)=2 and (0,0)=0 and trunc((0,1))=0 }
rule : 0.21	10	 { (2,0)!=5 and (0,-1)=3 and (0,0)=0 }
#macro(normal_traffic_rule)


[lane_end_rule3]
#macro(traffic_timing_rule)
%
%
%
rule : 0.310	10	 { (2,0)!=5 and (0,-1)=3 and (0,0)=0 and trunc((0,1))=0 and trunc((0,2))=0 }
rule : 0.305	10	 { (2,0)!=5 and (0,-1)=4 and (0,0)=0 }
#macro(normal_traffic_rule)


[traffic_rule]
#macro(traffic_timing_rule)
#macro(normal_traffic_rule)







[light_controller]
type :  cell
height : 1
width : 2
delay : inertial
defaultDelayTime : 1000
border : wrapped
neighbors : light_controller(0,0) light_controller(0,1)

% state : { green(5), yellow(6), red(7), standby(8) }
initialvalue : 7
initialrowvalue : 0 78
localtransition : light_controller_rule

out : light_ab light_cd
link : lights@light_controller(0,0) light_ab
link : lights@light_controller(0,1) light_cd


[light_controller_rule]
rule : 5			1000	{ (0,0)=7 and (0,1)=8}
rule : {6+send(lights,5)}	30000	{ cellpos(1)=1 and (0,0)=5 and (0,1)=7 }
rule : {6+send(lights,5)}	30000	{ cellpos(1)=0 and (0,0)=5 and (0,1)=7 }
rule : {8+send(lights,6)}	3000	{ (0,0)=6 and (0,1)=7 }
rule : {7+send(lights,7)}	1000	{ (0,0)=8 }
rule : 7			0	{ t }
