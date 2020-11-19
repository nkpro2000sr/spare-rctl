""" To setup spare-rctl

Files:
    /opt/spareRctl.sh
    /usr/lib/systemd/system/sparerctl.service
    /root/spareRctl/{name}
    /root/spareRctl/spareRctl.log
"""

import os
import sys
import shutil
import re
import shlex
import argparse

WDIR = '/root/spareRctl/'

if os.getuid() != 0:
    print('Root privileges required !')
    sys.exit(1)

shutil.copy('spareRctl.sh', '/opt/spareRctl.sh')
shutil.copy('sparerctl.service', '/usr/lib/systemd/system/sparerctl.service')

parser = argparse.ArgumentParser()
parser.add_argument('name', default='0', nargs='?',
                    help='name of a command file for spareRctl.sh')
parser.add_argument('--remove', action='store_true',
                    help="to REMOVE Entry (can't be used with others)")
parser.add_argument('-s', '--ssh', action="store_true",
                    help='to add ssh server')
parser.add_argument('-n', '--novnc', action="store_true",
                    help='to add novnc server')
parser.add_argument('-v', '--vnc', action="store_true",
                    help='to add vnc server')
parser.add_argument('-w', '--wifi', action="store_true",
                    help='to add wifi')
parser.add_argument('-a', '--ap', action="store_true",
                    help='to add access point')
args = parser.parse_args()

if args.remove and (args.ssh or args.novnc or args.vnc or args.wifi or args.ap):
    parser.error('--remove and --ssh|--novnc|--vnc|--wifi|--ap are mutually exclusive.')

if not args.remove:
    MENUENTRY = re.compile(r'menuentry [\s\S]*?\n\}\n')

    with os.popen('grub-mkconfig 2> /dev/null') as grub_cfg:
        config = grub_cfg.read()

    first_menu = MENUENTRY.findall(config)[0].splitlines()
    menu_name = shlex.split(first_menu[0])[1]
    new_name = menu_name + f' (spareRctl:{args.name})'
    new_menu = first_menu[0].replace(shlex.quote(menu_name), shlex.quote(new_name)) + os.linesep
    LINUX_CMD = re.compile(r'\s+linux')

    for line in first_menu[1:]:
        if LINUX_CMD.match(line) is not None:
            line += f' --spareRctl:{args.name}'
        new_menu += line + os.linesep

ENTRY = re.compile(rf'\n#spareRctl:{args.name}\{{\n[\s\S]*?\n#spareRctl:{args.name}\}}\n')

with open('/etc/grub.d/40_custom', 'r') as custom:
    custom_menus = custom.read()

if args.remove:
    custom_menus = ENTRY.sub('', custom_menus)
elif ENTRY.search(custom_menus) is not None:
    custom_menus = ENTRY.sub(f'\n#spareRctl:{args.name}{{\n{new_menu}#spareRctl:{args.name}}}\n', custom_menus)
else:
    custom_menus += f'\n#spareRctl:{args.name}{{\n{new_menu}#spareRctl:{args.name}}}\n'

with open('/etc/grub.d/40_custom', 'w') as custom:
    custom.write(custom_menus)

if args.remove:
    os.remove(WDIR+args.name)
    sys.exit(0)

cmd = ''
if args.ssh:
    cmd += '--ssh' + os.linesep
if args.novnc:
    cmd += '--novnc' + os.linesep
    cmd += input('VNC password: ') + os.linesep
if args.vnc:
    cmd += '--vnc' + os.linesep
    cmd += input('VNC password: ') + os.linesep
if args.wifi:
    cmd += '--wifi' + os.linesep
    cmd += input('wifi ssid : ') + os.linesep
    cmd += input('wifi password : ') + os.linesep
elif args.ap:
    cmd += '--ap' + os.linesep
    cmd += input('ap ssid : ') + os.linesep
    cmd += input('ap password : ') + os.linesep

try:
    os.mkdir(WDIR)
except FileExistsError:
    pass
with open(WDIR+args.name, 'w') as cmd_file:
    cmd_file.write(cmd)
