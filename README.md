# spare-rctl
A spare Remote Control. Linux booting with VNC, SSH, etc.,

It just adds a boot menuentry in grub to start VNC, SSJ, etc., after booting linux.

### Procedure
just execute 'setup_sparerctl.py' python script with root privilege, enter required id or password, done.

##### CLI
```bash
$ sudo python setup_sparerctl.py -h
usage: setup_sparerctl.py [-h] [--remove] [-s] [-n] [-v] [-w] [-a] [name]

positional arguments:
  name         name of a command file for spareRctl.sh

optional arguments:
  -h, --help   show this help message and exit
  --remove     to REMOVE Entry (can't be used with others)
  -s, --ssh    to add ssh server
  -n, --novnc  to add novnc server
  -v, --vnc    to add vnc server
  -w, --wifi   to add wifi
  -a, --ap     to add access point
```
