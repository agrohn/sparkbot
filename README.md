# Sparkbot

This is an RPA (Robotic Process Automation) solution for connecting chrome browswer automatically
to specific room in Jitsi service. It is installed on Raspberry Pi OS, lite version is sufficient.
By default, switch program requires you to connect switch wires to pin 1 (using WiringPi numbering) and ground pin.
Please see `switch.cpp` for details, and alter as you see fit. 

Sparkbot collects session data (count, duration) into usage.log, but does not collect any user information as such.

Sparkbot is developed as part of [Base Camp](https://basecamp.karelia.fi/) project in [Karelia University of Applied Sciences](https://www.karelia.fi).

## Requirements

You need a X session and auto-login, and Raspberry Pi 4. 

`/etc/X11/Xwrapper.config`:
```
allowed_users = anybody
```

`/etc/rc.local`:
```
su -l pi -c startx
exit 0
```

```
apt-get install xinit xserver-xorg fluxbox chromium-browser chromium-chromedriver python3-pip mplayer

```

Also be sure to use build and install latest [WiringPi](https://github.com/WiringPi/WiringPi)
so switch program works on RPi4.

## Install robot framework

```
$ sudo pip3 install robotframework robotframework-seleniumlibrary
```

## Configure Jitsi room name

Edit `sparkbot.robot`, and change string REPLACE_WITH_YOUR_ROOM_NAME to appropriate one.

```
${MeetingUrl}           https://meet.jit.si/REPLACE_WITH_YOUR_ROOM_NAME
```

## Install trigger services

```
$ cd systemd
$ sudo ./install.sh
```

