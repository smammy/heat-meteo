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
let DEFAULT_PREFERENCE_VERSION = "a32"

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
    
    var forecast6Code = NSMutableString()
    var forecast6Date = NSMutableString()
    var forecast6Day = NSMutableString()
    var forecast6High = NSMutableString()
    var forecast6Low = NSMutableString()
    var forecast6Conditions = NSMutableString()
    
    var forecast7Code = NSMutableString()
    var forecast7Date = NSMutableString()
    var forecast7Day = NSMutableString()
    var forecast7High = NSMutableString()
    var forecast7Low = NSMutableString()
    var forecast7Conditions = NSMutableString()
    
    var forecast8Code = NSMutableString()
    var forecast8Date = NSMutableString()
    var forecast8Day = NSMutableString()
    var forecast8High = NSMutableString()
    var forecast8Low = NSMutableString()
    var forecast8Conditions = NSMutableString()
    
    var forecast9Code = NSMutableString()
    var forecast9Date = NSMutableString()
    var forecast9Day = NSMutableString()
    var forecast9High = NSMutableString()
    var forecast9Low = NSMutableString()
    var forecast9Conditions = NSMutableString()
    
    var forecast10Code = NSMutableString()
    var forecast10Date = NSMutableString()
    var forecast10Day = NSMutableString()
    var forecast10High = NSMutableString()
    var forecast10Low = NSMutableString()
    var forecast10Conditions = NSMutableString()
    
    var forecast11Code = NSMutableString()
    var forecast11Date = NSMutableString()
    var forecast11Day = NSMutableString()
    var forecast11High = NSMutableString()
    var forecast11Low = NSMutableString()
    var forecast11Conditions = NSMutableString()
    
    var forecast12Code = NSMutableString()
    var forecast12Date = NSMutableString()
    var forecast12Day = NSMutableString()
    var forecast12High = NSMutableString()
    var forecast12Low = NSMutableString()
    var forecast12Conditions = NSMutableString()
    
    var forecast13Code = NSMutableString()
    var forecast13Date = NSMutableString()
    var forecast13Day = NSMutableString()
    var forecast13High = NSMutableString()
    var forecast13Low = NSMutableString()
    var forecast13Conditions = NSMutableString()
    
    var forecast14Code = NSMutableString()
    var forecast14Date = NSMutableString()
    var forecast14Day = NSMutableString()
    var forecast14High = NSMutableString()
    var forecast14Low = NSMutableString()
    var forecast14Conditions = NSMutableString()
    
    var forecast15Code = NSMutableString()
    var forecast15Date = NSMutableString()
    var forecast15Day = NSMutableString()
    var forecast15High = NSMutableString()
    var forecast15Low = NSMutableString()
    var forecast15Conditions = NSMutableString()
    
    var forecast16Code = NSMutableString()
    var forecast16Date = NSMutableString()
    var forecast16Day = NSMutableString()
    var forecast16High = NSMutableString()
    var forecast16Low = NSMutableString()
    var forecast16Conditions = NSMutableString()
    
    var URL = NSMutableString()
    
    var weatherTag = NSMutableString()

} // WeatherFields

class StatusMenuController: NSObject, NSXMLParserDelegate, PreferencesWindowDelegate {
    
    var preferencesWindow: PreferencesWindow!   // http://footle.org/WeatherBar/
    var radarWindow: RadarWindow!
    let yahooWeatherAPI = YahooWeatherAPI()     // https://developer.yahoo.com/weather/
    let openWeatherMapAPI = OpenWeatherMapAPI() // http://www.openweathermap.org
    var myTimer = NSTimer()                     // http://ios-blog.co.uk/tutorials/swift-nstimer-tutorial-lets-create-a-counter-application/
    
    let defaults = NSUserDefaults.standardUserDefaults()

    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var menuItem : NSMenuItem = NSMenuItem()
    
    // https://gist.github.com/vtardia/3f7d17efd7b258e82b62
    var appInfo: Dictionary<NSObject,AnyObject>
    var appName: String!
    override init() {
        
        // Init local parameters
        self.appInfo = CFBundleGetInfoDictionary(CFBundleGetMainBundle()) as Dictionary
        self.appName = appInfo["CFBundleName"] as! String
        
        // Init parent
        super.init()
        
        // Other init below...
        
        // Library/Logs/Meteo.log
        SetCustomLogFilename(self.appName)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if ((defaults.stringForKey("logMessages") != nil) &&
            (defaults.stringForKey("logMessages")! == "1")) {
                InfoLog(String(format:"Application %@ starting", self.appName))
        }
    }
    
    override func awakeFromNib() {
        
        let defaults = NSUserDefaults.standardUserDefaults()

        var webVERSION = ""
        let newVersion = defaults.stringForKey("newVersion")
        var whatChanged = ""
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
                if let url = NSURL(string: "http://www.danleys.org/" + "CHANGELOG") {
                    do {
                        whatChanged = try NSString(contentsOfURL: url, usedEncoding: nil) as String
                    } catch {
                    }
                }
                let myPopup: NSAlert = NSAlert()
                myPopup.messageText = NSLocalizedString("NewVersionAvailable_", // Unique key of your choice
                    value:"A new version of Meteorologist is available!" + "\n\n" + whatChanged, // Default (English) text
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
        
        var m = (14 as NSNumber)
        var font = NSFont(name: "Tahoma", size: 14)
        if ((defaults.stringForKey("font") != nil) &&
            (defaults.stringForKey("fontsize") != nil)) {
                m = NSNumberFormatter().numberFromString(defaults.stringForKey("fontsize")!)!
                font = NSFont(name: defaults.stringForKey("font")!, size: CGFloat(m))
        }
        menu.font = font
        statusBarItem.menu = menu
        statusBarItem.image = theCityImage
        
        m = (14 as NSNumber)
        font = NSFont(name: "Tahoma", size: 14)
        if ((defaults.stringForKey("menuBarFont") != nil) &&
            (defaults.stringForKey("menuBarFontsize") != nil)) {
                m = NSNumberFormatter().numberFromString(defaults.stringForKey("menuBarFontsize")!)!
                font = NSFont(name: defaults.stringForKey("menuBarFont")!, size: CGFloat(m))
        }
        
        // http://stackoverflow.com/questions/19487369/center-two-different-size-font-vertically-in-a-nsattributedstring
        statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
            NSLocalizedString("Loading_", // Unique key of your choice
                value:"Loading", // Default (English) text
                comment:"Loading") + "...",
            attributes:[NSFontAttributeName : font!]))

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
        //NSURLCache.sharedURLCache().removeAllCachedResponses()
        //NSURLCache.sharedURLCache().diskCapacity = 0
        //NSURLCache.sharedURLCache().memoryCapacity = 0

        radarWindow = RadarWindow()
        var controlsMenu = NSMenu()
        var weatherFields: WeatherFields
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var city = defaults.stringForKey("city")!
        let city2 = defaults.stringForKey("city2")!
        let city3 = defaults.stringForKey("city3")!
        let city4 = defaults.stringForKey("city4")!
        let city5 = defaults.stringForKey("city5")!
        let city6 = defaults.stringForKey("city6")!
        let city7 = defaults.stringForKey("city7")!
        let city8 = defaults.stringForKey("city8")!
        let displayCity  = defaults.stringForKey("displayCity")!
        let displayCity2 = defaults.stringForKey("displayCity2")!
        let displayCity3 = defaults.stringForKey("displayCity3")!
        let displayCity4 = defaults.stringForKey("displayCity4")!
        let displayCity5 = defaults.stringForKey("displayCity5")!
        let displayCity6 = defaults.stringForKey("displayCity6")!
        let displayCity7 = defaults.stringForKey("displayCity7")!
        let displayCity8 = defaults.stringForKey("displayCity8")!
        
        var m = (14 as NSNumber)
        var font = NSFont(name: "Tahoma", size: 14)
        if ((defaults.stringForKey("menuBarFont") != nil) &&
            (defaults.stringForKey("menuBarFontsize") != nil)) {
                m = NSNumberFormatter().numberFromString(defaults.stringForKey("menuBarFontsize")!)!
                font = NSFont(name: defaults.stringForKey("menuBarFont")!, size: CGFloat(m))
        }

        if (defaults.stringForKey("weatherSource")! == YAHOO_WEATHER) {
            yahooWeatherAPI.setRadarWind(radarWindow)
            weatherFields = yahooWeatherAPI.beginParsing(city)
            if (weatherFields.currentTemp != "") {
                
                if (displayCity != "") {
                        city = displayCity
                }
                
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
                statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                    statusTitle,
                    attributes:[NSFontAttributeName : font!]))
                
                yahooWeatherAPI.updateMenuWithPrimaryLocation(weatherFields, cityName: (city), displayCityName: (displayCity), menu: menu)
                
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
                        yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city2), displayCityName: (displayCity2), menu: menu)
                    }
                    if (city3 != "")
                    {
                        weatherFields = yahooWeatherAPI.beginParsing(city3)
                        yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city3), displayCityName: (displayCity3), menu: menu)
                    }
                    if (city4 != "")
                    {
                        weatherFields = yahooWeatherAPI.beginParsing(city4)
                        yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city4), displayCityName: (displayCity4), menu: menu)
                    }
                    if (city5 != "")
                    {
                        weatherFields = yahooWeatherAPI.beginParsing(city5)
                        yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city5), displayCityName: (displayCity5), menu: menu)
                    }
                    if (city6 != "")
                    {
                        weatherFields = yahooWeatherAPI.beginParsing(city6)
                        yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city6), displayCityName: (displayCity6), menu: menu)
                    }
                    if (city7 != "")
                    {
                        weatherFields = yahooWeatherAPI.beginParsing(city7)
                        yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city7), displayCityName: (displayCity7), menu: menu)
                    }
                    if (city8 != "")
                    {
                        weatherFields = yahooWeatherAPI.beginParsing(city8)
                        yahooWeatherAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city8), displayCityName: (displayCity8), menu: menu)
                    }
                    
                    menu.addItem(NSMenuItem.separatorItem())
                }
            }
        } else if (defaults.stringForKey("weatherSource")! == "1") {
            openWeatherMapAPI.setRadarWind(radarWindow)
            weatherFields = openWeatherMapAPI.beginParsing(city)
            
            if ((defaults.stringForKey("displayCity") != nil) &&
                (defaults.stringForKey("displayCity")! != "")) {
                    city = defaults.stringForKey("displayCity")!
            }
            
            if (weatherFields.currentTemp != "") {
                if (defaults.stringForKey("displayWeatherIcon")! == "1") {
                    statusBarItem.image = openWeatherMapAPI.setImage(weatherFields.currentCode as String)
                } else {
                    statusBarItem.image = nil
                }
                
                var statusTitle = ""
                if (defaults.stringForKey("displayCityName")! == "1") {
                    statusTitle = city + " " + openWeatherMapAPI.formatTemp((weatherFields.currentTemp as String))
                } else {
                    statusTitle = openWeatherMapAPI.formatTemp((weatherFields.currentTemp as String))
                }
                if (defaults.stringForKey("displayHumidity")! == "1") {
                    statusTitle = statusTitle + "/" + openWeatherMapAPI.formatHumidity((weatherFields.humidity as String))
                }
                statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                    statusTitle,
                    attributes:[NSFontAttributeName : menu.font!]))
                
                openWeatherMapAPI.updateMenuWithPrimaryLocation(weatherFields, cityName: (city), displayCityName: (displayCity), menu: menu)
                
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
                        weatherFields = openWeatherMapAPI.beginParsing(city2)
                        openWeatherMapAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city2), displayCityName: (displayCity2), menu: menu)
                    }
                    if (city3 != "")
                    {
                        weatherFields = openWeatherMapAPI.beginParsing(city3)
                        openWeatherMapAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city3), displayCityName: (displayCity3), menu: menu)
                    }
                    if (city4 != "")
                    {
                        weatherFields = openWeatherMapAPI.beginParsing(city4)
                        openWeatherMapAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city4), displayCityName: (displayCity4), menu: menu)
                    }
                    if (city5 != "")
                    {
                        weatherFields = openWeatherMapAPI.beginParsing(city5)
                        openWeatherMapAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city5), displayCityName: (displayCity5), menu: menu)
                    }
                    if (city6 != "")
                    {
                        weatherFields = openWeatherMapAPI.beginParsing(city6)
                        openWeatherMapAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city6), displayCityName: (displayCity6), menu: menu)
                    }
                    if (city7 != "")
                    {
                        weatherFields = openWeatherMapAPI.beginParsing(city7)
                        openWeatherMapAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city7), displayCityName: (displayCity7), menu: menu)
                    }
                    if (city8 != "")
                    {
                        weatherFields = openWeatherMapAPI.beginParsing(city8)
                        openWeatherMapAPI.updateMenuWithSecondaryLocation(weatherFields, cityName: (city8), displayCityName: (displayCity8), menu: menu)
                    }
                    
                    menu.addItem(NSMenuItem.separatorItem())
                }
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
        let i = NSNumberFormatter().numberFromString(defaults.stringForKey("fontsize")!)
        menu.font = NSFont(name: defaults.stringForKey("font")!, size: CGFloat(i!))
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
        preferencesWindow.window!.makeKeyAndOrderFront(preferencesWindow.window!)
        NSApp.activateIgnoringOtherApps(true)
    } // dummy
    
    @IBAction func weatherRefresh(sender: NSMenuItem) {
        updateWeather()
    } // weatherRefresh
    
} // StatusMenuController
