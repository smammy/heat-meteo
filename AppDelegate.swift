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
// A couple of problems were encountered with 10.9.
// 1. The labelColor font attribute was on for all labels in MainMenu.xib.
//    Had to updapte both the TEXT and BACKCOLOR to default.
//    No clue why but we're not alone. It's an Apple bug somewhere.
// 2. Fix the font problem above then starated getting another Apple crash.
//    Found this link, downloaded the Mavericks10.9.imageset file from this URL and it magically solved the problem.
//    http://stackoverflow.com/questions/39616332/tokencount-maxcountincludingzeroterminator-assertion-osx-10-9
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
//
// Preferences have been cached since 10.9
// https://forums.developer.apple.com/message/65946#65946
// killall -u $USER cfprefsd
//
// http://stackoverflow.com/questions/26340670/issue-with-genstrings-for-swift-file
//

import Cocoa
import WebKit

let DEFAULT_CITY = "Cupertino, CA"
let DEFAULT_INTERVAL = "60"

let YAHOO_WEATHER = "0"
let OPENWEATHERMAP = "1"
let THEWEATHER = "2"
let WEATHERUNDERGROUND = "3"
let AERISWEATHER = "4"
let WORLDWEATHERONLINE = "5"
let APIXU = "6"
let DARKSKY = "7"

var DEFAULT_PREFERENCE_VERSION = String()
var NoInternetConnectivity = Int()

// http://stackoverflow.com/questions/24196689/how-to-get-the-power-of-some-integer-in-swift-language
// Put this at file level anywhere in your project

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ** : PowerPrecedence

func ** (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}
func ** (radix: Double, power: Double) -> Double
{
    return pow(radix, power)
}
func ** (radix: Int,    power: Int   ) -> Double
{
    return pow(Double(radix), Double(power))
}
func ** (radix: Float,  power: Float ) -> Double
{
    return pow(Double(radix), Double(power))
}

func localizedString(forKey key: String) -> String {
    var result = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    
    if result == key {
        result = Bundle.main.localizedString(forKey: key, value: nil, table: "Default")
    }
    
    return result
}

struct WeatherFields {
    
    var title1 = String()
    var date = String()
    
    var latitude = String()
    var longitude = String()
    
    //var windChill = String()
    var windSpeed = String()
    var windDirection = String()
    
    var humidity = String()
    var pressure = String()
    var visibility = String()
    
    var sunrise = String()
    var sunset = String()
    
    var currentLink = String()
    var currentTemp = String()
    var currentCode = String()          // Abbreviated Conditions
    var currentConditions = String()    // Full Conditions
    
    // http://stackoverflow.com/questions/30430550/how-to-create-an-empty-array-in-swift
    var forecastCounter = 0
    var forecastDate = [String]()
    var forecastDay = [String]()
    var forecastHigh = [String]()
    var forecastLow = [String]()
    var forecastCode = [String]()       // Abbreviated Conditions
    var forecastConditions = [String]() // Full Condition

    var URL = String()
    
    var weatherTag = String()
    
} // WeatherFields

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate
{
    
    // https://github.com/soffes/clock-saver/blob/master/ClockDemo/Classes/AppDelegate.swift
    
    @IBOutlet weak var window: NSWindow!
    //@IBOutlet weak var prefWindows: NSWindow!
    @IBOutlet weak var newVersion: NSButton!
    @IBOutlet weak var logMessages: NSButton!
    
    @IBOutlet weak var cityNameLabel: NSTextField!
    @IBOutlet weak var cityDisplayNameLabel: NSTextField!
    @IBOutlet weak var weatherSourceLabel: NSTextField!
    @IBOutlet weak var API_Key_Label1: NSTextField!
    @IBOutlet weak var API_Key_Label2: NSTextField!
  
    @IBOutlet weak var cityTextField: NSTextField!
    @IBOutlet weak var cityDisplayTextField: NSTextField!
    @IBOutlet weak var weatherSource_1: NSPopUpButton!
    @IBOutlet weak var API_Key_Data1_1: NSTextField!
    @IBOutlet weak var API_Key_Data2_1: NSTextField!

    @IBOutlet weak var cityTextField2: NSTextField!
    @IBOutlet weak var cityDisplayTextField2: NSTextField!
    @IBOutlet weak var weatherSource_2: NSPopUpButton!
    @IBOutlet weak var API_Key_Data1_2: NSTextField!
    @IBOutlet weak var API_Key_Data2_2: NSTextField!

    @IBOutlet weak var cityTextField3: NSTextField!
    @IBOutlet weak var cityDisplayTextField3: NSTextField!
    @IBOutlet weak var weatherSource_3: NSPopUpButton!
    @IBOutlet weak var API_Key_Data1_3: NSTextField!
    @IBOutlet weak var API_Key_Data2_3: NSTextField!
    
    @IBOutlet weak var cityTextField4: NSTextField!
    @IBOutlet weak var cityDisplayTextField4: NSTextField!
    @IBOutlet weak var weatherSource_4: NSPopUpButton!
    @IBOutlet weak var API_Key_Data1_4: NSTextField!
    @IBOutlet weak var API_Key_Data2_4: NSTextField!
    
    @IBOutlet weak var cityTextField5: NSTextField!
    @IBOutlet weak var cityDisplayTextField5: NSTextField!
    @IBOutlet weak var weatherSource_5: NSPopUpButton!
    @IBOutlet weak var API_Key_Data1_5: NSTextField!
    @IBOutlet weak var API_Key_Data2_5: NSTextField!
    
    @IBOutlet weak var cityTextField6: NSTextField!
    @IBOutlet weak var cityDisplayTextField6: NSTextField!
    @IBOutlet weak var weatherSource_6: NSPopUpButton!
    @IBOutlet weak var API_Key_Data1_6: NSTextField!
    @IBOutlet weak var API_Key_Data2_6: NSTextField!
    
    @IBOutlet weak var cityTextField7: NSTextField!
    @IBOutlet weak var cityDisplayTextField7: NSTextField!
    @IBOutlet weak var weatherSource_7: NSPopUpButton!
    @IBOutlet weak var API_Key_Data1_7: NSTextField!
    @IBOutlet weak var API_Key_Data2_7: NSTextField!
    
    @IBOutlet weak var cityTextField8: NSTextField!
    @IBOutlet weak var cityDisplayTextField8: NSTextField!
    @IBOutlet weak var weatherSource_8: NSPopUpButton!
    @IBOutlet weak var API_Key_Data1_8: NSTextField!
    @IBOutlet weak var API_Key_Data2_8: NSTextField!
    
    @IBOutlet weak var menuBarFontLabel: NSTextField!
    @IBOutlet weak var menuBarFontButton: NSButton!
    @IBOutlet weak var fontLabel: NSTextField!
    @IBOutlet weak var fontButton: NSButton!
    @IBOutlet weak var updateFrequencyLabel: NSTextField!
    @IBOutlet weak var updateFrequenceMinutesLabel: NSTextField!
    @IBOutlet weak var updateFrequencyTextField: NSTextField!
    @IBOutlet weak var delayFrequencyLabel: NSTextField!
    @IBOutlet weak var delayFrequencySecondsLabel: NSTextField!
    @IBOutlet weak var delayFrequencyTextField: NSTextField!
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

    @IBOutlet weak var forecastLabel: NSTextField!
    @IBOutlet weak var forecastDays: NSPopUpButton!

    @IBOutlet weak var controlsInSubmenu: NSButton!
    @IBOutlet weak var displayHumidity: NSButton!
    @IBOutlet weak var displayDegreeType: NSButton!
    @IBOutlet weak var displayWeatherIcon: NSButton!
    @IBOutlet weak var displayCityName: NSButton!
    @IBOutlet weak var useNewWeatherIcons: NSButton!  //Added this to give choice between color and monochrome icons
    @IBOutlet weak var currentWeatherInSubmenu: NSButton!
    @IBOutlet weak var viewExtendedForecast: NSButton!
    @IBOutlet weak var extendedForecastInSubmenu: NSButton!
    @IBOutlet weak var extendedForecastIcons: NSButton!
    @IBOutlet weak var extendedForecastSingleLine: NSButton!
    @IBOutlet weak var rotateWeatherLocations: NSButton!

    @IBOutlet weak var versionTextLabel: NSTextField!
    
    @IBOutlet weak var apiKeyLabel: NSTextField!
    
    @IBOutlet weak var theWeatherLocation: NSTextField!
    @IBOutlet weak var openWeatherMapLocation: NSTextField!
    @IBOutlet weak var yahooLocation: NSTextField!
    @IBOutlet weak var wundergroundLocation: NSTextField!
    @IBOutlet weak var aerisLocation: NSTextField!
    @IBOutlet weak var worldWeatherLocation: NSTextField!
    @IBOutlet weak var darkSkyLocation: NSTextField!
    @IBOutlet weak var APIXULocation: NSTextField!
    
    @IBOutlet weak var theWeatherURL: NSButton!
    @IBOutlet weak var openWeatherMapURL: NSButton!
    @IBOutlet weak var yahooURL: NSButton!
    @IBOutlet weak var wundergroundURL: NSButton!
    @IBOutlet weak var aerisURL: NSButton!
    @IBOutlet weak var worldWeatherURL: NSButton!
    @IBOutlet weak var darkSkyURL: NSButton!
    @IBOutlet weak var apixuURL: NSButton!
    
    var buttonPresses = 0;
    
    var modalMenuBar = ColorPickerWindow(windowNibName: "ColorPickerWindow")
    var modalDisplay = ColorPickerWindow(windowNibName: "ColorPickerWindow")
    var radarWindow: RadarWindow!
    
    var statusBar = NSStatusBar.system()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var menuItem : NSMenuItem = NSMenuItem()
    
    let yahooWeatherAPI = YahooWeatherAPI()     // https://developer.yahoo.com/weather/
    let openWeatherMapAPI = OpenWeatherMapAPI() // http://www.openweathermap.org
    let theWeatherAPI = TheWeatherAPI()
    let weatherUndergroundAPI = WeatherUndergroundAPI()
    let darkSkyAPI = DarkSkyAPI()
    let aerisWeatherAPI = AerisWeatherAPI()
    let worldWeatherOnlineAPI = WorldWeatherOnlineAPI()
    let ApiXUApi = APIXUAPI()
    
    var myTimer = Timer()                     // http://ios-blog.co.uk/tutorials/swift-nstimer-tutorial-lets-create-a-counter-application/
    var loadTimer: Timer!  //For loading animation
    
    let defaults = UserDefaults.standard
    
    // Logging: https://gist.github.com/vtardia/3f7d17efd7b258e82b62
    var appInfo: Dictionary<NSObject,AnyObject>
    var appName: String!
    var weatherFields: WeatherFields

    var whichWeatherFirst = 0
    
    override init()
    {
        
        DEFAULT_PREFERENCE_VERSION = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        // Init local parameters
        self.appInfo = CFBundleGetInfoDictionary(CFBundleGetMainBundle()) as Dictionary
        self.appName = appInfo[kCFBundleNameKey] as! String
        
        weatherFields = WeatherFields()

        // Init parent
        super.init()
        
        // Other init below...
        
        // Library/Logs/Meteo.log
        SetCustomLogFilename(self.appName)
        
        let defaults = UserDefaults.standard
        if ((defaults.string(forKey: "logMessages") != nil) &&
            (defaults.string(forKey: "logMessages")! == "1"))
        {
            InfoLog(String(format:"Application %@ starting", self.appName))
        }

    } // init
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        //        let icon = NSImage(named: "Loading-1")
        //        icon?.template = true // best for dark mode
        //        statusItem.image = icon
        //        statusItem.menu = statusMenu
    }
    
    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }
    
    override func awakeFromNib()
    {
        
        let defaults = UserDefaults.standard
        
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0

        /*
         * Project settings/Target/Build Settings/Swift Compiler - Custom Flags/Other Swift Flags
         * -DAPP_STORE
         */

        #if APP_STORE
            API_Key_Data1_1.isHidden = true
            API_Key_Data2_1.isHidden = true
            API_Key_Data1_2.isHidden = true
            API_Key_Data2_2.isHidden = true
            API_Key_Data1_3.isHidden = true
            API_Key_Data2_3.isHidden = true
            API_Key_Data1_4.isHidden = true
            API_Key_Data2_4.isHidden = true
            API_Key_Data1_5.isHidden = true
            API_Key_Data2_5.isHidden = true
            API_Key_Data1_6.isHidden = true
            API_Key_Data2_6.isHidden = true
            API_Key_Data1_7.isHidden = true
            API_Key_Data2_7.isHidden = true
            API_Key_Data1_8.isHidden = true
            API_Key_Data2_8.isHidden = true
            API_Key_Label1.isHidden = true
            API_Key_Label2.isHidden = true
            apiKeyLabel.isHidden = true
            theWeatherLocation.isHidden = true
            openWeatherMapLocation.isHidden = true
            yahooLocation.isHidden = true
            wundergroundLocation.isHidden = true
            aerisLocation.isHidden = true
            worldWeatherLocation.isHidden = true
            theWeatherURL.isHidden = true
            openWeatherMapURL.isHidden = true
            yahooURL.isHidden = true
            wundergroundURL.isHidden = true
            aerisURL.isHidden = true
            worldWeatherURL.isHidden = true
            darkSkyURL.isHidden = true
            apixuURL.isHidden = true
        #else
        #endif
        
        statusBarItem = statusBar.statusItem(withLength: -1)
        statusBarItem.menu = menu
        statusBarItem.title = localizedString(forKey: "Loading_") + "..."
        statusBarItem.image = NSImage(named: "Loading-1")!
        loadTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AppDelegate.runTimedCode), userInfo: nil, repeats: true);  //Start animating the menubar icon

        let newItem : NSMenuItem = NSMenuItem(title: localizedString(forKey: "PleaseWait_"), action: #selector(AppDelegate.dummy(_:)), keyEquivalent: "")
        
        newItem.target=self
        menu.addItem(newItem)
        
        addControlOptions()
        
        var launchDelay = 10.0
        if (defaults.string(forKey: "launchDelay") != nil)
        {
            launchDelay = Double(defaults.string(forKey: "launchDelay")!)!
        }
        if (launchDelay > 0.00)
        {
            if ((defaults.string(forKey: "logMessages") != nil) &&
                (defaults.string(forKey: "logMessages")! == "1"))
            {
                InfoLog(String(format:"Sleeping for a %d seconds to allow WiFi to get started", launchDelay))
            }

            // Sleep for a few seconds to allow WiFi to get started
            // ToDo - make this a user parameter
            Timer.scheduledTimer(timeInterval: launchDelay, target: self, selector: #selector(AppDelegate.launchWeather), userInfo: nil, repeats: false)
        }
        else
        {
            launchWeather()
        }

    } // awakeFromNib
    
    func launchWeather() {
        var webVERSION = ""
        let newVersion = defaults.string(forKey: "newVersion")
        var whatChanged = ""
        if ((newVersion != nil) && (newVersion! == "1"))
        {
            // Check for updates
            if let url = URL(string: "http://heat-meteo.sourceforge.net/" + "VERSION2") {
                do
                {
                    webVERSION = try NSString(contentsOf: url, usedEncoding: nil) as String
                }
                catch
                {
                    // contents could not be loaded
                    webVERSION = ""
                }
            }
            else
            {
                // the URL was bad!
                webVERSION = ""
            }
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            
            if ((version != webVERSION) && (webVERSION != ""))
            {
                // New version!
                if let url = URL(string: "http://heat-meteo.sourceforge.net/" + "CHANGELOG2")
                {
                    do
                    {
                        whatChanged = try NSString(contentsOf: url, usedEncoding: nil) as String
                    }
                    catch
                    {
                    }
                }
                let myPopup: NSAlert = NSAlert()
                myPopup.messageText = localizedString(forKey: "NewVersionAvailable_") + "\n\n" + whatChanged
                myPopup.informativeText = localizedString(forKey: "Download?_")
                myPopup.alertStyle = NSAlertStyle.warning
                myPopup.addButton(withTitle: localizedString(forKey: "Yes_"))
                
                // http://swiftrien.blogspot.com/2015/03/code-sample-swift-nsalert_5.html
                // If any button is created with the title "Cancel" then that has the key "Escape" associated with it
                myPopup.addButton(withTitle: localizedString(forKey: "Cancel_"))
                let res = myPopup.runModal()
                if res == NSAlertFirstButtonReturn
                {
                    let myUrl = "http://heat-meteo.sourceforge.net"
                    
                    if let checkURL = URL(string: myUrl as String)
                    {
                        if NSWorkspace.shared().open(checkURL)
                        {
                            //print("URL successfully opened:", myUrl, terminator: "\n")
                            exit(0)
                        }
                    }
                    else
                    {
                        //print("Invalid URL:", myUrl, terminator: "\n")
                    }
                }
            }
        }
        
        defaultPreferences()
        initWindowPrefs()
        
        //Add statusBarItem
        //statusBarItem = statusBar.statusItem(withLength: -1)
        
        var m = (15 as NSNumber)
        var font = NSFont(name: "Tahoma", size: 15)
        if ((defaults.string(forKey: "font") != nil) &&
            (defaults.string(forKey: "fontsize") != nil))
        {
            m = NumberFormatter().number(from: defaults.string(forKey: "fontsize")!)!
            if (defaults.string(forKey: "fontDefault") == "1")
            {
                font = NSFont.systemFont(ofSize: CGFloat(m))
            }
            else
            {
                font = NSFont(name: defaults.string(forKey: "font")!, size: CGFloat(m))
            }
        }
        menu.font = font
        //statusBarItem.menu = menu
        //statusBarItem.image = NSImage(named: "Loading-1")!
        
        //loadTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AppDelegate.runTimedCode), userInfo: nil, repeats: true);  //Start animating the menubar icon
        
        m = (15 as NSNumber)
        font = NSFont(name: "Tahoma", size: 15)
        if ((defaults.string(forKey: "menuBarFont") != nil) &&
            (defaults.string(forKey: "menuBarFontsize") != nil))
        {
            m = NumberFormatter().number(from: defaults.string(forKey: "menuBarFontsize")!)!
            //            statusBarItem.image = nil
            if (defaults.string(forKey: "menuBarFontDefault") == "1")
            {
                font = NSFont.systemFont(ofSize: CGFloat(m))
            }
            else
            {
                font = NSFont(name: defaults.string(forKey: "menuBarFont")!, size: CGFloat(m))
            }
        }
        
        // Todo - Do we have a problem or not?
        // http://stackoverflow.com/questions/19487369/center-two-different-size-font-vertically-in-a-nsattributedstring
        if (webVERSION == "")
        {
            statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                localizedString(forKey: "NetworkFailure_"),
                                                                                                                  attributes:[NSFontAttributeName : font!]))
        }
        else
        {
            statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                localizedString(forKey: "Loading_") + "...",
                                                                                                                  attributes:[NSFontAttributeName : font!]))
        }
        
        let preferenceVersion = defaults.string(forKey: "preferenceVersion")
        if ((preferenceVersion == nil) || (preferenceVersion! != DEFAULT_PREFERENCE_VERSION))
        {
            //self.window!.orderOut(self)
            defaults.setValue(DEFAULT_PREFERENCE_VERSION, forKey: "preferenceVersion")
            self.window!.makeKeyAndOrderFront(self.window!)
            NSApp.activate(ignoringOtherApps: true)
        }
        updateWeather()
    }
    
    func runTimedCode()  //Animate the icon while loading
    {
        if (statusBarItem.image == NSImage(named: "Loading-8"))
        {
            statusBarItem.image = NSImage(named: "Loading-1")!
        }
        else if (statusBarItem.image == NSImage(named: "Loading-1"))
        {
            statusBarItem.image = NSImage(named: "Loading-2")!
        }
        else if (statusBarItem.image == NSImage(named: "Loading-2"))
        {
            statusBarItem.image = NSImage(named: "Loading-3")!
        }
        else if (statusBarItem.image == NSImage(named: "Loading-3"))
        {
            statusBarItem.image = NSImage(named: "Loading-4")!
        }
        else if (statusBarItem.image == NSImage(named: "Loading-4"))
        {
            statusBarItem.image = NSImage(named: "Loading-5")!
        }
        else if (statusBarItem.image == NSImage(named: "Loading-5"))
        {
            statusBarItem.image = NSImage(named: "Loading-6")!
        }
        else if (statusBarItem.image == NSImage(named: "Loading-6"))
        {
            statusBarItem.image = NSImage(named: "Loading-7")!
        }
        else
        {
            statusBarItem.image = NSImage(named: "Loading-8")!
        }
    } // runTimedCode
    
    func myMenuItem(_ string: String, url: String?, key: String) ->NSMenuItem
    {
        
        var newItem : NSMenuItem
        let defaults = UserDefaults.standard
        let attributedTitle: NSMutableAttributedString
        
        if (defaults.string(forKey: "fontRedText") == nil)
        {
            modalDisplay.setFont("font")
            modalDisplay.initPrefs()
        }
        
        let m = NumberFormatter().number(from: defaults.string(forKey: "fontsize")!)!
        
        if (url == nil)
        {
            newItem = NSMenuItem(title: "", action: nil, keyEquivalent: key)
        }
        else
        {
            newItem = NSMenuItem(title: "", action: Selector(url!), keyEquivalent: key)
        }
        
        if (defaults.string(forKey: "fontDefault") == "1")
        {
            attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                string,
                attributes:[NSFontAttributeName : NSFont.systemFont(ofSize: CGFloat(m))]))
        }
        else
        {
            var textColor = NSColor()
            if #available(iOS 10, *)
            {
                ErrorLog(String(format:"iOS 10", self.appName))
                textColor = NSColor(red: CGFloat(Float(defaults.string(forKey: "menuBarFontRedText")!)!)/255,
                                    green: CGFloat(Float(defaults.string(forKey: "menuBarFontGreenText")!)!)/255,
                                    blue: CGFloat(Float(defaults.string(forKey: "menuBarFontBlueText")!)!)/255, alpha: 1.0)
            }
            else
            {
                ErrorLog(String(format:"iOS 9", self.appName))
                textColor = NSColor(red: CGFloat(Float(defaults.string(forKey: "fontRedText")!)!),
                                    green: CGFloat(Float(defaults.string(forKey: "fontGreenText")!)!),
                                    blue: CGFloat(Float(defaults.string(forKey: "fontBlueText")!)!),
                                    alpha: 1.0)
            }
            
            if (defaults.string(forKey: "fontTransparency")! == "1")
            {
                attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                    string,
                    attributes:[NSFontAttributeName : NSFont(name: defaults.string(forKey: "font")!, size: CGFloat(m))!,
                        NSForegroundColorAttributeName : textColor]))
            }
            else
            {
                var backgroundColor = NSColor()
                if #available(iOS 10, *)
                {
                    backgroundColor = NSColor(
                        red: CGFloat(Float(defaults.string(forKey: "menuBarFontRedBackground")!)!)/255,
                        green: CGFloat(Float(defaults.string(forKey: "menuBarFontGreenBackground")!)!)/255,
                        blue: CGFloat(Float(defaults.string(forKey: "menuBarFontBlueBackground")!)!)/255, alpha: 1.0)
                }
                else
                {
                    backgroundColor = NSColor(
                        red: CGFloat(Float(defaults.string(forKey: "menuBarFontRedBackground")!)!),
                        green: CGFloat(Float(defaults.string(forKey: "menuBarFontGreenBackground")!)!),
                        blue: CGFloat(Float(defaults.string(forKey: "menuBarFontBlueBackground")!)!), alpha: 1.0)
                }
                
                attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                    string,
                    attributes:[NSFontAttributeName : NSFont(name: defaults.string(forKey: "font")!, size: CGFloat(m))!,
                        NSForegroundColorAttributeName : textColor,
                        NSBackgroundColorAttributeName : backgroundColor]))
            }
        }
        newItem.attributedTitle = attributedTitle
        newItem.target=self
        
        return newItem
    } // myMenuItem
    
    func addControlOptions()
    {
        var controlsMenu = NSMenu()
        var newItem : NSMenuItem
        if ((defaults.string(forKey: "controlsInSubmenu") == nil) || (defaults.string(forKey: "controlsInSubmenu")! == "1"))
        {
            newItem = myMenuItem(localizedString(forKey: "Controls_"), url: nil, key: "")
            menu.addItem(newItem)
            menu.setSubmenu(controlsMenu, for: newItem)
        }
        else
        {
            controlsMenu = menu
        }
        newItem = myMenuItem(localizedString(forKey: "Refresh_"), url: "weatherRefresh:", key: "r")
                controlsMenu.addItem(newItem)
        
        newItem = myMenuItem(localizedString(forKey: "Preferences_"), url: "preferences:", key: ",")
        controlsMenu.addItem(newItem)
        
        // https://gist.github.com/ericdke/75a42dc8d4c5f61df7d9
        newItem = myMenuItem(localizedString(forKey: "Relaunch_"), url: "Relaunch:", key: "`")
                controlsMenu.addItem(newItem)
        
        newItem = myMenuItem(localizedString(forKey: "Quit_"), url: "terminate:", key: "q")
        newItem.target=nil
        controlsMenu.addItem(newItem)
        
    } // addControlOptions
    
    func initWeatherFields(weatherFields: inout WeatherFields)
    {
        weatherFields.title1 = ""
        weatherFields.date = ""
        weatherFields.latitude = ""
        weatherFields.longitude = ""
        weatherFields.windDirection = ""
        weatherFields.windSpeed = ""
        weatherFields.humidity = ""
        weatherFields.pressure = ""
        weatherFields.visibility = ""
        weatherFields.sunrise = ""
        weatherFields.sunset = ""
        weatherFields.currentCode = ""
        weatherFields.currentTemp = ""
        weatherFields.currentConditions = ""
        weatherFields.weatherTag = ""
        weatherFields.URL = ""
        
        weatherFields.forecastCounter = 0
        var i = 0
        while (i < 25)
        {
            weatherFields.forecastCode.insert("", at: i)
            weatherFields.forecastDate.insert("", at: i)
            weatherFields.forecastDay.insert("", at: i)
            weatherFields.forecastHigh.insert("", at: i)
            weatherFields.forecastLow.insert("", at: i)
            weatherFields.forecastConditions.insert("", at: i)
            i = i + 1
        }
        
    }
    
    func updateWeather()
    {
        radarWindow = RadarWindow()
        let defaults = UserDefaults.standard
        
        // whichWeatherFirst
        if ((defaults.string(forKey: "rotateWeatherURLs") == nil) ||
            (defaults.string(forKey: "rotateWeatherLocations") == "0"))
        {
            whichWeatherFirst = 0
        }
        
        var weatherDataSource = [String]()
        var city = [String]()
        var displayCity = [String]()
        var APIKey1 = [String]()
        var APIKey2 = [String]()
        
        var i = 0

        while (i < 8)
        {
            weatherDataSource.insert(defaults.string(forKey: String(format:"weatherSource_%d", i + 1))!, at: i)
            if (i == 0)
            {
                city.insert(defaults.string(forKey: "city")!, at: i)
                displayCity.insert(defaults.string(forKey: "displayCity")!, at: i)
            }
            else
            {
                city.insert(defaults.string(forKey: String(format:"city%d", i + 1))!, at: i)
                displayCity.insert(defaults.string(forKey: String(format:"displayCity%d", i + 1))!, at: i)
            }
            APIKey1.insert(defaults.string(forKey: String(format:"API_Key_Data1_%d", i + 1))!, at: i)
            APIKey2.insert(defaults.string(forKey: String(format:"API_Key_Data2_%d", i + 1))!, at: i)
            i = i + 1
        }
        /*
        var weatherDataSource = defaults.string(forKey: "weatherSource_1")!
        var city = defaults.string(forKey: "city")!
        var displayCity  = defaults.string(forKey: "displayCity")!
        var APIKey1 = defaults.string(forKey: "API_Key_Data1_1")!
        var APIKey2 = defaults.string(forKey: "API_Key_Data2_1")!
         */
        
        var m = (15 as NSNumber)
        var font = NSFont(name: "Tahoma", size: 15)
        if ((defaults.string(forKey: "menuBarFont") != nil) &&
            (defaults.string(forKey: "menuBarFontsize") != nil))
        {
            m = NumberFormatter().number(from: defaults.string(forKey: "menuBarFontsize")!)!
            if (defaults.string(forKey: "menuBarFontDefault") == "1")
            {
                font = NSFont.systemFont(ofSize: CGFloat(m))
            }
            else
            {
                font = NSFont(name: defaults.string(forKey: "menuBarFont")!, size: CGFloat(m))
            }
        }
        
        if (weatherDataSource[whichWeatherFirst] == YAHOO_WEATHER)
        {
            yahooWeatherAPI.setRadarWind(radarWindow)
            weatherFields = yahooWeatherAPI.beginParsing(city[whichWeatherFirst],
                                                         displayCity: displayCity[whichWeatherFirst],
                                                         APIKey1: APIKey1[whichWeatherFirst],
                                                         APIKey2: APIKey2[whichWeatherFirst])
            
        }
        else if (weatherDataSource[whichWeatherFirst] == OPENWEATHERMAP)
        {
            openWeatherMapAPI.setRadarWind(radarWindow)
            weatherFields = openWeatherMapAPI.beginParsing(city[whichWeatherFirst],
                                                           APIKey1: APIKey1[whichWeatherFirst],
                                                           APIKey2: APIKey2[whichWeatherFirst])
        }
        else if (weatherDataSource[whichWeatherFirst] == THEWEATHER)
        {
            theWeatherAPI.setRadarWind(radarWindow)
            weatherFields = theWeatherAPI.beginParsing(city[whichWeatherFirst],
                                                       APIKey1: APIKey1[whichWeatherFirst],
                                                       APIKey2: APIKey2[whichWeatherFirst])
        }
        else if (weatherDataSource[whichWeatherFirst] == WEATHERUNDERGROUND)
        {
            weatherUndergroundAPI.setRadarWind(radarWindow)
            weatherFields = weatherUndergroundAPI.beginParsing(city[whichWeatherFirst],
                                                               APIKey1: APIKey1[whichWeatherFirst],
                                                               APIKey2: APIKey2[whichWeatherFirst])
        }
        else if (weatherDataSource[whichWeatherFirst] == DARKSKY)
        {
            darkSkyAPI.setRadarWind(radarWindow)
            weatherFields = darkSkyAPI.beginParsing(city[whichWeatherFirst],
                                                    APIKey1: APIKey1[whichWeatherFirst],
                                                    APIKey2: APIKey2[whichWeatherFirst])
        }
        else if (weatherDataSource[whichWeatherFirst] == AERISWEATHER)
        {
            aerisWeatherAPI.setRadarWind(radarWindow)
            weatherFields = aerisWeatherAPI.beginParsing(city[whichWeatherFirst],
                                                         APIKey1: APIKey1[whichWeatherFirst],
                                                         APIKey2: APIKey2[whichWeatherFirst])
        }
        else if (weatherDataSource[whichWeatherFirst] == WORLDWEATHERONLINE)
        {
            worldWeatherOnlineAPI.setRadarWind(radarWindow)
            weatherFields = worldWeatherOnlineAPI.beginParsing(city[whichWeatherFirst],
                                                               APIKey1: APIKey1[whichWeatherFirst],
                                                               APIKey2: APIKey2[whichWeatherFirst])
        }
        else if (weatherDataSource[whichWeatherFirst] == APIXU)
        {
            ApiXUApi.setRadarWind(radarWindow)
            weatherFields = ApiXUApi.beginParsing(city[whichWeatherFirst],
                                                  APIKey1: APIKey1[whichWeatherFirst],
                                                  APIKey2: APIKey2[whichWeatherFirst])
        }
        else
        {
            let i = Int(weatherDataSource[whichWeatherFirst])! + 1
            // Something bad should happen to let the developer know this option hasn't been implemented ...
            let ErrorMsg = String(format:localizedString(forKey: "notImplemented_"), i)
            ErrorLog(ErrorMsg)
            let alert:NSAlert = NSAlert()
            alert.messageText = ErrorMsg
            alert.informativeText = localizedString(forKey: "contactDeveloper_")
            alert.runModal()
            //self.window!.makeKeyAndOrderFront(self.window!)
        }
    
        if (loadTimer != nil)
        {
            loadTimer.invalidate();
            loadTimer = nil;
        }
        
        if (isConnectedToNetwork())
        {
            NoInternetConnectivity = 0
            if (weatherFields.currentTemp != "")
            {
                
                if (displayCity[whichWeatherFirst] == "")
                {
                    displayCity[whichWeatherFirst] = city[whichWeatherFirst]
                }
                
                if (defaults.string(forKey: "displayWeatherIcon")! == "1")
                {
                    statusBarItem.image = nil
                    
                    statusBarItem.image = setImage(weatherFields.currentCode as String, weatherDataSource: weatherDataSource[whichWeatherFirst])
                }
                else
                {
                    if (loadTimer != nil)
                    {
                        loadTimer.invalidate();
                        loadTimer = nil;
                    }
                    
                    statusBarItem.image = nil
                }
                
                var statusTitle = ""
                
                if (defaults.string(forKey: "displayCityName")! == "1")
                {
                    statusTitle = displayCity[whichWeatherFirst] + " " + formatTemp((weatherFields.currentTemp as String))
                }
                else
                {
                    statusTitle = formatTemp((weatherFields.currentTemp as String))
                }
                
                if (defaults.string(forKey: "displayHumidity")! == "1")
                {
                    statusTitle = statusTitle + "/" + formatHumidity((weatherFields.humidity as String))
                }
                
                if (defaults.string(forKey: "menuBarFontDefault") == "1")
                {
                    statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string: statusTitle,
                                                                                                                          attributes:[NSFontAttributeName : font!]))
                }
                else
                {
                    var textColor = NSColor()
                    if #available(iOS 10, *)
                    {
                        ErrorLog(String(format:"iOS 10b", self.appName))
                        textColor = NSColor(red: CGFloat(Float(defaults.string(forKey: "menuBarFontRedText")!)!)/255,
                                            green: CGFloat(Float(defaults.string(forKey: "menuBarFontGreenText")!)!)/255,
                                            blue: CGFloat(Float(defaults.string(forKey: "menuBarFontBlueText")!)!)/255, alpha: 1.0)
                    }
                    else
                    {
                        ErrorLog(String(format:"iOS 9b", self.appName))
                        textColor = NSColor(red: CGFloat(Float(defaults.string(forKey: "fontRedText")!)!),
                                            green: CGFloat(Float(defaults.string(forKey: "fontGreenText")!)!),
                                            blue: CGFloat(Float(defaults.string(forKey: "fontBlueText")!)!),
                                            alpha: 1.0)
                    }
                    
                    if (defaults.string(forKey: "menuBarFontTransparency")! == "1")
                    {
                        statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string: statusTitle,
                                                                                                                              attributes:[NSFontAttributeName : font!,
                                                                                                                                          NSForegroundColorAttributeName : textColor]))
                    }
                    else
                    {
                        var backgroundColor = NSColor()
                        if #available(iOS 10, *)
                        {
                            backgroundColor = NSColor(
                                red: CGFloat(Float(defaults.string(forKey: "menuBarFontRedBackground")!)!)/255,
                                green: CGFloat(Float(defaults.string(forKey: "menuBarFontGreenBackground")!)!)/255,
                                blue: CGFloat(Float(defaults.string(forKey: "menuBarFontBlueBackground")!)!)/255, alpha: 1.0)
                        }
                        else
                        {
                            backgroundColor = NSColor(
                                red: CGFloat(Float(defaults.string(forKey: "menuBarFontRedBackground")!)!),
                                green: CGFloat(Float(defaults.string(forKey: "menuBarFontGreenBackground")!)!),
                                blue: CGFloat(Float(defaults.string(forKey: "menuBarFontBlueBackground")!)!), alpha: 1.0)
                        }
                        statusBarItem.attributedTitle =
                            NSMutableAttributedString(attributedString: NSMutableAttributedString(string: statusTitle,
                                                                                                  attributes:[NSFontAttributeName : font!,
                                                                                                              NSForegroundColorAttributeName : textColor,
                                                                                                              NSBackgroundColorAttributeName : backgroundColor]))
                    }
                }
            }
        
            updateMenuWithPrimaryLocation(weatherFields, cityName: (city[whichWeatherFirst]), displayCityName: (displayCity[whichWeatherFirst]), menu: menu, weatherDataSource: weatherDataSource[whichWeatherFirst])
            
            var bFirstTime = 0
            var secondarys = whichWeatherFirst + 1
            if (secondarys > 7)
            {
                secondarys = 0
            }
            
            while (secondarys != whichWeatherFirst)
            {
                if (city[secondarys] != "")
                {
                    if (bFirstTime == 0)
                    {
                        menu.addItem(NSMenuItem.separator())
                    }
                    bFirstTime = 1
                    
                    if (displayCity[secondarys] == "")
                    {
                        displayCity[secondarys] = city[secondarys]
                    }
                    
                    weatherFields = processWeatherSource(weatherDataSource[secondarys],
                                                         inputCity: city[secondarys],
                                                         displayCity: displayCity[secondarys],
                                                         APIKey1: APIKey1[secondarys],
                                                         APIKey2: APIKey2[secondarys])
                    updateMenuWithSecondaryLocation(weatherFields,
                                                    cityName: (city[secondarys]),
                                                    displayCityName: (displayCity[secondarys]),
                                                    menu: menu,
                                                    weatherDataSource: weatherDataSource[secondarys])
                }
                secondarys = secondarys + 1
                if (secondarys > 7)
                {
                    secondarys = 0
                }
            }
            
            menu.addItem(NSMenuItem.separator())
            
            addControlOptions()
        }
        else
        {
            if (NoInternetConnectivity == 0)
            {
                var textColor = NSColor()
                if #available(iOS 10, *)
                {
                    ErrorLog(String(format:"iOS 10", self.appName))
                    textColor = NSColor(red: CGFloat(1),
                                        green: CGFloat(1),
                                        blue: CGFloat(1),
                                        alpha: 1.0)
                }
                else
                {
                    ErrorLog(String(format:"iOS 9", self.appName))
                    textColor = NSColor(red: CGFloat(255),
                                        green: CGFloat(255),
                                        blue: CGFloat(255),
                                        alpha: 1.0)
                }
                
                var backgroundColor = NSColor()
                if #available(iOS 10, *)
                {
                    backgroundColor = NSColor(
                        red: CGFloat(0),
                        green: CGFloat(0),
                        blue: CGFloat(0),
                        alpha: 1.0)
                }
                else
                {
                    backgroundColor = NSColor(
                        red: CGFloat(0),
                        green: CGFloat(0),
                        blue: CGFloat(0),
                        alpha: 1.0)
                }
                
                let attributedTitle: NSMutableAttributedString
                attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                    localizedString(forKey: "NoInternetConnectivity_"),
                                                                                                        attributes:[NSFontAttributeName : NSFont(name: defaults.string(forKey: "font")!, size: CGFloat(m))!,
                                                                                                                    NSForegroundColorAttributeName : textColor,
                                                                                                                    NSBackgroundColorAttributeName : backgroundColor]))

                let newItem = NSMenuItem()
                newItem.attributedTitle = attributedTitle
                newItem.target=self
                menu.addItem(newItem)
                
                NoInternetConnectivity = 1
            }
        }

        let uwTimer = myTimer
        if uwTimer == myTimer
        {
            if uwTimer.isValid
            {
                uwTimer.invalidate()
            }
        }
        
        let updateFrequency = defaults.string(forKey: "updateFrequency")
        myTimer = Timer.scheduledTimer(timeInterval: Double(updateFrequency!)!*60, target:self, selector: #selector(AppDelegate.updateWeather), userInfo: nil, repeats: false)
        
        // whichWeatherFirst
        if ((defaults.string(forKey: "rotateWeatherLocations") != nil) &&
            (defaults.string(forKey: "rotateWeatherLocations") == "1"))
        {
            whichWeatherFirst = whichWeatherFirst + 1
            if (whichWeatherFirst > 7)
            {
                whichWeatherFirst = 0
            }
        }

    } // updateWeather
    
    func processWeatherSource(_ weatherDataSource: String, inputCity: String, displayCity: String, APIKey1: String, APIKey2: String) -> WeatherFields
    {
        if (weatherDataSource == YAHOO_WEATHER) {
            weatherFields = yahooWeatherAPI.beginParsing(inputCity, displayCity: displayCity, APIKey1: APIKey1, APIKey2: APIKey2)
        }
        else if (weatherDataSource == OPENWEATHERMAP)
        {
            weatherFields = openWeatherMapAPI.beginParsing(inputCity,
                                                           APIKey1: APIKey1,
                                                           APIKey2: APIKey2)
        }
        else if (weatherDataSource == THEWEATHER)
        {
            theWeatherAPI.setRadarWind(radarWindow)
            weatherFields = theWeatherAPI.beginParsing(inputCity,
                                                       APIKey1: APIKey1,
                                                       APIKey2: APIKey2)
        }
        else if (weatherDataSource == WEATHERUNDERGROUND)
        {
            weatherUndergroundAPI.setRadarWind(radarWindow)
            weatherFields = weatherUndergroundAPI.beginParsing(inputCity,
                                                               APIKey1: APIKey1,
                                                               APIKey2: APIKey2)
        }
        else if (weatherDataSource == DARKSKY)
        {
            darkSkyAPI.setRadarWind(radarWindow)
            weatherFields = darkSkyAPI.beginParsing(inputCity,
                                                       APIKey1: APIKey1,
                                                       APIKey2: APIKey2)
        }
        else if (weatherDataSource == AERISWEATHER)
        {
            aerisWeatherAPI.setRadarWind(radarWindow)
            weatherFields = aerisWeatherAPI.beginParsing(inputCity,
                                                         APIKey1: APIKey1,
                                                         APIKey2: APIKey2)
        }
        else if (weatherDataSource == WORLDWEATHERONLINE)
        {
            worldWeatherOnlineAPI.setRadarWind(radarWindow)
            weatherFields = worldWeatherOnlineAPI.beginParsing(inputCity,
                                                               APIKey1: APIKey1,
                                                               APIKey2: APIKey2)
        }
        else if (weatherDataSource == APIXU)
        {
            ApiXUApi.setRadarWind(radarWindow)
            weatherFields =
                ApiXUApi.beginParsing(inputCity,
                                                               APIKey1: APIKey1,
                                                               APIKey2: APIKey2)
        }
        else
        {
            let i = Int(weatherDataSource)! + 1
            // Something bad should happen to let the developer know this option hasn't been implemented ...
            let ErrorMsg = String(format:"WeatherSource option %d hasn't been implemented", i)
            ErrorLog(ErrorMsg)
            let alert:NSAlert = NSAlert()
            alert.messageText = ErrorMsg
            alert.informativeText = "Choose another weather source"
            alert.runModal()
            //self.window!.makeKeyAndOrderFront(self.window!)
            weatherFields = WeatherFields()
        }

        return weatherFields
    } // processWeatherSource
    
    func setImage(_ weatherCode: String, weatherDataSource: String) -> NSImage
    {
        /*
         19	dust
         20	foggy
         22	smoky
         23	blustery
         25	cold                        Temperature-2
         36	hot                         Temperature-9
         3200	not available
         
         */
        
        var imageName = "Unknown"
        
        if (weatherDataSource == YAHOO_WEATHER)
        {
            if (weatherCode == "0")
            {
                imageName = "Tornado"
            }
            else if ((weatherCode == "1") ||
                (weatherCode == "2"))
            {
                imageName = "Hurricane"
            }
            else if ((weatherCode == "3") ||
                (weatherCode == "37") ||
                (weatherCode == "38") ||
                (weatherCode == "39") ||
                (weatherCode == "45") ||
                (weatherCode == "47") ||
                (weatherCode == "4"))
            {
                imageName = "Thunderstorm"
            }
            else if ((weatherCode == "6") ||
                (weatherCode == "8") ||
                (weatherCode == "9") ||
                (weatherCode == "10") ||
                (weatherCode == "11") ||
                (weatherCode == "12") ||
                (weatherCode == "17") ||
                (weatherCode == "35") ||
                (weatherCode == "40"))
            {
                imageName = "Rain"
            }
            else if ((weatherCode == "5") ||
                (weatherCode == "7") ||
                (weatherCode == "14") ||
                (weatherCode == "16") ||
                (weatherCode == "15") ||
                (weatherCode == "41") ||
                (weatherCode == "42") ||
                (weatherCode == "43") ||
                (weatherCode == "46"))
            {
                imageName = "Snow"
            }
            else if (weatherCode == "13")
            {
                imageName = "Flurries"
            }
            else if (weatherCode == "18")
            {
                imageName = "Sleet"
            }
            else if (weatherCode == "21")
            {
                imageName = "Hazy"
            }
            else if (weatherCode == "24")
            {
                imageName = "Wind"
            }
            else if ((weatherCode == "32") ||
                (weatherCode == "34"))
            {
                imageName = "Sun"
            }
            else if ((weatherCode == "23") ||
                (weatherCode == "24"))
            {
                imageName = "Wind"
            }
            else if ((weatherCode == "31") ||
                (weatherCode == "33"))
            {
                imageName = "Moon"
            }
            else if ((weatherCode == "30") ||
                (weatherCode == "44"))
            {
                imageName = "Sun-Cloud"  //Originally Sun-Cloud-1
            }
            else if ((weatherCode == "20") ||
                (weatherCode == "21"))
            {
                imageName = "Hazy"
            }
            else if ((weatherCode == "26"))
            {
                imageName = "Cloudy"
            }
            else if ((weatherCode == "27"))
            {
                imageName = "Moon-Cloud"  //Originally Moon-Cloud-2
            }
            else if ((weatherCode == "28"))
            {
                imageName = "Sun-Cloud"  //Originally Sun-Cloud-2
            }
            else if ((weatherCode == "29"))
            {
                imageName = "Moon-Cloud"  //Originally Moon-Cloud-2
            }
            else if ((weatherCode == "3200"))
            {
                // Yahoo! doesn't have a code so this really isn't an error
                imageName = "Unavailable"
            }
        } else if (weatherDataSource == OPENWEATHERMAP)
        {
            // http://openweathermap.org/weather-conditions
            if (weatherCode == "") {
                imageName = "Sun"
            }
            else if (weatherCode == "01d")
            {
                imageName = "Sun"
            }
            else if (weatherCode == "01n")
            {
                imageName = "Moon"
            }
            else if (weatherCode == "02d")
            {
                imageName = "Sun-Cloud"
            }
            else if (weatherCode == "02n")
            {
                imageName = "Moon-Cloud"
            }
            else if ((weatherCode == "03d") ||
                (weatherCode == "03n"))
            {
                imageName = "Cloudy"
            }
            else if (weatherCode == "04d")
            {
                imageName = "Sun-Cloud"
            }
            else if (weatherCode == "04n")
            {
                imageName = "Moon-Cloud"
            }
            else if ((weatherCode == "09d") ||
                (weatherCode == "09n") ||
                (weatherCode == "10d") ||
                (weatherCode == "10n"))
            {
                imageName = "Rain"
            }
            else if ((weatherCode == "50d") ||
                (weatherCode == "50n"))
            {
                imageName = "Hazy"
            }
            else if ((weatherCode == "11d") ||
                (weatherCode == "11n"))
            {
                imageName = "Thunderstorm"
            }
            else if ((weatherCode == "13d") ||
                (weatherCode == "13n"))
            {
                imageName = "Snow"
            }
        } else if (weatherDataSource == THEWEATHER)
        {
            // http://www.theweather.com/documentacion_api/manual_en.pdf
            if (weatherCode == "1")
            {
                imageName = "Sun"
            }
            else if ((weatherCode == "2") ||
                (weatherCode == "3"))
            {
                imageName = "Sun-Cloud"
            }
            else if (weatherCode == "4")
            {
                imageName = "Cloudy"
            }
            else if ((weatherCode == "5") ||
                (weatherCode == "6") ||
                (weatherCode == "7") ||
                (weatherCode == "8") ||
                (weatherCode == "9") ||
                (weatherCode == "10") ||
                (weatherCode == "11") ||
                (weatherCode == "12") ||
                (weatherCode == "13"))
            {
                imageName = "Rain"
            }
            else if ((weatherCode == "11") ||
                (weatherCode == "12") ||
                (weatherCode == "13") ||
                (weatherCode == "14") ||
                (weatherCode == "15") ||
                (weatherCode == "16"))
            {
                imageName = "Thunderstorm"
            }
            else if ((weatherCode == "17") ||
                (weatherCode == "18") ||
                (weatherCode == "19"))
            {
                imageName = "Snow"
            }
            else if ((weatherCode == "20") ||
                (weatherCode == "21") ||
                (weatherCode == "22"))
            {
                imageName = "Sleet"
            }
        } else if (weatherDataSource == WEATHERUNDERGROUND)
        {
            if (weatherCode == "") {
                imageName = "Sun"
            }
            else if ((weatherCode == "Overcast") ||
                (weatherCode == "ns_cloudy") ||
                (weatherCode == "cloudy"))
            {
                imageName = "Cloudy"
            }
            else if ((weatherCode == "Rain") ||
                (weatherCode == "rain") ||
                (weatherCode == "chancerain") ||
                (weatherCode == "nt_chancerain") ||
                (weatherCode == "nt_rain"))
            {
                imageName = "Rain"
            }
            else if ((weatherCode == "Rain") ||
                (weatherCode == "rain") ||
                (weatherCode == "chancerain") ||
                (weatherCode == "nt_chancerain") ||
                (weatherCode == "nt_rain"))
            {
                imageName = "Rain"
            }
            else if ((weatherCode == "tstorms") ||
                (weatherCode == "chancetstorms"))
            {
                imageName = "Thunderstorm"
            }
            else if ((weatherCode == "Snow") ||
                (weatherCode == "snow") ||
                (weatherCode == "chancesnow") ||
                (weatherCode == "nt_chancesnow") ||
                (weatherCode == "nt_snow"))
            {
                imageName = "Snow"
            }
            else if (weatherCode == "Fog")
            {
                imageName = "Hazy"
            }
            else if ((weatherCode == "Clear") ||
                (weatherCode == "nt_clear") ||
                (weatherCode == "clear"))
            {
                imageName = "Sun"
            }
            else if ((weatherCode == "nt_mostlycloudy") ||
                (weatherCode == "nt_partlycloudy") ||
                (weatherCode == "mostlycloudy") ||
                (weatherCode == "partlycloudy") ||
                (weatherCode == "Mostly Cloudy") ||
                (weatherCode == "Partly Cloudy"))
            {
                imageName = "Sun-Cloud"
            }
        } else if (weatherDataSource == AERISWEATHER)
        {
            let _ = weatherCode
            
            if ((weatherCode == "clear") ||
                (weatherCode == "sunny") ||
                (weatherCode == "fair") ||
                (weatherCode == "wind"))
            {
                imageName = "Sun"
            }
            else if ((weatherCode == "cloudy"))
            {
                imageName = "Sun-Cloud"
            }
            else if ((weatherCode == "showshowers") ||
                (weatherCode == "blizzard") ||
                (weatherCode == "blowingsnow") ||
                (weatherCode == "drizzlef") ||
                (weatherCode == "fdrizzle") ||
                (weatherCode == "flurries") ||
                (weatherCode == "freezingrain") ||
                (weatherCode == "cloudys") ||
                (weatherCode == "snowshowers") ||
                (weatherCode == "rainandsnow") ||
                (weatherCode == "raintosnow") ||
                (weatherCode == "sleet") ||
                (weatherCode == "sleetsnow") ||
                (weatherCode == "snow") ||
                (weatherCode == "snowtorain") ||
                (weatherCode == "wintrymix"))
            {
                imageName = "Snow"
            }
            else if ((weatherCode == "fog") ||
                (weatherCode == "dust") ||
                (weatherCode == "hazy") ||
                (weatherCode == "smoke"))
            {
                imageName = "Hazy"
            }
            else if ((weatherCode == "tstorms") ||
                (weatherCode == "cloudyr") ||
                (weatherCode == "showers") ||
                (weatherCode == "tstorm") ||
                (weatherCode == "chancetstorm") ||
                (weatherCode == "drizzle") ||
                (weatherCode == "cloudyt") ||
                (weatherCode == "rain"))
            {
                imageName = "Rain"
            }
        } else if (weatherDataSource == APIXU)
        {
            if (((weatherCode == "Sunny")) ||
                ((weatherCode == "Clear/Sunny")) ||
                ((weatherCode == "Clear")))
            {
                imageName = "Sun"
            }
            else if ((weatherCode == "Overcast") ||
                (weatherCode == "ns_cloudy") ||
                (weatherCode == "cloudy"))
            {
                imageName = "Cloudy"
            }
            else if ((weatherCode == "Light rain shower") ||
                (weatherCode == "Moderate rain") ||
                (weatherCode == "Patchy rain possible") ||
                (weatherCode == "Moderate or heavy rain shower") ||
                (weatherCode == "Light drizzle"))
            {
                imageName = "Rain"
            }
        } else if (weatherDataSource == WORLDWEATHERONLINE)
        {
            if (((weatherCode == "Sunny")) ||
                ((weatherCode == "Clear/Sunny")) ||
                ((weatherCode == "Clear")))
            {
                imageName = "Sun"
            }
            else if ((weatherCode == "Snow") ||
                (weatherCode == "snow") ||
                (weatherCode == "Snow, Mist") ||
                (weatherCode == "freezing rain") ||
                (weatherCode == "Blizzard") ||
                (weatherCode == "blizzard") ||
                (weatherCode == "Sleet") ||
                (weatherCode == "sleet"))
            {
                imageName = "Snow"
            }
            else if (((weatherCode == "Overcast")) ||
                ((weatherCode == "overcast")) ||
                ((weatherCode == "Cloudy")) ||
                ((weatherCode == "cloudy")))
            {
                imageName = "Sun-Cloud"
            }
            else if (weatherCode == "fog")
            {
                imageName = "Hazy"
            }
            else if ((weatherCode == "drizzle") ||
                (weatherCode == "Drizzle") ||
                (weatherCode == "mist") ||
                (weatherCode == "Mist") ||
                (weatherCode == "rain") ||
                (weatherCode == "Rain"))
            {
                imageName = "Rain"
            }
        } else if (weatherDataSource == DARKSKY)
        {
            let _ = weatherCode

            if ((weatherCode == "clear") ||
                (weatherCode == "clear-day") ||
                (weatherCode == "nt_clear") ||
                (weatherCode == "clear"))
            {
                imageName = "Sun"
            }
            else if ((weatherCode == "Snow") ||
                (weatherCode == "snow") ||
                (weatherCode == "chancesnow") ||
                (weatherCode == "nt_chancesnow") ||
                (weatherCode == "nt_snow"))
            {
                imageName = "Snow"
            }
            else if ((weatherCode == "partly-cloudy-night") ||
                (weatherCode == "partly-cloudy-day") ||
                (weatherCode == "mostlycloudy") ||
                (weatherCode == "partlycloudy") ||
                (weatherCode == "Mostly Cloudy") ||
                (weatherCode == "Partly Cloudy"))
            {
                imageName = "Sun-Cloud"
            }
            else if (weatherCode == "fog")
            {
                imageName = "Hazy"
            }
            else if ((weatherCode == "rain") ||
                (weatherCode == "rain") ||
                (weatherCode == "chancerain") ||
                (weatherCode == "nt_chancerain") ||
                (weatherCode == "nt_rain"))
            {
                imageName = "Rain"
            }
        }
        
        if (imageName == "Unknown")
        {
            ErrorLog(String(format:localizedString(forKey: "InvalidWeatherCode_") + " : " + weatherCode))
        }

        if (defaults.string(forKey: "useNewWeatherIcons")! == "1")
        {
            imageName = imageName + "-Dark"
        }
        else
        {
            imageName = imageName + "-Color"
        }
        
        return NSImage(named: imageName)!

    } // setImage
    
    func formatDay(_ temp: String) -> String
    {
        let returnDay = temp
        
        if ((temp != "Mon") && (temp != "Wed"))
        {
            //returnDay.append(" ")
        }
        else if (temp == "Fri")
        {
            //returnDay.append(" ")
        }
        
        return returnDay
    } // formatDay
    
    func formatTemp(_ temp: String) -> String
    {
        let defaults = UserDefaults.standard
        var formattedTemp = String(Int((temp as NSString).doubleValue))
        
        if (defaults.string(forKey: "degreesUnit")! == "1")
        {
            // http://www.rapidtables.com/convert/temperature/how-fahrenheit-to-celsius.htm
            formattedTemp = String(Int(((temp as NSString).doubleValue - 32) / 1.8))
        }
        
        formattedTemp += "°"
        
        if (defaults.string(forKey: "displayDegreeType")! == "1")
        {
            if (defaults.string(forKey: "degreesUnit")! == "0")
            {
                formattedTemp += "F"
            }
            else
            {
                formattedTemp += "C"
            }
        }
        return formattedTemp
    } // formatTemp
    
    func calculateFeelsLike(_ sTemperature: String, sWindspeed: String, sRH: String) -> String
    {
        // http://www.nws.noaa.gov/om/winter/faqs.shtml
        // http://www.srh.noaa.gov/epz/?n=wxcalc_heatindex
        // Wind-chill is calculated when temperatures are at or below 50 F and wind speeds are above 3 mph.
        // The heat index calculation applies only when the relative humidity is 40% or higher, and the air temperature is 80 F or higher
        // where:
        // T = Temperature (° F)
        // RH = Relative Humidity (%)
        // V = Wind Speed (mph)
        
        var temp = 0.0
        var windspeed = 0.0
        var rh = 0.0
        if (sTemperature != "")
        {
            temp = Double(sTemperature)!
        }
        if (sWindspeed != "")
        {
            windspeed = Double(sWindspeed)!
        }
        if (sRH != "")
        {
            rh = Double(sRH)!
        }
        
        var feelsLike = sTemperature
        
        if ((temp < 50) && (windspeed > 3))
        {
            // Windchill (ºF) = 35.74 + 0.6215T - 35.75(V^0.16) + 0.4275T(V^0.16)
            let Windchill1 = (0.6215 * temp)
            let Windchill2 = (35.75 * (windspeed ** 0.16))
            let Windchill3 = (0.4275 * temp * (windspeed ** 0.16))
            let Windchill = 35.74 + Windchill1 - Windchill2 + Windchill3
            feelsLike = String(format:"%.0f", Windchill)
        }
        else if ((temp > 80) && (rh > 40))
        {
            // Heat Index = − 42.379 + (2.04901523 × T ) + (10.14333127 × rh) − (0.22475541 × T × rh) − (6.83783×10−3×T2) − (5.481717 × 10−2 × rh2) + (1.22874 × 10−3 × T2 × rh) + (8.5282×10−4 × T × rh2) − (1.99×10−6 × T2 × rh2)
            let HI1 = (2.04901523 * temp )
            let HI2 = (10.14333127 * rh)
            let HI3 = (0.22475541 * temp * rh)
            let HI4 = (6.83783 * (10 ** -3) * (temp ** 2))
            let HI5 = (5.481717 * (10 ** -2) * (rh ** 2))
            let HI6 = (1.22874 * (10 ** -3) * (temp ** 2) * rh)
            let HI7 = (8.5282 * (10 ** -4) * temp * (rh ** 2))
            let HI8 = (1.99 * (0.000001) * (temp ** 2) * (rh ** 2))
            let HI = -42.379 + HI1 + HI2 - HI3 - HI4 - HI5 + HI6 + HI7 - HI8
            feelsLike = String(format:"%.0f", HI)
        }
        return formatTemp(feelsLike)
    } // calculateFeelsLike
    
    func convertUTCtoHHMM(_ myTime: String) -> String
    {
        if (myTime == "")
        {
            return ""
        }
        // create dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: myTime)
        if (date == nil)
        {
            return myTime
        }
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: date!)
    } // convertUTCtoHHMM
    
    func convertUTCtoEEE(_ myTime: String) -> String
    {
        // EEE is Mon, Tue, Wed, etc.
        // create dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        let date = dateFormatter.date(from: myTime)
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "EEE"
        return formatDay(dateFormatter.string(from: date!))
    } // convertUTCtoEEE
    
    func formatWindSpeed(_ speed: String, direction: String) -> String {
        let defaults = UserDefaults.standard
        let speed__ = String(Int((speed as NSString).doubleValue))
        let direction__ = String(Int((direction as NSString).doubleValue))
        var formattedWindSpeed = direction__ + "° @ "
        if (defaults.string(forKey: "directionUnit")! == "1")
        {
            var windDirection = direction__
            let iDirection = Int((direction__ as NSString).doubleValue)
            if (iDirection <= 22)
            {
                windDirection = "N"
            }
            else if (iDirection <= 67)
            {
                windDirection = "NE"
            }
            else if (iDirection <= 112)
            {
                windDirection = "E"
            }
            else if (iDirection <= 147)
            {
                windDirection = "SE"
            }
            else if (iDirection <= 202)
            {
                windDirection = "S"
            }
            else if (iDirection <= 247)
            {
                windDirection = "SW"
            }
            else if (iDirection <= 292)
            {
                windDirection = "W"
            }
            else if (iDirection <= 337)
            {
                windDirection = "NW"
            }
            else
            {
                windDirection = "N"
            }
            formattedWindSpeed = windDirection + " @ "
        }
        if (defaults.string(forKey: "speedUnit")! == "0") {
            formattedWindSpeed += speed__ + " " + localizedString(forKey: "mph_")
        } else if (defaults.string(forKey: "speedUnit")! == "1") {
            formattedWindSpeed += String(Int((speed__ as NSString).doubleValue * 1.6094)) + " " + localizedString(forKey: "km/h_")
        } else if (defaults.string(forKey: "speedUnit")! == "2") {
            formattedWindSpeed += String(Int((speed__ as NSString).doubleValue * 0.44704)) + " " + localizedString(forKey: "m/s_")
        } else if (defaults.string(forKey: "speedUnit")! == "3") {
            formattedWindSpeed += String(Int((speed__ as NSString).doubleValue * 1.15077944802)) + " " + localizedString(forKey: "Knots_")
        }
        return formattedWindSpeed
    } // formatWindSpeed
    
    func formatPressure(_ pressure: String) -> String {
        let defaults = UserDefaults.standard
        var formattedPressure = ""
        let pressure__ = String(format: "%.2f", (pressure as NSString).doubleValue / 33.8637526)
        if (defaults.string(forKey: "pressureUnit")! == "0")
        {
            formattedPressure += pressure__ + " " + localizedString(forKey: "Inches_")
        }
        else if (defaults.string(forKey: "pressureUnit")! == "1")
        {
            formattedPressure += String(Int((pressure__ as NSString).doubleValue * 33.8637526)) + " " + localizedString(forKey: "mb_")
        }
        else if (defaults.string(forKey: "pressureUnit")! == "2")
        {
            formattedPressure += String(Int((pressure__ as NSString).doubleValue * 3.39)) + " " + localizedString(forKey: "kPa_")
        }
        else if (defaults.string(forKey: "pressureUnit")! == "3")
        {
            // Meters/second
            formattedPressure += String(Int((pressure__ as NSString).doubleValue * 33.8637526)) + " " + localizedString(forKey: "hPa_")
        }
        else if (defaults.string(forKey: "pressureUnit")! == "4")
        {
            // Meters/second
            formattedPressure += String(Int((pressure__ as NSString).doubleValue * 25.4)) + " " + localizedString(forKey: "mmHg")
        }
        return formattedPressure
    } // formatPressure
    
    func formatVisibility(_ distance: String) -> String {
        let defaults = UserDefaults.standard
        var formattedVisibility = ""
        if (defaults.string(forKey: "distanceUnit")! == "0") {
            formattedVisibility += distance + " " + localizedString(forKey: "Miles_")
        } else if (defaults.string(forKey: "distanceUnit")! == "1") {
            formattedVisibility += String(Int((distance as NSString).doubleValue * 5280.0)) + " " + localizedString(forKey: "Feet_")
        } else if (defaults.string(forKey: "distanceUnit")! == "2") {
            formattedVisibility += String(Int((distance as NSString).doubleValue * 0.621371192237)) + " " + localizedString(forKey: "kilometers_")
        } else if (defaults.string(forKey: "distanceUnit")! == "3") {
            // Meters
            formattedVisibility += String(Int((distance as NSString).doubleValue * 621.371192237)) + " " + localizedString(forKey: "meters_")
        } else {
            // Knots
        }
        return formattedVisibility
    } // formatVisibility
    
    func formatHumidity(_ humidity: String) -> String {
        return humidity + "%"
    } // formatHumidity
    
    func extendedWeatherIcon(_ weatherCode: String, weatherDataSource: String) -> NSImage {
        let defaults = UserDefaults.standard
        if (defaults.string(forKey: "extendedForecastIcons")! == "1") {
            return setImage(weatherCode, weatherDataSource: weatherDataSource)
        } else {
            return NSImage()
        }
    } // extendedWeatherIcon
    
    func updateMenuWithPrimaryLocation(_ weatherFields: WeatherFields, cityName: String, displayCityName: String, menu: NSMenu, weatherDataSource: String) {
        
        var newItem : NSMenuItem
        DebugLog(String(format:"in updateMenuWithPrimaryLocation: %@", cityName))
        
        menu.removeAllItems()
        if (weatherFields.currentTemp.isEqual(nil) || weatherFields.currentTemp.isEqual(""))
        {
            menu.title = localizedString(forKey: "Failed_")
        }
        else
        {
            let defaults = UserDefaults.standard
            
            var city = displayCityName
            if (city == "")
            {
                city = weatherFields.title1 as String
            }
            else
            {
                if (weatherDataSource == YAHOO_WEATHER)
                {
                    city = displayCityName + "\t\tYahoo! Weather"
                }
                else if (weatherDataSource == OPENWEATHERMAP)
                {
                    city = displayCityName + "\t\tOpenWeatherMap"
                }
                else if (weatherDataSource == WEATHERUNDERGROUND)
                {
                    city = displayCityName + "\t\tWeather Underground"
                }
                else if (weatherDataSource == DARKSKY)
                {
                    city = displayCityName + "\t\tPowered by DarkSky"
                }
                else if (weatherDataSource == AERISWEATHER)
                {
                    city = displayCityName + "\t\tAERIS Weather"
                }
                else if (weatherDataSource == WORLDWEATHERONLINE)
                {
                    city = displayCityName + "\t\tWorld Weather Online"
                }
                else if (weatherDataSource == APIXU)
                {
                    city = displayCityName + "\t\tAPIXU"
                }
                else
                {
                    city = displayCityName + "\t\tWeatherSource unknown"
                }
            }
            
            // Need to incorporate currentLink
            newItem = myMenuItem(city, url: "openWeatherURL:", key: "")
            
            // http://stackoverflow.com/questions/24200888/any-way-to-replace-characters-on-swift-string
            var myURL = ""
            myURL = weatherFields.URL as String
            let replaced = String(myURL.characters.map {
                $0 == " " ? "-" : $0
                })
            
            newItem.representedObject = replaced
            menu.addItem(newItem)
            
            var currentForecastMenu = NSMenu()
            
            if (defaults.string(forKey: "currentWeatherInSubmenu")! == "1") {
                newItem = myMenuItem(localizedString(forKey: "currentConditions_") as String, url: nil, key: "")
                menu.addItem(newItem)
                menu.setSubmenu(currentForecastMenu, for: newItem)
            } else {
                currentForecastMenu = menu
                menu.addItem(NSMenuItem.separator())
            }
            
            currentConditions(weatherFields, cityName: displayCityName, currentForecastMenu: currentForecastMenu)
            
            newItem = myMenuItem(localizedString(forKey: "RadarImage_"), url: "showRadar:", key: "")
            newItem.representedObject = weatherFields.weatherTag as String
            //currentForecastMenu.addItem(newItem)
            
            if ((defaults.string(forKey: "viewExtendedForecast")! == "1") &&
                (weatherFields.forecastCounter > 0)) {
                var extendedForecastMenu = NSMenu()
                
                if (defaults.string(forKey: "extendedForecastInSubmenu")! == "1") {
                    newItem = myMenuItem(localizedString(forKey: "ExtendedForecast_"), url: nil, key: "")
                    menu.addItem(newItem)
                    menu.setSubmenu(extendedForecastMenu, for: newItem)
                } else {
                    extendedForecastMenu = menu
                    menu.addItem(NSMenuItem.separator())
                }
                extendedForecasts(weatherFields, cityName: displayCityName, extendedForecastMenu: extendedForecastMenu, weatherDataSource: weatherDataSource)
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        DebugLog(String(format:"leaving updateMenuWithPrimaryLocation: %@", cityName))
    } // updateMenuWithPrimaryLocation
    
    func updateMenuWithSecondaryLocation(_ weatherFields: WeatherFields,
                                         cityName: String,
                                         displayCityName: String,
                                         menu: NSMenu,
                                         weatherDataSource: String) {
        
        var newItem : NSMenuItem
        let defaults = UserDefaults.standard
        
        DebugLog(String(format:"in updateMenuWithSecondaryLocation: %@", cityName))
        
        var city = displayCityName
        /*
        if ((city == "") && (weatherFields.title1.length > 17)) {
            city = weatherFields.title1.substring(from: 17)
        }
         */
        if (city == "") {
            city = weatherFields.title1
        }
        
        var statusTitle = city
        if (weatherFields.currentTemp != "") {
            statusTitle = statusTitle + " " + formatTemp((weatherFields.currentTemp as String))
        }
        if (defaults.string(forKey: "displayHumidity")! == "1") {
            if (weatherFields.humidity != "") {
                statusTitle = statusTitle + "/" + formatHumidity((weatherFields.humidity as String))
            }
        }
        
        if (weatherDataSource == YAHOO_WEATHER)
        {
            statusTitle = statusTitle + "\t\tYahoo!"
        }
        else if (weatherDataSource == OPENWEATHERMAP)
        {
            statusTitle = statusTitle + "\t\tOpenWeather"
        }
        else if (weatherDataSource == THEWEATHER)
        {
            statusTitle = statusTitle + "\t\tTheWeather"
        }
        else if (weatherDataSource == WEATHERUNDERGROUND)
        {
            statusTitle = statusTitle + "\t\tWUnderground"
        }
        else if (weatherDataSource == DARKSKY)
        {
            statusTitle = statusTitle + "\t\tDark Sky"
        }
        else if (weatherDataSource == AERISWEATHER)
        {
            statusTitle = statusTitle + "\t\tAERIS Weather"
        }
        else if (weatherDataSource == WORLDWEATHERONLINE)
        {
            statusTitle = statusTitle + "\t\tWorld Weather Online"
        }
        else if (weatherDataSource == APIXU)
        {
            statusTitle = statusTitle + "\t\tAPIXU"
        }
        else
        {
            statusTitle = statusTitle + "\t\tWeatherSource unknown"
        }
        
        newItem = myMenuItem(statusTitle, url: "openWeatherURL:", key: "")
        if (weatherFields.currentCode != "") {
            newItem.image = setImage(weatherFields.currentCode as String, weatherDataSource: weatherDataSource)
        }
        
        // http://stackoverflow.com/questions/24200888/any-way-to-replace-characters-on-swift-string
        var myURL = ""
        myURL = weatherFields.URL as String
        let replaced = String(myURL.characters.map {
            $0 == " " ? "-" : $0
            })
        
        newItem.representedObject = replaced
        menu.addItem(newItem)
        
        let newLocation = NSMenu()
        menu.setSubmenu(newLocation, for: newItem)

        var currentForecastMenu = NSMenu()
        
        if (defaults.string(forKey: "currentWeatherInSubmenu")! == "1") {
            newItem = myMenuItem(localizedString(forKey: "currentConditions_") as String, url: nil, key: "")
            newItem.target=self
            newLocation.addItem(newItem)
            newLocation.setSubmenu(currentForecastMenu, for: newItem)
        } else {
            currentForecastMenu = newLocation
            newLocation.addItem(NSMenuItem.separator())
        }
        
        currentConditions(weatherFields, cityName: displayCityName, currentForecastMenu: currentForecastMenu)
        
        if ((defaults.string(forKey: "viewExtendedForecast")! == "1") &&
            (!weatherFields.forecastDay[0].isEqual(""))) {
            var extendedForecastMenu = NSMenu()
            
            if (defaults.string(forKey: "extendedForecastInSubmenu")! == "1") {
                newItem = myMenuItem(localizedString(forKey: "ExtendedForecast_"), url: nil, key: "")
                newItem.target=self
                newLocation.addItem(newItem)
                newLocation.setSubmenu(extendedForecastMenu, for: newItem)
            } else {
                extendedForecastMenu = newLocation
                newLocation.addItem(NSMenuItem.separator())
            }
            extendedForecasts(weatherFields, cityName: displayCityName, extendedForecastMenu: extendedForecastMenu, weatherDataSource: weatherDataSource)
        }

        DebugLog(String(format:"leaving updateMenuWithSecondaryLocation: %@", cityName))
    } // updateMenuWithSecondaryLocation
    
    func currentConditions(_ weatherFields: WeatherFields, cityName: String, currentForecastMenu: NSMenu) {
        
        if (weatherFields.currentTemp != "") {
            currentForecastMenu.addItem(myMenuItem(localizedString(forKey: "Temperature_") + ": " + formatTemp(weatherFields.currentTemp as String), url: "dummy:", key: ""))
        }
        
        if (weatherFields.windSpeed != "") {
            currentForecastMenu.addItem(myMenuItem(localizedString(forKey: "FeelsLike_") + ": " + formatTemp(weatherFields.currentTemp as String), url: "dummy:", key: ""))
        }
        
        if (weatherFields.humidity != "") {
            currentForecastMenu.addItem(myMenuItem(localizedString(forKey: "Humidity_") + ": " + formatHumidity(weatherFields.humidity as String), url: "dummy:", key: ""))
        }
        
        if (weatherFields.visibility != "") {
            currentForecastMenu.addItem(myMenuItem(localizedString(forKey: "Visibility_") + ": " + formatVisibility(weatherFields.visibility as String), url: "dummy:", key: ""))
        }
        
        if (weatherFields.pressure != "") {
            currentForecastMenu.addItem(myMenuItem(localizedString(forKey: "Pressure_") + ": " + formatPressure(weatherFields.pressure as String), url: "dummy:", key: ""))
        }
        
        if (weatherFields.windDirection != "") {
            currentForecastMenu.addItem(myMenuItem(localizedString(forKey: "Wind_") + ": " + formatWindSpeed(weatherFields.windSpeed as String, direction: weatherFields.windDirection as String), url: "dummy:", key: ""))
        }
        
        if (weatherFields.latitude != "") {
            currentForecastMenu.addItem(myMenuItem(localizedString(forKey: "LatLong_") + ": " + (weatherFields.latitude as String) + " " + (weatherFields.longitude as String), url: "dummy:", key: ""))
        }
        
        if (weatherFields.sunrise != "") {
            currentForecastMenu.addItem(myMenuItem(localizedString(forKey: "SunriseSunset_") + ": " + convertUTCtoHHMM(weatherFields.sunrise as String) + " / " + convertUTCtoHHMM(weatherFields.sunset as String), url: "dummy:", key: ""))
        }
        
        if (weatherFields.currentConditions != "") {
            currentForecastMenu.addItem(myMenuItem(localizedString(forKey: "currentConditions_") + ": " + localizedString(forKey: (weatherFields.currentConditions as String)), url: "dummy:", key: ""))
        }
        
        if (weatherFields.date != "") {
            currentForecastMenu.addItem(myMenuItem(localizedString(forKey: "LastUpdate_") + ": " + convertUTCtoHHMM(weatherFields.date as String), url: "dummy:", key: ""))
        }
        
    } // currentConditions
    
    // newItem = myMenuItem("", url: nil, key: "")
    func extendedForecasts(_ weatherFields: WeatherFields,
                           cityName: String,
                           extendedForecastMenu: NSMenu,
                           weatherDataSource: String) {
        
        var newItem : NSMenuItem
        let defaults = UserDefaults.standard
        
        DebugLog(String(format:"in extendedForecasts: %@", cityName))
        
        var extendedForecast = NSMenu()
        
        var i = 0
        
        var maxForecastDays = Int(defaults.string(forKey: "forecastDays")!)! + 1
        if (maxForecastDays > weatherFields.forecastCounter)
        {
            maxForecastDays = weatherFields.forecastCounter
        }
        
        while (i < maxForecastDays)
        {
            if (!weatherFields.forecastDay[i].isEqual("")) {
                extendedForecast = NSMenu()
                
                if (defaults.string(forKey: "extendedForecastSingleLine")! == "1") {
                    var menuString = "";
                    menuString = menuString + localizedString(forKey: formatDay(weatherFields.forecastDay[i] as String)) + " \t"
                    menuString = menuString + formatTemp(weatherFields.forecastHigh[i] as String) + "/" + formatTemp(weatherFields.forecastLow[i] as String) + " \t"
                    menuString = menuString + localizedString(forKey: (weatherFields.forecastConditions[i] as String))
                    newItem = myMenuItem(menuString, url: "dummy:", key: "")
                    if (defaults.string(forKey: "extendedForecastIcons")! == "1") {
                        newItem.image=setImage(weatherFields.forecastCode[i] as String, weatherDataSource: weatherDataSource)
                    } else {
                        newItem.image = nil
                    }
                    extendedForecastMenu.addItem(newItem)
                } else {
                    
                    newItem = myMenuItem(localizedString(forKey: formatDay(weatherFields.forecastDay[i] as String)) + " \t" + formatTemp(weatherFields.forecastHigh[i] as String), url: nil, key: "")
                    extendedForecastMenu.addItem(newItem)
                    if (defaults.string(forKey: "extendedForecastIcons")! == "1") {
                        newItem.image=setImage(weatherFields.forecastCode[i] as String, weatherDataSource: weatherDataSource)
                    } else {
                        newItem.image = nil
                    }
                    extendedForecastMenu.setSubmenu(extendedForecast, for: newItem)
                    
                    if (weatherFields.forecastDate[i] != "")
                    {
                        newItem = myMenuItem(localizedString(forKey: "Date_") + ": " + (weatherFields.forecastDate[i] as String), url: "dummy:", key: "")
                        extendedForecast.addItem(newItem)
                    }
                    
                    newItem = myMenuItem(localizedString(forKey: "Forecast_") + ": " + localizedString(forKey: (weatherFields.forecastConditions[i] as String)), url: "dummy:", key: "")
                    extendedForecast.addItem(newItem)
                    
                    newItem = myMenuItem(localizedString(forKey: "High_") + ": " + formatTemp(weatherFields.forecastHigh[i] as String), url: "dummy:", key: "")
                    extendedForecast.addItem(newItem)
                    
                    newItem = myMenuItem(localizedString(forKey: "Low_") + ": " + formatTemp(weatherFields.forecastLow[i] as String), url: "dummy:", key: "")
                    extendedForecast.addItem(newItem)
                }
            }
            i = i + 1
        }

        DebugLog(String(format:"leaving extendedForecasts: %@", cityName))
    } // extendedForecasts
    
    func dummy(_ sender: NSMenuItem)
    {
        //print("dummy", terminator: "\n")
    } // dummy
    
    func openWeatherURL(_ menu:NSMenuItem)
    {
        let myUrl = menu.representedObject as! NSString
        
        if let checkURL = URL(string: myUrl as String)
        {
            if NSWorkspace.shared().open(checkURL)
            {
                print("URL successfully opened:", myUrl, terminator: "\n")
                
            }
        }
        else
        {
            print("Invalid url:", myUrl, terminator: "\n")
        }
    } // openWeatherURL
    
    func showRadar(_ menu:NSMenuItem) {
        
        DebugLog(String(format:"in showRadar\n"))
        
        let radarURL = menu.representedObject as! String
        InfoLog(String(format:"URL: %@\n", radarURL))
        radarWindow.radarDisplay(radarURL)
        radarWindow.showWindow(nil)
        
        DebugLog(String(format:"leaving showRadar\n"))
    } // showRadar
    
    func testAndSet(_ key:String, defaultValue:String)
    {
        let defaults = UserDefaults.standard
        let d = defaults.string(forKey: key)
        if (d == nil)
        {
            defaults.setValue(defaultValue, forKey: key)
        }
    } // testAndSet
    
    func defaultPreferences()
    {
        
        testAndSet("weatherSource_1", defaultValue: YAHOO_WEATHER)
        testAndSet("API_Key_Data1_1", defaultValue: "")
        testAndSet("API_Key_Data2_1", defaultValue: "")
        testAndSet("weatherSource_2", defaultValue: YAHOO_WEATHER)
        testAndSet("API_Key_Data1_2", defaultValue: "")
        testAndSet("API_Key_Data2_2", defaultValue: "")
        testAndSet("weatherSource_3", defaultValue: YAHOO_WEATHER)
        testAndSet("API_Key_Data1_3", defaultValue: "")
        testAndSet("API_Key_Data2_3", defaultValue: "")
        testAndSet("weatherSource_4", defaultValue: YAHOO_WEATHER)
        testAndSet("API_Key_Data1_4", defaultValue: "")
        testAndSet("API_Key_Data2_4", defaultValue: "")
        testAndSet("weatherSource_5", defaultValue: YAHOO_WEATHER)
        testAndSet("API_Key_Data1_5", defaultValue: "")
        testAndSet("API_Key_Data2_5", defaultValue: "")
        testAndSet("weatherSource_6", defaultValue: YAHOO_WEATHER)
        testAndSet("API_Key_Data1_6", defaultValue: "")
        testAndSet("API_Key_Data2_6", defaultValue: "")
        testAndSet("weatherSource_7", defaultValue: YAHOO_WEATHER)
        testAndSet("API_Key_Data1_7", defaultValue: "")
        testAndSet("API_Key_Data2_7", defaultValue: "")
        testAndSet("weatherSource_8", defaultValue: YAHOO_WEATHER)
        testAndSet("API_Key_Data1_8", defaultValue: "")
        testAndSet("API_Key_Data2_8", defaultValue: "")
        
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
        testAndSet("rotateWeatherLocations", defaultValue: "0")
        testAndSet("extendedForecastInSubmenu", defaultValue: "1")
        testAndSet("extendedForecastIcons", defaultValue: "1")
        testAndSet("newVersion", defaultValue: "1")
        testAndSet("logMessages", defaultValue: "0")
        testAndSet("useNewWeatherIcons", defaultValue: "1")  //Use new weather icons
        
        testAndSet("degreesUnit", defaultValue: "0")
        testAndSet("distanceUnit", defaultValue: "0")
        testAndSet("speedUnit", defaultValue: "0")
        testAndSet("pressureUnit", defaultValue: "0")
        testAndSet("directionUnit", defaultValue: "0")

        testAndSet("forecastDays", defaultValue: "4")

        testAndSet("preferenceVersion", defaultValue: DEFAULT_PREFERENCE_VERSION)
        
    } // defaultPreferences
    
    func initWindowPrefs()
    {
        
        initDisplay()
        
        modalDisplay.setFont("font")
        modalDisplay.initPrefs()
        
        modalMenuBar.setFont("menuBarFont")
        modalMenuBar.initPrefs()
        
        // https://www.youtube.com/watch?v=lJS4YWUT8Hk
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionTextLabel.stringValue = localizedString(forKey: "Version_") + " " + version // + " build " + build
        
        let defaults = UserDefaults.standard
        
        weatherSource_1.selectItem(at: Int(defaults.string(forKey: "weatherSource_1") ?? YAHOO_WEATHER)!)
        API_Key_Data1_1.stringValue           = defaults.string(forKey: "API_Key_Data1_1") ?? ""
        API_Key_Data2_1.stringValue           = defaults.string(forKey: "API_Key_Data2_1") ?? ""
        weatherSource_2.selectItem(at: Int(defaults.string(forKey: "weatherSource_2") ?? YAHOO_WEATHER)!)
        API_Key_Data1_2.stringValue           = defaults.string(forKey: "API_Key_Data1_2") ?? ""
        API_Key_Data2_2.stringValue           = defaults.string(forKey: "API_Key_Data2_2") ?? ""
        weatherSource_3.selectItem(at: Int(defaults.string(forKey: "weatherSource_3") ?? YAHOO_WEATHER)!)
        API_Key_Data1_3.stringValue           = defaults.string(forKey: "API_Key_Data1_3") ?? ""
        API_Key_Data2_3.stringValue           = defaults.string(forKey: "API_Key_Data2_3") ?? ""
        weatherSource_4.selectItem(at: Int(defaults.string(forKey: "weatherSource_4") ?? YAHOO_WEATHER)!)
        API_Key_Data1_4.stringValue           = defaults.string(forKey: "API_Key_Data1_4") ?? ""
        API_Key_Data2_4.stringValue           = defaults.string(forKey: "API_Key_Data2_4") ?? ""
        weatherSource_5.selectItem(at: Int(defaults.string(forKey: "weatherSource_5") ?? YAHOO_WEATHER)!)
        API_Key_Data1_5.stringValue           = defaults.string(forKey: "API_Key_Data1_5") ?? ""
        API_Key_Data2_5.stringValue           = defaults.string(forKey: "API_Key_Data2_5") ?? ""
        weatherSource_6.selectItem(at: Int(defaults.string(forKey: "weatherSource_6") ?? YAHOO_WEATHER)!)
        API_Key_Data1_6.stringValue           = defaults.string(forKey: "API_Key_Data1_6") ?? ""
        API_Key_Data2_6.stringValue           = defaults.string(forKey: "API_Key_Data2_6") ?? ""
        weatherSource_7.selectItem(at: Int(defaults.string(forKey: "weatherSource_7") ?? YAHOO_WEATHER)!)
        API_Key_Data1_7.stringValue           = defaults.string(forKey: "API_Key_Data1_7") ?? ""
        API_Key_Data2_7.stringValue           = defaults.string(forKey: "API_Key_Data2_7") ?? ""
        weatherSource_8.selectItem(at: Int(defaults.string(forKey: "weatherSource_8") ?? YAHOO_WEATHER)!)
        API_Key_Data1_8.stringValue           = defaults.string(forKey: "API_Key_Data1_8") ?? ""
        API_Key_Data2_8.stringValue           = defaults.string(forKey: "API_Key_Data2_8") ?? ""
        
        cityTextField.stringValue           = defaults.string(forKey: "city") ?? DEFAULT_CITY
        cityTextField2.stringValue          = defaults.string(forKey: "city2") ?? ""
        cityTextField3.stringValue          = defaults.string(forKey: "city3") ?? ""
        cityTextField4.stringValue          = defaults.string(forKey: "city4") ?? ""
        cityTextField5.stringValue          = defaults.string(forKey: "city5") ?? ""
        cityTextField6.stringValue          = defaults.string(forKey: "city6") ?? ""
        cityTextField7.stringValue          = defaults.string(forKey: "city7") ?? ""
        cityTextField8.stringValue          = defaults.string(forKey: "city8") ?? ""
        cityDisplayTextField.stringValue    = defaults.string(forKey: "displayCity") ?? ""
        cityDisplayTextField2.stringValue   = defaults.string(forKey: "displayCity2") ?? ""
        cityDisplayTextField3.stringValue   = defaults.string(forKey: "displayCity3") ?? ""
        cityDisplayTextField4.stringValue   = defaults.string(forKey: "displayCity4") ?? ""
        cityDisplayTextField5.stringValue   = defaults.string(forKey: "displayCity5") ?? ""
        cityDisplayTextField6.stringValue   = defaults.string(forKey: "displayCity6") ?? ""
        cityDisplayTextField7.stringValue   = defaults.string(forKey: "displayCity7") ?? ""
        cityDisplayTextField8.stringValue   = defaults.string(forKey: "displayCity8") ?? ""
        
        updateFrequencyTextField.stringValue = defaults.string(forKey: "updateFrequency") ?? DEFAULT_INTERVAL
        delayFrequencyTextField.stringValue = defaults.string(forKey: "launchDelay") ?? "10"
        controlsInSubmenu.stringValue       = defaults.string(forKey: "controlsInSubmenu") ?? "1"
        displayHumidity.stringValue         = defaults.string(forKey: "displayHumidity") ?? "1"
        displayDegreeType.stringValue       = defaults.string(forKey: "displayDegreeType") ?? "1"
        displayWeatherIcon.stringValue      = defaults.string(forKey: "displayWeatherIcon") ?? "1"
        displayCityName.stringValue         = defaults.string(forKey: "displayCityName") ?? "1"
        useNewWeatherIcons.stringValue      = defaults.string(forKey: "useNewWeatherIcons") ?? "1"
        currentWeatherInSubmenu.stringValue = defaults.string(forKey: "currentWeatherInSubmenu") ?? "1"
        viewExtendedForecast.stringValue    = defaults.string(forKey: "viewExtendedForecast") ?? "1"
        extendedForecastSingleLine.stringValue = defaults.string(forKey: "extendedForecastSingleLine") ?? "1"
        rotateWeatherLocations.stringValue = defaults.string(forKey: "rotateWeatherLocations") ?? "0"
        extendedForecastInSubmenu.stringValue = defaults.string(forKey: "extendedForecastInSubmenu") ?? "1"
        extendedForecastIcons.stringValue   = defaults.string(forKey: "extendedForecastIcons") ?? "1"
        newVersion.stringValue              = defaults.string(forKey: "newVersion") ?? "1"
        logMessages.stringValue             = defaults.string(forKey: "logMessages") ?? "0"
        
        degreesUnit.selectItem(at: Int(defaults.string(forKey: "degreesUnit") ?? "0")!)
        distanceUnit.selectItem(at: Int(defaults.string(forKey: "distanceUnit") ?? "0")!)
        speedUnit.selectItem(at: Int(defaults.string(forKey: "speedUnit") ?? "0")!)
        pressureUnit.selectItem(at: Int(defaults.string(forKey: "pressureUnit") ?? "0")!)
        directionUnit.selectItem(at: Int(defaults.string(forKey: "directionUnit") ?? "0")!)
        
        forecastDays.selectItem(at: Int(defaults.string(forKey: "forecastDays") ?? "4")!)
    } // initWindowPrefs
    
    func windowWillClose(_ notification: Notification)
    {
        
        let defaults = UserDefaults.standard
        
        defaults.setValue(weatherSource_1.indexOfSelectedItem, forKey: "weatherSource_1")
        defaults.setValue(API_Key_Data1_1.stringValue, forKey: "API_Key_Data1_1")
        defaults.setValue(API_Key_Data2_1.stringValue, forKey: "API_Key_Data2_1")
        defaults.setValue(weatherSource_2.indexOfSelectedItem, forKey: "weatherSource_2")
        defaults.setValue(API_Key_Data1_2.stringValue, forKey: "API_Key_Data1_2")
        defaults.setValue(API_Key_Data2_2.stringValue, forKey: "API_Key_Data2_2")
        defaults.setValue(weatherSource_3.indexOfSelectedItem, forKey: "weatherSource_3")
        defaults.setValue(API_Key_Data1_3.stringValue, forKey: "API_Key_Data1_3")
        defaults.setValue(API_Key_Data2_3.stringValue, forKey: "API_Key_Data2_3")
        defaults.setValue(weatherSource_4.indexOfSelectedItem, forKey: "weatherSource_4")
        defaults.setValue(API_Key_Data1_4.stringValue, forKey: "API_Key_Data1_4")
        defaults.setValue(API_Key_Data2_4.stringValue, forKey: "API_Key_Data2_4")
        defaults.setValue(weatherSource_5.indexOfSelectedItem, forKey: "weatherSource_5")
        defaults.setValue(API_Key_Data1_5.stringValue, forKey: "API_Key_Data1_5")
        defaults.setValue(API_Key_Data2_5.stringValue, forKey: "API_Key_Data2_5")
        defaults.setValue(weatherSource_6.indexOfSelectedItem, forKey: "weatherSource_6")
        defaults.setValue(API_Key_Data1_6.stringValue, forKey: "API_Key_Data1_6")
        defaults.setValue(API_Key_Data2_6.stringValue, forKey: "API_Key_Data2_6")
        defaults.setValue(weatherSource_7.indexOfSelectedItem, forKey: "weatherSource_7")
        defaults.setValue(API_Key_Data1_7.stringValue, forKey: "API_Key_Data1_7")
        defaults.setValue(API_Key_Data2_7.stringValue, forKey: "API_Key_Data2_7")
        defaults.setValue(weatherSource_8.indexOfSelectedItem, forKey: "weatherSource_8")
        defaults.setValue(API_Key_Data1_8.stringValue, forKey: "API_Key_Data1_8")
        defaults.setValue(API_Key_Data2_8.stringValue, forKey: "API_Key_Data2_8")
        
        defaults.setValue(cityTextField.stringValue, forKey: "city")
        if (cityTextField.stringValue == "")
        {
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
        defaults.setValue(delayFrequencyTextField.stringValue, forKey: "launchDelay")
        defaults.setValue(controlsInSubmenu.stringValue, forKey: "controlsInSubmenu")
        defaults.setValue(displayHumidity.stringValue, forKey: "displayHumidity")
        defaults.setValue(displayDegreeType.stringValue, forKey: "displayDegreeType")
        defaults.setValue(displayWeatherIcon.stringValue, forKey: "displayWeatherIcon")
        defaults.setValue(displayCityName.stringValue, forKey: "displayCityName")
        defaults.setValue(useNewWeatherIcons.stringValue, forKey: "useNewWeatherIcons")
        defaults.setValue(currentWeatherInSubmenu.stringValue, forKey: "currentWeatherInSubmenu")
        defaults.setValue(viewExtendedForecast.stringValue, forKey: "viewExtendedForecast")
        defaults.setValue(extendedForecastSingleLine.stringValue, forKey: "extendedForecastSingleLine")
        defaults.setValue(rotateWeatherLocations.stringValue, forKey: "rotateWeatherLocations")
        defaults.setValue(extendedForecastInSubmenu.stringValue, forKey: "extendedForecastInSubmenu")
        defaults.setValue(extendedForecastIcons.stringValue, forKey: "extendedForecastIcons")
        defaults.setValue(newVersion.stringValue, forKey: "newVersion")
        defaults.setValue(logMessages.stringValue, forKey: "logMessages")
        
        defaults.setValue(degreesUnit.indexOfSelectedItem, forKey: "degreesUnit")
        defaults.setValue(distanceUnit.indexOfSelectedItem, forKey: "distanceUnit")
        defaults.setValue(speedUnit.indexOfSelectedItem, forKey: "speedUnit")
        defaults.setValue(pressureUnit.indexOfSelectedItem, forKey: "pressureUnit")
        defaults.setValue(directionUnit.indexOfSelectedItem, forKey: "directionUnit")
        
        defaults.setValue(forecastDays.indexOfSelectedItem, forKey: "forecastDays")
       
        defaults.setValue(DEFAULT_PREFERENCE_VERSION, forKey: "preferenceVersion")
        
        let i = NumberFormatter().number(from: defaults.string(forKey: "fontsize")!)
        menu.font = NSFont(name: defaults.string(forKey: "font")!, size: CGFloat(i!))
        
        updateWeather()
        
    } // windowWillClose
    
    
    func initDisplay()
    {
        self.window!.title = localizedString(forKey: "Preferences_")
        cityNameLabel.stringValue = localizedString(forKey: "CityNames_") + ":"
        cityDisplayNameLabel.stringValue = localizedString(forKey: "CityDisplayNames_") + ":"
        updateFrequencyLabel.stringValue = localizedString(forKey: "UpdateFrequency_") + ":"
        updateFrequenceMinutesLabel.stringValue = localizedString(forKey: "UpdateMinutes_")
        delayFrequencyLabel.stringValue = localizedString(forKey: "launchDelay_") + ":"
        delayFrequencySecondsLabel.stringValue = localizedString(forKey: "delaySeconds_")
        API_Key_Label1.stringValue = localizedString(forKey: "API Key 1:_")
        API_Key_Label2.stringValue = localizedString(forKey: "API Key 2:_")
        
        newVersion.title = localizedString(forKey: "NewVersion_")
        
        logMessages.title = localizedString(forKey: "logMessages_")
        
        weatherSourceLabel.stringValue = localizedString(forKey: "weatherSource_") + ":"
        
        InitWeatherSourceButton(weatherSourceButton: weatherSource_1)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_2)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_3)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_4)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_5)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_6)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_7)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_8)
        
        currentWeatherInSubmenu.title = localizedString(forKey: "CurrentWeather_")
        displayHumidity.title = localizedString(forKey: "DisplayHumidity_")
        displayDegreeType.title = localizedString(forKey: "DisplayDegreeType_")
        displayWeatherIcon.title = localizedString(forKey: "DisplayWeatherIcon_")
        displayCityName.title = localizedString(forKey: "DisplayCityName_")
        useNewWeatherIcons.title = localizedString(forKey: "UseNewWeatherIcons_")
        controlsInSubmenu.title = localizedString(forKey: "ControlsInSubmenu_")
        viewExtendedForecast.title = localizedString(forKey: "ViewExtendedForecast_")
        extendedForecastInSubmenu.title = localizedString(forKey: "ExtendedForecastInSubmenu_")
        extendedForecastIcons.title = localizedString(forKey: "ExtendedForecastIcons_")
        extendedForecastSingleLine.title = localizedString(forKey: "ExtendedForecastSingleLine_")
        rotateWeatherLocations.title = localizedString(forKey: "rotateWeatherLocations_")
        
        globalUnitsLabel.stringValue = localizedString(forKey: "GlobalUnits_") + ":"
        
        degreesLabel.stringValue = localizedString(forKey: "Degrees_") + ":"
        degreesUnit.item(at: 0)?.title = localizedString(forKey: "Fahrenheit_")
        degreesUnit.item(at: 1)?.title = localizedString(forKey: "Celsius_")
        
        forecastLabel.stringValue = localizedString(forKey: "forecastLabel_") + ":"
        
        speedLabel.stringValue = localizedString(forKey: "Speed_") + ":"
        speedUnit.item(at: 0)?.title = localizedString(forKey: "MilesPerHour_")
        speedUnit.item(at: 1)?.title = localizedString(forKey: "KMPerHour_")
        speedUnit.item(at: 2)?.title = localizedString(forKey: "MPerSec_")
        speedUnit.item(at: 3)?.title = localizedString(forKey: "Knots_")
        // Need default value
        
        distanceLabel.stringValue = localizedString(forKey: "Distance_") + ":"
        distanceUnit.item(at: 0)?.title = localizedString(forKey: "Miles_")
        distanceUnit.item(at: 1)?.title = localizedString(forKey: "Feet_")
        distanceUnit.item(at: 2)?.title = localizedString(forKey: "kilometers_")
        distanceUnit.item(at: 3)?.title = localizedString(forKey: "Meters_")
        // Need default value
        
        pressureLabel.stringValue = localizedString(forKey: "Pressure_") + ":"
        pressureUnit.item(at: 0)?.title = localizedString(forKey: "Inches_")
        pressureUnit.item(at: 1)?.title = localizedString(forKey: "Millibars_")
        pressureUnit.item(at: 2)?.title = localizedString(forKey: "kiloPascal_")
        pressureUnit.item(at: 3)?.title = localizedString(forKey: "hectoPascal_")
        pressureUnit.item(at: 4)?.title = localizedString(forKey: "mmHg_")
        // Need default value
        
        directionLabel.stringValue = localizedString(forKey: "Direction_") + ":"
        directionUnit.item(at: 0)?.title = localizedString(forKey: "Degrees_")
        directionUnit.item(at: 1)?.title = localizedString(forKey: "Ordinal_")
        // Need default value
        
        fontLabel.stringValue = localizedString(forKey: "DisplayFont_") + ":"
        menuBarFontLabel.stringValue = localizedString(forKey: "menuBarFont_") + ":"
        
        fontButton.title = localizedString(forKey: "SetFont_")
        menuBarFontButton.title = localizedString(forKey: "SetFont_")
        
        apiKeyLabel.stringValue = localizedString(forKey: "apiKeyLabel_")
        theWeatherLocation.stringValue = localizedString(forKey: "theWeatherLocation_")
        openWeatherMapLocation.stringValue = localizedString(forKey: "openWeatherMapLocation_")
        yahooLocation.stringValue = localizedString(forKey: "yahooLocation_")
        wundergroundLocation.stringValue = localizedString(forKey: "wundergroundLocation_")
        aerisLocation.stringValue = localizedString(forKey: "aerisLocation_") + ":"
        worldWeatherLocation.stringValue = localizedString(forKey: "worldWeatherLocation_")
        darkSkyLocation.stringValue = localizedString(forKey: "darkSkyLocation_")
        APIXULocation.stringValue = localizedString(forKey: "APIXULocation_")

    } // initDisplay
    
    func InitWeatherSourceButton(weatherSourceButton: NSPopUpButton)
    {
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "Yahoo!_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "OpenWeatherMap_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "TheWeather.com_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "WeatherUnderground_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "AERISWeather_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "WorldWeatherOnline_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "APIXU_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "DarkSky_") )
    } // InitWeatherSourceButton
    
    @IBAction func DisplayFontPressed(_ sender: NSButton)
    {
        // https://translate.google.com/translate?sl=auto&tl=en&js=y&prev=_t&hl=en&ie=UTF-8&u=http%3A%2F%2Fcocoaapi.hatenablog.com%2Fentry%2FAppkit%2FNSWindow_class%2FbeginSheet%253AcompletionHandler%253A&edit-text=&act=url
        modalDisplay.setFont("font")
        self.window!.beginSheet (modalDisplay.window!, completionHandler: nil)
    }
    
    @IBAction func MenuBarFontPressed(_ sender: NSButton)
    {
        // https://translate.google.com/translate?sl=auto&tl=en&js=y&prev=_t&hl=en&ie=UTF-8&u=http%3A%2F%2Fcocoaapi.hatenablog.com%2Fentry%2FAppkit%2FNSWindow_class%2FbeginSheet%253AcompletionHandler%253A&edit-text=&act=url
        modalMenuBar.setFont("menuBarFont")
        self.window!.beginSheet (modalMenuBar.window!, completionHandler: nil)
    }
    
    @IBAction func preferences(_ sender: NSMenuItem)
    {
        self.window!.delegate = self
        self.window!.orderOut(self)
        self.window!.makeKeyAndOrderFront(self.window!)
        NSApp.activate(ignoringOtherApps: true)
    } // dummy
    
    @IBAction func launchLink(_ sender: NSButton)
    {
        if let url = URL(string: sender.title) {
            NSWorkspace.shared().open(url)
        }
    } // dummy
    
    @IBAction func Relaunch(_ sender: NSMenuItem)
    {
        let defaults = UserDefaults.standard
        if (defaults.string(forKey: "logMessages")! == "1")
        {
            InfoLog(String(format:"Application %@ relaunching", self.appName))
        }
        
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep 0.2; open \"\(Bundle.main.bundlePath)\""]
        task.launch()
        NSApplication.shared().terminate(nil)
    } // dummy
    
    @IBAction func weatherRefresh(_ sender: NSMenuItem)
    {
        updateWeather()
    } // weatherRefresh
    
} // AppDelegate
