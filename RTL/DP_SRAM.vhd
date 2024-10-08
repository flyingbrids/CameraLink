---------------------------------------------------------------------------------
-- DUAL-PORT SRAM interface for part IDT70T3509MS/IDT70T3519S/IDT70T3539MS
-- For more information visit www.idt.com  
---------------------------------------------------------------------------------
--For the dual port interface, the left bank is connected to LX30 U5.
-- The right bank is bussed only to the  Xilinx FPGA.  All  right bank SRAM control signals
--  are generated by the user programmable FPGA U7.  For the
-- purposes of this file all signal relating to the right bank will begin with "SRR_".

-- Note: This component is design for a memory size of 256K x 64.

-- Note that this revision is only applicale to the XMC-SLX150 product.  

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--Entity decalaration for clock generator
entity DP_SRAM is port(

 --Global signals ---------------------------------------------------------------
	CLK: in STD_LOGIC;
	RESET: in STD_LOGIC;

--Right Bank SRAM pin connections -----------------------------------------------
	SRR_A: out STD_LOGIC_VECTOR (19 downto 0) ; -- SRAM Address Bus
	SRR1_CE0n: out STD_LOGIC;	 -- SRAM Chip Enable Active Low -- 1 are lower long word 0 to 31
	SRR1_OEn: out STD_LOGIC;	 -- SRAM Output Enable Active Low
	SRR3_CE0n: out STD_LOGIC;	 -- SRAM Chip Enable Active Low --3 are high long word 32 to 63
	SRR3_OEn: out STD_LOGIC;	 -- SRAM Output Enable Active Low
	SRR_BE0n: out STD_LOGIC;	 -- SRAM Individual Byte Write Select Active Low
	SRR_BE1n: out STD_LOGIC;	 -- SRAM Individual Byte Write Select Active Low
	SRR_BE2n: out STD_LOGIC;	 -- SRAM Individual Byte Write Select Active Low
	SRR_BE3n: out STD_LOGIC;	 -- SRAM Individual Byte Write Select Active Low
	SRR_BE4n: out STD_LOGIC;	 -- SRAM Individual Byte Write Select Active Low
	SRR_BE5n: out STD_LOGIC;	 -- SRAM Individual Byte Write Select Active Low
	SRR_BE6n: out STD_LOGIC;	 -- SRAM Individual Byte Write Select Active Low
	SRR_BE7n: out STD_LOGIC;	 -- SRAM Individual Byte Write Select Active Low
	SRR_ADSn: out STD_LOGIC; 	-- SRAM Address Strobe Enable Active Low
	SRR_PL_FTn: out STD_LOGIC;	-- SRAM Pipeline / Flow-Throu Mode Select Line
	SRR_CNTENn: out STD_LOGIC;	-- SRAM Counter Enable Active Low
	SRR_REPEATn: out STD_LOGIC;	-- SRAM Counter Repeat Active Low
	SRR_ZZ: out STD_LOGIC;		-- SRAM Sleep Mode Active High
	SRR_INTn: in STD_LOGIC;		-- SRAM Interrupt Flag Active Low
	SRR_COLn: in STD_LOGIC;		-- SRAM Collision Flag Active Low
 	SRR1_R_Wn: out STD_LOGIC;	 -- SRAM Read / Write low
 	SRR3_R_Wn: out STD_LOGIC;	 -- SRAM Read / Write low
 	SRR_IO: inout STD_LOGIC_VECTOR (63 downto 0); -- SRAM I/O Bus
	SRR_IOP: inout STD_LOGIC_VECTOR (7 downto 0); -- SRAM I/O Bus Parity Bits

	--for right port
 	SRR_I_Bus: in STD_LOGIC_VECTOR (63 downto 0); --Right Port Input Data Bus
	SRR_IOPar_Bus: inout STD_LOGIC_VECTOR (7 downto 0); -- Right Port Parity Bus
		
	SRR_SEL: in STD_LOGIC;	--Right port Select signal
		
	SRR_W_Rn_Sel: in STD_LOGIC;  --Right port Write / Read low  signal
	SRR_Ack: out STD_LOGIC;  --Right port read Acknowledge signal
	SRR_Ready: out STD_LOGIC; 
	--only single cycle pipeline reads are supported in this example. 
	
--Local Bus connections ---------------------------------------------------------
	ADS_n: in STD_LOGIC;  -- Address Strobe from PCI
	LW_R_n: in STD_LOGIC;  -- Local Bus Write / Read driven by PCI

	LD: in STD_LOGIC_VECTOR(31 downto 0); --Local Data Bus
	LBE0_n: in STD_LOGIC; --Local Data Bus Byte 0 Enables active low
	LBE1_n: in STD_LOGIC; --Local Data Bus Byte 1 Enables active low
	LBE2_n: in STD_LOGIC; --Local Data Bus Byte 2 Enables active low
	LBE3_n: in STD_LOGIC; --Local Data Bus Byte 3 Enables active low

	READ_DATA: out STD_LOGIC_VECTOR(31 downto 0); --Readback data bus of SRAM Reg
	
	SRAM_Read_Adr : in STD_LOGIC; --SRAM Read Right Port Address Strobe
	SRAM_Read_Adr2 : in STD_LOGIC; --SRAM Read Right Port Address Strobe MSW
	SRAM_CONTROL_Adr: in STD_LOGIC; --SRAM Control Register Address Strobe
	SRAM_IntAdr: in STD_LOGIC; --SRAM Internal Address Register Address Strobe
	SRAM_DMA0Thr_Adr: in STD_LOGIC; --SRAM DMA0 Threshold Register Addr Strobe
	SRAM_DMA1Thr_Adr: in STD_LOGIC; --SRAM DMA1 Threshold Register Addr Strobe
	SRAM_Reset0_Adr: in STD_LOGIC; --SRAM Address Reset Value Reg 0 (DMA0 Thres) 
	SRAM_Reset1_Adr: in STD_LOGIC; --SRAM Address Reset Value Reg 1 (DMA1 Thres) 
	DMA0_REQ: out STD_LOGIC;	 --SRAM DMA0 Request
	DMA1_REQ: out STD_LOGIC;	 --SRAM DMA1 Request
	SRAM_ENABLED: out STD_LOGIC
     );

     
END DP_SRAM;

---ARCHITECTURE BODY	
ARCHITECTURE DP_SRAM_ARCH OF DP_SRAM IS

--with of Dual-Port Address Bus.  19 for SLX150-1M, 17 for SLX150.
constant addr_max: integer := 17; 


-- Right Bank SRAM signals -------------------------------------------
signal SRR1_OE : STD_LOGIC :='0';
signal SRR3_OE : STD_LOGIC :='0';
signal SRR_ACCESS, SRR_Pipeline_Wait: STD_LOGIC :='0';
signal SRR_ACCESS_W: STD_LOGIC;
signal SRR_WRITE, SRR_WRITE_n: STD_LOGIC;
signal SRR_WRITE_R1: STD_LOGIC;
signal SRR_WRITE_R2: STD_LOGIC;
signal SRR_IO_REG: STD_LOGIC_VECTOR (63 downto 0);
signal SRR_IOPar_REG: STD_LOGIC_VECTOR (7 downto 0);
signal SRR_IO_RD: STD_LOGIC_VECTOR (63 downto 0);
signal SRR_Pipeline_Wait2: STD_LOGIC;
signal SRR_Pipeline_Wait3: STD_LOGIC;
signal SRR_Pipeline_Wait_ReadOnly: STD_LOGIC;
signal I1_SRR_OE: STD_LOGIC;
signal I3_SRR_OE: STD_LOGIC;
signal SRAM_Read_Adr_Reg : STD_LOGIC; --SRAM Read Right Port Address Strobe
signal SRAM_Read_Adr2_Reg : STD_LOGIC; --SRAM Read Right Port Address Strobe MSW
signal SRR1_CE0nR, SRR3_CE0nR : STD_LOGIC;
signal SRR1_R_Wn_reg, SRR3_R_Wn_reg: STD_LOGIC;
signal SRR_ACK_WAIT1, SRR_ACK_WAIT2: STD_LOGIC;
 
 
--SRAM Register strobe signals
signal SRAM_CONTROL_Stb0: STD_LOGIC;
signal SRAM_IntAdr_StbAll: STD_LOGIC;
signal SRAM_DMA0Thr_StbAll: STD_LOGIC;
signal SRAM_DMA1Thr_StbAll: STD_LOGIC;
signal SRAM_RESET0_StbAll, SRAM_RESET1_StbAll: STD_LOGIC;  

--SRAM Register signals
signal SRAM_WRITE_EN: STD_LOGIC;
signal SRAM_DMA0EN: STD_LOGIC;
signal SRAM_DMA1EN: STD_LOGIC;
signal SRAM_Reset0_EN: STD_LOGIC;
signal SRAM_Reset1_EN: STD_LOGIC;
signal SRAM_WRITE_EN_Reset: STD_LOGIC;

signal DMA0_THRESHOLD: STD_LOGIC_VECTOR(addr_max downto 0);
signal DMA1_THRESHOLD: STD_LOGIC_VECTOR(addr_max downto 0);
signal DMA0_RESET: STD_LOGIC_VECTOR(addr_max downto 0);
signal DMA1_RESET: STD_LOGIC_VECTOR(addr_max downto 0);

--SRAM DMA Event signals
signal DMA0_EVENT: STD_LOGIC;
signal DMA1_EVENT: STD_LOGIC;


--SRAM Address Counter
signal SRAM_ADD_Count: STD_LOGIC_VECTOR(addr_max downto 0);
signal Add_Reset: STD_LOGIC;
signal Address_Inc: STD_LOGIC;
signal ADD_RESET_VALUE: STD_LOGIC_VECTOR(addr_max downto 0);

signal Add_Load_DMA, Add_Load_register: STD_LOGIC;

--other signals
signal NotUsed_Group: STD_LOGIC;
--State Machine signals
type SRAM_state_type is (st1_RESET, st2_SRR_SEL, st3_OEEnabled, st4_CEEnabled, st5_Hold,  st7_RegRead, st8_Ack); 
signal SRAM_state, SRAM_next_state : SRAM_state_type; 
signal  SRAM_IntAdr_StbAll_Reg1,  SRAM_IntAdr_StbAll_Reg2: STD_LOGIC;

BEGIN

------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------
-- Right Bank SRAM Read and Write Circuitry -----------------------------------
-- Note: All signals for the right bank connect directly to the FPGA.  
-- To perform a write place the data on the bus (SRR_I_BUS), the address is 
-- generated internally within this component, and set the SRR_SEL   
-- High for one clock cycle. SRR_W_Rn_Sel must remain constant until the SRR_ACK
-- is received.  Subsequent writes can occur once the SRR_ACK is received. 
-- There are three wait states to perform a write.

-- To perform a read place the address on the internal address register 8044 hex
-- and hold SRR_W_Rn_Sel Low. Set SRR_SEL high for one clock cycle. The read
-- command has five wait states.  The Address and SRR_W_Rn_Sel must remain
-- constant until the acknowledge signal (SRR_ACK) is received.  During the acknowledge
-- signal the data is available on the bus (READ_DATA). 
  
  --SRAM Pipeline / Flow-Through Mode Select Line: Default access mode is
  -- pipeline mode.  This value should be kept constant during all operations.    
  SRR_PL_FTn <= '1';

  -- SRAM Sleep Mode Active High
  SRR_ZZ <= '0';
  --SRR_ZZ <= '1'; -- Sleep Mode
  
  -- SRAM Counter Repeat Active Low 
  SRR_REPEATn <= '1';

  -- SRAM Counter Enable Active Low	  
  SRR_CNTENn <= '1';
  
  -- SRAM Individual Byte Enable Active Low
  -- Read/Write access will always use all eight bytes.
  SRR_BE0n <= '0';
  SRR_BE1n <= '0';
  SRR_BE2n <= '0';
  SRR_BE3n <= '0';	
  SRR_BE4n <= '0';
  SRR_BE5n <= '0';
  SRR_BE6n <= '0';
  SRR_BE7n <= '0';	
  SRR_Ready <= '1' when SRAM_state = st8_ACK and SRAM_Read_Adr2 = '1' else '0';
--SRAM state machine
   SYNC_PROC: process (CLK)
   begin
      if (CLK'event and CLK = '1') then
         if (RESET = '1') then
            SRAM_state <= st1_RESET;
         else
            SRAM_state <= SRAM_next_state;
         end if;        
      end if;
   end process;
 
--	SRAM Read/Write State Machine.  
--	st1_RESET: Reset/default state.  No SRAM action.
--	st2_SRR_SEL: Received SRR_SEL signal (active high). Registered SRR_I_BUS and SRR_W_Rn signals.
--					 Then goto st3_OEEnabled if read or st4_CEEnabled if write.
--	st3_OEEnabled: Read only action.  Enable the Output Enable (OEn) SRAM signals. Next state st4_CEEnabled.
--	st4_CEEnabled: Read/Write action.  SRAM chip enable state.  Next state st5_Hold.
--	st5_Hold: Hold SRAM Output enables and Chip Enable for an additional clock cycle.
--				 Goto st7_RegRead if read or st8_Ack if write.
-- st7_RegRead: Read only action. Register Read Data. Goto to st8_Ack.
-- st8_Ack:  Set SRAM_ACK high and increment address counter if necessary.  Return to st1_reset.
	
   NEXT_STATE_DECODE: process (SRAM_state, SRR_SEL, SRR_W_Rn_Sel)
   begin
      case (SRAM_state) is
         when st1_RESET =>
            if SRR_SEL = '1' then
               SRAM_next_state <= st2_SRR_SEL;
				else
					SRAM_next_state <= st1_RESET;
            end if;
				
         when st2_SRR_SEL =>
            if SRR_W_Rn_Sel = '0' then
               SRAM_next_state <= st3_OEEnabled;
				else
					SRAM_next_state <= st4_CEEnabled;
            end if;
				
         when st3_OEEnabled =>
            SRAM_next_state <= st4_CEEnabled;
				
			when st4_CEEnabled =>
				SRAM_next_state <= st5_Hold;
				
			when st5_Hold =>
				if SRR_W_Rn_Sel = '0' then
               SRAM_next_state <= st7_RegRead;
				else
					SRAM_next_state <= st8_Ack;
            end if;
				
			when st7_RegRead => 
				SRAM_next_state <= st8_Ack;
			
			when st8_Ack =>
				SRAM_next_state <= st1_RESET;
			when others =>
				SRAM_next_state <= st1_RESET;

      end case;      
   end process;
	
	--Note that all SRAM control signals are changed on the falling edge of the CLK.
	--SRAM lower 32bit Read/Write Signal.  Always set to read unless write cycle.
	process(CLK)
	begin
		if(CLK'event and CLK = '0') then
			if (RESET = '1') then
				SRR1_R_Wn_reg <= '1';
			elsif(SRAM_State /= st1_RESET) then
				SRR1_R_Wn_reg <= not (SRR_W_Rn_Sel and SRAM_Read_Adr);
			else
				SRR1_R_Wn_reg <= '1';
			end if;
		end if;
	end process;
	
	--SRAM upper 32bit Read/Write Signal.  Always set to read unless write cycle.
	process(CLK)
	begin
		if(CLK'event and CLK = '0') then
			if(RESET = '1') then
				SRR3_R_Wn_reg <= '1';
			elsif(SRAM_State /= st1_RESET) then
				SRR3_R_Wn_reg <= not (SRR_W_Rn_Sel and SRAM_Read_Adr2);
			else
				SRR3_R_Wn_reg <= '1';
			end if;
		end if;
	end process;
	
	
	SRR1_R_Wn <= SRR1_R_Wn_reg;
	SRR3_R_Wn <= SRR3_R_Wn_reg;
	

  --Address select signal
  -- The address will constantly be externally loaded on the rising edge of the clock.
   SRR_ADSn <= '0';

 --SRAM lower 32bit Output Enable Signal. Active low.
process(CLK)
begin
	if(CLK'event and CLK = '0') then
		if((SRAM_state = st3_OEEnabled or SRAM_state = st4_CEEnabled or SRAM_state = st5_Hold or SRAM_state = st7_RegRead) and SRAM_Read_Adr = '1' and SRR_W_Rn_Sel = '0') then
			SRR1_OEn <= '0';
		else
			SRR1_OEn <= '1';
		end if;
	end if;
end process;

--SRAM upper 32bit Output Enable Signal. Active low.
process(CLK)
begin
	if(CLK'event and CLK = '0') then
		if((SRAM_state = st3_OEEnabled or SRAM_state = st4_CEEnabled or SRAM_state = st5_Hold or SRAM_state = st7_RegRead) and SRAM_Read_Adr2 = '1' and SRR_W_Rn_Sel = '0') then
			SRR3_OEn <= '0';
		else
			SRR3_OEn <= '1';
		end if;
	end if;
end process;

--SRAM lower 32bit Chip Enable Signal. Active low.
process(CLK)
begin
	if(CLK'event and CLK = '0') then
		if((SRAM_state = st4_CEEnabled or SRAM_state = st5_Hold) and SRAM_Read_Adr = '1') then
			SRR1_CE0n <= '0';
		else
			SRR1_CE0n <= '1';
		end if;
	end if;
end process;

--SRAM upper 32bit Chip Enable Signal. Active low.
process(CLK)
begin
	if(CLK'event and CLK = '0') then
		if((SRAM_state = st4_CEEnabled or SRAM_state = st5_Hold) and SRAM_Read_Adr2 = '1') then
			SRR3_CE0n <= '0';
		else
			SRR3_CE0n <= '1';
		end if;
	end if;
end process;

--Register Write Data from SRR_I_Bus
process(CLK)
begin
	if(CLK'event and CLK = '0') then 
		if (reset = '1') then
			SRR_IO_REG <= (others => '0');
		elsif (SRAM_state = st2_SRR_SEL) then
			SRR_IO_REG <= SRR_I_BUS;
		else
			SRR_IO_REG <= SRR_IO_REG;
		end if;
	end if;
end process;

--Register Parity bits (not used in example design).
process(CLK)
begin
	if(CLK'event and CLK = '0') then
		if (RESET = '1') then
			SRR_IOPar_REG <= (others => '0');
		elsif(SRAM_state = st2_SRR_SEL) then
			SRR_IOPar_REG <= SRR_IOPar_BUS;
		else
			SRR_IOPar_REG <= SRR_IOPar_REG;
		end if;
	end if;
end process;

--Output Write Data (I/O bus) to SRAM during write cycle.
process(CLK) 
begin
	if(CLK'event and CLK = '0') then
		if (SRR_W_Rn_Sel = '1') then
			SRR_IO <= SRR_IO_REG;
		else
			SRR_IO <= (others => 'Z');
		end if;
	end if;
end process;

--Output Write Data (partiy bus) to SRAM during write cycle.
process(CLK) 
begin
	if(CLK'event and CLK = '0') then
		if (SRR_W_Rn_Sel = '1') then
			SRR_IOP <= SRR_IOPar_REG;
		else
			SRR_IOP <= (others => 'Z');
		end if;
	end if;
end process;

--Register read data
process(CLK) 
begin
	if(CLK'event and CLK = '0') then 
		if (SRAM_state = st7_RegRead) then
			SRR_IO_RD <= SRR_IO;
		else
			SRR_IO_RD <= SRR_IO_RD;
		end if;
	end if;
end process;

--Register read data -- parity bits.
process(CLK) 
begin
	if(CLK'event and CLK = '0') then 
		if (SRAM_state = st7_RegRead) then
			SRR_IOPar_BUS <= SRR_IOP;
		else
			SRR_IOPar_BUS <= SRR_IOPar_BUS;
		end if;
	end if;
end process;

--SRAM component Acknowledge when read/write complete.
process (CLK)
begin
	if(CLK'event and CLK = '0') then 
      if (SRAM_state = st8_ACK) then
          SRR_ACK <= '1'; 
		else
			 SRR_ACK <= '0';
      end if;
	end if;
end process;
---------------------------------------------------------------------------------
--SRAM Registers
-- The logic below controls the features for writing data from 
-- FPGA into the Dual-Port SRAM.  The features include a automatic DMA initiator 
-- for both channels and an user defined reset on DMA.  Furthermore there is a
-- settable internal address counter that provides the address to the Dual-Port
-- SRAM.    


-------------SRAM Register Write Strobes-----------------

  --SRAM Control Register Byte 0
  process (CLK)
  begin
      if (CLK'event and CLK = '1') then
         SRAM_CONTROL_Stb0 <= SRAM_CONTROL_Adr and not ADS_n  and
	                           not LBE0_n and LW_R_n;
      end if;
  end process;
  						  
  --SRAM Internal Address Register is only accessible by a 32-bit data transfer.
  process (CLK)
  begin
      if (CLK'event and CLK = '1') then
         SRAM_IntAdr_StbAll_Reg1 <= SRAM_IntAdr and not ADS_n  and
                                not LBE0_n and not LBE1_n and not LBE2_n 
						  and not LBE3_n and LW_R_n;
      end if;
  end process;
  
  --Add Second clock cycle to Load Internal SRAM Address register
  process (CLK)
  begin
      if (CLK'event and CLK = '1') then
         SRAM_IntAdr_StbAll_Reg2 <= SRAM_IntAdr_StbAll_Reg1;
      end if;
  end process;

  SRAM_IntAdr_StbAll <= SRAM_IntAdr_StbAll_Reg1 or SRAM_IntAdr_StbAll_Reg2;

  --SRAM DMA Channel 0 Threshold Reg is only accessible by a 32-bit data transfer.
  process (CLK)
  begin
      if (CLK'event and CLK = '1') then
         SRAM_DMA0Thr_StbAll <= SRAM_DMA0Thr_Adr and not ADS_n  and
                                not LBE0_n and not LBE1_n and not LBE2_n 
						  and not LBE3_n and LW_R_n;
      end if;
  end process;
	
  --SRAM DMA Channel 1 Threshold Reg is only accessible by a 32-bit data transfer.
  process (CLK)
  begin
      if (CLK'event and CLK = '1') then
         SRAM_DMA1Thr_StbAll <= SRAM_DMA1Thr_Adr and not ADS_n  and
                                not LBE0_n and not LBE1_n and not LBE2_n 
						  and not LBE3_n and LW_R_n;
      end if;
  end process;
  
  --SRAM RESET Value after DMA0 Register --All bytes
  process (CLK)
  begin
      if (CLK'event and CLK = '1') then
         SRAM_RESET0_StbAll <= SRAM_Reset0_Adr and not ADS_n and
	                           not LBE0_n and not LBE1_n and not LBE2_n 
						  and not LBE3_n and LW_R_n;
      end if;
  end process;

  --SRAM RESET Value after DMA1 Register --All bytes
  process (CLK)
  begin
      if (CLK'event and CLK = '1') then
         SRAM_RESET1_StbAll <= SRAM_Reset1_Adr and not ADS_n and
	                           not LBE0_n and not LBE1_n and not LBE2_n 
						  and not LBE3_n and LW_R_n;
      end if;
  end process;


-----------------SRAM REGISTERS ----------------------

  --SRAM CONTROL REGISTER: SRAM Enable-- Bit 0


  SRAM_WRITE_EN_Reset <= RESET;
 
  process(CLK, SRAM_WRITE_EN_Reset)
  begin
	if (CLK'event and CLK = '1') then
		if (SRAM_WRITE_EN_Reset = '1') then
			SRAM_WRITE_EN <= '0';
		elsif (SRAM_CONTROL_Stb0 = '1') then
			SRAM_WRITE_EN <= LD(0);
		else
			SRAM_WRITE_EN <= SRAM_WRITE_EN; 
		end if;
	end if;
  end process;
 
  SRAM_ENABLED <= SRAM_WRITE_EN;
	   
  --SRAM CONTROL REGISTER: DMA0 Enable - Bit 1
  process(CLK, RESET)
  begin
  	if (CLK'event and CLK = '1') then
		if (RESET = '1') then
			SRAM_DMA0EN <= '0';
		elsif (SRAM_CONTROL_Stb0 = '1') then
			SRAM_DMA0EN <= LD(1);	--Enable/Disable DMA0.
		else
			SRAM_DMA0EN <= SRAM_DMA0EN;
		end if;
	end if;
  end process;
 
  --SRAM CONTROL REGISTER: DMA1 Enable - Bit 2
  process(CLK, RESET)
  begin
 	if (CLK'event and CLK = '1') then
		if (RESET = '1') then
			SRAM_DMA1EN <= '0';
		elsif (SRAM_CONTROL_Stb0 = '1') then
			SRAM_DMA1EN <= LD(2); --Enable/Disable DMA1.
		else
			SRAM_DMA1EN <= SRAM_DMA1EN;
		end if;
	end if;
  end process;

  --SRAM CONTROL REGISTER: Reset on DMA Threshold 0 Enable - Bit 3
  process(CLK, RESET)
  begin
 	if (CLK'event and CLK = '1') then
		if (RESET = '1') then
			SRAM_Reset0_EN <= '0';
		elsif (SRAM_CONTROL_Stb0 = '1') then
			SRAM_Reset0_EN <= LD(3); 
		else
			SRAM_Reset0_EN <= SRAM_Reset0_EN;
		end if;
	end if;
  end process;

  --SRAM CONTROL REGISTER: Reset on DMA Threshold 1 Enable - Bit 4
  process(CLK, RESET)
  begin
  	if (CLK'event and CLK = '1') then
		if (RESET = '1') then
			SRAM_Reset1_EN <= '0';
		elsif (SRAM_CONTROL_Stb0 = '1') then
			SRAM_Reset1_EN <= LD(4); 
		else
			SRAM_Reset1_EN <= SRAM_Reset1_EN;
		end if;
	end if;
  end process;

  --DMA0 THRESHOLD REGISTER:
  process(CLK, RESET)
  begin
  	if (CLK'event and CLK = '1') then
		if (RESET = '1') then
			DMA0_THRESHOLD <= (others => '1');
			DMA0_THRESHOLD(addr_max) <= '0'; --set msb to logic 0 at reset.  all others 1.
		elsif (SRAM_DMA0Thr_StbAll = '1') then
			DMA0_THRESHOLD <= LD(addr_max downto 0);
		else
			DMA0_THRESHOLD <= DMA0_THRESHOLD; 
		end if;
	end if;
  end process;


  --DMA1 THRESHOLD REGISTER:
  process(CLK, RESET)
  begin

  	if (CLK'event and CLK = '1') then
		if (RESET = '1') then
			DMA1_THRESHOLD <= (others => '1'); --initialize all bits to logic high.
		elsif (SRAM_DMA1Thr_StbAll = '1') then
			DMA1_THRESHOLD <= LD(addr_max downto 0);
		else
			DMA1_THRESHOLD <= DMA1_THRESHOLD; 
		end if;
	end if;
  end process;

  --DMA0 Event
  process(CLK)
  begin
	if(CLK'event and CLK = '1') then
		if (DMA0_THRESHOLD = SRAM_ADD_Count) then
			DMA0_EVENT <= '1';
		else
			DMA0_EVENT <= '0';
		end if;
	end if;
  end process;

  process(CLK,RESET)
  begin

	if (CLK'event and CLK = '1') then
		if(RESET = '1') then
			DMA0_REQ <= '0';
		elsif(SRAM_State = st8_ACK) then
			DMA0_REQ <= DMA0_EVENT and SRAM_DMA0EN;
		end if;
	end if;
  end process;
 
    
  --DMA1 Event
  process(CLK)
  begin
	if(CLK'event and CLK = '1') then
		if (DMA1_THRESHOLD = SRAM_ADD_Count) then
			DMA1_EVENT <= '1';
		else
			DMA1_EVENT <= '0';
		end if;
	end if;
  end process;

  process(CLK,RESET)
  begin

	if (CLK'event and CLK = '1') then
		if(RESET = '1') then
			DMA1_REQ <= '0';
		elsif(SRAM_State = st8_ACK) then
			DMA1_REQ <= DMA1_EVENT and SRAM_DMA1EN;-- and ADDInc_Delay3;
		end if;
	end if;
  end process;


  --RESET on DMA0 REGISTER
  process(CLK, RESET)
  begin

  if (CLK'event and CLK = '1') then
	  	if (RESET = '1') then
			DMA0_RESET <= (others => '0');
		elsif (SRAM_RESET0_StbAll = '1') then
			DMA0_RESET <= LD(addr_max downto 0);
		else
			DMA0_RESET <= DMA0_RESET; 
		end if;
	end if;
  end process;

  --RESET on DMA1 REGISTER
  process(CLK, RESET)
  begin
  	if (CLK'event and CLK = '1') then
		if (RESET = '1') then
			DMA1_RESET <= (others => '0');
		elsif (SRAM_RESET1_StbAll = '1') then
			DMA1_RESET <= LD(addr_max downto 0);
		else
			DMA1_RESET <= DMA1_RESET; 
		end if;
	end if;
  end process;

-------------------- ADDRESS Logic--------------------

  --Multiplexer to determine load value for counter.
  -- 1. Value from writing to the Internal Address Register.
  -- 2. Reset Register 0 on DMA0. 
  -- 3. Reset Register 1 on DMA1.
  						
   ADD_RESET_VALUE(0) <= (SRAM_IntAdr_StbAll and LD(0)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(0) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(0) and not SRAM_IntAdr_StbAll);
  ADD_RESET_VALUE(1) <= (SRAM_IntAdr_StbAll and LD(1)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(1) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(1) and not SRAM_IntAdr_StbAll);
  ADD_RESET_VALUE(2) <= (SRAM_IntAdr_StbAll and LD(2)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(2) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(2) and not SRAM_IntAdr_StbAll);
  ADD_RESET_VALUE(3) <= (SRAM_IntAdr_StbAll and LD(3)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(3) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(3) and not SRAM_IntAdr_StbAll);
  ADD_RESET_VALUE(4) <= (SRAM_IntAdr_StbAll and LD(4)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(4) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(4) and not SRAM_IntAdr_StbAll) ;
  ADD_RESET_VALUE(5) <=  (SRAM_IntAdr_StbAll and LD(5)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(5) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(5) and not SRAM_IntAdr_StbAll);
  ADD_RESET_VALUE(6) <=  (SRAM_IntAdr_StbAll and LD(6)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(6) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(6) and not SRAM_IntAdr_StbAll) ;
  ADD_RESET_VALUE(7) <= (SRAM_IntAdr_StbAll and LD(7)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(7) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(7) and not SRAM_IntAdr_StbAll);
  ADD_RESET_VALUE(8) <= (SRAM_IntAdr_StbAll and LD(8)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(8) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(8) and not SRAM_IntAdr_StbAll) ;
  ADD_RESET_VALUE(9) <=  (SRAM_IntAdr_StbAll and LD(9)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(9) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(9) and not SRAM_IntAdr_StbAll) ;
  ADD_RESET_VALUE(10) <= (SRAM_IntAdr_StbAll and LD(10)) or   
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(10) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(10) and not SRAM_IntAdr_StbAll) ;
  ADD_RESET_VALUE(11) <=(SRAM_IntAdr_StbAll and LD(11)) or  
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(11) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(11) and not SRAM_IntAdr_StbAll);
  ADD_RESET_VALUE(12) <= (SRAM_IntAdr_StbAll and LD(12)) or  
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(12) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(12) and not SRAM_IntAdr_StbAll) ;
  ADD_RESET_VALUE(13) <= (SRAM_IntAdr_StbAll and LD(13)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(13) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(13) and not SRAM_IntAdr_StbAll);
  ADD_RESET_VALUE(14) <= (SRAM_IntAdr_StbAll and LD(14)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(14) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(14) and not SRAM_IntAdr_StbAll);
  ADD_RESET_VALUE(15) <= (SRAM_IntAdr_StbAll and LD(15)) or 
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(15) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(15) and not SRAM_IntAdr_StbAll);
  ADD_RESET_VALUE(16) <= (SRAM_IntAdr_StbAll and LD(16)) or  
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(16) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(16) and not SRAM_IntAdr_StbAll);
  ADD_RESET_VALUE(17) <= (SRAM_IntAdr_StbAll and LD(17)) or  
  					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(17) and not SRAM_IntAdr_StbAll) or
  					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(17) and not SRAM_IntAdr_StbAll);
--  ADD_RESET_VALUE(18) <= (SRAM_IntAdr_StbAll and LD(18)) or  
-- 					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(18)) or
-- 					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(18));
-- ADD_RESET_VALUE(19) <= (SRAM_IntAdr_StbAll and LD(19)) or  
-- 					(DMA0_EVENT and SRAM_Reset0_EN and DMA0_RESET(19)) or
-- 					(DMA1_EVENT and SRAM_Reset1_EN and DMA1_RESET(19));
  
 
  Add_Reset <= (SRAM_IntAdr_StbAll and LD(31)) or RESET; --Reset address to 0x0.
    
  --Address load conditions

  Add_Load_DMA <=  (DMA0_EVENT and SRAM_Reset0_EN and SRAM_Read_Adr2) or --DMA0Resetload
			         (DMA1_EVENT and SRAM_Reset1_EN and SRAM_Read_Adr2);	  --DMA1Resetload
			
  Add_Load_Register <=  (not Add_Reset and SRAM_IntAdr_StbAll_Reg2);	 --Register load

--Address Counter. Reset sets address to 0x0. Will load on DMA0/DMA1 after the last write to that
-- register or will load if Internal Address register (Bar 2 0x8040 is written).  Will increment with
-- either a read/write of Bar 2 0x803C)
  process (CLK)
  begin
      if (CLK'event and CLK = '1') then
			if (Add_Reset = '1') then
				SRAM_ADD_Count(addr_max downto 0) <= (others => '0');  
			elsif ((SRAM_state = st8_ACK and Add_Load_DMA = '1') or (Add_Load_Register = '1')) then
					SRAM_ADD_Count <= ADD_RESET_VALUE;
			elsif(SRAM_state = st8_ACK and SRAM_Read_Adr2 = '1') then
				SRAM_ADD_Count <= SRAM_ADD_Count + 1;
			else
				SRAM_ADD_Count <= SRAM_ADD_Count;
        end if;
      end if;
  end process;

-- Delay address for one clock cycle to allow SRAM to complete operations.
  process(CLK)
  begin
	if(CLK'event and CLK = '1') then 
		SRR_A(addr_max downto 0) <= SRAM_ADD_Count;	
	end if;
  end process;	
  
  SRR_A(18) <= '0'; --not used in standard model
  SRR_A(19) <= '0'; --not used in standard model
  
   --Assigned inputs from Dual-Port SRAM must be used to prevent synthesis errors.
  NotUsed_Group <= SRR_INTn or SRR_COLn;
 	
  --Read back of SRAM Registers
  READ_DATA(0) <=     (SRAM_Read_Adr and SRR_IO_RD(0)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(32)) or
                      (SRAM_CONTROL_Adr and SRAM_WRITE_EN) or
				  (SRAM_IntAdr and SRAM_ADD_Count(0)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(0)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(0)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(0)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(0));

  READ_DATA(1) <=     (SRAM_Read_Adr and SRR_IO_RD(1)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(33)) or
                      (SRAM_CONTROL_Adr and SRAM_DMA0EN) or
				  (SRAM_IntAdr and SRAM_ADD_Count(1)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(1)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(1)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(1)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(1));

  READ_DATA(2) <=  	  (SRAM_Read_Adr and SRR_IO_RD(2)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(34)) or
                      (SRAM_CONTROL_Adr and SRAM_DMA1EN) or
				  (SRAM_IntAdr and SRAM_ADD_Count(2)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(2)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(2)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(2)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(2));

  READ_DATA(3) <=  	  (SRAM_Read_Adr and SRR_IO_RD(3)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(35)) or
                      (SRAM_CONTROL_Adr and SRAM_Reset0_EN) or
				  (SRAM_IntAdr and SRAM_ADD_Count(3)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(3)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(3)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(3)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(3));

  READ_DATA(4) <=  	  (SRAM_Read_Adr and SRR_IO_RD(4)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(36)) or
                      (SRAM_CONTROL_Adr and SRAM_Reset1_EN) or
				  (SRAM_IntAdr and SRAM_ADD_Count(4)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(4)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(4)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(4)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(4));
 
  READ_DATA(5) <=  	  (SRAM_Read_Adr and SRR_IO_RD(5)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(37)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(5)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(5)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(5)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(5)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(5));

  READ_DATA(6) <=  	  (SRAM_Read_Adr and SRR_IO_RD(6)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(38)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(6)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(6)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(6)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(6)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(6));

  READ_DATA(7) <=  	  (SRAM_Read_Adr and SRR_IO_RD(7)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(39)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(7)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(7)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(7)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(7)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(7));

  READ_DATA(8) <=  	  (SRAM_Read_Adr and SRR_IO_RD(8)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(40)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(8)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(8)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(8)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(8)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(8));

  READ_DATA(9) <=  	  (SRAM_Read_Adr and SRR_IO_RD(9)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(41)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(9)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(9)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(9)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(9)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(9));

  READ_DATA(10) <=    (SRAM_Read_Adr and SRR_IO_RD(10)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(42)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(10)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(10)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(10)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(10)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(10));

  READ_DATA(11) <=    (SRAM_Read_Adr and SRR_IO_RD(11)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(43)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(11)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(11)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(11)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(11)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(11));

  READ_DATA(12) <=    (SRAM_Read_Adr and SRR_IO_RD(12)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(44)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(12)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(12)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(12)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(12)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(12));

  READ_DATA(13) <=    (SRAM_Read_Adr and SRR_IO_RD(13)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(45)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(13)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(13)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(13)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(13)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(13));

  READ_DATA(14) <=    (SRAM_Read_Adr and SRR_IO_RD(14)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(46)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(14)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(14)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(14)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(14)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(14));

  READ_DATA(15) <=    (SRAM_Read_Adr and SRR_IO_RD(15)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(47)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(15)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(15)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(15)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(15)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(15));

  READ_DATA(16) <=    (SRAM_Read_Adr and SRR_IO_RD(16)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(48)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(16)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(16)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(16)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(16)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(16));

  READ_DATA(17) <=    (SRAM_Read_Adr and SRR_IO_RD(17)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(49)) or
				  (SRAM_IntAdr and SRAM_ADD_Count(17)) or
				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(17)) or
				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(17)) or
				  (SRAM_Reset0_Adr and DMA0_RESET(17)) or
				  (SRAM_Reset1_Adr and DMA1_RESET(17));

  READ_DATA(18) <= (SRAM_Read_Adr and SRR_IO_RD(18)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(50));--or Removed for standard model
--				  (SRAM_IntAdr and SRAM_ADD_Count(18)) or
--				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(18)) or
--				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(18)) or
--				  (SRAM_Reset0_Adr and DMA0_RESET(18)) or
--				  (SRAM_Reset1_Adr and DMA1_RESET(18));  
  READ_DATA(19) <= (SRAM_Read_Adr and SRR_IO_RD(19)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(51));-- or  Removed for standard model.
--				  (SRAM_IntAdr and SRAM_ADD_Count(19)) or
--				  (SRAM_DMA0Thr_Adr and DMA0_THRESHOLD(19)) or
--				  (SRAM_DMA1Thr_Adr and DMA1_THRESHOLD(19)) or
--				  (SRAM_Reset0_Adr and DMA0_RESET(19)) or
--				  (SRAM_Reset1_Adr and DMA1_RESET(19));  
  READ_DATA(20) <= (SRAM_Read_Adr and SRR_IO_RD(20)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(52));  
  READ_DATA(21) <= (SRAM_Read_Adr and SRR_IO_RD(21)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(53));  
  READ_DATA(22) <= (SRAM_Read_Adr and SRR_IO_RD(22)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(54));  
  READ_DATA(23) <= (SRAM_Read_Adr and SRR_IO_RD(23)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(55));  
  READ_DATA(24) <= (SRAM_Read_Adr and SRR_IO_RD(24)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(56));  
  READ_DATA(25) <= (SRAM_Read_Adr and SRR_IO_RD(25)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(57));  
  READ_DATA(26) <= (SRAM_Read_Adr and SRR_IO_RD(26)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(58));  
  READ_DATA(27) <= (SRAM_Read_Adr and SRR_IO_RD(27)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(59));  
  READ_DATA(28) <= (SRAM_Read_Adr and SRR_IO_RD(28)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(60));  
  READ_DATA(29) <= (SRAM_Read_Adr and SRR_IO_RD(29)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(61));  
  READ_DATA(30) <= (SRAM_Read_Adr and SRR_IO_RD(30)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(62));  
  READ_DATA(31) <= (SRAM_IntAdr and NotUsed_Group and Add_Reset) or 
                   (SRAM_Read_Adr and SRR_IO_RD(31)) or
                      (SRAM_Read_Adr2 and SRR_IO_RD(63));


END  DP_SRAM_ARCH;

