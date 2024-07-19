/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc.  All rights reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
#ifndef __XLWIPCONFIG_H_
#define __XLWIPCONFIG_H_

/* #undef XLWIP_CONFIG_INCLUDE_AXIETH_ON_ZYNQ */
/* #undef XLWIP_CONFIG_INCLUDE_EMACLITE_ON_ZYNQ */
/* #undef XLWIP_CONFIG_INCLUDE_EMACLITE */
/* #undef XLWIP_CONFIG_INCLUDE_AXI_ETHERNET */
/* #undef XLWIP_CONFIG_INCLUDE_AXI_ETHERNET_DMA */
/* #undef XLWIP_CONFIG_INCLUDE_AXI_ETHERNET_FIFO */
/* #undef XLWIP_CONFIG_AXI_ETHERNET_ENABLE_1588 */
/* #undef XLWIP_CONFIG_INCLUDE_AXI_ETHERNET_MCDMA */
#define XLWIP_CONFIG_INCLUDE_GEM 1
#define XLWIP_CONFIG_N_TX_DESC 64
#define XLWIP_CONFIG_N_RX_DESC 64
#define XLWIP_CONFIG_N_TX_COALESCE 1
#define XLWIP_CONFIG_N_RX_COALESCE 1
/* #undef XLWIP_CONFIG_EMAC_NUMBER */
/* #undef XLWIP_CONFIG_PCS_PMA_1000BASEX_CORE_PRESENT */
/* #undef XLWIP_CONFIG_PCS_PMA_SGMII_CORE_PRESENT */

#endif
