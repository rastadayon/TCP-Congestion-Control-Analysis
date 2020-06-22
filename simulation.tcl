
#Create a simulator object
set ns [new Simulator]

#Open the nam file basic1.nam and the variable-trace file basic1.tr
set namfile [open basic1.nam w]
$ns namtrace-all $namfile
set tracefile [open basic1.tr w]
$ns trace-all $tracefile

#Define a 'finish' procedure
proc finish {} {
        global ns namfile tracefile
        $ns flush-trace
        close $namfile
        close $tracefile
        exit 0
}

#Create the network nodes
# set A [$ns node]
# set R [$ns node]
# set B [$ns node]

for {set i 0} {$i < 6} {incr i} {   
     set N($i) [$ns node]       
}
#N3 and N4 are routers

#Create a duplex link between the nodes

# $ns duplex-link $A $R 10Mb 10ms DropTail
# $ns duplex-link $R $B 800Kb 50ms DropTail

set recvr_delay1 [new RandomVariable/Uniform];
$recvr_delay1 set min_ 5ms
$recvr_delay1 set max_ 25ms

set recvr_delay2 [new RandomVariable/Uniform];
$recvr_delay2 set min_ 5ms
$recvr_delay2 set max_ 25ms

# TODO: make these delays random
#Create links between the nodes
$ns duplex-link $n0 $n2 100Mb 5ms DropTail
$ns duplex-link $n1 $n2 100Mb $recvr_delay1 DropTail

$ns duplex-link $n2 $n3 100Kb 1ms DropTail

$ns duplex-link $n3 $n4 100Mb 5ms DropTail
$ns duplex-link $n3 $n5 100Mb $recvr_delay2 DropTail

# The queue size at $R is to be 7, including the packet being sent
# $ns queue-limit $R $B 10
$ns queue-limit $N3 $N4 10
$ns queue-limit $N4 $N5 10
$ns queue-limit $N4 $N6 10


# some hints for nam
# color packets of flow 0 red
$ns color 0 Red
$ns duplex-link-op $A $R orient right
$ns duplex-link-op $R $B orient right
$ns duplex-link-op $R $B queuePos 0.5

# Create a TCP sending agent and attach it to A
# set tcp0 [new Agent/TCP/Reno]
set tcp1 [new Agent/TCP/Reno]
set tcp2 [new Agent/TCP/Reno]

# We make our one-and1-only flow be flow 0
$tcp0 set class_ 0
$tcp0 set window_ 100
$tcp0 set packetSize_ 960
$ns attach-agent $A $tcp0

# Let's trace some variables
$tcp0 attach $tracefile
$tcp0 tracevar cwnd_
$tcp0 tracevar ssthresh_
$tcp0 tracevar ack_
$tcp0 tracevar maxseq_

#Create a TCP receive agent (a traffic sink) and attach it to B
set end0 [new Agent/TCPSink]
$ns attach-agent $B $end0

#Connect the traffic source with the traffic sink
$ns connect $tcp0 $end0

#Schedule the connection data flow; start sending data at T=0, stop at T=10.0
set myftp [new Application/FTP]
$myftp attach-agent $tcp0
$ns at 0.0 "$myftp start"
$ns at 1000.0 "finish"

#Run the simulation
$ns run