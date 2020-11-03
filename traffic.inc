

This macro should be run when the state of current light signal, timing
and blocking conditions are not within consideration.
   a) Move out current car to next cell.
   b) Move car into this cell from previous cell with different speed.
      stop(1), low(2), middle(3) and high(4) speed.
   c) for all other cases, no state change.


#BeginMacro(normal_traffic_rule)

rule : {(0,0)}  3000	{ (0,0)=1 and (0, 1)=1 }

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

rule : {(0,0)}	1000	{ t }

#EndMacro


Check whether I'm waiting for timeout notification from time plane.
if so, do onthing before current timing reached. otherwise, when 
timeout happened in time plane, change my state to final state.

#BeginMacro(traffic_timing_rule)
rule : {(0,0)}				1000	{ fractional((0,0))!=0 and (1,0)=0 }
rule : {trunc(fractional((0,0))*10)}	0	{ fractional((0,0))!=0 and (1,0)!=0 }
#EndMacro

