[top]
components : traffic

[traffic]
type : cell
height : 2
width : 20
delay : inertial
defaultDelayTime  : 1000
border : wrapped 
neighbors :                traffic(-1,0)
neighbors : traffic(0,-1)  traffic(0,0)  traffic(0,1) traffic(0,2) traffic(0,3)
neighbors :                traffic(1,0)
initialvalue : 0
initialrowvalue :  0      10101000100001001010 
initialrowvalue :  1      00000000000000000000 

zone : time_plane_rule { (1,0)..(1,19) }

localtransition : traffic-rule

# NOTA:
# 0 - no car
# 1 - stop car		3s
# 2 - low speed car	2s
# 3 - middle speed car	1s
# 4 - hight speed car	0.5s

[time_plane_rule]
rule : 9  { round(fractional(10*(-1, 0))*100)*100 - 10} { fractional((-1, 0))!=0 }
rule : 0  0 { t }



[traffic-rule]

rule : {(0,0)}  0     { fractional((0,0))!=0 and (1,0)=0}

rule : {trunc(fractional((0,0))*10)}  0  { fractional((0,0))!=0 and (1,0)!=0}

rule : {(0,0)}  4000	{ (0,0)=1 and (0, 1)=1 }

rule : 1.03	10	{ (0, 0) = 1 and (0, 1) = 0 }
rule : 2.02	10	{ (0, 0) = 2 and (0, 1) = 0 }
rule : 3.01	10	{ (0, 0) = 3 and (0, 1) = 0 }
rule : 4.005	10	{ (0, 0) = 4 and (0, 1) = 0 }

rule : 0.13	10	{ (0,-1) = 1 and (0, 0) = 0 and trunc((0, 1))=1 }
rule : 0.23	10	{ (0,-1) = 1 and (0, 0) = 0 and trunc((0, 1))!=1 }

rule : 0.12	10	{ (0,-1) = 2 and (0, 0) = 0 and trunc((0, 1))=1 }
rule : 0.22	10	{ (0,-1) = 2 and (0, 0) = 0 and trunc((0, 1))=2 }
rule : 0.32	10	{ (0,-1) = 2 and (0, 0) = 0 and trunc((0, 1))!=0 }
rule : 0.22	10	{ (0,-1) = 2 and (0, 0) = 0 and trunc((0,2))=1 }
rule : 0.32	10	{ (0,-1) = 2 and (0, 0) = 0 and trunc((0,2))!=1 }

rule : 0.21	10	{ (0,-1) = 3 and (0, 0) = 0 and trunc((0, 1))!=0 }
rule : 0.21	10	{ (0,-1) = 3 and (0, 0) = 0 and (trunc((0,2))=1 or trunc((0,2))=2) }
rule : 0.31	10	{ (0,-1) = 3 and (0, 0) = 0 and trunc((0,2))!=0 }
rule : 0.31	10	{ (0,-1) = 3 and (0, 0) = 0 and trunc((0,3))=1 }
rule : 0.41	10	{ (0,-1) = 3 and (0, 0) = 0 and trunc((0,3))!=1 }

rule : 0.305	10	{ (0,-1) = 4 and (0, 0) = 0 and (trunc((0, 1))!=0 or trunc((0,2))!=0) }
rule : 0.405	10	{ (0,-1) = 4 and (0, 0) = 0 and trunc((0,3))=4 }
rule : 0.305	10	{ (0,-1) = 4 and (0, 0) = 0 and trunc((0,3))!=0 }
rule : 0.405	10	{ (0,-1) = 4 and (0, 0) = 0 and trunc((0,3))=0 }

rule : { (0, 0) }	1000	{ t }