#!/bin/bash
#  This file is part of sparkbot.
#  Copyright (C) 2021 Anssi Gröhn

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.

if [ "$USER" != "root" ]; then
    echo $0 needs to run with root permissions. Try sudo $0.
    exit 1
fi

installdir=/lib/systemd/system
cp sparkbot-switch.service $installdir
cp sparkbot-trigger.service $installdir
systemctl enable sparkbot-switch.service 
systemctl enable sparkbot-trigger.service 
systemctl start sparkbot-switch.service 
systemctl start sparkbot-trigger.service 

