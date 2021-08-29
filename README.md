# TCP Congestion Control Analysis

In this repository we have simulated a network with the following topology. Also the following conditions hold for the network at all times:
- The flow from node 1 to 5 and 2 to 6 is constant
- Queue size in all routers equals to 10 packets
- TTL is always equal to 64
- Network capacity is considered to be constant. Packet size is equal to the default size in NS2 which is 1000 bytes. The protocol used is IPV4.
- For variables such as initial window size, maximum window size, etc. default values of NS2 are used.

<img src="project description/topology.png" alt="topology" width="400" align="center"/>

The following factors are observed:
- Changes in congestion window size
- Goodput rate
- Packet loss rate
- Round-trip time rate