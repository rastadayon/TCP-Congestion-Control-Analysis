
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

for {set i 1} {$i < 7} {incr i} {   
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
$ns duplex-link $N(1) $N(3) 100Mb 5ms DropTail
$ns duplex-link $N(2) $N(3) 100Mb $recvr_delay1 DropTail

$ns duplex-link $N(3) $N(4) 100Kb 1ms DropTail

$ns duplex-link $N(4) $N(5) 100Mb 5ms DropTail
$ns duplex-link $N(4) $N(6) 100Mb $recvr_delay2 DropTail

# The queue size at $R is to be 7, including the packet being sent
# $ns queue-limit $R $B 10
$ns queue-limit $N(3) $N(4) 10
$ns queue-limit $N(4) $N(5) 10
$ns queue-limit $N(4) $N(6) 10


# some hints for nam
# color packets of flow 0 red
$ns color 0 Red
$ns duplex-link-op $N(1) $N(3) orient right
$ns duplex-link-op $N(2) $N(3) orient up
$ns duplex-link-op $N(4) $N(5) orient left
$ns duplex-link-op $N(4) $N(6) orient down
$ns duplex-link-op $N(3) $N(4) orient right
$ns duplex-link-op $N(4) $N(5) queuePos 0.5
$ns duplex-link-op $N(4) $N(6) queuePos 0.5
$ns duplex-link-op $N(3) $N(4) queuePos 0.5

# Create a TCP sending agent and attach it to A
# set tcp0 [new Agent/TCP/Reno]
set tcp1 [new Agent/TCP/Reno]
set tcp2 [new Agent/TCP/Reno]

# We make our one-and1-only flow be flow 0
# $tcp0 set class_ 0
$tcp1 set packetSize_ 960
$tcp2 set packetSize_ 960
$ns attach-agent $N(1) $tcp1
$ns attach-agent $N(2) $tcp2

# Let's trace some variables
$tcp1 attach $tracefile
$tcp1 tracevar cwnd_
$tcp1 tracevar ssthresh_
$tcp1 tracevar ack_
$tcp1 tracevar maxseq_

$tcp2 attach $tracefile
$tcp2 tracevar cwnd_
$tcp2 tracevar ssthresh_
$tcp2 tracevar ack_
$tcp2 tracevar maxseq_

#Create a TCP receive agent (a traffic sink) and attach it to B
set end1 [new Agent/TCPSink]
$ns attach-agent $N(5) $end1
set end2 [new Agent/TCPSink]
$ns attach-agent $N(6) $end2

#Connect the traffic source with the traffic sink
$ns connect $tcp1 $end1
$ns connect $tcp2 $end2

#Schedule the connection data flow; start sending data at T=0, stop at T=10.0

$tcp1 set _ttl 64
$tcp2 set _ttl 64

set myftp1 [new Application/FTP]
$myftp1 attach-agent $tcp1
set myftp2 [new Application/FTP]
$myftp2 attach-agent $tcp2
$ns at 0.0 "$myftp1 start"
$ns at 0.0 "$myftp2 start"
$ns at 1000.0 "finish"

#Run the simulation
$ns run