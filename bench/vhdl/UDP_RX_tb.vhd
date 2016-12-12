--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   16:53:03 06/10/2011
-- Design Name:
-- Module Name:   C:/Users/pjf/Documents/projects/fpga/xilinx/Network/ip1/UDP_RX_tb.vhd
-- Project Name:  ip1
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: UDP_RX
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
library vunit_lib;
context vunit_lib.vunit_context;
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.axi.all;
use work.ipv4_types.all;

entity UDP_RX_tb is
  generic (runner_cfg : string := runner_cfg_default);
end UDP_RX_tb;

architecture behavior of UDP_RX_tb is

  -- Component Declaration for the Unit Under Test (UUT)

  component UDP_RX
    port(
      -- UDP Layer signals
      udp_rxo      : inout udp_rx_type;
      udp_rx_start : out   std_logic;   -- indicates receipt of udp header
      -- system signals
      clk          : in    std_logic;
      reset        : in    std_logic;
      -- IP layer RX signals
      ip_rx_start  : in    std_logic;   -- indicates receipt of ip header
      ip_rx        : inout ipv4_rx_type
      );
  end component;


  --Inputs
  signal clk         : std_logic := '0';
  signal reset       : std_logic := '0';
  signal ip_rx_start : std_logic := '0';

  --BiDirs
  signal udp_rxo : udp_rx_type;
  signal ip_rx   : ipv4_rx_type;

  --Outputs
  signal udp_rx_start : std_logic;

  -- Clock period definitions
  constant clk_period : time := 8 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : UDP_RX port map (
    udp_rxo      => udp_rxo,
    udp_rx_start => udp_rx_start,
    clk          => clk,
    reset        => reset,
    ip_rx_start  => ip_rx_start,
    ip_rx        => ip_rx
    );

  -- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process
  stim_proc : process
    procedure reset_uut is
    begin
      -- hold reset state for 100 ns.
      wait for 100 ns;
      ip_rx_start                <= '0';
      ip_rx.data.data_in_valid   <= '0';
      ip_rx.data.data_in_last    <= '0';
      ip_rx.hdr.is_valid         <= '0';
      ip_rx.hdr.protocol         <= (others => '0');
      ip_rx.hdr.num_frame_errors <= (others => '0');
      ip_rx.hdr.last_error_code  <= (others => '0');
      ip_rx.hdr.is_broadcast     <= '0';

      reset <= '1';
      wait for clk_period*10;
      reset <= '0';
      wait for clk_period*5;
      reset <= '0';
    end;

    procedure test_reset_conditions is
    begin
      -- check reset conditions
      assert udp_rx_start = '0' report "udp_rx_start not initialised correctly on reset";
      assert udp_rxo.hdr.is_valid = '0' report "udp_rxo.hdr.is_valid not initialised correctly on reset";
      assert udp_rxo.data.data_in = x"00" report "udp_rxo.data.data_in not initialised correctly on reset";
      assert udp_rxo.data.data_in_valid = '0' report "udp_rxo.data.data_in_valid not initialised correctly on reset";
      assert udp_rxo.data.data_in_last = '0' report "udp_rxo.data.data_in_last not initialised correctly on reset";
    end;

    procedure test_that_one_packet_can_be_received is
    begin
      report "T1: Send an ip frame with IP src ip_address c0a80501, udp protocol from port x1498 to port x8724 and 3 bytes data";
      ip_rx_start              <= '1';
      ip_rx.data.data_in_valid <= '0';
      ip_rx.data.data_in_last  <= '0';
      ip_rx.hdr.is_valid       <= '1';
      ip_rx.hdr.protocol       <= x"11";                       -- UDP
      ip_rx.hdr.data_length    <= x"000b";
      ip_rx.hdr.src_ip_addr    <= x"c0a80501";
      wait for clk_period*3;
      -- now send the data
      ip_rx.data.data_in_valid <= '1';
      ip_rx.data.data_in       <= x"14"; wait for clk_period;  -- src port
      ip_rx.data.data_in       <= x"98"; wait for clk_period;
      ip_rx.data.data_in       <= x"87"; wait for clk_period;  -- dst port
      ip_rx.data.data_in       <= x"24"; wait for clk_period;
      ip_rx.data.data_in       <= x"00"; wait for clk_period;  -- len (hdr + data)
      ip_rx.data.data_in       <= x"0b"; wait for clk_period;
      ip_rx.data.data_in       <= x"00"; wait for clk_period;  -- mty cks
      ip_rx.data.data_in       <= x"00"; wait for clk_period;
      -- udp hdr should be valid
      assert udp_rxo.hdr.is_valid = '1' report "T1: udp_rxo.hdr.is_valid not set";

      ip_rx.data.data_in <= x"41"; wait for clk_period;  -- data

      assert udp_rxo.hdr.src_ip_addr = x"c0a80501" report "T1: udp_rxo.hdr.src_ip_addr not set correctly";
      assert udp_rxo.hdr.src_port = x"1498" report "T1: udp_rxo.hdr.src_port not set correctly";
      assert udp_rxo.hdr.dst_port = x"8724" report "T1: udp_rxo.hdr.dst_port not set correctly";
      assert udp_rxo.hdr.data_length = x"0003" report "T1: udp_rxo.hdr.data_length not set correctly";
      assert udp_rx_start = '1' report "T1: udp_rx_start not set";
      assert udp_rxo.data.data_in_valid = '1' report "T1: udp_rxo.data.data_in_valid not set";

      ip_rx.data.data_in       <= x"45"; wait for clk_period;  -- data
      ip_rx.data.data_in       <= x"49"; ip_rx.data.data_in_last <= '1'; wait for clk_period;
      assert udp_rxo.data.data_in_last = '1' report "T1: udp_rxo.data.data_in_last not set";
      ip_rx_start              <= '0';
      ip_rx.data.data_in_valid <= '0';
      ip_rx.data.data_in_last  <= '0';
      ip_rx.hdr.is_valid       <= '0';
      wait for clk_period;
      assert udp_rxo.data.data_in = x"00" report "T1: udp_rxo.data.data_in not cleared";
      assert udp_rxo.data.data_in_valid = '0' report "T1: udp_rxo.data.data_in_valid not cleared";
      assert udp_rxo.data.data_in_last = '0' report "T1: udp_rxo.data.data_in_last not cleared";

      wait for clk_period;
    end;

    procedure test_that_second_packet_can_be_received is
    begin
      report "T2: Send an ip frame with IP src ip_address c0a80501, udp protocol from port x7623 to port x0365 and 5 bytes data";

      ip_rx_start              <= '1';
      ip_rx.data.data_in_valid <= '0';
      ip_rx.data.data_in_last  <= '0';
      ip_rx.hdr.is_valid       <= '1';
      ip_rx.hdr.protocol       <= x"11";                       -- UDP
      ip_rx.hdr.data_length    <= x"000b";
      ip_rx.hdr.src_ip_addr    <= x"c0a80501";
      wait for clk_period*3;
      -- now send the data
      ip_rx.data.data_in_valid <= '1';
      ip_rx.data.data_in       <= x"76"; wait for clk_period;  -- src port
      ip_rx.data.data_in       <= x"23"; wait for clk_period;
      ip_rx.data.data_in       <= x"03"; wait for clk_period;  -- dst port
      ip_rx.data.data_in       <= x"65"; wait for clk_period;
      ip_rx.data.data_in       <= x"00"; wait for clk_period;  -- len (hdr + data)
      ip_rx.data.data_in       <= x"0d"; wait for clk_period;
      ip_rx.data.data_in       <= x"00"; wait for clk_period;  -- mty cks
      ip_rx.data.data_in       <= x"00"; wait for clk_period;
      -- udp hdr should be valid
      assert udp_rxo.hdr.is_valid = '1' report "T2: udp_rxo.hdr.is_valid not set";

      ip_rx.data.data_in <= x"17"; wait for clk_period;  -- data

      assert udp_rxo.hdr.src_ip_addr = x"c0a80501" report "T2: udp_rxo.hdr.src_ip_addr not set correctly";
      assert udp_rxo.hdr.src_port = x"7623" report "T2: udp_rxo.hdr.src_port not set correctly";
      assert udp_rxo.hdr.dst_port = x"0365" report "T2: udp_rxo.hdr.dst_port not set correctly";
      assert udp_rxo.hdr.data_length = x"0005" report "T2: udp_rxo.hdr.data_length not set correctly";
      assert udp_rx_start = '1' report "T2: udp_rx_start not set";
      assert udp_rxo.data.data_in_valid = '1' report "T2: udp_rxo.data.data_in_valid not set";

      ip_rx.data.data_in       <= x"37"; wait for clk_period;  -- data
      ip_rx.data.data_in       <= x"57"; wait for clk_period;  -- data
      ip_rx.data.data_in       <= x"73"; wait for clk_period;  -- data
      ip_rx.data.data_in       <= x"f9"; ip_rx.data.data_in_last <= '1'; wait for clk_period;
      assert udp_rxo.data.data_in_last = '1' report "T2: udp_rxo.data.data_in_last not set";
      ip_rx_start              <= '0';
      ip_rx.data.data_in_valid <= '0';
      ip_rx.data.data_in_last  <= '0';
      ip_rx.hdr.is_valid       <= '0';
      wait for clk_period;
      assert udp_rxo.data.data_in = x"00" report "T2: udp_rxo.data.data_in not cleared";
      assert udp_rxo.data.data_in_valid = '0' report "T2: udp_rxo.data.data_in_valid not cleared";
      assert udp_rxo.data.data_in_last = '0' report "T2: udp_rxo.data.data_in_last not cleared";
    end;

    procedure test_that_non_udp_packets_are_rejected is
    begin
      report "T3: Send an ip frame with IP src ip_address c0a80501, protocol x12 from port x7623 to port x0365 and 5 bytes data";

      ip_rx_start              <= '1';
      ip_rx.data.data_in_valid <= '0';
      ip_rx.data.data_in_last  <= '0';
      ip_rx.hdr.is_valid       <= '1';
      ip_rx.hdr.protocol       <= x"12";                       -- non-UDP
      ip_rx.hdr.data_length    <= x"000b";
      ip_rx.hdr.src_ip_addr    <= x"c0a80501";
      wait for clk_period*3;
      -- now send the data
      ip_rx.data.data_in_valid <= '1';
      ip_rx.data.data_in       <= x"76"; wait for clk_period;  -- src port
      ip_rx.data.data_in       <= x"23"; wait for clk_period;
      ip_rx.data.data_in       <= x"03"; wait for clk_period;  -- dst port
      ip_rx.data.data_in       <= x"65"; wait for clk_period;
      ip_rx.data.data_in       <= x"00"; wait for clk_period;  -- len (hdr + data)
      ip_rx.data.data_in       <= x"0d"; wait for clk_period;
      ip_rx.data.data_in       <= x"00"; wait for clk_period;  -- mty cks
      ip_rx.data.data_in       <= x"00"; wait for clk_period;
      -- udp hdr should be valid
      assert udp_rxo.hdr.is_valid = '0' report "T3: udp_rxo.hdr.is_valid incorrectly set";

      ip_rx.data.data_in <= x"17"; wait for clk_period;  -- data

      assert udp_rx_start = '0' report "T3: udp_rx_start incorrectly set";
      assert udp_rxo.data.data_in_valid = '0' report "T3: udp_rxo.data.data_in_valid not set";

      ip_rx.data.data_in       <= x"37"; wait for clk_period;  -- data
      ip_rx.data.data_in       <= x"57"; wait for clk_period;  -- data
      ip_rx.data.data_in       <= x"73"; wait for clk_period;  -- data
      ip_rx.data.data_in       <= x"f9"; ip_rx.data.data_in_last <= '1'; wait for clk_period;
      assert udp_rxo.data.data_in_last = '0' report "T3: udp_rxo.data.data_in_last incorrectly set";
      ip_rx_start              <= '0';
      ip_rx.data.data_in_valid <= '0';
      ip_rx.data.data_in_last  <= '0';
      ip_rx.hdr.is_valid       <= '0';
      wait for clk_period;
      assert udp_rxo.data.data_in = x"00" report "T3: udp_rxo.data.data_in not cleared";
      assert udp_rxo.data.data_in_valid = '0' report "T3: udp_rxo.data.data_in_valid not cleared";
      assert udp_rxo.data.data_in_last = '0' report "T3: udp_rxo.data.data_in_last not cleared";

      wait for clk_period;
    end;

    procedure test_that_a_udp_packet_can_be_received_after_a_non_udp_packet is
    begin
      report "T4: Send an ip frame with IP src ip_address c0a80501, udp protocol from port x1498 to port x8724 and 3 bytes data";

      ip_rx_start              <= '1';
      ip_rx.data.data_in_valid <= '0';
      ip_rx.data.data_in_last  <= '0';
      ip_rx.hdr.is_valid       <= '1';
      ip_rx.hdr.protocol       <= x"11";                       -- UDP
      ip_rx.hdr.data_length    <= x"000b";
      ip_rx.hdr.src_ip_addr    <= x"c0a80501";
      wait for clk_period*3;
      -- now send the data
      ip_rx.data.data_in_valid <= '1';
      ip_rx.data.data_in       <= x"14"; wait for clk_period;  -- src port
      ip_rx.data.data_in       <= x"98"; wait for clk_period;
      ip_rx.data.data_in       <= x"87"; wait for clk_period;  -- dst port
      ip_rx.data.data_in       <= x"24"; wait for clk_period;
      ip_rx.data.data_in       <= x"00"; wait for clk_period;  -- len (hdr + data)
      ip_rx.data.data_in       <= x"0b"; wait for clk_period;
      ip_rx.data.data_in       <= x"00"; wait for clk_period;  -- mty cks
      ip_rx.data.data_in       <= x"00"; wait for clk_period;
      -- udp hdr should be valid
      assert udp_rxo.hdr.is_valid = '1' report "T4: udp_rxo.hdr.is_valid not set";

      ip_rx.data.data_in <= x"41"; wait for clk_period;  -- data

      assert udp_rxo.hdr.src_ip_addr = x"c0a80501" report "T4: udp_rxo.hdr.src_ip_addr not set correctly";
      assert udp_rxo.hdr.src_port = x"1498" report "T4: udp_rxo.hdr.src_port not set correctly";
      assert udp_rxo.hdr.dst_port = x"8724" report "T4: udp_rxo.hdr.dst_port not set correctly";
      assert udp_rxo.hdr.data_length = x"0003" report "T4: udp_rxo.hdr.data_length not set correctly";
      assert udp_rx_start = '1' report "T4: udp_rx_start not set";
      assert udp_rxo.data.data_in_valid = '1' report "T4: udp_rxo.data.data_in_valid not set";

      ip_rx.data.data_in       <= x"45"; wait for clk_period;  -- data
      ip_rx.data.data_in       <= x"49"; ip_rx.data.data_in_last <= '1'; wait for clk_period;
      assert udp_rxo.data.data_in_last = '1' report "T4: udp_rxo.data.data_in_last not set";
      ip_rx_start              <= '0';
      ip_rx.data.data_in_valid <= '0';
      ip_rx.data.data_in_last  <= '0';
      ip_rx.hdr.is_valid       <= '0';
      wait for clk_period;
      assert udp_rxo.data.data_in = x"00" report "T4: udp_rxo.data.data_in not cleared";
      assert udp_rxo.data.data_in_valid = '0' report "T4: udp_rxo.data.data_in_valid not cleared";
      assert udp_rxo.data.data_in_last = '0' report "T4: udp_rxo.data.data_in_last not cleared";

      wait for clk_period;
    end;
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      if run("Test reset conditions") then
        reset_uut;
        test_reset_conditions;
      elsif run("Test that one packet can be received") then
        test_that_one_packet_can_be_received;
      elsif run("Test that many packets can be received") then
        test_that_second_packet_can_be_received;
      elsif run("Test that UDP and non-UDP packets can be mixed") then
        test_that_non_udp_packets_are_rejected;
        test_that_a_udp_packet_can_be_received_after_a_non_udp_packet;
      end if;
    end loop;

    report "--- end of tests ---";
    test_runner_cleanup(runner);
    wait;
  end process;

end;
-- vunit_pragma run_all_in_same_sim
