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

*** Settings ***
Library	     SeleniumLibrary
Library	     Process
Library	     OperatingSystem
Suite Teardown		Close Browser
*** Variables ***
${MeetingUrl}           https://meet.jit.si/REPLACE_WITH_YOUR_ROOM_NAME
${EightHoursInSeconds}	28800
${sparkOpenFile}	/home/pi/spark-is-open.txt
${BrowserProfileDir}	/home/pi/.config/chromium/Robot

*** Keywords ***
Open Jitsi
      ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
      Call Method    ${options}    add_argument    test-type
      Call Method    ${options}    add_argument    --disable-web-security
      Call Method    ${options}    add_argument    --use-fake-ui-for-media-stream
      Call Method    ${options}    add_argument    --user-data-dir\=/home/pi/.config/chromium/Robot
      Create WebDriver    Chrome    my_alias	   chrome_options=${options}
      Go To	${MeetingUrl}
      Maximize Browser Window
      Wait Until Element Is Visible	//div[@id="lobby-screen"]
      
Disable Chrome Extension Install


	# Alright, camera causes some overlay popping, so wait it through - unless camera is disabled
	Run Keyword And Ignore Error		Wait Until Element Is Visible	//div[@id="overlay"]
	Run Keyword And Ignore Error		Wait Until Element Is Not Visible	//div[@id="overlay"]	35 seconds
	
	Wait Until Page Contains Element	//div[@class="chrome-extension-banner"]
	Click Element	//div[@class="chrome-extension-banner"]/div/label/input[@type="checkbox"]
	Click Element	//div[@class="chrome-extension-banner__close-container"]
	Wait Until Element Is Not Visible	//div[@class="chrome-extension-banner__button-text"]

Inform About Timeout
     Input Text		//textarea[@id="usermsg"]	Tässä on tullut päivystettyä 8h putkeen
     Press Keys		//textarea[@id="usermsg"]	RETURN
     Sleep 		1 second
     Input Text		//textarea[@id="usermsg"]	Nyt loppuu, pohja se on minunkin säkissäni!
     Press Keys		//textarea[@id="usermsg"]	RETURN
     Sleep 		1 second
Insert Random Comment To Chat
     Input Text		//textarea[@id="usermsg"]	mielenkiintoista...
     Press Keys		//textarea[@id="usermsg"]	RETURN

Toggle Tile View
     Click Element	//body
     Wait Until Element Is Visible	//div[@aria-label="Toggle tile view"]
     Click Element			//div[@aria-label="Toggle tile view"]
                 


*** Test Cases ***
Login to meeting
      	 Open Jitsi
	 Log To Console		Jitsi is open, waiting for Cousteau...
      	 Wait Until Page Contains	Join meeting	timeout=15 seconds

Enter Meeting
   
      Set Focus To Element	//div[@class="prejoin-input-area"]/input
      Press Keys	//div[@class="prejoin-input-area"]/input	CTRL+a
      Sleep 		1 seconds
      Press Keys	//div[@class="prejoin-input-area"]/input	DELETE
      Sleep 		1 seconds
      Input Text	//div[@class="prejoin-input-area"]/input	Spark Local	

      Disable Chrome Extension Install

      Click Element	//div[@class="prejoin-preview-dropdown-container"]/div


      
Keep Meeting Alive
     Click Element	//body
     Sleep 		1 second
     Click Element	//body     
     Wait Until Element Is Visible	//div[@aria-label="Toggle chat window"]
     
     Click Element	//div[@aria-label="Toggle chat window"]
     Input Text		//textarea[@id="usermsg"]	Heippa kaikki, Sparkbot paikalla!
     Press Keys		//textarea[@id="usermsg"]	RETURN

     Toggle Tile View

     Sleep	5 seconds

     ${shouldExit}=	Set Variable	False
     
     FOR	${i}	IN RANGE	${EightHoursInSeconds}
     	  ${fiveSecondsPassed}=		Evaluate	${i} % 5 == 0
#	  Run Keyword If	${fiveSecondsPassed}	Insert Random Comment To Chat
	  ${shouldExit}=	Run Keyword And Return Status		File Should Not Exist	${sparkOpenFile}
	  Log To Console	Should we exit ${shouldExit} ${sparkOpenFile}
	  Exit For Loop If	${shouldExit}
     	  Sleep			1 seconds
     END
     Run Keyword Unless		${shouldExit}	Inform About Timeout

Exit Meeting
     Input Text		//textarea[@id="usermsg"]	Ok, suljen yhteyden Sparkkiin!
     Press Keys		//textarea[@id="usermsg"]	RETURN
     Sleep	2 seconds
     Click Element	//div[@aria-label="Leave the call"]
     