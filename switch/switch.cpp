/*
  This file is part of sparkbot.
  Copyright (C) 2021 Anssi Gröhn

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <wiringPi.h>
#include <iostream>
#include <stdexcept>
#include <unistd.h>
#include <fstream>
#include <filesystem>
////////////////////////////////////////////////////////////////////////////////
using namespace std;
////////////////////////////////////////////////////////////////////////////////
#define ButtonPin 1
////////////////////////////////////////////////////////////////////////////////
// How button action is handled.
// kPressAndHold -	connection is alive when button is held down.
// kPressAndRelease -	connection is made alive on first press. Connection
//			is killed on second press.
////////////////////////////////////////////////////////////////////////////////
enum Mode { kPressAndHold, kPressAndRelease };
////////////////////////////////////////////////////////////////////////////////
void CloseConnection( filesystem::path & controlFile )
{
  cout << "removing '" << absolute(controlFile) << "'\n";
  filesystem::remove(absolute(controlFile));
}
////////////////////////////////////////////////////////////////////////////////
void OpenConnection( filesystem::path & controlFile )
{
  string filename = absolute(controlFile);
  // touch file 
  fstream f(filename, fstream::app | fstream::out | fstream::ate);
  f.close();
  cout << "creating '" << filename << "'\n";
 
}
////////////////////////////////////////////////////////////////////////////////
void DisplayUsage( const char * name)
{
  cerr << "Usage:\n" << name  << " <mode> <file-to-create-on-press-and-delete-on-release>\n";
  cerr << "\t<mode>\t\tEither press-and-hold or press-and-release.\n\t\t\t";
  cerr << "press-and-hold mode requires button to be held down continuously in order to keep connection alive.\n";
  cerr << "\t\t\tpress-and-release needs also release and another press to open and close connection.\n";
    
}
////////////////////////////////////////////////////////////////////////////////
int main( int argc, char **argv )
{

  if ( argc < 3 )
  {
    DisplayUsage(argv[0]);
    return 1;
  }
  filesystem::path controlFile = filesystem::path(argv[2]);
  string modestr(argv[1]);
  if ( modestr != "press-and-hold" &&  modestr != "press-and-release" )
  {
    DisplayUsage(argv[0]);
    return 1;
  }
  
  Mode mode = modestr == "press-and-hold" ? kPressAndHold : kPressAndRelease;

  // init using default pin numbering (Pin 1 = GPIO1, BCM GPIO18)
  if ( wiringPiSetup() == -1 ) 
  {
    throw runtime_error("WiringPi setup failed!");
  }
  
  pinMode(ButtonPin, INPUT);
  pullUpDnControl(ButtonPin, PUD_UP);
  
  timespec loopDelay         = { 0, 50000000 }; // 0,5s
  timespec buttonJitterDelay = { 0,  1000000 }; // 10ms
  bool pressed = false;
  
  while (true)
  {

    if ( digitalRead(ButtonPin) == 0 )
    {

      // wait for button to settle
      nanosleep(&buttonJitterDelay, nullptr);
      
      // check is button down and first time while it is being pressed
      if ( digitalRead(ButtonPin) == 0 && pressed == false ) 
      {
	  pressed = true;
	  filesystem::file_status fs = filesystem::status(filesystem::absolute(controlFile));
	  if ( filesystem::exists(fs) && mode == kPressAndRelease )
	  {
	    CloseConnection(controlFile);
	  }
	  else
	  {
	    OpenConnection(controlFile);
	  }
	}
    }
    else if ( pressed == true )
    {

      // wait for button to settle
      nanosleep(&buttonJitterDelay, nullptr);
      // read again
      if ( digitalRead(ButtonPin) != 0 )
      {
	pressed = false;
	if ( mode == kPressAndHold )
	{
	  CloseConnection(controlFile);
	}
      }
    }
    nanosleep(&loopDelay, nullptr);
  }
  return 0;
}
