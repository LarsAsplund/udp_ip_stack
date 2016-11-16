from vunit import VUnit
from os.path import join, dirname

prj = VUnit.from_argv()
root = dirname(__file__)

udp_ip_lib = prj.add_library('udp_ip_lib')
udp_ip_lib.add_source_files(join(root, 'rtl', 'vhdl', '*.vhd'))
udp_ip_lib.add_source_files(join(root, 'bench', 'vhdl', '*.vhd'))

prj.main()
