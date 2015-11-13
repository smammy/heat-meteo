//
//  StatusMenuController.swift
//  Meteo2
//
//  Swift code written by Ed Danley on 9/19/15.
//  Copyright © 2015 The Meteorologist Group, LLC. All rights reserved.
//
//  Original source by Joe Crobak and Meteorologist Group
//  Some new graphics by Matthew Fahrenbacher
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify,
//  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
//  OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Cocoa
//import CoreLocation
import Foundation

let DEFAULT_CITY = "Cupertino, CA"
let DEFAULT_INTERVAL = "60"
let YAHOO_WEATHER = "0"
let DEFAULT_PREFERENCE_VERSION = "a10"

struct WeatherFields {
    
    var title1 = NSMutableString()
    var date = NSMutableString()
    
    var latitude = NSMutableString()
    var longitude = NSMutableString()
    
    var windChill = NSMutableString()
    var windSpeed = NSMutableString()
    var windDirection = NSMutableString()
    
    var humidity = NSMutableString()
    var pressure = NSMutableString()
    var visibility = NSMutableString()
    
    var sunrise = NSMutableString()
    var sunset = NSMutableString()
    
    var currentCode = NSMutableString()
    var currentLink = NSMutableString()
    var currentTemp = NSMutableString()
    var currentConditions = NSMutableString()
    
    var forecast1Code = NSMutableString()
    var forecast1Date = NSMutableString()
    var forecast1Day = NSMutableString()
    var forecast1High = NSMutableString()
    var forecast1Low = NSMutableString()
    var forecast1Conditions = NSMutableString()
    
    var forecast2Code = NSMutableString()
    var forecast2Date = NSMutableString()
    var forecast2Day = NSMutableString()
    var forecast2High = NSMutableString()
    var forecast2Low = NSMutableString()
    var forecast2Conditions = NSMutableString()
    
    var forecast3Code = NSMutableString()
    var forecast3Date = NSMutableString()
    var forecast3Day = NSMutableString()
    var forecast3High = NSMutableString()
    var forecast3Low = NSMutableString()
    var forecast3Conditions = NSMutableString()
    
    var forecast4Code = NSMutableString()
    var forecast4Date = NSMutableString()
    var forecast4Day = NSMutableString()
    var forecast4High = NSMutableString()
    var forecast4Low = NSMutableString()
    var forecast4Conditions = NSMutableString()
    
    var forecast5Code = NSMutableString()
    var forecast5Date = NSMutableString()
    var forecast5Day = NSMutableString()
    var forecast5High = NSMutableString()
    var forecast5Low = NSMutableString()
    var forecast5Conditions = NSMutableString()
    
    var URL = NSMutableString()
    
    var weatherTag = NSMutableString()

}

class StatusMenuController: NSObject, NSXMLParserDelegate, PreferencesWindowDelegate {
    
    var preferencesWindow: PreferencesWindow!   // http://footle.org/WeatherBar/
    var radarWindow: RadarWindow!
    let yahooWeatherAPI = YahooWeatherAPI()     // https://developer.yahoo.com/weather/
    var myTimer = NSTimer()                     // http://ios-blog.co.uk/tutorials/swift-nstimer-tutorial-lets-create-a-counter-application/
    
    let defaults = NSUserDefaults.standardUserDefaults()

    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var menuItem : NSMenuItem = NSMenuItem()
    var webVERSION = ""
    
    override func awakeFromNib() {
        
        let newVersion = defaults.stringForKey("newVersion")
        if ((newVersion != nil) && (newVersion! == "1")) {
            // Check for updates
            if let url = NSURL(string: "http://www.danleys.org/" + "VERSION") {
                do {
                    webVERSION = try NSString(contentsOfURL: url, usedEncoding: nil) as String
                } catch {
                    // contents could not be loaded
                    webVERSION = ""
                }
            } else {
                // the URL was bad!
                webVERSION = ""
            }
            let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
            
            if (version != webVERSION) {
                // New version!
                let myPopup: NSAlert = NSAlert()
                myPopup.messageText = NSLocalizedString("NewVersionAvailable_", // Unique key of your choice
                    value:"A new version of Meteorologist is available!", // Default (English) text
                    comment:"A new version of Meteorologist is available!")
                myPopup.informativeText = NSLocalizedString("Download?_", // Unique key of your choice
                    value:"Would you like to download it now?", // Default (English) text
                    comment:"Would you like to download it now?")
                myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
                myPopup.addButtonWithTitle(NSLocalizedString("Yes_", // Unique key of your choice
                    value:"Yes", // Default (English) text
                    comment:"Yes"))
                
                // http://swiftrien.blogspot.com/2015/03/code-sample-swift-nsalert_5.html
                // If any button is created with the title "Cancel" then that has the key "Escape" associated with it
                myPopup.addButtonWithTitle(NSLocalizedString("Cancel_", // Unique key of your choice
                    value:"Cancel", // Default (English) text
                    comment:"Cancel"))
                let res = myPopup.runModal()
                if res == NSAlertFirstButtonReturn {
                    //let myUrl = "http://heat-meteo.sourceforge.net"
                    let myUrl = "http://www.danleys.org/Meteo2.zip"
                    
                    if let checkURL = NSURL(string: myUrl as String) {
                        if NSWorkspace.sharedWorkspace().openURL(checkURL) {
                            //print("URL successfully opened:", myUrl, terminator: "\n")
                            
                        }
                    } else {
                        //print("Invalid URL:", myUrl, terminator: "\n")
                    }
                }
            }
        }
        
        var theCityImage = NSImage()
        //theCityImage = NSApp.applicationIconImage
        theCityImage = NSImage(named: "Loading-1")!
        
        //Add statusBarItem
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        statusBarItem.image = theCityImage
        statusBarItem.title = NSLocalizedString("Loading_", // Unique key of your choice
            value:"Loading", // Default (English) text
            comment:"Loading") + "..."
        
        //Add menuItem to menu
        let newItem : NSMenuItem = NSMenuItem(title: NSLocalizedString("PleaseWait_", // Unique key of your choice
            value:"Please wait while Meteo fetches the weather", // Default (English) text
            comment:"Please wait"), action: Selector("dummy:"), keyEquivalent: "")
        
        newItem.target=self
        menu.addItem(newItem)
        
        // ToDo: Need a way to make Command-W work on these windows
        radarWindow = RadarWindow()
        radarWindow.delegate = self
        
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        let preferenceVersion = defaults.stringForKey("preferenceVersion")
        if ((preferenceVersion == nil) || (preferenceVersion! != DEFAULT_PREFERENCE_VERSION)) {
            preferencesWindow.showWindow(nil)
        } else {
            updateWeather()
            //preferencesWindow.showWindow(nil)
        }

    } // awakeFromNib
    
    func updateWeather()
    {
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLCache.sharedURLCache().diskCapacity = 0
        NSURLCache.sharedURLCache().memoryCapacity = 0

        radarWindow = RadarWindow()
        var controlsMenu = NSMenu()
        var weatherFields: WeatherFields
        let defaults = NSUserDefaults.standardUserDefaults()
        let city = defaults.stringForKey("city")!
        let city2 = defaults.stringForKey("city2")!
        let city3 = defaults.stringForKey("city3")!
        let city4 = defaults.stringForKey("city4")!
        let city5 = defaults.stringForKey("city5")!
        let city6 = defaults.stringForKey("city6")!
        let city7 = defaults.stringForKey("city7")!
        let city8 = defaults.stringForKey("city8")!

        if (defaults.stringForKey("weatherSource")! == YAHOO_WEATHER) {
            yahooWeatherAPI.setRadarWind(radarWindow)
            weatherFields = yahooWeatherAPI.beginParsing(city)
            
            if (defaults.stringForKey("displayWeatherIcon")! == "1") {
                statusBarItem.image = yahooWeatherAPI.setImage(weatherFields.currentCode as String)
            } else {
                statusBarItem.image = nil
            }

            var statusTitle = ""
            if (defaults.stringForKey("displayCityName")! == "1") {
                statusTitle = city + " " + yahooWeatherAPI.formatTemp((weatherFields.currentTemp as String))
            } else {
                statusTitle = yahooWeatherAPI.formatTemp((weatherFields.currentTemp as String))
            }
            if (defaults.stringForKey("displayHumidity")! == "1") {
                statusTitle = statusTitle + "/" + yahooWeatherAPI.formatHumidity((weatherFields.humidity as String))
            }
            statusBarItem.title = statusTitle
            
            yahooWeatherAPI.updateMenuWithPrimaryLocation(weatherFields, cityName: (city), menu: menu)

            if ((city2 != "") ||
                (city3 != "") ||
                (city4 != "") ||
                (city5 != "") ||
                (city6 != "") ||
                (city7 != "") ||
                (city8 != ""))
            {
                if (city2 != "")
                {
                    weatherFields = yahooWeatherAPI.beginParsing(city2)
                    yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city2), menu: menu)
                }
                if (city3 != "")
                {
                    weatherFields = yahooWeatherAPI.beginParsing(city3)
                    yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city3), menu: menu)
                }
                if (city4 != "")
                {
                    weatherFields = yahooWeatherAPI.beginParsing(city4)
                    yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city4), menu: menu)
                }
                if (city5 != "")
                {
                    weatherFields = yahooWeatherAPI.beginParsing(city5)
                    yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city5), menu: menu)
                }
                if (city6 != "")
                {
                    weatherFields = yahooWeatherAPI.beginParsing(city6)
                    yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city6), menu: menu)
                }
                if (city7 != "")
                {
                    weatherFields = yahooWeatherAPI.beginParsing(city7)
                    yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city7), menu: menu)
                }
                if (city8 != "")
                {
                    weatherFields = yahooWeatherAPI.beginParsing(city8)
                    yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city8), menu: menu)
                }

                menu.addItem(NSMenuItem.separatorItem())
            }
        }

        var newItem : NSMenuItem
        if (defaults.stringForKey("controlsInSubmenu")! == "1") {
            newItem = NSMenuItem(title: NSLocalizedString("Controls_", // Unique key of your choice
                value:"Controls", // Default (English) text
                comment:"Controls"), action: nil, keyEquivalent: "")
            menu.addItem(newItem)
            menu.setSubmenu(controlsMenu, forItem: newItem)
        } else {
            controlsMenu = menu
        }
        newItem = NSMenuItem(title: NSLocalizedString("Refresh_", // Unique key of your choice
            value:"Refresh", // Default (English) text
            comment:"Refresh"), action: Selector("weatherRefresh:"), keyEquivalent: "r")
        newItem.target=self
        controlsMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("Preferences_", // Unique key of your choice
            value:"Preferences", // Default (English) text
            comment:"Preferences"), action: Selector("preferences:"), keyEquivalent: ",")
        newItem.target=self
        controlsMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("Quit_", // Unique key of your choice
            value:"Quit", // Default (English) text
            comment:"Quit"), action: Selector("terminate:"), keyEquivalent: "q")
        controlsMenu.addItem(newItem)
        
        let uwTimer = myTimer
        if uwTimer == myTimer {
            if uwTimer.valid {
                uwTimer.invalidate()
            }
        }
        
        let updateFrequency = defaults.stringForKey("updateFrequency")
        myTimer = NSTimer.scheduledTimerWithTimeInterval(Double(updateFrequency!)!*60, target:self, selector: Selector("updateWeather"), userInfo: nil, repeats: false)
        
    } // updateWeather
    
    func dummy(sender: NSMenuItem) {
        //print("dummy", terminator: "\n")
    } // dummy
    
    func preferencesDidUpdate() {
        updateWeather()
    }

    func openWeatherURL_(menu:NSMenuItem) {
        let myUrl = menu.representedObject as! NSString
        
        if let checkURL = NSURL(string: myUrl as String) {
            if NSWorkspace.sharedWorkspace().openURL(checkURL) {
                print("URL successfully opened:", myUrl, terminator: "\n")
                
            }
        } else {
            print("Invalid url:", myUrl, terminator: "\n")
        }
    } // openWeatherURL
    
    @IBAction func preferences(sender: NSMenuItem) {
        //print("Preferences_", terminator: "\n")
        preferencesWindow.showWindow(nil)
    } // dummy
    
    @IBAction func weatherRefresh(sender: NSMenuItem) {
        updateWeather()
    } // weatherRefresh
    
} // StatusMenuController
