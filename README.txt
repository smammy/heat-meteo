This file could also be called the change log.

3.2.0
* Correct crash when rotating cities and all cities are not in use
* Correct crash if first city was empty
* Correct crash if all locations were empty

3.1.9
* Correct Yahoo! lookup by US ZIP code
* Add option to display Feels Like on menu bar (vs. actual temperature)
* Correct rotation of cities
* Adjust pressure (QFE) based on altitude (QNH), where altitude is provided (currently only via <here>)

3.1.8
* Add translation of German special characters (umlauts) to ASCII.
* Add detection of wake from sleep to avoid some wifi problems.
* Detect and report (but can't auto-resolve) Yahoo! OAuth errors in the Console log (along with other possible validation errors).
* Update Yahoo! authentication, again. This time for X-Yahoo-App-Id.
* Add support for Yahoo! location to be either city,state or lat,long.
* Allow for unknown weather icons for APIXU (after wake from sleep)
* Correct a recurring 9999 for OpenWeatherMap
* Provide a reference URL for Yahoo! locations.
* Update source code to Swift 5 and Xcode 10.2.
* Updated support for WunderGround and PWS's (put your PWS ID as the city).
* Updated OhhAuth to latest version.

3.1.7
* At startup, Meteo will now determine your current location and display it if you use a location of <here>. That is the word *here* surrounded by angle brackets. Meteo does not retain or share on your location.
* Updated display of Preferences window, now tabbed.
* Allow for formatting of Latitude, Longitude containing: <comma>, <space>, <comma><space> or <space><comma>.
* Clean up a few memory leaks.
* Updated README in the DMG installation package, including French translation (thank you Manfred).
* Logging of message is now ON by default for new users.
* Default location is <here> and second default location is Cupertino, CA.
* Received notice that Wunderground.com is shutting down on 31 Dec 2019.
*   https://apicommunity.wunderground.com/weatherapi/topics/end-of-service-for-the-weather-underground-api
* Add current Visibility to DarkSky and Wunderground
* Add UV Index where available
* Add Wind gusts where and when available

3.1.6
* Now requires macOS 10.10 or newer
* New weather source: Environment Canada (http://weather.gc.ca/)
* Re-structure code for Yahoo support (added ohhAuth)
* 9999 will show as temp for both F and C for error condition
* Fixed "cloudy" icon with DarkSky
* If you are using DarkSky, you will need to reselect it in the preferences
* Update to Swift 4.2 (Xcode 10.1)
* Correct "km/h" location
* Added Help option under Controls that provides a brief explaination of Meteo
* Double bump of version number

3.1.4
* Add French translations for Blowing Snow
* Reduce WeatherUnderground calls from 2 to 1 for each city
* Update to Swift 4.1 (Xcode 9.4)

3.1.3
* Change in processing for OpenWeatherMap. Location is now lat/long based. All users must update their location.
* New option to display date instead of day in extended forecast.
* Fix some DarkSky icons

3.1.2
* Correct a mistake in French translation

3.1.1
* Xcode 9.0.1 fixed the bug with 10.9

3.1.0
* Now written in Swift 4
* Correct Yahoo date missing leading 0 on time's (7:7 vs 7:07)
* DarkSky Extended Forecast now displays DOW based on local timezone (vs. UTC)
* Correct current weather icon display from DarkSky
* Still supporting 10.9 but this may be the last update

3.0.5
* Add French translation of: Patchy rain possible and moderate rain
* Correct code signing issue
* Update Dark Sky access

3.0.4
* Correct alignment of Forecast weather.
* Correct link for Yahoo! weather.
* Correct Wunderground location format.
* Force DarkSky updates to hourly (far too popular)
* Add option to reset preferences

3.0.3
* Correct problems with Last Update for Yahoo and OpenWeatherMap
* Correct -9999 for wind direction for WeatherUnderground
* Meteorologist is fully localized for French language
* APIXU now has localized current and forecast conditions (but not other terms)
* Dark Sky now has localized current and forecast conditions (but not other terms)
* If you are using Dark Sky, your update frequency will be a minimum of 30 minutes.

3.0.2
* Improve French localization
* Add weather source APIXU.com
* Add weather source DarkSky.net (no key required)
* Display cached weather information if network connection is lost
*   Does not detect if you have an IP but router is not connected

3.0.1
* Fix launch failure on 10.9 systems
* Add French localizations (any other offers?)
* Add "Loading..." display to the startup delay
* Change default WeatherSource back to Yahoo!.
*

3.0.0
* STOP!!! - Don't update without reading and understanding the 3.x update. Also recommend that you keep the prior version and turn off version checks if you aren't 100% comfortable with this version.

* Rather than trying to be all things for everybody for all weather stations for all locations, Meteo is now geared to be specific the particular weather service selected.
*   Each user will needs an API key for each weather source so the usage for one person doesn't infringe on another.
*   Also the Input City Name is specific to the service. For example WeatherUnderground will require IL/NAPERVILLE where the Input city for TheWeather.com would be 157281. Experimentation with search city names will be required.
*   A new Display City field will be used to provide a "pretty" output display.
* Upgraded Swift syntax to version 3 (still supports 10.9 and up)
* Upgraded to Xcode 8.2.1
* Switch weather source internal format from XML to json where possible
* Add TheWeather.com, WeatherUnderground, AerisWeather, and WorldWeatherOnline as data sources
*   WeatherUnderground is the recommended API for Weather.com
*   OpenWeatherMap now requires an API key
*   No change to Yahoo
*   Recommended weather sources are OpenWeatherMap,WeatherUnderground, AerisWeather, or Yahoo
*   All except for Yahoo require individual API keys for each service so users don't step on each other - See the preference pane for additional information
*   Yahoo is still squirrely but seems to be stable lately
*   TheWeather.com is forecast only, no current weather.
* Add mmHg option for barometric pressure
* Add option to rotate cities (on same schedule as weather refresh)
* Add option to limit forecast days
* Add option for startup delay to allow for computers using WiFi (default is 10 seconds - change to 0 for immediate launch)
* Correct a crash if the non-system font (default TAHOMA) was disabled or otherwise not available

2.0.5
* Update provided by Eric W., a senior at Longwood University in Virginia (USA).
* Animated "loading" icon weather information before the animation kicks in.
* Optional new graphics for the various weather conditions that work well with OS X's new recommendations.
  Also retina compatible.
  Default is Yes.
* Sorry no change for Yahoo yet.

2.0.4
* Correct setting of Preference Version.

2.0.3
* OpenWeatherMap returning empty data causing crashes.

2.0.2
* Prevent crash if invalid icon from OpenWeather (display "unknown")
* Display "unknown" icon from Yahoo if necessary

2.0.1
* Ability to select System Font
* System Font is now the default font
* Change default font size to 15

2.0.0
- A whole new Meteorologist
- Rewritten in Swift for modern OS's
- Requires 10.9 or greater
- No longer screen scrapes, uses published XML interfaces
- XML Weather data from Yahoo!
- XML Weather data from OpenWeatherMap
- Sorry you will need to start your list of cities all over
- Menubar only, no dock support
- Based on Xcode 7


v1.6.1
- INTEL Only!!!! No more PPC.
- Requires OS X 10.5 or greater.
- Update to Xcode 4.5.
- Get Radar working again.
- Fix alignment with Extended Forecast.
- Add Show Humidity option.
- Remove white dot in Mission Control.

v1.5.6
- Condense multiple alert messages into a single message where possible.
- Update find cities location.
- Start Intel 64 bit version.

v1.5.5
- Correct French localization (thanks to xf75013).
- Corrected a problem reading an older preference file.
- Correct a problem where only the last of multiple weather alerts were being sent to the alert.

v1.5.4
- Remove Wunderground and NWS in weather.xml. It was causing crashes when adding new city.
- Reset Xcode 3.2.6 architecures to regain PPC support.

v1.5.3
- Add Portuguese localization.
- Some attempt to fix formatting of "Forecasts on one line"
- Add SMS Alert. Similar to email but less verbose.
- Start to re-add Wunderground.com and NWS.

v1.5.2
- Fixed "Add City" name parsing.
- Move weather link for alerts to beginning of message. If message was texted and city name was long, link was getting broken.
- Fix ZIP for "Add City" search.
- Corrected "Import this cities preferences" to read "Import this city's preferences" - bug 3015765
- Add city name list now displays up to 25 cities (yes the text wrong)

v1.5.1
- Fixed "Forecast - Link".
- Radar Image is now a hyperlink.
- Fixed distance to allow global units.
- German localization updates
- Japanese localization updates
- Fixed memory leaks
- Fixed crash on 10.3 systems
- Restored 9 day forecasts

v1.5.0
- Latest weather.com site changes (3 Mar 10).
- Added a hyperlink link to weather alert message.
- Fixed some radar display bugs.
- Fixed hyperlink for Web Support Group.
- Update build version.
- Restored full browser based "Weather For" URL, no longer the mobile version.
- Major localization updates, now easier to add new localles.
- Added Italian localization thanks to "asdesign", partially incomplete.
- German localization is partially incomplete (always was).
- Meteo will now auto quit when going to the web server to download a new version.
- Re-added UV Index and Visibility, delete and re-add city if they are not in acceptable order.
- Clicking on a weather alert in the menu will take you to a web page with details.
- Radar will not take up more then 1/3 of the width of your display, if you have too many menu bar items on a smaller width display, radar may be clipped. Perhaps a future update to control actual size.
- Corrected missing highlight bar on 10.3 and 10.4 systems.
- Now only gets up to 5 days of forecast weather regardless of requested value (weather.com split data onto two pages).

v1.4.9
- Fixed weather.com server support.
- Re-implemented alerts.
- Larger radar images (mostly weather.com changes).
- Add option to display or not display message to the console.
- Updated city parser.

v1.4.2
- Fixed a bug where the rain icon was displayed during snow flurries
- Fixed a bug where Meteo crashed after wakeup
- Fixed an interface glitch regarding the enabling of Global Units
- Fixed the ability to change the pressure units

v1.4.1
- NSLogs are redirected to Meteo.log inside ~/Library/Logs.
- Fixed weather.com server support.
- New "Default City" of Cupertino, CA (thanks for the idea, wadetemp).
- Fixed Dock support.
- Meteo can once again automatically check for updates.
- The UV Index and Visibility attributes are not longer available as part of the current conditions (because of how weather.com has changed its website).
- Many new forecast attributes are available for extended forecast.

v1.4.0
- Identical to version 1.4.0b3

v1.4.0b3: (never released)
- in solution to the various "it just quits" bugs

v1.4.0b2:
- Uses CURLHandler instead of NSURLHandler to download internet content.
- Ability to paste the URL of a weather page into the search box (from weather.com only) if "Perform Search" does not work.

v1.4.0b2:
- Fixed SourceForge Bug #976396 "ZIP code searches do not return results"
- Fixed SourceForge Bug #975997 "Temperature is reading Celsius for Fahrenheit"
- Fixed SourceForge Bug #975970 "Button state problems on "Cities" tab of Preferences"
- Fixed SourceForge Bug #977146 "Minor UI element glitches when editing and updating a city."
- Fixed SourceForge Bug #976035 "Menu bar menu inaccessible if Meteo launched as Startup Item"
- Fixed _initWithWindowNumber "crash" on close
- Fixed low/hi issues for the current night under extended forecast.
- Fixed SourceForge Bug #977204 "Reset to defaults doesn't redraw menubar."
- Fixed SourceForge Bug #978127 "Main menu's 'High' and 'Low' inconsistent with Forecast"
- Fixed SourceForge Bug #978268 "Unicode/Ascii discrepancies"
- Fixed SourceForge Bug #976396 "ZIP code searches do not return results"
- Fixed SourceForge Bug #977789 "Weird redraw bug."

v1.4.0b:
- First build by JoeCrow
- Changed text in city editor to "City or Zip Code Search" instead of "City search"
- Got rid of second popup "weather info."
- Rearranged and Renamed buttons for Preferences Window.
- Fixed SourceForge Bug #975925 "Weather Items can't be reordered.."
- Fixed SourceForge Bug #975943 "Invalid input for update intervals will crash meteo"
- Fixed SourceForget Bug #975941 "Changes to update interval prefs. cannot be applied.
- Made the city editor open up as a sheet.
- Fixed SourceForge Bug #975946 "City Editor dialog gets stuck open"
- Fixed sourceforge bug #976055 "'Date' field makes forecasts incorrect/incomplete."

v1.3.1
- First SourceForge team build
- Bug fixes in startup code
- Bug fixes in parsers

v1.3.0
- The last update from HEAT
- All weather servers should work again

v1.2.9
- Updated homepage link to go straight to sourceforge
- Fixed annoying problem where loading icon would stay in menubar
- Weather Alerts window will now always stay visible
- Fixed trailing nulls problem

v1.2.8
- Fixed Wunderground Forecast parsing
- Fixed version number problems in 1.2.7
- Fixed problem where forecast would skip every other day
- Fixed problem where thermometer in dock would not display celsius info properly
- Note: Helvetica-Bold and a white color look really good in Dock mode
- Bug: Seattle has a weird NWS format and currently can't be parsed correctly; this may apply to other cities as well
- Added cool new loading animation (thanks Adam!) in menu bar

v1.2.7
- Updated parsing engine for new Wunderground format
- Meteo will no longer continuously reposition itself on the left of the menu bar after being launched
- Fixed Weather Alerts - the music plays on now!
- Fixed problem where Wunderground forecast info wasn't being relayed
- Fixed problem where no icon was shown in the menu bar
- Weather Alert window will no longer hide when Meteo deactivates
- Updated parsing engine for new city format for NWS
- Added wind icons (thanks Adam!)


v1.2.6
- "Kill other Meteo" is now an option in the preferences
- Temperature data from wunderground and NWS will be mapped as so:
	low 10's => 12
	mid/middle 10's => 15
	upper 10's => 18
- Radio buttons for weather alerts are now check boxes
- Radio buttons for cycling cities are now check boxes
- Removed html garbage and ads that were showing up in extending forecast
- Added exception handlers to hopefully prevent MMS (missing menu symptom)
- If icons can't be downloaded to /Library/Application Support (requires admin privileges), they will be downloaded to ~/Library/Application Support instead
- Changed naming of record and normal hi's and low's
- Closing Alerts window now stops music/beeping
- Added threading support (experimental)
- Improved interlacing of weather data (hopefully fixes problem where Friday Night was before Friday, etc)
- Mapped most NWS icons correctly
- Pressure shouldn't be reported as a wind attribute anymore
- NWS will now relay current forecast info again
- Because NWS and Wunderground don't provide a current weather image, Meteo looks at the first forecast image for those servers, explaining why some users get a moon image during the day; I'll look into a better way for the future

v1.2.5
- Added "Kill other Meteo" on launch feature (only effects 1.2.5 and later)
- Made Wunderground.com the default server, Weather.com the last
- Fixed problem some people where having with extended forecast and Wunderground.com
- Changed "Load New Data" to "Refresh"
- Added awesome new icons: BIG THANKS TO ADAM BETTS!
- Moved icons to /Library/Application Support/Meteo
- Icons now only need to be downloaded once instead of each time you download Meteo
- Noted bug - sometimes the hi is really the low and vice versa for Weather.com
- Added option to disable weather servers that you have already looked your city up on
- Meteo now displays its name in the Dock instead of its version number
- Improved NWS parser (again)
- Nights are back for extended forecasts
- Rearranged the preferences again, deleting one tab
- Added Meters per second
- Added "Grouping" feature - check out the "Weather Items" tab and hit the "+" button to see
- Fixed bug that limited city search results
- Added character cap that prevents menus from being too wide (doesn't effect inlined forecasts)
- Added Weather Alerts tab to preferences

v1.2.4
- Updated Meteo for new and improved Weather.com format... (sigh)
- Fixed "string out of bounds" error that would sometimes cause Meteo to not display a menu
- About tab now allows user to scroll in text fields
- Potentially fixed problems people where having with corrupted preferences
- Added Hectopascal unit for pressure readings
- Added better radar and NWS image caching for faster updates
- Added preference to change embedding of controls (Quit, etc)

v1.2.3
- Fixed update bug where after changing the order of cities, Meteo would stop displaying any menu at all
- Fixed bug where Meteo would have no title or image when launched with no internet connectivity
- Fixed bug where cities looked up in NWS system would have first two letters truncated
- Fixed bug related to importing other city weather items
- Shrunk preference window to help out people with prefer lower resolutions
- Added About tab to preferences
- Merged cycling controls into Units tab
- Added Knots to speed units
- Fixed several little bugs in city editor
- Fixed bug where if the main city (the one showing in the menu bar), then two instances of the main city will appear - one in the menu bar and one in the menu below
- "Update Menu Now" button will cycle the active cities now only if the cycle mode is activated in the preferences
- Created "Group" for users to post comments and concerns: http://groups.yahoo.com/group/heat_software/
- Forecast inlining is off by default now
- Fixed bug where if a user had radar images on, wunderground active, and wunderground didn't have radar images, then no weather info was displayed at all
- Removed pointless 10th day forecast option
- Improved NWS parser engine (again)
- Cycling should now work better now
- Added NWS radar images

v1.2.2
- Increased the maximum menu bar font size to 24
- Fixed odd dragging behavior (use to be more like swap)
- Fixed problem where forecast items looked like they could be dragged to the current weather table.
- Added City Switcher menu item
- Added proper city cycling preference, as well as cycling to new active cities preference
- Fixed problem where data would be shown twice for inlined forecasts (only effects newly created cities - this behavior can be fixed manually in the City Editor window, under the Weather items tab for existing cities).
- Combined City Window with Preference window.
- Re-implemented Link support
- Improved the Wunderground.com and NWS parser engine, meaning more info from these servers and fewer instances of displaying garbage
- Added support for Radar Images (Wunderground.com and Weather.com)
- Updated for new Weather.com format

v1.2.1
- Fixed Moon Rise and Moon Set not always showing
- Fixed Wind not showing in kilometer per Hour when it should
- Added displaying forecast items inline (one line)
- Added Font size controls for the menu bar
- Fixed a bug in the Wunderground city search (skipping every other result)
- I have learned how to spell Version again... :sigh:
- Fixed bug where NWS weather lookup would cause Meteo to lock up on launch
- Fixed bug where dragging cities or weather items in a certain way could cause them to disappear
- Added global unit controls
- Added warning window when a user tries to add a city without performing a lookup on any of the weather servers
- Added auto-fill of City Search field
- Fixed bug that prevented Meteo from working right on 10.1.5
- Added dialog window asking if a user wants to save unsaved preferences when quitting
- Menu bar item now highlights when clicked on
- Old data is still displayed even after a loss of network connectivity: servers that did not retrieve enough information are shown in the cities window as being grayed out.
- Added Instructions.rtf file; it's still a little rough around the edges
- Improved the overall interface; keep suggestions coming!

v1.2.0
- Added multiple, simultaneous city support
- Added multiple city cycling (first two cities, then next two, etc)
- Added version checking and server error checking on launch
- Added multiple, simultaneous server support (Weather.com, Wunderground.con, and NWS)
	- Get info from any of these servers...
	- Or get info from all these servers at the same time!
- Improved menu layout
- Added individualized unit controls
- Made Forecast and Current Weather items be set on a per city basis
- Fixed potential bug where nothing would display in the menu bar
- Fixed bug where a drop down menu would not always be displayed
- Lost some features (Clicking on the city name now does not open up a browser... this be a challenge, especially in Dock mode)
- Still missing:
	Much of the extended forecast info off of NWS and Wunderground
	Better data formating
	Additional Icon sets
	A more "global" icon
- Several things I'm sure I forgot

v1.1.9
- Fixed parsing engine for Weather.com (silly Weather.com)

v1.1.8
- Re-aranged the preferences in a much clear way (thanks for the mock ups Joshua Ochs!)
- Temperature data will now always be displayed with the degree symbol (�)
- It works again: Weather.com changed their format a little, so I had to tweak my algorithm to compensate.  I apologize for the delay.

v1.1.7
- The icon set is now complete (thanks Sara Romini!) - feel free to create your own icon sets and email me - I'll mirror them on my website
- "Bad" info will no longer be displayed... really.
- One cavet to the above: the temperature always has to be displayed (so it will show up as N/A)
- If valid data use to exist, new data which is corrupt will be discarded and the meteo icon will be given a red hue... really.
- Preference changes now have to be applied by pushing a button - this helps out slower systems that couldn't handle applying preferences each time one was changed
- Made preference layout cleaner, while making the Update tab seem more naked (what else can I put there?)

v1.1.6
- Fixed bug where forecast information was displayed in the opposite format than the preferences indicated
- Fixed bug where the icon in the menu would eventually become a solid red color
- Improved error range when converting between SI and Metric
- Hi and lo temperaturers, when displayed inline, will now be ordered hi and then lo
- Added interface (not implementation yet) for using other weather sources, including combining the data from multiple sources
- Added short name column to cities table: this editable column allows the displayed city name to be user defined
- Added ability to reorder cities table
- No more spelling errors!
- Unlimited visibility will no longer be displayed as 0
- The first forecast info is now Today's or Tonight's info, not tomorrows
- There are now 10 instead of 9 forecast days
- Changed Vision to Visibility
- Except for in a few cases, data recieved from weather.com which is useless (i.e. N/A) will not be displayed
- Even more, and higher quality, icons where added, accounting for the increase in size of the download

v1.1.5
- Found and fixed bug that prevented 10.2.x version from working on 10.1.x; it was a problem with loading images by URL
- Added better handling of bad data, hopefully preventing some of the crashes users have been seeing
- Meteo will now load local images instead of the ugly weather.com images... as soon as there are images - I have a few people volunteering their time, but please be patient, as there are over 40 images to make in people's free time
- Added new, spiffy image for Meteo, created by Flavio Andrade.  Thanks a ton!
- Added preference validation routine which should make it unneccessary to ever trash your preferences again
- Bug in "dock mode" that prevents active location from being represented with a check mark in the "Location Switcher" menu has been noted - it's an Apple thing, I have no control over this behavior.  This also prevents images from being displayed in the dock menu.
- Added tool tip to menu bar - holding the mouse over Meto in the menu bar will now display a little yellow box indicating the location of the currently active city
- Local images for the menu's and menu bar are of size 16 by 16, and for the dock icon are of size 128 by 128 (when local images become available)
- Added better centering for different sizes and menu fonts (it's not perfect - some fonts will simply not look good)
- Made LucidaGrande size 14 the default menu font
- Meteo icon will now be displayed in the dock icon or menu bar if no image can be found for the current weather
- Menu bar and dock icon will have a red hue whenever the last info downloaded from the server was bad - if there was previous data that was good, that will be displayed instead
- Reorganized preferences some more (thanks for the suggestion Ronald Leroux)
- Added preference to not show degree symbols after temperatures
- Added instructions on how to run multiple versions of meteo that will display different cities

v1.1.4a
- Special build for 10.1.5 (shouldn't be necessary in the future, yay!)
- Fixed part of the problem about Meteo crashing on launch

v1.1.4
- Precipitation in todays weather no longer tries to do some silly metric conversions
- Fixed problem where pressure preference somehow controlled temperature preference instead
- City codes should no longer get cut off in the two tables
- Updated the Problems.txt file
- Added reset defaults button to preferences (no more trashing the Meteorologist.plist file!)
- Multiple kilometer are now displayed as km instead of kms
- Made display of dates look better (i.e Sun, Sep 22 10:36 PM)
- Location tables now allow you to resize (although not reorder) their contents
- Clarified that Dock font/image controls relate to the icon, not the menu
- Removed "Font Name" popup button from Menu Display preference tab - I have no idea why that was there
- Added preferences to change the font and size of the text displayed in the menu bar (not the menu items)
- Clicking on the menu bar item now properly highlights the item
- Images size better in menu bar
- Created RoadMap.txt

v1.1.3
- NOTE: Meteo only *officially* works on 10.2.  Users having problems with N/A (to my knowledge) have only been using 10.1.5.  I plan to build a version on a 10.1.5 machine I make at work in a week to compensate 
- Added metric supprot for wind, visibility, and pressure
- Added ability to rearrange the order of the current day's long range forecast's menu items
- Added hi, low, and precipitation directly to the current weather information area
- Removed first day in long range forecast (it was essentially redundant), so there is only 9 now
- Added ability to group todays weather data in a sub menu
- Added option to cycle through the set of choosen units
- Added option to display the current city name (or not), weather icon (or not), and temperature (or not) in the menu bar
- Added option to disable displaying temperature in the dock

v1.1.1-2
- Temperatures in Celsius no longer have long trailing decimal places
- All menu items are dark black instead of some of them being light gray
- Added progress bar when obtaining possible matches to desired cities
- Error message now displays when searching for the code for a city that doesn't exist
- Added field to "New Location" window that indicates the city behind the code (takes affect after next location set)
- City Lookup now works even if that city is the only one in the world with that name
- City Lookup now supports cities with spaces
- Preferences are a little cleaner
- Added support for multiple locations
- Simplified process for looking up locations
- Auto-update works again
- Fixed spelling errors (percipitation != precipitation)
- Added ability to display last update time in menu
- Added *potential* fix for people who are behind firewalls
- If an update fails (except for the first attempt), bad data will not be displayed
- Preferences are wiped if you used an older version - sorry, but it was neccessary
- Preference added to change the minutes between updates from 1 to 120

v1.1
- Added international weather support
- Added City Lookup function to "New Location" window (not threaded, yet)
- Fixed bug when converting from Celsius to Fahrenheight (rounding error)
- Meteorologist has always updated every 15 minutes - now it's documented :)

v0.0.0 - v1.0.x
- Much was done, little was recorded
