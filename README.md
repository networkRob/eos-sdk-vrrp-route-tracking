# EOS SDK VRRP Route Tracking

This EOS SDK Agent is used to modify the VRRP Priority-levels on a single node. The actions are based on a tracked route. The node will be VRRP Master if the next-hop for the route is on either an Ethernet Interface or Port-Channel.


## Switch Setup

### Install
1. Copy `VRRPRouteTracking-x.x.x-x.swix` to `/mnt/flash/` on the switch or to the `flash:` directory.
2. Copy and install the `.swix` file to the extensions directory from within EOS.  Below command output shows the copy and install process for the extension.
```
L3-L11#copy flash:VRRPRouteTracking-0.2.1-3.swix extension:
Copy completed successfully.
L3-L11#sh extensions
Name                                Version/Release      Status      Extension
----------------------------------- -------------------- ----------- ---------
VRRPRouteTracking-0.2.1-3.swix      0.2.1/3              A, NI       1


A: available | NA: not available | I: installed | NI: not installed | F: forced
S: valid signature | NS: invalid signature
The extensions are stored on internal flash (flash:)
L3-L11#extension VRRPRouteTracking-0.2.1-3.swix
L3-L11#show extensions
Name                                Version/Release      Status      Extension
----------------------------------- -------------------- ----------- ---------
VRRPRouteTracking-0.2.1-3.swix      0.2.1/3              A, I        1


A: available | NA: not available | I: installed | NI: not installed | F: forced
S: valid signature | NS: invalid signature
The extensions are stored on internal flash (flash:)
```
3. In order for the extension to be installed on-boot, enter the following command:
```
L3-L11#copy installed-extensions boot-extensions
Copy completed successfully.
```

### VRRP Route Tracking Agent Configuration
1. In EOS config mode perform the following commands for basic functionality (see step #4 for further customization):
```
config
daemon VRRPRouteTracking
exec /usr/bin/VRRPRouteTracking
no shutdown
```

2. By default, the agent has the following default values:
- master = 110
- standby = 90

To modify the default behavior, use the following commands to override the defaults:
```
config
daemon VRRPRouteTracking
option master value {master_value}
option standby value {standby_value}
```
**`master_value` **(optional)** Specify a specific priority level for the node to become the VRRP Master**
**`standby_value` **(optional)** Specify a specific priority level for the node to become the VRRP Backup**

3. To add VLANs and VRRP IDs to be modified for priority-level, the following commands will need to be added to the agent config:
```
config
daemon VRRPRouteTracking
option vlan{vlan_id} value {vrrp_id}
```
**`vlan_id` needs to be the VLAN ID for the VLAN interface that has the VRRP config. (integer)**

**`vrrp_id` needs to be the VRRP ID number configured for the appropriate VLAN Interface config. (integer)**

4. In order for this agent to create a static kernel route for specific destinations, the following commands will need to be taken:
```
config
daemon VRRPRouteTracking
option {destination_name} value {ip_of_destination}
```
**`destination_name` needs to be a unique identifier for each remote switch/device**

**`ip_of_destination` needs to be a valid IPv4 address for the destination address for the route to be created**

***To see what unique peer identifiers have been created, enter `show daemon VRRPRouteTracking`***

Example of a full `daemon VRRPRouteTracking` config would look like with all parameters specified
```
daemon VRRPRouteTracking
   exec /usr/bin/VRRPRouteTracking
   option master value 115
   option standby value 95
   option vlan101 value 1
   option remote-host1 value 10.0.2.11
   no shutdown
!
```


#### Sample output of `show daemon VRRPRouteTracking`
```
L3-L11#sh daemon VRRPRouteTracking
Agent: VRRPRouteTracking (running with PID 20403)
Uptime: 0:27:36 (Start time: Wed May 18 20:46:39 2022)
Configuration:
Option             Value
------------------ ---------
master             115
remote-track       10.0.2.11
vlan101            1

Status:
Data                   Value
---------------------- -------------------------------------------
Master-Priority        115
Standby-Priority       90
VRF                    default
remote-track           10.0.2.10/31 network via Ethernet3 next-hop
vlan101                master
```
