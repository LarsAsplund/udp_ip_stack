from vunit import VUnit
from os.path import join, dirname

prj = VUnit.from_argv()
root = dirname(__file__)

udp_ip_lib = prj.add_library('udp_ip_lib')
#udp_ip_lib.add_source_files(join(root, 'rtl', 'vhdl', '*.vhd'))
#udp_ip_lib.add_source_files(join(root, 'bench', 'vhdl', '*.vhd'))
udp_ip_lib.add_source_files(join(root, 'rtl', 'vhdl', 'UDP_TX.vhd'))
udp_ip_lib.add_source_files(join(root, 'rtl', 'vhdl', 'ipv4_types.vhd'))
udp_ip_lib.add_source_files(join(root, 'rtl', 'vhdl', 'arp_types.vhd'))
udp_ip_lib.add_source_files(join(root, 'rtl', 'vhdl', 'axi.vhd'))
udp_ip_lib.add_source_files(join(root, 'bench', 'vhdl', 'UDP_TX_tb.vhd'))

prj.main()
