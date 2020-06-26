
#Create a simulator object
set ns [new Simulator]

#Open the nam file basic1.nam and the variable-trace file basic1.tr
set tracefile [open trace.tr w]
$ns trace-all $tracefile

#Define a 'finish' procedure
proc finish {} {
        global ns namfile tracefile
        $ns flush-trace
        close $tracefile
        exit 0
}

#Create the network nodes
#N3 and N4 are routers
for {set i 0} {$i < 6} {incr i} {   
     set N($i) [$ns node]       
}

proc rand {} {
        set recvr_delay [expr int([expr rand() * 20])];
        set recvr_delay [expr $recvr_delay + 5];
        return $recvr_delay;
}
# set recvr_delay2 [expr int([expr rand() * 20])];
# set recvr_delay2 [expr $recvr_delay2 + 5];

# puts $recvr_delay1;
# puts $recvr_delay2;

#Create links between the nodes
$ns duplex-link $N(0) $N(2) 100Mb 5ms DropTail
$ns duplex-link $N(1) $N(2) 100Mb [rand]ms DropTail

$ns duplex-link $N(2) $N(3) 100Kb 1ms DropTail

$ns duplex-link $N(3) $N(4) 100Mb 5ms DropTail
$ns duplex-link $N(3) $N(5) 100Mb [rand]ms DropTail

# The queue size
$ns queue-limit $N(2) $N(3) 10
$ns queue-limit $N(3) $N(4) 10
$ns queue-limit $N(3) $N(5) 10

# Create a TCP sending agent and attach it
set tcp1 [new Agent/TCP/Newreno]
set tcp2 [new Agent/TCP/Newreno]

# Attaching nodes
$tcp1 set packetSize_ 960
$tcp2 set packetSize_ 960
$ns attach-agent $N(0) $tcp1
$ns attach-agent $N(1) $tcp2

# Let's trace some variables
$tcp1 attach $tracefile
$tcp1 tracevar cwnd_
$tcp1 tracevar ssthresh_
$tcp1 tracevar ack_
$tcp1 tracevar maxseq_
$tcp1 tracevar rtt_

$tcp2 attach $tracefile
$tcp2 tracevar cwnd_
$tcp2 tracevar ssthresh_
$tcp2 tracevar ack_
$tcp2 tracevar maxseq_
$tcp2 tracevar rtt_

#Create a TCP receive agent (a traffic sink) and attach it
set end1 [new Agent/TCPSink]
$ns attach-agent $N(4) $end1
set end2 [new Agent/TCPSink]
$ns attach-agent $N(5) $end2

#Connect the traffic source with the traffic sink
$ns connect $tcp1 $end1
$ns connect $tcp2 $end2

#Set TTL
$tcp1 set ttl_ 64
$tcp2 set ttl_ 64

#Set Fid
$tcp1 set fid_ 0
$tcp2 set fid_ 1

proc save_cwnd { filename source1 source2 } {
        global ns
        set time [$ns now]
        set cwnd1 [$source1 set cwnd_]
        set cwnd2 [$source2 set cwnd_]
        puts $filename "$time $cwnd1 $cwnd2"

        $ns at [expr $time+1] "save_cwnd $filename $source1 $source2"
}

proc save_rtt { filename source1 source2 } {
        global ns
        set time [$ns now]
        set rtt1 [$source1 set rtt_]
        set rtt2 [$source2 set rtt_]
        puts $filename "$time $rtt1 $rtt2"

        $ns at [expr $time+1] "save_rtt $filename $source1 $source2"
}

set myftp1 [new Application/FTP]
$myftp1 attach-agent $tcp1
set myftp2 [new Application/FTP]
$myftp2 attach-agent $tcp2
$ns at 0.0 "$myftp1 start"
$ns at 0.0 "$myftp2 start"
$ns at 100.0 "finish"

#Run the simulation
set fp [open cwnd w+]
save_cwnd $fp $tcp1 $tcp2

set rttfile [open rtt w+]
save_rtt $rttfile $tcp1 $tcp2

$ns run