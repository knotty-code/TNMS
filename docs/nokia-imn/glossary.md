Source: installation_manual_linux.pdf, pages 76–84.

# Glossary

These glossary entries are intended for the entire Transcend product range and may not apply to this document in particular.

### @CT

@CT is a web-based craft terminal (that is, element manager) software which provides Node Manager web access to hiT 7300 network elements (NEs) in the customer network without the use of a management system. It communicates via SNMP with the NEs and uses the FTPS for upload/download of software or other data configuration (for example, log files).

### 3DES

Triple DES is the common name for the Triple Data Encryption Algorithm (TDEA or Triple DEA) symmetric-key block cipher, which applies the Data Encryption Standard (DES) cipher algorithm three times to each data block.

### Actual Creation State (ACS)

Is the current state of the path which results from the accumulation of the actual creation states of the path's route elements.

### Administration Console

A command line interface to issue administrative commands. In Linux root or TNMS user shell, in Windows, TNMS provided admin-console.

### Advanced Encryption Standard (AES)

Is a specification for the encryption of electronic data. AES is based on a design principle known as a substitution-permutation network, and is fast in both software and hardware.

### Alarm

An alarm is a management mechanism intended to inform the user that there is a standing fault condition in the system.

### Alarm log

An alarm log provides a list of the alarms associated with a managed object, and provides the following information about each of the alarms:

- the identification of the affected object
- the location and the affected traffic
- the identification of the failed NE or the NE in which the failed unit resides
- the alarm severity
- the time the event occurred
- the indication of whether the alarmed event is service affecting or not

### Alarm severity

Each failure is assigned a severity. The following values are used:

- indeterminate
- critical
- major
- minor
- warning
- cleared alarms
- not Existent
- not Alarmed

### Alien wavelength

A wavelength that does not originate from a managed transponder or muxponder card, but is still allowed to be multiplexed into the aggregate line signal for transport as an optical channel by the system.

### Automatic Laser Shutdown (ALS)

Is a technique used to automatically shut down the output power of the transmitter in case of fiber break. This is a safety feature that prevents dangerous levels of laser light from leaking out of a broken fiber, provided ALS is provisioned on both ends of the fiber pair.

### Alarm Severity Assignment Profile (ASAP)

The Alarm Severity Assignment Profile is a feature that allows the management of Alarm Severity profiles in TNMS and also at the NE side.

### Automatically-Switched Optical Networks (ASON)

ASON domains are built on OCh layer of hiT 7300 which have a Control Plane. The Control Plane uses network-generated signaling and routing protocols to set up or release a connection, and can restore one when it fails. ASON domains can be built up as part of the transport network. They provide the benefit of easy end-to-end provisioning, and fault and protection management. Soft permanent connections (SPCs) connect both endpoints (NE1 and NE2) within an ASON domain. If a path fails, an alternative path is automatically used.

### ASON Call

A Call is a Soft Permanent Connection between two end-points (inside the same domain or between different domains) and defines the type and attributes of the connection. The establishment of a Call leads to having a path (and/or multiple alternative paths) connecting the end-points that respect the constraints and attributes defined in the Call.

### Bidirectional Self- healing Ring (BSHR)

Is a telecommunications term for loop network topology, a common configuration in tele- communications transmission systems, this loop or ring is used to provide redundancy. The system consists of a ring of bidirectional links between a set of stations. In normal use, traffic is dispatched in the direction of the shortest path towards its destination. In the event of the loss of a link, or of an entire station, the two nearest surviving stations "loop back" their ends of the ring. In this way, traffic can still travel to all surviving parts of the ring, even if it has to travel "the long way round".

### Capacity Planning

Capacity planning is the process of determining the capacity needed by a system to meet future needs.

### Card

A card is a plug-in unit that occupies one (or multiple) shelf slots. Cards perform specific electrical and/or optical functions within an NE. Each card has a faceplate with information LEDs and, in most cases, several ports for interconnection of optical fibers and/or optical interfaces.

### Card slot

A card slot is the insertion facility for a card in a shelf. Each card slot is designed for one or several particular card types. Mechanical coding elements make sure that each card can be fully inserted only into a card slot that is suitable for the given card type. Therefore, fundamental shelf equipping errors (which might cause hardware damage or fatal malfunctions) are impossible.

### Ethernet Connectivity Fault Management (CFM)

Is an end-to-end per service Ethernet layer OA&M protocol. IEEE 802.1ag CFM is a service-level OA&M protocol that provides tools for detecting and isolating connectivity failures in the network. This includes proactive connectivity monitoring, fault verification and fault isolation for large Ethernet Metropolitan Area Networks (MANs) and WANs.

### Committed Information Rate (CIR)

Is the guaranteed average rate (in Mbit/s) at which the information units are transferred through the port over a measurement interval.

### CLFI

CLFI Codes provide a standard, mnemonic naming scheme to uniquely identify cable and transmission facilities between two standardized locations within a network. It comprises facility designation, facility type, channel/pair/time slot, location of facility terminal A and location of facility terminal Z.

### Commissioning

Commissioning an network element (NE) is the process of taking an installed NE and bringing it in to an operational state. The NE commissioning phase is performed after the NE is installed and powered-up.

### Controller card

NE controller cards provide the central monitoring and controlling functions of the system, as well as the MCF to operate the Q and QF Ethernet interfaces. The controller card performs the following main functions: Fault Management, Performance Management, Configuration Management, Security Management, Equipment Management, Communication Management, Software Management (performing all software downloads, uploads, and software integrity functions) and controlling the NE alarm LEDs.

### Data Communication Network (DCN)

Data Communications Network is a management network for telecommunication transport systems. A DCN domain interconnects several NEs for the purpose of network management. The communication is established via the Optical Supervisory Channel (OSC) of the optical links and an Ethernet/L2 switching network implemented by the NEs.

### Dense Wavelength Division Multiplexing (DWDM)

In fiber-optic communications, wavelength-division multiplexing (WDM) is a technology which multiplexes a number of optical carrier signals onto a single optical fiber by using different wavelengths (colors) of laser light, that is, simultaneously places a large number of optical signals (in C or L band) on a single optical fiber. This technique enables bidirectional communications over one strand of fiber, as well as multiplication of capacity.

### Data Encryption Standard (DES)

Is a widely-used method of data encryption using a private key. DES applies a 56-bit key to each 64-bit block of data. The process can run in several modes and involves 16 rounds or operations.

### Dynamic Host Configuration Protocol (DHCP)

Is a standardized networking protocol used on IP networks that dynamically configures IP addresses and other information that is needed for Internet communication. DHCP allows computers and other devices to receive an IP address automatically from a central DHCP server, reducing the need for a network administrator or a user from having to configure these settings manually.

### Domain

TNMS allows you to restrict user groups to operate only a set of NEs or DCN subnets instead of the entire network. This partitioning is called a "Domain" and limits the operation on nodes outside of their partitions by assigning user groups to domains. Further, you can also assign policies to domains for further control and security, limiting the user groups to specific menu entries and actions. This arrangement is required, for example, in network centers that are responsible for maintaining only a subset of the nodes. The main purpose is security: it avoids that a login to the system grants access to the entire network. TNMS now supports the creation, modification or deletion of multiple domains, granting or restricting their accesses. By default, all NEs belong to the GLOBAL domain which cannot be modified or deleted.

### Ethernet Linear Protection (ELP)

Is a protection scheme defined in the ITU-T G.8031 standard designed to protect point-to-point Ethernet paths such as VLAN based Ethernet networks. To achieve protection ELP uses two disjointed paths, a working path and a protection path, traffic is carried firstly on the active path (working path) and in case of failure, traffic is switched to the protection path. Both paths can be monitored using OAM protocols like CFM. ELP provides 1:1 bi-directional protection switching with revertive mode capabilities. ELP must first be configured at the NE side via the LCT, only then they are visible in TNMS so that you can use it in the E-LAN and E-Line service creation via the New Ethernet Service wizard. ELP is supported in specific network elements and cards only. Refer to the NE dedicated documentation for more information.

### Ethernet

Ethernet is a family of frame-based computer networking technologies for LANs. It defines a number of wiring and signaling standards for the physical layer, through means of network access at the MAC/Data Link Layer, and a common addressing format.

### Fault management

Fault management reports all hardware and software malfunctions within an NE, and monitors the integrity of all incoming and outgoing digital signals.

### Flight Data Recorder

Flight Data Recorder (FDR) retrieves FDR files from NEs in network and provide a snapshot of the status of the Field Replacement Unit (FRU) at a given point in time.

### Forward Error Correction

Forward Error Correction (FEC) or channel coding is a technique used for controlling errors in data transmission over unreliable or noisy communication channels.

### File Transfer Protocol (FTP)

FTP is a network protocol used to transfer files from one computer to an NE and vice versa through the network.

### Frequency

Frequency is a physical attribute of a wave (for example, an optical wave), defined as the number of wave cycles per time unit. The frequency is directly related to the wavelength.

### Generalized Multi- Protocol Label Switching (GMPLS)

Is a protocol suite extending MPLS to manage further classes of interfaces and switching technologies other than packet interfaces and switching, such as time division multiplex, layer-2 switch, wavelength switch and fiber-switch.

### Internet Protocol (IP)

Is the principal communications protocol in the Internet protocol suite for relaying datagrams across network boundaries. Its routing function enables internetworking, and essentially establishes the Internet.

### Internet Protocol version 4 (IPV4)

Is a connectionless protocol for use on packet-switched networks. It operates on a best effort delivery model, in that it does not guarantee delivery, nor does it assure proper sequencing or avoidance of duplicate delivery. These aspects, including data integrity, are addressed by an upper layer transport protocol, such as the Transmission Control Protocol (TCP).

### Job

A schedule load that must be processed by the system.

### Link Aggregation Control Protocol (LACP)

Within the IEEE specification the Link Aggregation Control Protocol (LACP) provides a method to control the bundling of several physical ports together to form a single logical channel. LACP allows a network device to negotiate an automatic bundling of links by sending LACP packets to the peer (directly connected device that also implements LACP).

### Link Aggregation (LAG)

Allows a bridge to treat multiple physical links between two end-points as a single logical link, referred to also as a port-channel. The feature can be used to directly connect two switches when the traffic between them requires high bandwidth and/or reliability, or to provide a higher bandwidth connection to a public network. For this purpose, all the physical links in a given port-channel must operate in full-duplex mode and at the same speed. If a physical port or the related link of a LAG fails, the traffic previously carried over the failed link automatically is switched to the remaining link(s) of the LAG (rapid reconfiguration). Bandwidth degradation is an obvious impact if the sum of throughput of the two/multiple aggregated links are higher than the throughput of the remaining link(s). Be aware that certain link failures are not always visible to both ends of a link. Link Aggregation Control Protocol (LACP) and Automatic Laser Shutdown (ALS) enabled, guarantees that both ends of a link properly detect all failures and perform the correct response. LAG groups must first be created at the NE side via the LCT, only then, they are visible in TNMS so that you can use it in the E-LAN and E-Line service creation via the New Ethernet Service wizard. LAG is supported in specific network elements and cards only. Refer to the NE dedicated documentation for more information.

### Laser

A laser is a device that generates an intense narrow beam of light by stimulating the emission of photons from excited atoms or molecules.

### Laser safety

Laser safety rules are a group of mechanisms and actions necessary to protect all users from harmful laser light emissions.

### Local Craft network (LCT)

LCT is a client-based craft terminal (that is, element manager) software which provides access to network elements (NEs) in the customer network without the use of a management system.

### Lightweight Directory Access Protocol (LDAP)

Is an application protocol for accessing and maintaining distributed directory information services over an Internet Protocol network.

### Line interface

A line interface is a transponder interface that faces the line side of the link. Contrast with "client interface" which faces the client equipment side of the link. Long Haul (LH) hiT 7300 LH segment is a DWDM application characterized by a reach of more than 500 km and up to 1200 km.

### Label Switched Path (LSP)

Is a path through an MPLS network, set up by a signaling protocol such as LDP, RSVPTE, BGP or CR-LDP. The path is set up based on criteria in the forwarding equivalence class (FEC).

### Label switch router (LSR)

Sometimes called transit router, is a type of a router located in the middle of a Multiprotocol Label Switching (MPLS) network. It is responsible for switching the labels used to route packets. When an LSR receives a packet, it uses the label included in the packet header as an index to determine the next hop on the Label Switched Path (LSP) and a corresponding label for the packet from a look-up table. The old label is then removed from the header and replaced with the new label before the packet is routed forward.

### MD5

Message-digest algorithm is a widely used cryptographic hash function producing a 128-bit (16-byte) hash value, typically expressed as a 32 digit hexadecimal number

### Maintenance Association End Points (MEP)

Are points at the edge of the domain that define the boundaries and sends and receives CFM frames through the wire side (physical port) or relay function side.

### Maintenance Domain (MD)

A Maintenance Domain (or OAM Domain) is a group of maintenance external and internal points (MEPs and MIPs) created directly in the NE (standard IEEE 802.1ag) that gives performance and fault values.

### Management Information Base (MIB)

Is used for backup purposes where you can plan automatic upload jobs.

### Multiprotocol Label Switching

Multiprotocol Label Switching (MPLS) is a mechanism in high-performance telecommunications networks that directs data from one network node to the next based on short path labels rather than long network addresses, avoiding complex lookups in a routing table. The labels identify virtual links (paths) between distant nodes rather than endpoints.

### NetConf

Network Configuration Protocol (NETCONF), is an IETF network management protocol. NETCONF provides mechanisms to install, manipulate, and delete the configuration of network devices. Its operations are realized on top of a simple Remote Procedure Call (RPC) layer. The NETCONF protocol uses an Extensible Markup Language (XML) based data encoding for the configuration data as well as the protocol messages. This in turn is realized on top of the transport protocol.

### Network Element (NE)

A network element (NE) is a self-contained logical unit within the network. The NE can be uniquely addressed and individually managed via software. Each NE consists of hardware and software components to perform given electrical and optical functions within the network.

### Network Management

The network management layer includes all the required functions to manage the optical network in an effective and user-friendly way, such as the visualization of the network topology, creation of services, and correlation of alarms to network resources.

### Network topologies

A topology of a network is defined by the list of NEs included in the network and the list of links that connect those NEs (for example, point-to-point, chain, ring, and so on).

### NNI

Is an interface which specifies signaling and management functions between two networks. NNI circuit can be used for interconnection of IP (e.g. MPLS) networks.

### Optical Channel

A predefined wavelength that can be used to transmit a bit stream by means of a modulated light signal.

### Optical Network Node (ONN)

An ONN is an NE where the incoming channels are either dropped or routed to a line in a different direction, outgoing channels can also be added locally. Apart from multiplexing and demultiplexing an ONN NE implements optical or 3R signal regeneration and dispersion compensation.

### Optical path

The path followed by an optical channel from the first multiplexer to the last demultiplexer.

### Optical Transport Hierarchy (OTH)

Optical Transport Hierarchy is a transport technology for the Optical Transport Network.

### Path Computation Engine Protocol (PCEP)

Implements, sets up and manages PCEP, while also notifying OM when PCEP is available or unavailable to send/receive PCEP Route messages.

### Performance management

Performance monitoring and signal quality analysis provide information for detecting and alerting, a cause that could lead to a degraded performance before a failure is declared.

### Peak Information Rate (PIR)

Is a burstable rate set on routers and/or switches that allows throughput overhead. Related to Committed Information Rate which is a committed rate speed guaranteed/ capped. For example, a CIR of 10 Mbit/s PIR of 12 Mbit/s allows you access to 10 Mbit/s minimum speed with burst/spike control that allows a throttle of an additional 2 Mbit/s.

### Plesiochronous Digital Hierarchy (PDH)

Is a technology used to transport large quantities of data over digital transport equipment.

### Pseudo-Random Binary Sequence (PRBS)

Is a known sequence of bits that can be used as a test signal to measure transmission delay and bit error rate of a channel. In this test, one port inserts the PRBS signal in the channel (source port) and another detects if the sequence was received correctly (sinkport). This kind of test is traffic affecting since the test sequence is inserted into the OPUk until the test is stopped.

### Physical Trails (PT)

Trails are represented as Physical Trails (PTs). They connect two Physical Termination Points (PTP) on a physical layer rate, but can also contain non-physical layers.

### Planning Tool Connector (PTC)

Interfaces Nokia TransNet/Intelligent Optical Control DWDM network planning tool.

### PMP

A Performance Measurement Point is a metric represented by a set of counters for a specific point in the network. It provides data for monitoring the performance and availability of the network.

### `<Product_Data_Folder>`

The directory defined at TNMS/Transcend Controller Installation for all software Data storage, by default `/nokia/tnms` or `/nokia/transcend`.

### `<Product_Installation_Folder>`

The directory defined at TNMS/Transcend Controller Installation where the software is installed, by default `/opt/nokia/tnms` or `/opt/nokia/transcend`.

### `<Product_Installer_Folder>`

The directory where the TNMS/Transcend Controller software zip was extracted before TNMS/Transcend Controller installation.

> **NOTICE:** The `<Product_Installer_Folder>` must not be in the same directory as the `<Product_Installation_Folder>` or the `<Product_Data_Folder>`.

### Qualitative System Requirements

Quality System Requirements are non-functional requirements that must be meet by a System such as Reliability, Availability, Performance, Scalability, Security, Maintainability, Portability, etc.

### Required Creation State (RCS)

Is the desired state of the path, which is set by the user upon creation.

### Optical Signal to Noise Ratio (OSNR)

OSNR is the ratio of an optical signal power to the noise power in the signal.

### Ring network

A ring network is a network topology in which each NE connects to exactly two other NEs, forming a circular optical path for signals (that is, a ring).

### Synchronous Digital Hierarchy (SDH)

Is a standardized protocol that transfer multiple digital bit streams over optical fiber using lasers or highly coherent light from light-emitting diodes. At low transmission rates data can also be transferred via an electrical interface. The method was developed to replace the Plesiochronous Digital Hierarchy system for transporting large amounts of telephone calls and data traffic over the same fiber without synchronization problems.

### Security management

Security Management controls the individual access to particular NE functions via the network management system and/or via a craft terminal, using a hierarchical security management user ID, and password concept.

### State Event Machine (SEM)

In computation, a finite-state machine is event driven if the transition from one state to another is triggered by an event or a message.

### Service Provisioning via NMS

Provisioning mode in hiT 7300. The core equipment is provisioned by downloading and swapping NCFs, while services are manually provisioned via the NMS. When adding new services or expanding an existing network, the relevant line cards, cross connections and internal port connections between line cards and multiplexers/demultiplexers are provisioned via the NMS.

### Secure Hash Algorithm (SHA)

Is a family of cryptographic hash functions that takes an arbitrary block of data and returns a fixed-size bit string, the cryptographic hash value, such that any (accidental or intentional) change to the data will (with very high probability) change the hash value. The data to be encoded are often called the message, and the hash value is sometimes called the message digest or simply digest.

### Simple Network Management Protocol (SNMP)

SNMP is used in network management systems to monitor network-attached devices for conditions that warrant administrative control. It consists of a set of standards for network management, including an application layer protocol, a database schema, and a set of data objects.

### Software management

Software management performs all software downloads, uploads, and software integrity functions.

### Secure Shell (SSH)

Secure Shell (SSH) Is a cryptographic network protocol for secure data communication, remote commandline login, remote command execution, and other secure network services between two networked computers that connects, via a secure channel over an insecure network, a server and a client (running SSH server and SSH client programs, respectively).

### Subsystem

A subsystem is a set of shelves and cards in multicontroller NE that is controlled by a subagent. All subagents within a multicontroller NE are controlled by the master agent. Subsystem is defined for the HW only. In software, the concept is different. A major component of a system. It is made up of two or more interacting and interdependent components. Subsystems of a system interact in order to attain their own purpose(s) and the purpose(s) of the system in which they are embedded.

### Synchronous Optical Networking (SONET)

Synchronous Optical Networking and Synchronous Digital Hierarchy are standardized protocols that transfer multiple digital bit streams over optical fiber using lasers or highly coherent light from light-emitting diodes.

### Throughput

Throughput measures the number of work units performed in a given time unit.

### Topological Container (TC)

Defines a containment relationship between other topological container and/or NEs. This means they can contain NE symbols and other TCs. The network map is always associated with one TC, which corresponds to a network view.

### Tandem Connection Monitoring (TCM)

TCMs are configurable parameters (via Element Manager) of the transponders. They provide a Performance Management of all the Optical Transport Network (that is, end-to-end connection) or specific sections only and implement an Optical channel Data Unit (ODU) termination provisioned to support up to six TCM levels.

### Transmission Control Protocol (TCP)

Is one of the core protocols of the Internet protocol suite (IP), and is so common that the entire suite is often called TCP/IP. TCP provides reliable, ordered, error-checked delivery of a stream of octets between programs running on computers connected to a local area network, intranet or the public Internet. It resides at the transport layer.

### TL1

Transaction Language 1 (TL1) is a widely used management protocol in telecommunications. It is a cross-vendor, cross-technology man-machine language, and is widely used to manage optical (SONET) and broadband access infrastructure in North America. TL1 is used in the input and output messages that pass between Operations Systems (OSs) and Network Elements (NEs). Operations domains such as surveillance, memory administration, and access and testing define and use TL1 messages to accomplish specific functions between the OS and the NE.

### TNMS

Transcend Network Management System - is a standalone application that provides a full range of network-management functions, from the transport network's physical structure and its NEs to those required for Automatically-Switched Optical Networks (ASON), SW management (also referred to as Cross-NE), Optical Management and Ethernet Management.

### TNMS Core

TNMS Core is an integrated solution designed for large, medium and small size networks. It supports NEs with DWDM, OTH, SDH, PDH, Ethernet in line, star, ring and mesh network configurations. TNMS Core can be used to manage networks in the access, edge, metro, core and backbone levels.

### TransNet

Planning of a hiT 7300 network is done by the Nokia TransNet tool. Nokia TransNet is a sophisticated software simulation tool developed specifically for designing and/or upgrading optical DWDM networks with hiT 7300. It runs on PCs using Microsoft Windows operating systems.

### Trail Trace Identifier (TTI)

TTI is a transponder card parameter (configurable via Element Manager) of which is used to verify correct cabling or correct Tandem Connection Monitoring (TCM) configuration. The basic principle is that specific overhead bytes are reserved for Trace Messages of the user's choosing. By specifying the Actually Sent (transmitted) and the Expected (received) trace messages, the system can automatically verify that fiber connections have been made as intended. This is accomplished by comparing the expected Trace Message to that actually received. If they differ, an alarm is raised, alerting personnel of the incorrect connections.

### Transponder card

A transponder card receives an optical input signal and converts it to an optical output signal suitable for DWDM multiplexing and transmission.

### Transponder loopback

Loopbacks are diagnostic tests that can be activated via Element Manager. Loopbacks return the transmitted signal back to the sending device after the signal has passed across a particular link. The returned signal can then be compared to the transmitted one. Any discrepancy between the transmitted and the returned signal helps to trace faults.

### User Datagram Protocol (UDP)

Is one of the core members of the Internet protocol suite (the set of network protocols used for the Internet). With UDP, computer applications can send messages, in this case referred to as datagrams, to other hosts on an Internet Protocol (IP) network without prior communications to set up special transmission channels or data paths. UDP uses a simple transmission model with a minimum of protocol mechanism. It has no handshaking dialogues, and thus exposes any unreliability of the underlying network protocol to the user's program. As this is normally IP over unreliable media, there is no guarantee of delivery, ordering or duplicate protection. UDP provides checksums for data integrity, and port numbers for addressing different functions at the source and destination of the datagram.

### Ultra Long Haul (ULH)

Ultra Long Haul (ULH) hiT 7300 ULH segment is a DWDM (p. 70) application characterized by long path lengths of up to 1600 km.

### User-to-Network Interface (UNI)

User-to-Network Interface (UNI) Is a demarcation point between the responsibility of the service provider and the responsibility of the subscriber. This is distinct from a Network to Network Interface (NNI) that defines a similar interface between provider networks

### Universal Network Object (UNO)

Universal Network Object (UNO) Universal Network Objects are software NEs that can be configured and used to represent network elements which are not supported by TNMS. UNO also supports devices with restricted functionalities, for example, without supervising interfaces. They are also used to represent network services between third parties and TNMS networks.

### Virtual Local Area Networks (VLAN)

In computer networking, a single layer-2 network may be partitioned to create multiple distinct broadcast domains, which are mutually isolated so that packets can only pass between them via one or more routers; such a domain is referred to as a Virtual Local Area Network, Virtual LAN or VLAN.

### Wavelength

Wavelength is a physical attribute of a wave (for example, an optical wave), defined as the distance between corresponding points of two consecutive wave cycles. The wavelength is directly related to the frequency of the wave.

### Wavelength Division Multiplexing (WDM)

Wavelength Division Multiplexing is a technique of multiplexing multiple optical carrier signals through a single optical fiber channel by varying the wavelengths of laser lights.

### Wait to restore time (WTR)

The time in minutes that TNMS waits until it tries to switch to the working path again, assuming the Revertive option is selected.

### workload Model

Representation of the typical load to be processed by the system.

### eXtensible Markup Language (XML)

Is a markup language that defines a set of rules for encoding documents in a format that is both human-readable and machine-readable. The design goals of XML emphasize simplicity, generality, and usability over the Internet. It is a textual data format with strong support via Unicode for the languages of the world. Although the design of XML focuses on documents, it is widely used for the representation of arbitrary data structures, for example in web services.
