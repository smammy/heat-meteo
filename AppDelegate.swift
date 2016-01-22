//
//  AppDelegate.swift
//  Meteorologist
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
// http://www.johnmullins.co/blog/2014/08/08/menubar-app/
// http://acapio.de/Programmierung/XCode/Swift_-_Display_window_as_modal/index.html
// http://footle.org/WeatherBar/
// https://developer.yahoo.com/weather/
// http://www.programmableweb.com/news/top-10-weather-apis/analysis/2014/11/13
//
// Future weather feeds?
// http://www.myweather2.com/developer/
// http://www.worldweatheronline.com/api/local-city-town-weather-api.aspx
// http://www.programmableweb.com/news/top-10-weather-apis/analysis/2014/11/13
//
// Preferences have been cached since 10.9
// https://forums.developer.apple.com/message/65946#65946
// killall -u $USER cfprefsd

import Cocoa
import WebKit

let DEFAULT_CITY = "Cupertino, CA"
let DEFAULT_INTERVAL = "60"
let YAHOO_WEATHER = "0"
let DEFAULT_PREFERENCE_VERSION = "2.0.0"

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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    // https://github.com/soffes/clock-saver/blob/master/ClockDemo/Classes/AppDelegate.swift

    @IBOutlet weak var window: NSWindow!
    //@IBOutlet weak var prefWindows: NSWindow!
    @IBOutlet weak var newVersion: NSButton!
    @IBOutlet weak var logMessages: NSButton!
    @IBOutlet weak var cityNameLabel: NSTextField!
    @IBOutlet weak var cityTextField: NSTextField!
    @IBOutlet weak var cityTextField2: NSTextField!
    @IBOutlet weak var cityTextField3: NSTextField!
    @IBOutlet weak var cityTextField4: NSTextField!
    @IBOutlet weak var cityTextField5: NSTextField!
    @IBOutlet weak var cityTextField6: NSTextField!
    @IBOutlet weak var cityTextField7: NSTextField!
    @IBOutlet weak var cityTextField8: NSTextField!
    @IBOutlet weak var cityDisplayNameLabel: NSTextField!
    @IBOutlet weak var cityDisplayTextField: NSTextField!
    @IBOutlet weak var cityDisplayTextField2: NSTextField!
    @IBOutlet weak var cityDisplayTextField3: NSTextField!
    @IBOutlet weak var cityDisplayTextField4: NSTextField!
    @IBOutlet weak var cityDisplayTextField5: NSTextField!
    @IBOutlet weak var cityDisplayTextField6: NSTextField!
    @IBOutlet weak var cityDisplayTextField7: NSTextField!
    @IBOutlet weak var cityDisplayTextField8: NSTextField!
    @IBOutlet weak var weatherSource: NSPopUpButton!
    @IBOutlet weak var weatherSourceLabel: NSTextField!
    @IBOutlet weak var controlsInSubmenu: NSButton!
    @IBOutlet weak var displayHumidity: NSButton!
    @IBOutlet weak var displayDegreeType: NSButton!
    @IBOutlet weak var displayWeatherIcon: NSButton!
    @IBOutlet weak var displayCityName: NSButton!
    @IBOutlet weak var currentWeatherInSubmenu: NSButton!
    @IBOutlet weak var viewExtendedForecast: NSButton!
    @IBOutlet weak var extendedForecastInSubmenu: NSButton!
    @IBOutlet weak var extendedForecastIcons: NSButton!
    @IBOutlet weak var extendedForecastSingleLine: NSButton!
    @IBOutlet weak var versionTextLabel: NSTextField!
    @IBOutlet weak var updateFrequencyLabel: NSTextField!
    @IBOutlet weak var updateFrequenceMinutesLabel: NSTextField!
    @IBOutlet weak var updateFrequencyTextField: NSTextField!
    @IBOutlet weak var globalUnitsLabel: NSTextField!
    @IBOutlet weak var degreesLabel: NSTextField!
    @IBOutlet weak var degreesUnit: NSPopUpButton!
    @IBOutlet weak var distanceLabel: NSTextField!
    @IBOutlet weak var distanceUnit: NSPopUpButton!
    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var speedUnit: NSPopUpButton!
    @IBOutlet weak var pressureLabel: NSTextField!
    @IBOutlet weak var pressureUnit: NSPopUpButton!
    @IBOutlet weak var directionLabel: NSTextField!
    @IBOutlet weak var directionUnit: NSPopUpButton!
    @IBOutlet weak var fontLabel: NSTextField!
    @IBOutlet weak var fontButton: NSButton!
    @IBOutlet weak var menuBarFontLabel: NSTextField!
    @IBOutlet weak var menuBarFontButton: NSButton!

    var buttonPresses = 0;
    
    var modalMenuBar = ColorPickerWindow(windowNibName: "ColorPickerWindow")
    var modalDisplay = ColorPickerWindow(windowNibName: "ColorPickerWindow")
    var radarWindow: RadarWindow!

    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var menuItem : NSMenuItem = NSMenuItem()
    
    let yahooWeatherAPI = YahooWeatherAPI()     // https://developer.yahoo.com/weather/
    let openWeatherMapAPI = OpenWeatherMapAPI() // http://www.openweathermap.org
    var myTimer = NSTimer()                     // http://ios-blog.co.uk/tutorials/swift-nstimer-tutorial-lets-create-a-counter-application/
    
    let defaults = NSUserDefaults.standardUserDefaults()
        
    // Logging: https://gist.github.com/vtardia/3f7d17efd7b258e82b62
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
    
    } // init

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    override func awakeFromNib() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLCache.sharedURLCache().diskCapacity = 0
        NSURLCache.sharedURLCache().memoryCapacity = 0
        
        var webVERSION = ""
        let newVersion = defaults.stringForKey("newVersion")
        var whatChanged = ""
        if ((newVersion != nil) && (newVersion! == "1")) {
            // Check for updates
            if let url = NSURL(string: "http://heat-meteo.sourceforge.net/" + "VERSION2") {
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
            
            if ((version != webVERSION) && (webVERSION != "")) {
                // New version!
                if let url = NSURL(string: "http://heat-meteo.sourceforge.net/" + "CHANGELOG2") {
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
                    let myUrl = "http://heat-meteo.sourceforge.net"
                    
                    if let checkURL = NSURL(string: myUrl as String) {
                        if NSWorkspace.sharedWorkspace().openURL(checkURL) {
                            //print("URL successfully opened:", myUrl, terminator: "\n")
                            exit(0)
                        }
                    } else {
                        //print("Invalid URL:", myUrl, terminator: "\n")
                    }
                }
            }
        }
        
        defaultPreferences()
        initWindowPrefs()
        
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
        statusBarItem.image = NSImage(named: "Loading-1")!
        
        m = (14 as NSNumber)
        font = NSFont(name: "Tahoma", size: 14)
        if ((defaults.stringForKey("menuBarFont") != nil) &&
            (defaults.stringForKey("menuBarFontsize") != nil)) {
                m = NSNumberFormatter().numberFromString(defaults.stringForKey("menuBarFontsize")!)!
                font = NSFont(name: defaults.stringForKey("menuBarFont")!, size: CGFloat(m))
        }
        
        // Todo - Do we have a problem or not?
        // http://stackoverflow.com/questions/19487369/center-two-different-size-font-vertically-in-a-nsattributedstring
        if (webVERSION == "") {
            statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                NSLocalizedString("NetworkFailure_", // Unique key of your choice
                    value:"No Network", // Default (English) text
                    comment:"No Network"),
                attributes:[NSFontAttributeName : font!]))
        } else {
            statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                NSLocalizedString("Loading_", // Unique key of your choice
                    value:"Loading", // Default (English) text
                    comment:"Loading") + "...",
                attributes:[NSFontAttributeName : font!]))
        }
        
        //Add menuItem to menu
        let newItem : NSMenuItem = NSMenuItem(title: NSLocalizedString("PleaseWait_", // Unique key of your choice
            value:"Please wait while Meteo fetches the weather", // Default (English) text
            comment:"Please wait"), action: Selector("dummy:"), keyEquivalent: "")
        
        newItem.target=self
        menu.addItem(newItem)
        
        addControlOptions()
        //let preferenceVersion = defaults.stringForKey("preferenceVersion")
        let preferenceVersion = defaults.stringForKey("preferenceVersion")
        //var preferenceVersion = defaults.stringForKey("preferenceVersion")
        //preferenceVersion! = ""
        if ((preferenceVersion == nil) || (preferenceVersion! != DEFAULT_PREFERENCE_VERSION)) {
            //self.window!.orderOut(self)
            self.window!.makeKeyAndOrderFront(self.window!)
            NSApp.activateIgnoringOtherApps(true)
            updateWeather()
        } else {
            updateWeather()
        }
        
    } // awakeFromNib

    func myMenuItem(string: String, url: String?, key: String) ->NSMenuItem {
        
        var newItem : NSMenuItem
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.stringForKey("fontRedText") == nil) {
            modalDisplay.setFont("font")
            modalDisplay.initPrefs()
        }
        
        let textColor = NSColor(red: CGFloat(Float(defaults.stringForKey("fontRedText")!)!),
            green: CGFloat(Float(defaults.stringForKey("fontGreenText")!)!),
            blue: CGFloat(Float(defaults.stringForKey("fontBlueText")!)!),
            alpha: 1.0)
        
        let attributedTitle: NSMutableAttributedString
        if (defaults.stringForKey("fontTransparency")! == "1") {
            attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                string,
                attributes:[NSFontAttributeName : NSFont(name: defaults.stringForKey("font")!, size: CGFloat(Float(NSNumberFormatter().numberFromString(defaults.stringForKey("fontsize")!)!)))!,
                    NSForegroundColorAttributeName : textColor]))
        } else {
            let backgroundColor = NSColor(
                red: CGFloat(Float(defaults.stringForKey("fontRedBackground")!)!),
                green: CGFloat(Float(defaults.stringForKey("fontGreenBackground")!)!),
                blue: CGFloat(Float(defaults.stringForKey("fontBlueBackground")!)!), alpha: 1.0)

            attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                string,
                attributes:[NSFontAttributeName : NSFont(name: defaults.stringForKey("font")!, size: CGFloat(Float(NSNumberFormatter().numberFromString(defaults.stringForKey("fontsize")!)!)))!,
                    NSForegroundColorAttributeName : textColor,
                    NSBackgroundColorAttributeName : backgroundColor]))
        }
        
        if (url == nil) {
            newItem = NSMenuItem(title: "", action: nil, keyEquivalent: key)
        } else {
            newItem = NSMenuItem(title: "", action: Selector(url!), keyEquivalent: key)
        }
        newItem.attributedTitle = attributedTitle
        newItem.target=self
        
        return newItem
    } // myMenuItem
    
    func addControlOptions()
    {
        var controlsMenu = NSMenu()
        var newItem : NSMenuItem
        if ((defaults.stringForKey("controlsInSubmenu") == nil) || (defaults.stringForKey("controlsInSubmenu")! == "1")) {
            newItem = myMenuItem(NSLocalizedString("Controls_", // Unique key of your choice
                value:"Controls", // Default (English) text
                comment:"Controls"), url: nil, key: "")
            menu.addItem(newItem)
            menu.setSubmenu(controlsMenu, forItem: newItem)
        } else {
            controlsMenu = menu
        }
        newItem = myMenuItem(NSLocalizedString("Refresh_", // Unique key of your choice
            value:"Refresh", // Default (English) text
            comment:"Refresh"), url: "weatherRefresh:", key: "r")
        newItem.target=self
        controlsMenu.addItem(newItem)
        
        newItem = myMenuItem(NSLocalizedString("Preferences_", // Unique key of your choice
            value:"Preferences", // Default (English) text
            comment:"Preferences"), url: "preferences:", key: ",")
        newItem.target=self
        controlsMenu.addItem(newItem)
        
        // https://gist.github.com/ericdke/75a42dc8d4c5f61df7d9
        newItem = myMenuItem(NSLocalizedString("Relaunch_", // Unique key of your choice
            value:"Relaunch", // Default (English) text
            comment:"Relaunch"), url: "Relaunch:", key: "`")
        newItem.target=self
        controlsMenu.addItem(newItem)
        
        newItem = myMenuItem(NSLocalizedString("Quit_", // Unique key of your choice
            value:"Quit", // Default (English) text
            comment:"Quit"), url: "terminate:", key: "q")
        newItem.target=nil
        controlsMenu.addItem(newItem)
        
    } // addControlOptions
    
    func updateWeather()
    {
        radarWindow = RadarWindow()
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
                
                let textColor = NSColor(red: CGFloat(Float(defaults.stringForKey("menuBarFontRedText")!)!),
                    green: CGFloat(Float(defaults.stringForKey("menuBarFontGreenText")!)!),
                    blue: CGFloat(Float(defaults.stringForKey("menuBarFontBlueText")!)!), alpha: 1.0)
                
                if (defaults.stringForKey("menuBarFontTransparency")! == "1") {
                    statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                        statusTitle,
                        attributes:[NSFontAttributeName : font!,
                            NSForegroundColorAttributeName : textColor]))
                } else {
                    let backgroundColor = NSColor(
                        red: CGFloat(Float(defaults.stringForKey("menuBarFontRedBackground")!)!),
                        green: CGFloat(Float(defaults.stringForKey("menuBarFontGreenBackground")!)!),
                        blue: CGFloat(Float(defaults.stringForKey("menuBarFontBlueBackground")!)!), alpha: 1.0)
                    statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                        statusTitle,
                        attributes:[NSFontAttributeName : font!,
                            NSForegroundColorAttributeName : textColor,
                            NSBackgroundColorAttributeName : backgroundColor]))
                }
                
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
                addControlOptions()
            }
        } else if (defaults.stringForKey("weatherSource")! == "1") {
            openWeatherMapAPI.setRadarWind(radarWindow)
            weatherFields = openWeatherMapAPI.beginParsing(city)
            
            if (weatherFields.currentTemp != "") {
                
                if (displayCity != "") {
                    city = displayCity
                }
                
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

                let textColor = NSColor(red: CGFloat(Float(defaults.stringForKey("menuBarFontRedText")!)!),
                    green: CGFloat(Float(defaults.stringForKey("menuBarFontGreenText")!)!),
                    blue: CGFloat(Float(defaults.stringForKey("menuBarFontBlueText")!)!), alpha: 1.0)
                
                if (defaults.stringForKey("menuBarFontTransparency")! == "1") {
                    statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                        statusTitle,
                        attributes:[NSFontAttributeName : font!,
                            NSForegroundColorAttributeName : textColor]))
                } else {
                    let backgroundColor = NSColor(
                        red: CGFloat(Float(defaults.stringForKey("menuBarFontRedBackground")!)!),
                        green: CGFloat(Float(defaults.stringForKey("menuBarFontGreenBackground")!)!),
                        blue: CGFloat(Float(defaults.stringForKey("menuBarFontBlueBackground")!)!), alpha: 1.0)
                    statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                        statusTitle,
                        attributes:[NSFontAttributeName : font!,
                            NSForegroundColorAttributeName : textColor,
                            NSBackgroundColorAttributeName : backgroundColor]))
                }
                
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
                addControlOptions()
            }
        }
        
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
    
    func testAndSet(key:String, defaultValue:String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let d = defaults.stringForKey(key)
        if (d == nil) {
            defaults.setValue(defaultValue, forKey: key)
        }
    } // testAndSet
    
    func defaultPreferences() {
        
        testAndSet("weatherSource", defaultValue: YAHOO_WEATHER)
        
        testAndSet("city", defaultValue: DEFAULT_CITY)
        testAndSet("city2", defaultValue: "")
        testAndSet("city3", defaultValue: "")
        testAndSet("city4", defaultValue: "")
        testAndSet("city5", defaultValue: "")
        testAndSet("city6", defaultValue: "")
        testAndSet("city7", defaultValue: "")
        testAndSet("city8", defaultValue: "")
        testAndSet("displayCity", defaultValue: "")
        testAndSet("displayCity2", defaultValue: "")
        testAndSet("displayCity3", defaultValue: "")
        testAndSet("displayCity4", defaultValue: "")
        testAndSet("displayCity5", defaultValue: "")
        testAndSet("displayCity6", defaultValue: "")
        testAndSet("displayCity7", defaultValue: "")
        testAndSet("displayCity8", defaultValue: "")
        
        testAndSet("updateFrequency", defaultValue: DEFAULT_INTERVAL)
        testAndSet("controlsInSubmenu", defaultValue: "1")
        testAndSet("displayHumidity", defaultValue: "1")
        testAndSet("displayDegreeType", defaultValue: "1")
        testAndSet("displayWeatherIcon", defaultValue: "1")
        testAndSet("displayCityName", defaultValue: "1")
        testAndSet("currentWeatherInSubmenu", defaultValue: "1")
        testAndSet("viewExtendedForecast", defaultValue: "1")
        testAndSet("extendedForecastSingleLine", defaultValue: "1")
        testAndSet("extendedForecastInSubmenu", defaultValue: "1")
        testAndSet("extendedForecastIcons", defaultValue: "1")
        testAndSet("newVersion", defaultValue: "1")
        testAndSet("logMessages", defaultValue: "0")

        testAndSet("degreesUnit", defaultValue: "0")
        testAndSet("distanceUnit", defaultValue: "0")
        testAndSet("speedUnit", defaultValue: "0")
        testAndSet("pressureUnit", defaultValue: "0")
        testAndSet("directionUnit", defaultValue: "0")
        
        testAndSet("preferenceVersion", defaultValue: DEFAULT_PREFERENCE_VERSION)

    } // defaultPreferences
    
    func initWindowPrefs() {
        
        initDisplay()
        
        modalDisplay.setFont("font")
        modalDisplay.initPrefs()
        
        modalMenuBar.setFont("menuBarFont")
        modalMenuBar.initPrefs()
        
        // https://www.youtube.com/watch?v=lJS4YWUT8Hk
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        //let build = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        versionTextLabel.stringValue = "Version " + version // + " build " + build
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        weatherSource.selectItemAtIndex(Int(defaults.stringForKey("weatherSource") ?? YAHOO_WEATHER)!)
        
        cityTextField.stringValue           = defaults.stringForKey("city") ?? DEFAULT_CITY
        cityTextField2.stringValue          = defaults.stringForKey("city2") ?? ""
        cityTextField3.stringValue          = defaults.stringForKey("city3") ?? ""
        cityTextField4.stringValue          = defaults.stringForKey("city4") ?? ""
        cityTextField5.stringValue          = defaults.stringForKey("city5") ?? ""
        cityTextField6.stringValue          = defaults.stringForKey("city6") ?? ""
        cityTextField7.stringValue          = defaults.stringForKey("city7") ?? ""
        cityTextField8.stringValue          = defaults.stringForKey("city8") ?? ""
        cityDisplayTextField.stringValue    = defaults.stringForKey("displayCity") ?? ""
        cityDisplayTextField2.stringValue   = defaults.stringForKey("displayCity2") ?? ""
        cityDisplayTextField3.stringValue   = defaults.stringForKey("displayCity3") ?? ""
        cityDisplayTextField4.stringValue   = defaults.stringForKey("displayCity4") ?? ""
        cityDisplayTextField5.stringValue   = defaults.stringForKey("displayCity5") ?? ""
        cityDisplayTextField6.stringValue   = defaults.stringForKey("displayCity6") ?? ""
        cityDisplayTextField7.stringValue   = defaults.stringForKey("displayCity7") ?? ""
        cityDisplayTextField8.stringValue   = defaults.stringForKey("displayCity8") ?? ""
        
        updateFrequencyTextField.stringValue = defaults.stringForKey("updateFrequency") ?? DEFAULT_INTERVAL
        controlsInSubmenu.stringValue       = defaults.stringForKey("controlsInSubmenu") ?? "1"
        displayHumidity.stringValue         = defaults.stringForKey("displayHumidity") ?? "1"
        displayDegreeType.stringValue       = defaults.stringForKey("displayDegreeType") ?? "1"
        displayWeatherIcon.stringValue      = defaults.stringForKey("displayWeatherIcon") ?? "1"
        displayCityName.stringValue         = defaults.stringForKey("displayCityName") ?? "1"
        currentWeatherInSubmenu.stringValue = defaults.stringForKey("currentWeatherInSubmenu") ?? "1"
        viewExtendedForecast.stringValue    = defaults.stringForKey("viewExtendedForecast") ?? "1"
        extendedForecastSingleLine.stringValue = defaults.stringForKey("extendedForecastSingleLine") ?? "1"
        extendedForecastInSubmenu.stringValue = defaults.stringForKey("extendedForecastInSubmenu") ?? "1"
        extendedForecastIcons.stringValue   = defaults.stringForKey("extendedForecastIcons") ?? "1"
        newVersion.stringValue              = defaults.stringForKey("newVersion") ?? "1"
        logMessages.stringValue             = defaults.stringForKey("logMessages") ?? "0"
        
        degreesUnit.selectItemAtIndex(Int(defaults.stringForKey("degreesUnit") ?? "0")!)
        distanceUnit.selectItemAtIndex(Int(defaults.stringForKey("distanceUnit") ?? "0")!)
        speedUnit.selectItemAtIndex(Int(defaults.stringForKey("speedUnit") ?? "0")!)
        pressureUnit.selectItemAtIndex(Int(defaults.stringForKey("pressureUnit") ?? "0")!)
        directionUnit.selectItemAtIndex(Int(defaults.stringForKey("directionUnit") ?? "0")!)
    } // initWindowPrefs
    
    func windowWillClose(notification: NSNotification) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setValue(weatherSource.indexOfSelectedItem, forKey: "weatherSource")
        
        defaults.setValue(cityTextField.stringValue, forKey: "city")
        if (cityTextField.stringValue == "") {
            defaults.setValue(DEFAULT_CITY, forKey: "city")
        }
        defaults.setValue(cityTextField2.stringValue, forKey: "city2")
        defaults.setValue(cityTextField3.stringValue, forKey: "city3")
        defaults.setValue(cityTextField4.stringValue, forKey: "city4")
        defaults.setValue(cityTextField5.stringValue, forKey: "city5")
        defaults.setValue(cityTextField6.stringValue, forKey: "city6")
        defaults.setValue(cityTextField7.stringValue, forKey: "city7")
        defaults.setValue(cityTextField8.stringValue, forKey: "city8")
        defaults.setValue(cityDisplayTextField.stringValue,  forKey: "displayCity")
        defaults.setValue(cityDisplayTextField2.stringValue, forKey: "displayCity2")
        defaults.setValue(cityDisplayTextField3.stringValue, forKey: "displayCity3")
        defaults.setValue(cityDisplayTextField4.stringValue, forKey: "displayCity4")
        defaults.setValue(cityDisplayTextField5.stringValue, forKey: "displayCity5")
        defaults.setValue(cityDisplayTextField6.stringValue, forKey: "displayCity6")
        defaults.setValue(cityDisplayTextField7.stringValue, forKey: "displayCity7")
        defaults.setValue(cityDisplayTextField8.stringValue, forKey: "displayCity8")
        
        defaults.setValue(updateFrequencyTextField.stringValue, forKey: "updateFrequency")
        defaults.setValue(controlsInSubmenu.stringValue, forKey: "controlsInSubmenu")
        defaults.setValue(displayHumidity.stringValue, forKey: "displayHumidity")
        defaults.setValue(displayDegreeType.stringValue, forKey: "displayDegreeType")
        defaults.setValue(displayWeatherIcon.stringValue, forKey: "displayWeatherIcon")
        defaults.setValue(displayCityName.stringValue, forKey: "displayCityName")
        defaults.setValue(currentWeatherInSubmenu.stringValue, forKey: "currentWeatherInSubmenu")
        defaults.setValue(viewExtendedForecast.stringValue, forKey: "viewExtendedForecast")
        defaults.setValue(extendedForecastSingleLine.stringValue, forKey: "extendedForecastSingleLine")
        defaults.setValue(extendedForecastInSubmenu.stringValue, forKey: "extendedForecastInSubmenu")
        defaults.setValue(extendedForecastIcons.stringValue, forKey: "extendedForecastIcons")
        defaults.setValue(newVersion.stringValue, forKey: "newVersion")
        defaults.setValue(logMessages.stringValue, forKey: "logMessages")
        
        defaults.setValue(degreesUnit.indexOfSelectedItem, forKey: "degreesUnit")
        defaults.setValue(distanceUnit.indexOfSelectedItem, forKey: "distanceUnit")
        defaults.setValue(speedUnit.indexOfSelectedItem, forKey: "speedUnit")
        defaults.setValue(pressureUnit.indexOfSelectedItem, forKey: "pressureUnit")
        defaults.setValue(directionUnit.indexOfSelectedItem, forKey: "directionUnit")
        
        defaults.setValue(DEFAULT_PREFERENCE_VERSION, forKey: "preferenceVersion")

        let i = NSNumberFormatter().numberFromString(defaults.stringForKey("fontsize")!)
        menu.font = NSFont(name: defaults.stringForKey("font")!, size: CGFloat(i!))
        
        updateWeather()
        
    } // windowWillClose
    
    
    func initDisplay() {
        self.window!.title = NSLocalizedString("Preferences_", // Unique key of your choice
            value:"Preferences", // Default (English) text
            comment:"Preferences")
        cityNameLabel.stringValue = NSLocalizedString("CityNames_", // Unique key of your choice
            value:"City Names", // Default (English) text
            comment:"City Names") + ":"
        cityDisplayNameLabel.stringValue = NSLocalizedString("CityDisplayNames_", // Unique key of your choice
            value:"Display Names", // Default (English) text
            comment:"Display Names") + ":"
        updateFrequencyLabel.stringValue = NSLocalizedString("UpdateFrequency_", // Unique key of your choice
            value:"Update Frequency", // Default (English) text
            comment:"Update Frequency") + ":"
        updateFrequenceMinutesLabel.stringValue = NSLocalizedString("UpdateMinutes_", // Unique key of your choice
            value:"minutes", // Default (English) text
            comment:"minutes")
        
        newVersion.title = NSLocalizedString("NewVersion_", // Unique key of your choice
            value:"Check for new versions on launch", // Default (English) text
            comment:"Check for new versions on launch")
        
        logMessages.title = NSLocalizedString("logMessages_", // Unique key of your choice
            value:"Log messages to console", // Default (English) text
            comment:"Log messages to console")
        
        weatherSourceLabel.stringValue = NSLocalizedString("WeatherSource_", // Unique key of your choice
            value:"Weather Source", // Default (English) text
            comment:"Weather Source") + ":"
        weatherSource.itemAtIndex(0)?.title = NSLocalizedString("Yahoo!_", // Unique key of your choice
            value:"Yahoo!", // Default (English) text
            comment:"Yahoo")
        weatherSource.itemAtIndex(1)?.title = NSLocalizedString("OpenWeatherMap_", // Unique key of your choice
            value:"OpenWeatherMap", // Default (English) text
            comment:"OpenWeatherMap")
        
        currentWeatherInSubmenu.title = NSLocalizedString("CurrentWeather_", // Unique key of your choice
            value:"Current weather in submenu", // Default (English) text
            comment:"Current weather in submenu")
        displayHumidity.title = NSLocalizedString("DisplayHumidity_", // Unique key of your choice
            value:"Display Humidity", // Default (English) text
            comment:"Display Humidity")
        displayDegreeType.title = NSLocalizedString("DisplayDegreeType_", // Unique key of your choice
            value:"Display type (C/F)", // Default (English) text
            comment:"Display type (C/F)")
        displayWeatherIcon.title = NSLocalizedString("DisplayWeatherIcon_", // Unique key of your choice
            value:"Display weather icon", // Default (English) text
            comment:"Display weather icon")
        displayCityName.title = NSLocalizedString("DisplayCityName_", // Unique key of your choice
            value:"Display city name", // Default (English) text
            comment:"Display city name")
        controlsInSubmenu.title = NSLocalizedString("ControlsInSubmenu_", // Unique key of your choice
            value:"Show controls in submenu", // Default (English) text
            comment:"Show controls in submenu")
        viewExtendedForecast.title = NSLocalizedString("ViewExtendedForecast_", // Unique key of your choice
            value:"View extended forecast", // Default (English) text
            comment:"View extended forecast")
        extendedForecastInSubmenu.title = NSLocalizedString("ExtendedForecastInSubmenu_", // Unique key of your choice
            value:"Extended forecast in submenu", // Default (English) text
            comment:"Extended forecast in submenu")
        extendedForecastIcons.title = NSLocalizedString("ExtendedForecastIcons_", // Unique key of your choice
            value:"Extended forecast icons", // Default (English) text
            comment:"Extended forecast icons")
        extendedForecastSingleLine.title = NSLocalizedString("ExtendedForecastSingleLine_", // Unique key of your choice
            value:"Extended forecast single line", // Default (English) text
            comment:"Extended forecast single line")
        
        globalUnitsLabel.stringValue = NSLocalizedString("GlobalUnits_", // Unique key of your choice
            value:"Global Units", // Default (English) text
            comment:"Global Units") + ":"
        
        degreesLabel.stringValue = NSLocalizedString("Degrees_", // Unique key of your choice
            value:"Degrees", // Default (English) text
            comment:"Degrees") + ":"
        degreesUnit.itemAtIndex(0)?.title = NSLocalizedString("Fahrenheit_", // Unique key of your choice
            value:"Fahrenheit", // Default (English) text
            comment:"Fahrenheit")
        degreesUnit.itemAtIndex(1)?.title = NSLocalizedString("Celsius_", // Unique key of your choice
            value:"Celsius", // Default (English) text
            comment:"Celsius")
        // Need default value
        
        speedLabel.stringValue = NSLocalizedString("Speed_", // Unique key of your choice
            value:"Speed", // Default (English) text
            comment:"Speed") + ":"
        speedUnit.itemAtIndex(0)?.title = NSLocalizedString("MilesPerHour_", // Unique key of your choice
            value:"Miles/Hour", // Default (English) text
            comment:"Miles/Hour")
        speedUnit.itemAtIndex(1)?.title = NSLocalizedString("KMPerHour_", // Unique key of your choice
            value:"Kilometers/Hour", // Default (English) text
            comment:"Kilometers/Hour")
        speedUnit.itemAtIndex(2)?.title = NSLocalizedString("MPerSec_", // Unique key of your choice
            value:"Meters/Second", // Default (English) text
            comment:"Meters/Second")
        speedUnit.itemAtIndex(3)?.title = NSLocalizedString("Knots_", // Unique key of your choice
            value:"Knots", // Default (English) text
            comment:"Knots")
        // Need default value
        
        distanceLabel.stringValue = NSLocalizedString("Distance_", // Unique key of your choice
            value:"Distance", // Default (English) text
            comment:"Distance") + ":"
        distanceUnit.itemAtIndex(0)?.title = NSLocalizedString("Miles_", // Unique key of your choice
            value:"Miles", // Default (English) text
            comment:"Miles")
        distanceUnit.itemAtIndex(1)?.title = NSLocalizedString("Feet_", // Unique key of your choice
            value:"Feet", // Default (English) text
            comment:"Feet")
        distanceUnit.itemAtIndex(2)?.title = NSLocalizedString("Kilometers_", // Unique key of your choice
            value:"Kilometers", // Default (English) text
            comment:"Kilometers")
        distanceUnit.itemAtIndex(3)?.title = NSLocalizedString("Meters_", // Unique key of your choice
            value:"Meters", // Default (English) text
            comment:"Meters")
        // Need default value
        
        pressureLabel.stringValue = NSLocalizedString("Pressure_", // Unique key of your choice
            value:"Pressure", // Default (English) text
            comment:"Pressure") + ":"
        pressureUnit.itemAtIndex(0)?.title = NSLocalizedString("Inches_", // Unique key of your choice
            value:"Inches", // Default (English) text
            comment:"Inches")
        pressureUnit.itemAtIndex(1)?.title = NSLocalizedString("Millibars_", // Unique key of your choice
            value:"Millibars", // Default (English) text
            comment:"Millibars")
        pressureUnit.itemAtIndex(2)?.title = NSLocalizedString("Kilopascals_", // Unique key of your choice
            value:"Kilopascals", // Default (English) text
            comment:"Kilopascals")
        pressureUnit.itemAtIndex(3)?.title = NSLocalizedString("Hectopascals_", // Unique key of your choice
            value:"Hectopascals", // Default (English) text
            comment:"Hectopascals")
        // Need default value
        
        directionLabel.stringValue = NSLocalizedString("Direction_", // Unique key of your choice
            value:"Direction", // Default (English) text
            comment:"Direction") + ":"
        directionUnit.itemAtIndex(0)?.title = NSLocalizedString("Degrees_", // Unique key of your choice
            value:"Degrees", // Default (English) text
            comment:"Degrees")
        directionUnit.itemAtIndex(1)?.title = NSLocalizedString("Ordinal_", // Unique key of your choice
            value:"Ordinal", // Default (English) text
            comment:"Ordinal")
        // Need default value
        
        fontLabel.stringValue = NSLocalizedString("DisplayFont_", // Unique key of your choice
            value:"Display Font", // Default (English) text
            comment:"Display") + ":"
        menuBarFontLabel.stringValue = NSLocalizedString("menuBarFont_", // Unique key of your choice
            value:"Menu Bar Font", // Default (English) text
            comment:"Menu Bar Font") + ":"
        
        fontButton.title = NSLocalizedString("SetFont_", // Unique key of your choice
            value:"Set Font", // Default (English) text
            comment:"Set Font")
        menuBarFontButton.title = NSLocalizedString("SetFont_", // Unique key of your choice
            value:"Set Font", // Default (English) text
            comment:"Set Font")
        
    } // initDisplay
    
    @IBAction func DisplayFontPressed(sender: NSButton) {
        // https://translate.google.com/translate?sl=auto&tl=en&js=y&prev=_t&hl=en&ie=UTF-8&u=http%3A%2F%2Fcocoaapi.hatenablog.com%2Fentry%2FAppkit%2FNSWindow_class%2FbeginSheet%253AcompletionHandler%253A&edit-text=&act=url
        modalDisplay.setFont("font")
        self.window!.beginSheet (modalDisplay.window!, completionHandler: nil)
    }
    
    @IBAction func MenuBarFontPressed(sender: NSButton) {
        // https://translate.google.com/translate?sl=auto&tl=en&js=y&prev=_t&hl=en&ie=UTF-8&u=http%3A%2F%2Fcocoaapi.hatenablog.com%2Fentry%2FAppkit%2FNSWindow_class%2FbeginSheet%253AcompletionHandler%253A&edit-text=&act=url
        modalMenuBar.setFont("menuBarFont")
        self.window!.beginSheet (modalMenuBar.window!, completionHandler: nil)
    }
    
    @IBAction func preferences(sender: NSMenuItem) {
        self.window!.delegate = self
        self.window!.orderOut(self)
        self.window!.makeKeyAndOrderFront(self.window!)
        NSApp.activateIgnoringOtherApps(true)
    } // dummy
    
    @IBAction func Relaunch(sender: NSMenuItem) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("logMessages")! == "1") {
            InfoLog(String(format:"Application %@ relaunching", self.appName))
        }
        
        let task = NSTask()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep 0.2; open \"\(NSBundle.mainBundle().bundlePath)\""]
        task.launch()
        NSApplication.sharedApplication().terminate(nil)
    } // dummy
    
    @IBAction func weatherRefresh(sender: NSMenuItem) {
        updateWeather()
    } // weatherRefresh
    
}
