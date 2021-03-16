Lojban Word Lookup Server
=========================

This is the containerized service infrastructure for vlasisku (
https://github.com/lojban/vlasisku ).

This is an LBCS instance (see https://github.com/lojban/lbcs/ ), which is why a
bunch of things in here are symlinks off into apparently empty space; you have
to have LBCS installed in /opt/lbcs/ for them to work.

That's also where the docs on how to like start and stop the service and so on
are.

Deploying A Fresh Instance
==========================

Assuming you have rootless podman working, you should be able to deploy a copy
of vlasisku with something like this:

As yourself or root or whatever:

$ cd /opt
$ git clone git@github.com:lojban/lbcs.git

As the system account you're using for the service:

$ cd ~
$ git clone git@github.com:lojban/vlasisku-containers.git vlasisku/
$ cd ~/vlasisku/containers/web
$ git clone https://github.com/lojban/vlasisku src/

vlasisku doesn't really have a database as such, so that should be enough.

$ cd ~/vlasisku
$ ./setup.sh

At that point systemctl commands should work as expected, although you'll probably want to test with:

$ ./run_container.sh web
$ ./run_container.sh bots

Running The Tests
-----------------

You can run the tests in another window with:

        $ podman exec -it web nosetests -v --with-doctest

Managing The Production Instance
================================

How To Reach The Server
-----------------------

Starting from stodi.lojban.org:

	$ ssh spvlasisku@lebna

Login is via ssh key, so if you think you should have access but that doesn't
work, email webmaster@lojban.org or find rlpowell in #lojban on freenode irc.

How To Restart The Server
-------------------------

	$ systemctl --user restart web

	$ systemctl --user restart bots

How To Show What Should Be Running
----------------------------------

	$ systemctl list-units --user --no-page -t service -a
	  UNIT                      LOAD   ACTIVE   SUB     DESCRIPTION
	  bots.service              loaded active   running vlasisku bots service, runs in the web container
	  dbus-broker.service       loaded active   running D-Bus User Message Bus
	  grub-boot-success.service loaded inactive dead    Mark boot as successful
	  web.service               loaded active   running main vlasisku container
	
	LOAD   = Reflects whether the unit definition was properly loaded.
	ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
	SUB    = The low-level unit activation state, values depend on unit type.
	
	4 loaded units listed.
	To show all installed unit files use 'systemctl list-unit-files'.

You can ignore the grub-boot and dbus units.

How To Show What Is Actually Running
------------------------------------
	$ systemctl --user status
	● lebna
	    State: running
	     Jobs: 0 queued
	   Failed: 0 units
	    Since: Sun 2021-03-14 22:17:00 PDT; 1 day 1h ago
	   CGroup: /user.slice/user-1100.slice/user@1100.service
	           ├─bots.service
	           │ ├─4181325 /bin/bash /home/spvlasisku/vlasisku/misc/run_bots.sh 2>&1
	           │ ├─4181328 sudo -u spvlasisku /usr/bin/podman exec web /srv/lojban/vlasisku/manage.py runbots
	           │ ├─4181334 /usr/bin/podman exec web /srv/lojban/vlasisku/manage.py runbots
	           │ └─4181349 /usr/bin/podman exec web /srv/lojban/vlasisku/manage.py runbots
	           ├─dbus-broker.service
	           │ ├─4077968 /usr/bin/dbus-broker-launch --scope user
	           │ └─4077969 dbus-broker --log 4 --controller 10 --machine-id 2565b24c05644e3eb3bf66e268191597 --max-bytes 100000000000000 --max-fds 25000000000000 --max-matches 5000000000
	           ├─user.slice
	           │ └─user-libpod_pod_e9cfd7450a767f9c27bef66c9b594c1ce2ddffb86eda9310c5316589c3caf0be.slice
		   [snip]
	           ├─web.service
	           │ ├─4180303 /bin/bash -x /home/spvlasisku/vlasisku/run_container.sh web 2>&1
		   [snip]
	           │ ├─4180951 containers-rootlessport-child
	           └─init.scope
	             ├─4074740 /usr/lib/systemd/systemd --user
	             └─4074742 (sd-pam)
	
	        $ systemctl --user status
	        ● jukni.digitalkingdom.org
	            State: running
	             Jobs: 0 queued
	           Failed: 0 units
	            Since: Sat 2018-01-06 22:54:47 PST; 6 days ago
	           CGroup: /user.slice/user-1087.slice/user@1087.service
	                   ├─dbus.service
	                   │ └─25260 /usr/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
	                   ├─init.scope
	                   │ ├─30255 /usr/lib/systemd/systemd --user
	                   │ └─30257 (sd-pam)
	                   └─vlasisku.service
	                     └─21277 /bin/bash -x /home/sampre_vs/vlasisku/run_container.sh 2>&1

How To Interact With The Instances Directly
-------------------------------------------

	$ sudo docker exec -it web bash 

This will give you a shell on the production web instance.

How To See Instance Logs
------------------------

	$ journalctl -n 50 -f -t web

This will give you the logs on the production web instance.

Thanks
======

* dag, for all of the original code
* Twey, for compiling the grammatical class usage scales.
* Adam Lopresto, for the Perl code compound2affixes mimics.
