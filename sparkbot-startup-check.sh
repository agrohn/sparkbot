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

function ShouldSparkbotBeRunning()
{
    [ -f "/home/pi/spark-is-open.txt" ]
    result=$?
    if [ $result -eq 0 ]; then
	echo 1
    else
	echo 0
    fi

}

function RunSparkbot()
{
    echo "running sparkbot"
    # get rid of old logs
    /bin/rm -f /home/pi/sparkbot/{log.html,report.html,output.xml,selenium-screenshot-*.png}
    echo Session start: `date --iso-8601=s` >> /home/pi/sparkbot/usage.log
    DISPLAY=:0 robot --exitonfailure sparkbot.robot
    echo Session stop: `date --iso-8601=s` >> /home/pi/sparkbot/usage.log
}

function IsSparkbotRunning()
{
    result=$(lsof -t /home/pi/sparkbot/sparkbot.robot)
    if [ "$result" != "" ]; then
	echo 1
    else
	echo 0
    fi
}


function Run()
{
    DISPLAY=:0 fbsetbg -f /home/pi/.fluxbox/backgrounds/spark_tausta_painakytkinta.png 
    while [ 1 ]; do
	shouldBeActive=$(ShouldSparkbotBeRunning)
	isActive=$(IsSparkbotRunning)
	if [ $shouldBeActive -eq 1 ] && [ $isActive -eq 0 ]; then
	    DISPLAY=:0 mplayer -rootwin video/0001-0070.mp4 &
	    RunSparkbot
	    DISPLAY=:0 fbsetbg -f /home/pi/.fluxbox/backgrounds/spark_tausta_painakytkinta.png 
	fi
	sleep 1
    done
}
# Run only if we are not running yet 
num_running_instances=$(lsof -t /home/pi/sparkbot/sparkbot-startup-check.sh|wc -w)
if [ ${num_running_instances} -eq 1 ]; then 
    Run
else
    echo "Already running, exiting."
fi

