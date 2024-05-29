/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc.  All rights reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
#ifndef __LWIPOPTS_H_
#define __LWIPOPTS_H_

#ifndef PROCESSOR_LITTLE_ENDIAN
#define PROCESSOR_LITTLE_ENDIAN
#endif

/* always use lightweight prot mechanism for critical regions */
#define SYS_LIGHTWEIGHT_PROT 1

#define NO_SYS			  1
#define LWIP_SOCKET 		 0
#define LWIP_COMPAT_SOCKETS	 0
#define LWIP_NETCONN		 0

#define NO_SYS_NO_TIMERS   1
#define LWIP_TCP_KEEPALIVE  0

/* #undef SGMII_FIXED_LINK */
#define MEM_ALIGNMENT 64
#define MEM_SIZE 131072
#define MEMP_NUM_PBUF 16
#define MEMP_NUM_UDP_PCB 4
#define MEMP_NUM_TCP_PCB 32
#define MEMP_NUM_TCP_PCB_LISTEN 8
#define MEMP_NUM_TCP_SEG 256
#define MEMP_NUM_SYS_TIMEOUT 8
#define MEMP_NUM_NETBUF 8
#define MEMP_NUM_NETCONN 16
#define MEMP_NUM_TCPIP_MSG_API 16
#define MEMP_NUM_TCPIP_MSG_INPKT 64

#define PBUF_POOL_SIZE 256
#define PBUF_POOL_BUFSIZE 1700
#define PBUF_LINK_HLEN 16

#define ARP_TABLE_SIZE 10
#define ARP_QUEUEING 1

#define ICMP_TTL 255

#define LWIP_IPV6  0
/* #undef LWIP_IGMP */

/* #undef IP_OPTIONS */
/* #undef IP_FORWARD */
#define IP_REASSEMBLY 1
#define IP_FRAG 1
#define IP_REASS_MAX_PBUFS 128
#define IP_FRAG_MAX_MTU 1500
#define IP_DEFAULT_TTL 255
#define LWIP_CHKSUM_ALGORITHM 3

#define LWIP_UDP 1
#define UDP_TTL 255

#define LWIP_TCP 1
#define TCP_MSS 1460
#define TCP_SND_BUF 8192
#define TCP_WND 2048
#define TCP_TTL 255
#define TCP_MAXRTX 12
#define TCP_SYNMAXRTX 4
#define TCP_QUEUE_OOSEQ 1
#define TCP_SND_QUEUELEN   16 * TCP_SND_BUF/TCP_MSS

#define CHECKSUM_GEN_TCP	   0
#define CHECKSUM_GEN_UDP    0
#define CHECKSUM_GEN_IP     0
#define CHECKSUM_CHECK_TCP  0
#define CHECKSUM_CHECK_UDP  0
#define CHECKSUM_CHECK_IP   0

#define LWIP_FULL_CSUM_OFFLOAD_RX 1
#define LWIP_FULL_CSUM_OFFLOAD_TX 1

#define MEMP_SEPARATE_POOLS 1
#define MEMP_NUM_FRAG_PBUF 256
#define IP_OPTIONS_ALLOWED 0

#define TCP_OVERSIZE TCP_MSS
/* #undef USE_JUMBO_FRAMES */

#define LWIP_DHCP  0
#define DHCP_DOES_ARP_CHECK  0

#define CONFIG_LINKSPEED_AUTODETECT 1

/* #undef LWIP_STATS */
/* #undef LWIP_STATS_DISPLAY */

/* #undef LWIP_DEBUG */
/* #undef DBG_TYPES_ON */
/* #undef IP_DEBUG */
/* #undef TCP_DEBUG */
/* #undef TCP_INPUT_DEBUG */
/* #undef TCP_OUTPUT_DEBUG */
/* #undef TCPIP_DEBUG */
/* #undef UDP_DEBUG */
/* #undef ICMP_DEBUG */
/* #undef IGMP_DEBUG */
/* #undef NETIF_DEBUG */
/* #undef SYS_DEBUG */
/* #undef API_MSG_DEBUG */
/* #undef PBUF_DEBUG */
/* #undef MEMP_DEBUG */
/* #undef OS_IS_FREERTOS */
/* #undef LWIP_PROVIDE_ERRNO */
/* #undef DEFAULT_THREAD_PRIO */
/* #undef TCPIP_THREAD_PRIO */
/* #undef DEFAULT_TCP_RECVMBOX_SIZE */
/* #undef DEFAULT_ACCEPTMBOX_SIZE */
/* #undef TCPIP_MBOX_SIZE */
/* #undef DEFAULT_UDP_RECVMBOX_SIZE */
/* #undef DEFAULT_RAW_RECVMBOX_SIZE */
/* #undef LWIP_COMPAT_MUTEX */
/* #undef LWIP_ALLOW_MEM_FREE_FROM_OTHER_CONTEXT */
/* #undef LWIP_TCPIP_CORE_LOCKING_INPUT */
/* #undef TCPIP_THREAD_STACKSIZE */

#endif
