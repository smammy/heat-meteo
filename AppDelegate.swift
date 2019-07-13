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
//    Had to update both the TEXT and BACKCOLOR to default.
//    No clue why but we're not alone. It's an Apple bug somewhere.
// 2. Fixed the font problem above then started getting another Apple crash.
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
// https://www.weatherbit.io/api
//
// Preferences have been cached since 10.9
// https://forums.developer.apple.com/message/65946#65946
// killall -u $USER cfprefsd
//
// http://stackoverflow.com/questions/26340670/issue-with-genstrings-for-swift-file
//

import Cocoa
import WebKit
import CoreLocation

// This isn't needed but kept here for future reference
#if os(iOS)
#elseif os(OSX)
#endif

let DEFAULT_CITY = "<here>"
let DEFAULT_CITY2 = "Cupertino, CA"
let DEFAULT_INTERVAL = "60"

let YAHOO_WEATHER = "0"
let OPENWEATHERMAP = "1"
let THEWEATHER = "2"
let WEATHERUNDERGROUND = "3"
let AERISWEATHER = "4"
let WORLDWEATHERONLINE = "5"
let DARKSKY = "6"
let APIXU = "7"
let CANADAGOV = "8"
let MAX_LOCATIONS = 8

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

// https://stackoverflow.com/questions/24200888/any-way-to-replace-characters-on-swift-string
extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    // https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
} // extension String

// https://bluelemonbits.com/index.php/2015/08/20/evaluate-string-width-and-return-cgfloat-swift-osx/
func evaluateStringWidth (textToEvaluate: String) -> CGFloat{
    
    let defaults = UserDefaults.standard
    
    var font = NSFont()
    let m = NumberFormatter().number(from: defaults.string(forKey: "fontsize")!)!
    
    if (defaults.string(forKey: "fontDefault") == "1") {
        font = NSFont.systemFont(ofSize: CGFloat(truncating: m))
    }
    else {
        font = NSFont(name: defaults.string(forKey: "font")!, size: CGFloat(truncating: m))!
    }
    
    let attributes = NSDictionary(object: font, forKey:NSAttributedString.Key.font as NSCopying)
    let sizeOfText = textToEvaluate.size(withAttributes: (attributes as! [NSAttributedString.Key : Any]))
    //let sizeOfText = textToEvaluate.size(withAttributes: (attributes as! [String : AnyObject]))
    
    return sizeOfText.width
} // evaluateStringWidth

func localizedString(forKey key: String) -> String {
    var result = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    
    if result == key {
        result = Bundle.main.localizedString(forKey: key, value: nil, table: "Default")
    }
    
    return result
} // localizedString

struct WeatherFields {
    
    // TODO Change data to metric (standard)
    
    var title1 = String()
    var date = String()             // In UTC
    
    var latitude = String()
    var longitude = String()
    
    //var windChill = String()
    var windSpeed = String()        // mph
    var windGust = String()         // mph
    var windDirection = String()    // degrees
    
    var altitude = String()         // meters
    var humidity = String()         // percent
    var pressure = String()         // millibars
    var visibility = String()       // miles
    var UVIndex = String()          // Int
    
    var sunrise = String()          // UTC "mm:dd:yyyy'T'hh:MM:ss"
    var sunset = String()           // UTC "mm:dd:yyyy'T'hh:MM:ss"

    var currentLink = String()
    var currentTemp = String()          // *F
    var currentCode = String()          // Abbreviated Conditions
    var currentConditions = String()    // Full Conditions
    
    // http://stackoverflow.com/questions/30430550/how-to-create-an-empty-array-in-swift
    var forecastCounter = 0
    var forecastDate = [String]()       // 31
    var forecastDay = [String]()        // Monday
    var forecastHigh = [String]()       // *F
    var forecastLow = [String]()        // *F
    var forecastCode = [String]()       // Abbreviated Conditions
    var forecastConditions = [String]() // Full Condition
    
    var URL = String()
    
    var weatherTag = String()
    
} // WeatherFields

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, CLLocationManagerDelegate
{
    
    // https://github.com/soffes/clock-saver/blob/master/ClockDemo/Classes/AppDelegate.swift
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var locationsTab: NSTabViewItem!
    @IBOutlet weak var optionsTab: NSTabViewItem!
    @IBOutlet weak var globalTab: NSTabViewItem!
    @IBOutlet weak var keyTab: NSTabViewItem!
    @IBOutlet weak var helpTab: NSTabViewItem!
    
    @IBOutlet var helpView: NSTextView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var newVersion: NSButton!
    @IBOutlet weak var logMessages: NSButton!
    @IBOutlet weak var allowLocation: NSButton!

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
    @IBOutlet weak var convertQFEtoQNH: NSButton!
    
    @IBOutlet weak var forecastLabel: NSTextField!
    @IBOutlet weak var forecastDays: NSPopUpButton!
    
    @IBOutlet weak var controlsInSubmenu: NSButton!
    @IBOutlet weak var displayHumidity: NSButton!
    @IBOutlet weak var displayDegreeType: NSButton!
    @IBOutlet weak var displayWeatherIcon: NSButton!
    @IBOutlet weak var displayCityName: NSButton!
    @IBOutlet weak var displayFeelsLike: NSButton!
    @IBOutlet weak var useNewWeatherIcons: NSButton!  //Added this to give choice between color and monochrome icons
    @IBOutlet weak var currentWeatherInSubmenu: NSButton!
    @IBOutlet weak var viewExtendedForecast: NSButton!
    @IBOutlet weak var extendedForecastInSubmenu: NSButton!
    @IBOutlet weak var extendedForecastIcons: NSButton!
    @IBOutlet weak var extendedForecastSingleLine: NSButton!
    @IBOutlet weak var extendedForecastDisplayDate: NSButton!
    @IBOutlet weak var rotateWeatherLocations: NSButton!
    
    @IBOutlet weak var versionTextLabel: NSTextField!
    
    @IBOutlet weak var apiKeyLabel: NSTextField!
    
    @IBOutlet weak var resetPrefsButton: NSButton!
    @IBOutlet weak var latLongFormat: NSTextField!
    
    @IBOutlet weak var theWeatherLocation: NSTextField!
    @IBOutlet weak var openWeatherMapLocation: NSTextField!
    @IBOutlet weak var yahooLocation: NSTextField!
    @IBOutlet weak var wundergroundLocation: NSTextField!
    @IBOutlet weak var aerisLocation: NSTextField!
    @IBOutlet weak var worldWeatherLocation: NSTextField!
    @IBOutlet weak var darkSkyLocation: NSTextField!
    @IBOutlet weak var APIXULocation: NSTextField!
    @IBOutlet weak var canadaGovLocation: NSTextField!

    @IBOutlet weak var theWeatherURL: NSButton!
    @IBOutlet weak var openWeatherMapURL: NSButton!
    @IBOutlet weak var yahooURL: NSButton!
    @IBOutlet weak var wundergroundURL: NSButton!
    @IBOutlet weak var aerisURL: NSButton!
    @IBOutlet weak var worldWeatherURL: NSButton!
    @IBOutlet weak var darkSkyURL: NSButton!
    @IBOutlet weak var apixuURL: NSButton!
    @IBOutlet weak var canadaGovURL: NSButton!
    
    var buttonPresses = 0
    
    var modalMenuBar = ColorPickerWindow(windowNibName: "ColorPickerWindow")
    var modalDisplay = ColorPickerWindow(windowNibName: "ColorPickerWindow")
    var radarWindow = RadarWindow()

    
    var statusBar = NSStatusBar.system
    //var statusBarItem : NSStatusItem = NSStatusItem()
    var statusBarItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    
    let yahooWeatherAPI = YahooWeatherAPI()     // https://developer.yahoo.com/weather/
    let openWeatherMapAPI = OpenWeatherMapAPI() // http://www.openweathermap.org
    let theWeatherAPI = TheWeatherAPI()
    let weatherUndergroundAPI = WeatherUndergroundAPI()
    let darkSkyAPI = DarkSkyAPI()
    let aerisWeatherAPI = AerisWeatherAPI()
    let worldWeatherOnlineAPI = WorldWeatherOnlineAPI()
    let ApiXUApi = APIXUAPI()
    let canadaWeatherAPI = CanadaWeatherAPI()

    var myTimer = Timer()   // http://ios-blog.co.uk/tutorials/swift-nstimer-tutorial-lets-create-a-counter-application/
    var loadTimer: Timer!   //For loading animation
    
    let defaults = UserDefaults.standard
    
    // Logging: https://gist.github.com/vtardia/3f7d17efd7b258e82b62
    var appInfo: Dictionary<NSObject,AnyObject>
    var appName: String!
    var weatherFields: WeatherFields
    
    var whichWeatherFirst = 0

    var locationInformationArray: [[String]] = []

    var weatherArray = [WeatherFields]()
    let locationManager = CLLocationManager()
    var myLatitude = ""
    var myLongitude = ""
    var myCity = ""
    var myState = ""
    
    var firstTime = false
    
    var locationAltitude = "9999"     // meters
    
    override init()
    {
        
        DEFAULT_PREFERENCE_VERSION = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        // Init local parameters
        self.appInfo = CFBundleGetInfoDictionary(CFBundleGetMainBundle()) as Dictionary
        self.appName = appInfo[kCFBundleNameKey] as? String
        
        weatherFields = WeatherFields()
        
        // Init parent
        super.init()
        
        // Other init below...
        defaultPreferences()
        initPrefs()

        // Library/Logs/Meteo.log
        SetCustomLogFilename(self.appName)
        
        let defaults = UserDefaults.standard
        if ((defaults.string(forKey: "logMessages") != nil) &&
            (defaults.string(forKey: "logMessages")! == "1"))
        {
            InfoLog(String(format:"Application %@ starting", self.appName))
        }
        
        if ((defaults.string(forKey: "allowLocation") != nil) &&
            (defaults.string(forKey: "allowLocation")! == "1")) {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    } // init
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        InfoLog("location manager auth status changed to:" )
        switch status {
        case .restricted:
            InfoLog("status restricted")
            _ = "status restricted"
        case .denied:
            InfoLog("status denied")
            _ = "status denied"
            
        case .authorized:
            InfoLog("status authorized")
            let location = locationManager.location
            
            if (location != nil) {
                self.myLatitude = String(format: "%f", location?.coordinate.latitude ?? "")
                self.myLongitude = String(format: "%f", location?.coordinate.longitude ?? "")
                
                // <here>
                locationAltitude = String(format: "%.2f", location?.altitude ?? "")
                
                InfoLog("")
                InfoLog("This stuff is spooky, macOS knowing all this. But we're using parts of it...")
                InfoLog("")
                InfoLog("location data:")
                InfoLog("latitude: " + String(format: "%.4f", location?.coordinate.latitude ?? ""))
                InfoLog("longitude: " + String(format: "%.4f", location?.coordinate.longitude ?? ""))
                InfoLog("altitude: " + String(format: "%.2f", location?.altitude ?? "") + " meters")
                //InfoLog("floor: " + String(format: "%.2f", location?.floor ?? ""))    // Not in macOS
                InfoLog("horizontalAccuracy: " + String(format: "%.2f", location?.horizontalAccuracy ?? "") + " meters")
                InfoLog("verticalAccuracy: " + String(format: "%.2f", location?.verticalAccuracy ?? "") + " meters")
                InfoLog("speed: " + String(format: "%.2f", location?.speed ?? "") + " meters/second")
                InfoLog("course: " + String(format: "%.2f", location?.course ?? "") + "˚")
                
                let geocoder = CLGeocoder()
                // Geocode Location
                if (location != nil) {
                    geocoder.reverseGeocodeLocation(location!) { (placemarks, error) in
                        // Process Response
                        self.processResponse(withPlacemarks: placemarks, error: error)
                    }
                }
            } else {
                InfoLog("Location data not available")
                myCity = "Location unavailable"
            }

        //case .authorizedAlways:
            //InfoLog("status authorized always")
            //_ = "status authorized always"
        default:
        //case .notDetermined:
            InfoLog("status not yet determined")
            _ = "status not yet determined"
        }
        locationManager.stopUpdatingLocation()
    } // locationManager
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        if let error = error {
            InfoLog("Unable to Reverse Geocode Location (\(error))")
            myCity = "Location not available"
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                myCity = placemark.locality ?? "anytown"
                myState = placemark.administrativeArea ?? "??"
                
                // https://developer.apple.com/documentation/corelocation/clplacemark
                InfoLog("")
                InfoLog("placemark data:")
                InfoLog("locality " + (placemark.locality ?? "unknown")) // City name
                InfoLog("administrativeArea " + (placemark.administrativeArea ?? "unknown")) // State/Province name
                
                //InfoLog("location " + (placemark.location ?? "unknown"))
                InfoLog("name " + (placemark.name ?? "unknown"))
                InfoLog("isoCountryCode " + (placemark.isoCountryCode ?? "unknown"))  // ISO Country Code
                InfoLog("country " + (placemark.country ?? "unknown"))  // Country Name
                InfoLog("postalCode " + (placemark.postalCode ?? "unknown"))
                InfoLog("subAdministrativeArea " + (placemark.subAdministrativeArea ?? "unknown"))
                InfoLog("subLocality " + (placemark.subLocality ?? "unknown"))
                InfoLog("thoroughfare " + (placemark.thoroughfare ?? "unknown"))
                InfoLog("subThoroughfare " + (placemark.subThoroughfare ?? "unknown"))
                InfoLog("region " + (placemark.region?.identifier ?? "unknown"))
                //InfoLog("timeZone " + (placemark.timeZone?.identifier ?? "unknown"))   // 10.11
                //InfoLog("postalAddress " + (placemark.postalAddress ?? "unknown")) // 10.13
                InfoLog("inlandWater " + (placemark.inlandWater ?? "unknown"))
                InfoLog("ocean " + (placemark.ocean ?? "unknown"))
                var i = 0
                while (i < placemark.areasOfInterest?.count ?? 0) {
                    InfoLog("areasOfInterest " + (placemark.areasOfInterest?[i] ?? "unknown"))
                    i = i + 1
                }
                InfoLog("")
            } else {
                myCity = "unknown3"
            }
        }
    } // processResponse

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
        canadaGovURL.isHidden = true
        #else
        #endif
        
        statusBarItem = statusBar.statusItem(withLength: -1)
        statusBarItem.menu = menu
        statusBarItem.title = localizedString(forKey: "Loading_") + "..."
        statusBarItem.image = NSImage(named: "Loading-1")!
        loadTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AppDelegate.runTimedCode), userInfo: nil, repeats: true)  //Start animating the menubar icon

        let newItem : NSMenuItem = NSMenuItem(title: localizedString(forKey: "PleaseWait_"), action: #selector(AppDelegate.dummy(_:)), keyEquivalent: "")
        
        newItem.target=self
        menu.addItem(newItem)
        
        addControlOptions()
        initWindowPrefs()

        var launchDelay = 10.0
        if (defaults.string(forKey: "launchDelay") != nil)
        {
            launchDelay = Double(defaults.string(forKey: "launchDelay")!)!
        }
        if ((defaults.string(forKey: "logMessages") != nil) &&
            (defaults.string(forKey: "logMessages")! == "1") &&
            (launchDelay > 0.00))
        {
            InfoLog(String(format:"Sleeping for %.0f second(s) to allow WiFi to get started", launchDelay))
        }
        
        //firstTime = true   // Force TRUE for debuging Preference Pane
        if (firstTime)
        {
            //tabView.activeTab = 4 // Help Panel
            showPreferencePane()
        }

        // Sleep for a few seconds to allow WiFi to get started
        if (launchDelay == 0.0) {
            launchDelay = 0.1
        }
        Timer.scheduledTimer(timeInterval: launchDelay, target: self, selector: #selector(AppDelegate.launchWeather), userInfo: nil, repeats: false)

    } // awakeFromNib
    
    // This gets called when we Wake from sleep. See the setup below
    // https://stackoverflow.com/questions/9247710/what-event-is-fired-when-mac-is-back-from-sleep
    @objc func onWakeNote(note: NSNotification) {
        let defaults = UserDefaults.standard
        var launchDelay = 10.0
        if ((defaults.string(forKey: "logMessages") != nil) &&
            (defaults.string(forKey: "logMessages")! == "1")) {
            InfoLog("Received wake notice: \(note.name)")

            if (defaults.string(forKey: "launchDelay") != nil)
            {
                launchDelay = Double(defaults.string(forKey: "launchDelay")!)!
            }

        }

        if (loadTimer != nil)
        {
            loadTimer.invalidate()
            loadTimer = nil
        }
        
        let uwTimer = myTimer
        if uwTimer == myTimer
        {
            if uwTimer.isValid
            {
                uwTimer.invalidate()
            }
        }
        
        if (launchDelay < 10.0) {
            launchDelay = launchDelay * 2 // Waking up takes twice as long as starting up
        }
        if (launchDelay > 0.0)
        {
            InfoLog(String(format:"Sleeping for %.0f second(s) to allow WiFi to get started", launchDelay))
        }

        // Sleep XX seconds for WiFi to wake up again
        if (launchDelay == 0.0) {
            launchDelay = 0.1
        }
        myTimer = Timer.scheduledTimer(timeInterval: Double(launchDelay), target:self, selector: #selector(AppDelegate.updateWeather), userInfo: nil, repeats: false)
    } // onWakeNote
    
    @objc func launchWeather() {

        // This actually lets us get notified when we Wake from sleep
        // https://stackoverflow.com/questions/9247710/what-event-is-fired-when-mac-is-back-from-sleep
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(onWakeNote(note:)),
            name: NSWorkspace.didWakeNotification, object: nil)

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
                    webVERSION = webVERSION.replacingOccurrences(of: "\n", with: "", options: .regularExpression)
                    if (webVERSION.count > 6) {
                        ErrorLog("http://heat-meteo.sourceforge.net/" + "VERSION2" + " not in the proper format\n" + webVERSION)
                        webVERSION = ""
                    }
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
            let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            var version = ""
            if (bundleVersion.count > 4) {
                version = String(bundleVersion[bundleVersion.startIndex..<bundleVersion.index(bundleVersion.startIndex, offsetBy: 5)])
            }
            
            if ((version > webVERSION) && (bundleVersion.count > 5)) {
                // Once released, don't allow beta's
                version = webVERSION
            } else if ((version == webVERSION) && (bundleVersion.count > 5)) {
                // Allow beta versions until release
                version = ""
            }

            if ((version < webVERSION) && (webVERSION != ""))
            {
                // New version!
                if let url = URL(string: "http://heat-meteo.sourceforge.net/" + "CHANGELOG2")
                {
                    do
                    {
                        whatChanged = try NSString(contentsOf: url, usedEncoding: nil) as String
                        //if (whatChanged[0] == '<') {
                        //  ErrorLog (whatChanged)
                        //}
                    }
                    catch
                    {
                    }
                }
                let myPopup: NSAlert = NSAlert()
                myPopup.messageText = localizedString(forKey: "NewVersionAvailable_") + "\n\n" + whatChanged
                myPopup.informativeText = localizedString(forKey: "Download?_")
                myPopup.alertStyle = NSAlert.Style.warning
                myPopup.addButton(withTitle: localizedString(forKey: "Yes_"))
                
                // http://swiftrien.blogspot.com/2015/03/code-sample-swift-nsalert_5.html
                // If any button is created with the title "Cancel" then that has the key "Escape" associated with it
                myPopup.addButton(withTitle: localizedString(forKey: "Cancel_"))
                let res = myPopup.runModal()
                if res == NSApplication.ModalResponse.alertFirstButtonReturn
                {
                    let myUrl = "http://heat-meteo.sourceforge.net"
                    
                    if let checkURL = URL(string: myUrl as String)
                    {
                        if NSWorkspace.shared.open(checkURL)
                        {
                            InfoLog("New version URL successfully opened:" + (myUrl as String))
                            exit(0)
                        }
                    }
                    else
                    {
                        InfoLog("New Version Invalid URL:" + (myUrl as String))
                    }
                }
            }
        }
        
        var m = (15 as NSNumber)
        var font = NSFont(name: "Tahoma", size: 15)
        if ((defaults.string(forKey: "font") != nil) &&
            (defaults.string(forKey: "fontsize") != nil))
        {
            m = NumberFormatter().number(from: defaults.string(forKey: "fontsize")!)!
            if (defaults.string(forKey: "fontDefault") == "1")
            {
                font = NSFont.systemFont(ofSize: CGFloat(truncating: m))
            }
            else
            {
                font = NSFont(name: defaults.string(forKey: "font")!, size: CGFloat(truncating: m))
            }
        }
        menu.font = font
        
        m = (15 as NSNumber)
        font = NSFont(name: "Tahoma", size: 15)
        if ((defaults.string(forKey: "menuBarFont") != nil) &&
            (defaults.string(forKey: "menuBarFontsize") != nil))
        {
            m = NumberFormatter().number(from: defaults.string(forKey: "menuBarFontsize")!)!
            //            statusBarItem.image = nil
            if (defaults.string(forKey: "menuBarFontDefault") == "1")
            {
                font = NSFont.systemFont(ofSize: CGFloat(truncating: m))
            }
            else
            {
                font = NSFont(name: defaults.string(forKey: "menuBarFont")!, size: CGFloat(truncating: m))
            }
        }
        
        // Todo - Do we have a problem or not?
        // http://stackoverflow.com/questions/19487369/center-two-different-size-font-vertically-in-a-nsattributedstring
        if (webVERSION == "")
        {
            statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                localizedString(forKey: "NetworkFailure_"),
                                                                                                                  attributes:[NSAttributedString.Key.font : font!]))
        }
        else
        {
            statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                localizedString(forKey: "Loading_") + "...",
                                                                                                                  attributes:[NSAttributedString.Key.font : font!]))
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
    } // launchWeather
    
    @objc func runTimedCode()  //Animate the icon while loading
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
    
    func myMenuItem(_ string: String, url: String?, key: String, newItem: inout NSMenuItem)
    {
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
                                                                                                    attributes:[NSAttributedString.Key.font : NSFont.systemFont(ofSize: CGFloat(truncating: m))]))
        }
        else
        {
            var textColor = NSColor()
            if #available(iOS 10, *)
            {
                ErrorLog(String(format:"iOS 10", self.appName))
                textColor = NSColor(red: CGFloat(Float(defaults.string(forKey: "fontRedText")!)!)/255,
                                    green: CGFloat(Float(defaults.string(forKey: "fontGreenText")!)!)/255,
                                    blue: CGFloat(Float(defaults.string(forKey: "fontBlueText")!)!)/255, alpha: 1.0)
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
                                                                                                        attributes:[NSAttributedString.Key.font : NSFont(name: defaults.string(forKey: "font")!, size: CGFloat(truncating: m))!,
                                                                                                                    NSAttributedString.Key.foregroundColor : textColor]))
            }
            else
            {
                var backgroundColor = NSColor()
                if #available(iOS 10, *)
                {
                    backgroundColor = NSColor(
                        red: CGFloat(Float(defaults.string(forKey: "fontRedBackground")!)!)/255,
                        green: CGFloat(Float(defaults.string(forKey: "fontGreenBackground")!)!)/255,
                        blue: CGFloat(Float(defaults.string(forKey: "fontBlueBackground")!)!)/255, alpha: 1.0)
                }
                else
                {
                    backgroundColor = NSColor(
                        red: CGFloat(Float(defaults.string(forKey: "fontRedBackground")!)!),
                        green: CGFloat(Float(defaults.string(forKey: "fontGreenBackground")!)!),
                        blue: CGFloat(Float(defaults.string(forKey: "fontBlueBackground")!)!), alpha: 1.0)
                }
                
                attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                    string,
                                                                                                        attributes:[NSAttributedString.Key.font : NSFont(name: defaults.string(forKey: "font")!, size: CGFloat(truncating: m))!,
                                                                                                                    NSAttributedString.Key.foregroundColor : textColor,
                                                                                                                    NSAttributedString.Key.backgroundColor : backgroundColor]))
            }
        }
        newItem.attributedTitle = attributedTitle
        newItem.target=self
        
    } // myMenuItem
    
    func addControlOptions()
    {
        var controlsMenu = NSMenu()
        var newItem = NSMenuItem()
        if ((defaults.string(forKey: "controlsInSubmenu") == nil) || (defaults.string(forKey: "controlsInSubmenu")! == "1"))
        {
            myMenuItem(localizedString(forKey: "Controls_"), url: nil, key: "", newItem: &newItem)
            menu.addItem(newItem)
            menu.setSubmenu(controlsMenu, for: newItem)
        }
        else
        {
            controlsMenu = menu
        }
        myMenuItem(localizedString(forKey: "Refresh_"), url: "weatherRefresh:", key: "r", newItem: &newItem)
        controlsMenu.addItem(newItem)
        
        myMenuItem(localizedString(forKey: "Preferences_"), url: "preferences:", key: ",", newItem: &newItem)
        controlsMenu.addItem(newItem)
        
        // https://gist.github.com/ericdke/75a42dc8d4c5f61df7d9
        myMenuItem(localizedString(forKey: "Relaunch_"), url: "Relaunch:", key: "`", newItem: &newItem)
        controlsMenu.addItem(newItem)
        
        myMenuItem(localizedString(forKey: "Quit_"), url: "terminate:", key: "q", newItem: &newItem)
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
        weatherFields.windGust = ""
        weatherFields.humidity = ""
        weatherFields.pressure = ""
        weatherFields.visibility = ""
        weatherFields.UVIndex = ""
        weatherFields.sunrise = ""
        weatherFields.sunset = ""
        weatherFields.currentCode = ""
        weatherFields.currentTemp = ""
        weatherFields.currentConditions = ""
        weatherFields.weatherTag = ""
        weatherFields.URL = ""
        
        // Resolve memory leak
        weatherFields.forecastCode.removeAll()
        weatherFields.forecastDate.removeAll()
        weatherFields.forecastDay.removeAll()
        weatherFields.forecastHigh.removeAll()
        weatherFields.forecastLow.removeAll()
        weatherFields.forecastConditions.removeAll()
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
        
    } // initWeatherFields
    
    func loadWeatherData(weatherDataSource: [String], city: [String], displayCity: [String], APIKey1: [String], APIKey2: [String], altitude: [String]) {

        //let group = DispatchGroup()
        
        var secondarys = whichWeatherFirst
        if (secondarys > MAX_LOCATIONS - 1)
        {
            secondarys = 0
        }
        
        // Resolve memory leak
        weatherArray.removeAll()

        var index = 0
        repeat
        {
            if (city[secondarys] != "")
            {
                initWeatherFields(weatherFields: &weatherFields)
                weatherArray.insert(weatherFields, at: index)

                var displayCityName = displayCity[secondarys]
                if (displayCityName == "")
                {
                    displayCityName = city[secondarys]
                }
                processWeatherSource(weatherDataSource[secondarys],
                                     inputCity: city[secondarys],
                                     displayCity: displayCity[secondarys],
                                     APIKey1: APIKey1[secondarys],
                                     APIKey2: APIKey2[secondarys],
                                     weatherFields: &weatherArray[index])
                index = index + 1
            }
            secondarys = secondarys + 1
            if (secondarys > MAX_LOCATIONS - 1)
            {
                secondarys = 0
            }
        } while (secondarys != whichWeatherFirst)

        self.displayWeatherData(city: city,
                                displayCity: displayCity,
                                weatherDataSource: weatherDataSource,
                                menu: self.menu,
                                altitude: altitude)

    } // loadWeatherData
    
    func displayWeatherData(city: [String],
                            displayCity: [String],
                            weatherDataSource: [String],
                            menu: NSMenu,
                            altitude: [String]) {
        
        updateMenuWithPrimaryLocation(weatherArray[0],
                                      cityName: (city[whichWeatherFirst]),
                                      displayCityName: (displayCity[whichWeatherFirst]),
                                      menu: menu,
                                      weatherDataSource: weatherDataSource[whichWeatherFirst],
                                      altitude: altitude[whichWeatherFirst])
        
        var bFirstTime = 0
        var secondarys = whichWeatherFirst + 1
        if (secondarys > MAX_LOCATIONS - 1)
        {
            secondarys = 0
        }
        
        var index = 1
        while (secondarys != whichWeatherFirst)
        {
            if (city[secondarys] != "")
            {
                if (bFirstTime == 0)
                {
                    menu.addItem(NSMenuItem.separator())
                }
                bFirstTime = 1
                
                var displayCityName = displayCity[secondarys]
                if (displayCityName == "")
                {
                    displayCityName = city[secondarys]
                }
                
                if (weatherArray.count > index) {
                    updateMenuWithSecondaryLocation(weatherArray[index],
                                                    cityName: (city[secondarys]),
                                                    displayCityName: (displayCityName),
                                                    menu: menu,
                                                    weatherDataSource: weatherDataSource[secondarys],
                                                    altitude: altitude[secondarys])
                }
                index = index + 1
            }
            secondarys = secondarys + 1
            if (secondarys > MAX_LOCATIONS - 1)
            {
                secondarys = 0
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        addControlOptions()

    } // displayWeatherData

    @objc func updateWeather()
    {
        let defaults = UserDefaults.standard
        
        if (loadTimer != nil)
        {
            loadTimer.invalidate()
            loadTimer = nil
        }
        
        let uwTimer = myTimer
        if uwTimer == myTimer
        {
            if uwTimer.isValid
            {
                uwTimer.invalidate()
            }
        }
        
        // whichWeatherFirst
        if  (defaults.string(forKey: "rotateWeatherLocations") == "0")
        {
            whichWeatherFirst = 0
        }
        
        var weatherDataSource = [String]()
        var city = [String]()
        var displayCity = [String]()
        var APIKey1 = [String]()
        var APIKey2 = [String]()
        var Altitude = [String]()

        var i = 0
        
        while (i < MAX_LOCATIONS)
        {
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
            weatherDataSource.insert(defaults.string(forKey: String(format:"weatherSource_%d", i + 1))!, at: i)
            Altitude.insert("9999", at: i)
            if ((city[i] == "<" + localizedString(forKey: "here") + ">") ||
                (city[i] == "<here>")) {
                Altitude[i] = locationAltitude
                if ((weatherDataSource[i] == YAHOO_WEATHER) ||
                    (weatherDataSource[i] == AERISWEATHER) ||
                    (weatherDataSource[i] == CANADAGOV)) {
                    city[i] = myCity + "," + myState
                } else if ((weatherDataSource[i] == WORLDWEATHERONLINE)) {
                    city[i] = myCity + " " + myState
                } else{
                    city[i] = myLatitude + "," + myLongitude
                }
                if (displayCity[i] == "") {
                    displayCity[i] = myCity + " " + myState
                }
            }
            if ((displayCity[i] == "") && (city[i] != "")) {
                displayCity[i] = city[i]
            }
            APIKey1.insert(defaults.string(forKey: String(format:"API_Key_Data1_%d", i + 1))!, at: i)
            APIKey2.insert(defaults.string(forKey: String(format:"API_Key_Data2_%d", i + 1))!, at: i)
            i = i + 1
        }

        let saveWWF = whichWeatherFirst
        while (city[whichWeatherFirst] == "") {
            whichWeatherFirst += 1
            if (whichWeatherFirst > MAX_LOCATIONS - 1)
            {
                whichWeatherFirst = 0
            }
            if (whichWeatherFirst == saveWWF) {
                // We are  in a loop!

                statusBarItem = statusBar.statusItem(withLength: -1)
                statusBarItem.menu = menu
                statusBarItem.title = "9999°"

                menu.removeAllItems()
                addControlOptions()

                return
            }
        }
        
        // TODO: Launch all weather sources as background task (async/in parallel)
        // Wait for all to complete then build menus
        
        loadWeatherData(weatherDataSource: weatherDataSource, city: city, displayCity: displayCity, APIKey1: APIKey1, APIKey2: APIKey2, altitude: Altitude)
        
        var updateFrequency = defaults.string(forKey: "updateFrequency")
        if (updateFrequency == "0") {
            updateFrequency = "0.1"
        }
        myTimer = Timer.scheduledTimer(timeInterval: Double(updateFrequency!)!*60, target:self, selector: #selector(AppDelegate.updateWeather), userInfo: nil, repeats: false)
        
        // whichWeatherFirst
        if ((defaults.string(forKey: "rotateWeatherLocations") != nil) &&
            (defaults.string(forKey: "rotateWeatherLocations") == "1"))
        {
            whichWeatherFirst = whichWeatherFirst + 1
            if (whichWeatherFirst > MAX_LOCATIONS - 1)
            {
                whichWeatherFirst = 0
            }
        }

    } // updateWeather
    
    func processWeatherSource(_ weatherDataSource: String,
                              inputCity: String,
                              displayCity: String,
                              APIKey1: String,
                              APIKey2: String,
                              weatherFields: inout WeatherFields) {
        weatherFields.currentTemp = "9999"
        
        // https://german.stackexchange.com/questions/4992/conversion-table-for-diacritics-e-g-ü-→-ue
        var escapedCity = inputCity.replacingOccurrences(of: "\u{00dc}", with: "UE")
        escapedCity = escapedCity.replacingOccurrences(of: "\u{00c4}", with: "AE")
        escapedCity = escapedCity.replacingOccurrences(of: "\u{00d6}", with: "OE")
        escapedCity = escapedCity.replacingOccurrences(of: "\u{00fc}", with: "ue")
        escapedCity = escapedCity.replacingOccurrences(of: "\u{00e4}", with: "ae")
        escapedCity = escapedCity.replacingOccurrences(of: "\u{00f6}", with: "oe")
        escapedCity = escapedCity.replacingOccurrences(of: "\u{00df}", with: "ss")

        if (weatherDataSource == YAHOO_WEATHER) {
            //yahooWeatherAPI.setRadarWind(radarWindow)
            yahooWeatherAPI.beginParsing(escapedCity,
                                              displayCity: displayCity,
                                              APIKey1: APIKey1,
                                              APIKey2: APIKey2,
                                              weatherFields: &weatherFields)
        }
        else if (weatherDataSource == OPENWEATHERMAP)
        {
            //openWeatherMapAPI.setRadarWind(radarWindow)
            openWeatherMapAPI.beginParsing(escapedCity,
                                           APIKey1: APIKey1,
                                           APIKey2: APIKey2,
                                           weatherFields: &weatherFields)
        }
        else if (weatherDataSource == THEWEATHER)
        {
            //theWeatherAPI.setRadarWind(radarWindow)
            theWeatherAPI.beginParsing(escapedCity,
                                       APIKey1: APIKey1,
                                       APIKey2: APIKey2,
                                       weatherFields: &weatherFields)
        }
        else if (weatherDataSource == WEATHERUNDERGROUND)
        {
            //weatherUndergroundAPI.setRadarWind(radarWindow)
            weatherUndergroundAPI.beginParsing(escapedCity,
                                               APIKey1: APIKey1,
                                               APIKey2: APIKey2,
                                               weatherFields: &weatherFields)
        }
        else if (weatherDataSource == DARKSKY)
        {
            //darkSkyAPI.setRadarWind(radarWindow)
            darkSkyAPI.beginParsing(escapedCity,
                                    APIKey1: APIKey1,
                                    APIKey2: APIKey2,
                                    weatherFields: &weatherFields)
        }
        else if (weatherDataSource == AERISWEATHER)
        {
            //aerisWeatherAPI.setRadarWind(radarWindow)
            aerisWeatherAPI.beginParsing(escapedCity,
                                         APIKey1: APIKey1,
                                         APIKey2: APIKey2,
                                         weatherFields: &weatherFields)
        }
        else if (weatherDataSource == WORLDWEATHERONLINE)
        {
            //worldWeatherOnlineAPI.setRadarWind(radarWindow)
            worldWeatherOnlineAPI.beginParsing(escapedCity,
                                               APIKey1: APIKey1,
                                               APIKey2: APIKey2,
                                               weatherFields: &weatherFields)
        }
        else if (weatherDataSource == APIXU)
        {
            //ApiXUApi.setRadarWind(radarWindow)
            ApiXUApi.beginParsing(escapedCity,
                                  APIKey1: APIKey1,
                                  APIKey2: APIKey2,
                                  weatherFields: &weatherFields)
        }
        else if (weatherDataSource == CANADAGOV)
        {
            //canadaWeatherAPI.setRadarWind(radarWindow)
            canadaWeatherAPI.beginParsing(escapedCity,
                                  APIKey1: APIKey1,
                                  APIKey2: APIKey2,
                                  weatherFields: &weatherFields)
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
        
        return
    } // processWeatherSource
    
    func setImage(_ weatherCode: String, weatherDataSource: String) -> NSImage
    {
        /*
         19    dust
         20    foggy
         22    smoky
         23    blustery
         25    cold                        Temperature-2
         36    hot                         Temperature-9
         3200    not available
         
         */
        
        //InfoLog("In setImage")
        //InfoLog("weatherCode: " + weatherCode + ", weatherDataSource: " + weatherDataSource)
        
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
            if ((weatherCode == "32") ||
                (weatherCode == "36")){
                imageName = "Sun"
            }
            else if ((weatherCode == "26") ||
                (weatherCode == "27") ||
                (weatherCode == "28") ||
                (weatherCode == "29") ||
                (weatherCode == "30") ||
                (weatherCode == "33") ||
                (weatherCode == "34"))
            {
                imageName = "Cloudy"
            }
            else if ((weatherCode == "09") ||
                (weatherCode == "9") ||
                (weatherCode == "11") ||
                (weatherCode == "12") ||
                (weatherCode == "39") ||
                (weatherCode == "40") ||
                (weatherCode == "45"))
            {
                imageName = "Rain"
            }
            else if ((weatherCode == "03") ||
                (weatherCode == "04") ||
                (weatherCode == "3") ||
                (weatherCode == "4") ||
                (weatherCode == "37") ||
                (weatherCode == "38") ||
                (weatherCode == "47"))
            {
                imageName = "Thunderstorm"
            }
            else if ((weatherCode == "06") ||
                (weatherCode == "08") ||
                (weatherCode == "6") ||
                (weatherCode == "8") ||
                (weatherCode == "10") ||
                (weatherCode == "17") ||
                (weatherCode == "18") ||
                (weatherCode == "35"))
            {
                imageName = "Sleet"
            }
            else if ((weatherCode == "05") ||
                (weatherCode == "07") ||
                (weatherCode == "5") ||
                (weatherCode == "7") ||
                (weatherCode == "13") ||
                (weatherCode == "14") ||
                (weatherCode == "15") ||
                (weatherCode == "16") ||
                (weatherCode == "25") ||
                (weatherCode == "41") ||
                (weatherCode == "42") ||
                (weatherCode == "43") ||
                (weatherCode == "46"))
            {
                imageName = "Snow"
            }
            else if ((weatherCode == "00") ||
                (weatherCode == "19") ||
                (weatherCode == "20") ||
                (weatherCode == "21") ||
                (weatherCode == "22") ||
                (weatherCode == "0"))
            {
                imageName = "Hazy"
            }
            else if ((weatherCode == "31") ||
                (weatherCode == "31"))
            {
                imageName = "Moon"
            }
            else if ((weatherCode == "01") ||
                (weatherCode == "1") ||
                (weatherCode == "2") ||
                (weatherCode == "02"))
            {
                imageName = "Hurricane"
            }
            else if ((weatherCode == "23") ||
                (weatherCode == "24"))
            {
                imageName = "Wind"
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
            imageName = weatherCode

        } else if (weatherDataSource == CANADAGOV)
        {
            // http://dd.weather.gc.ca/citypage_weather/docs/current_conditions_icon_code_descriptions_e.csv
            if ((weatherCode == "02") ||
                (weatherCode == "03") ||
                (weatherCode == "10") ||
                (weatherCode == "32") ||
                (weatherCode == "33"))
            {
                imageName = "Cloudy"
            }
            else if ((weatherCode == "08") ||
                (weatherCode == "17") ||
                (weatherCode == "18") ||
                (weatherCode == "38"))
            {
                imageName = "Flurries"
            }
            else if ((weatherCode == "23") ||
                (weatherCode == "24") ||
                (weatherCode == "44") ||
                (weatherCode == "38") ||
                (weatherCode == "44") ||
                (weatherCode == "45"))
            {
                imageName = "Hazy"
            }
            else if ((weatherCode == "06") ||
                (weatherCode == "07") ||
                (weatherCode == "11") ||
                (weatherCode == "12") ||
                (weatherCode == "14") ||
                (weatherCode == "15") ||
                (weatherCode == "19") ||
                (weatherCode == "24") ||
                (weatherCode == "28") ||
                (weatherCode == "37") ||
                (weatherCode == "39") ||
                (weatherCode == "46") ||
                (weatherCode == "47"))
            {
                imageName = "Rain"
            }
            else if ((weatherCode == "14") ||
                (weatherCode == "26") ||
                (weatherCode == "27"))
            {
                imageName = "Sleet"
            }
            else if ((weatherCode == "16") ||
                (weatherCode == "17") ||
                (weatherCode == "18") ||
                (weatherCode == "25") ||
                (weatherCode == "27") ||
                (weatherCode == "28") ||
                (weatherCode == "40"))
            {
                imageName = "Snow"
            }
            else if ((weatherCode == "00") ||
                (weatherCode == "01") ||
                (weatherCode == "30") ||
                (weatherCode == "31"))
            {
                imageName = "Sun"
            }
            else if ((weatherCode == "41") ||
                (weatherCode == "42") ||
                (weatherCode == "48"))
            {
                imageName = "Tornado"
            }
            else if ((weatherCode == "43") ||
                (weatherCode == "45"))
            {
                imageName = "Wind"
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
                (weatherCode == "cloudy") ||
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
            else if (weatherCode == "clear-night")
            {
                imageName = "Moon"
            }
            else if (weatherCode == "wind")
            {
                imageName = "Wind"
            }
            else if ((weatherCode == "rain") ||
                (weatherCode == "rain") ||
                (weatherCode == "chancerain") ||
                (weatherCode == "nt_chancerain") ||
                (weatherCode == "nt_rain"))
            {
                imageName = "Rain"
            }
            else if ((weatherCode == "cloudy"))
            {
                imageName = "Cloudy"
            }
        }
        
        if (weatherCode == "") {
            imageName = "Unknown"
        }
        if (imageName == "Unknown")
        {
            ErrorLog(String(format:localizedString(forKey: "InvalidWeatherCode_") + " : weatherDataSource=" + weatherDataSource + ", weatherCode=" + weatherCode))
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
        if ((temp == "") || (temp == "-")) {
            return "---"
        }
        var formattedTemp = String(Int((temp as NSString).doubleValue))
        
        if (defaults.string(forKey: "degreesUnit")! == "1")
        {
            // http://www.rapidtables.com/convert/temperature/how-fahrenheit-to-celsius.htm
            if (temp == "9999") {
                formattedTemp = temp // Leave the bogus temp alone
            } else {
                formattedTemp = String(Int(((temp as NSString).doubleValue - 32) / 1.8))
            }
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
        
        // Fix (Yahoo bug) myTime = "7:7 am"
        var string = myTime
        let part1 = string.split(separator: ":")
        let part2 = String(part1[1]).split(separator: " ")
        if ( 1 == String(part2[0]).count ) {
            string = String(part1[0]) + ":0" + String(part1[1])
        }
        
        // create dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.local
        let date = dateFormatter.date(from: string)
        if (date == nil)
        {
            return string
        }
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.string(from: date!)
    } // convertUTCtoHHMM
    
    func convertUTCtoEEE(_ myTime: String) -> String
    {
        // EEE is Mon, Tue, Wed, etc.
        // create dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone.local
        let date = dateFormatter.date(from: myTime)
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "EEE"
        return formatDay(dateFormatter.string(from: date!))
    } // convertUTCtoEEE
    
    func formatWindSpeed(_ speed: String, direction: String, gust: String) -> String {
        let defaults = UserDefaults.standard
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
        let speed__ = String(Int((speed as NSString).doubleValue))
        let gspeed__ = String(Int((gust as NSString).doubleValue))
        
        var gust = ""
        if ((gspeed__ != "") && (gspeed__ != "0") && (speed__ != gspeed__)) {
            gust = "-"
            if (defaults.string(forKey: "speedUnit")! == "0") {
                gust += gspeed__
            } else if (defaults.string(forKey: "speedUnit")! == "1") {
                gust += String(Int((gspeed__ as NSString).doubleValue * 1.6094))
            } else if (defaults.string(forKey: "speedUnit")! == "2") {
                gust += String(Int((gspeed__ as NSString).doubleValue * 0.44704))
            } else if (defaults.string(forKey: "speedUnit")! == "3") {
                gust += String(Int((gspeed__ as NSString).doubleValue * 1.15077944802))
            }
        }
        
        if (defaults.string(forKey: "speedUnit")! == "0") {
            formattedWindSpeed += speed__ + gust + " " + localizedString(forKey: "mph_")
        } else if (defaults.string(forKey: "speedUnit")! == "1") {
            formattedWindSpeed += String(Int((speed__ as NSString).doubleValue * 1.6094)) + gust + " " + localizedString(forKey: "km/h_")
        } else if (defaults.string(forKey: "speedUnit")! == "2") {
            formattedWindSpeed += String(Int((speed__ as NSString).doubleValue * 0.44704)) + gust + " " + localizedString(forKey: "m/s_")
        } else if (defaults.string(forKey: "speedUnit")! == "3") {
            formattedWindSpeed += String(Int((speed__ as NSString).doubleValue * 1.15077944802)) + gust + " " + localizedString(forKey: "Knots_")
        }
        return formattedWindSpeed
    } // formatWindSpeed
    
    func formatPressure(_ pressure: String, altitude: String) -> String {
        // input is millibars
        let defaults = UserDefaults.standard
        var formattedPressure = ""
        // TODO - This is stupid - double conversion for most cases
        var pressure__ = String(format: "%.2f", (pressure as NSString).doubleValue / 33.8637526) // mbar -> Inches
        
        // Convert QFE to QNH
        /* 1 inch mercury is approximately equal to 900 feet. This calculation is therefore also approximate but is
            good for airfield elevations to several hundred feet since we round to the nearest hundredth inches.
        
            Divide the airfield altitude in feet by 900 to get the number of inches above MSL.
            Add this to the QFE to get QNH or subtract it from QNH to get QFE.
        
            For example, the airfield elevation is 300 feet. Diving by 900 gives us 0.33r.
            The QFE is 30.12. Add 0.33 to get 30.45 which is the QNH.
        */
        if ((defaults.string(forKey: "convertQFEtoQNH")! == "1") &&
            (altitude != "9999")) {
            // First convert Meters to Feet
            var meters = Double(altitude)
            meters = Double(altitude)
            let diffQFE = (meters! * 3.2808) / 900.0
            let QFE = (Double(pressure__))!
            let QNH = QFE + diffQFE
            pressure__ = String(format: "%.2f", QNH)
        }
        
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
            formattedPressure += String(Int((pressure__ as NSString).doubleValue * 33.8637526)) + " " + localizedString(forKey: "hPa_")
        }
        else if (defaults.string(forKey: "pressureUnit")! == "4")
        {
            formattedPressure += String(Int((pressure__ as NSString).doubleValue * 25.4)) + " " + localizedString(forKey: "mmHg")
        }
        return formattedPressure
    } // formatPressure
    
    func formatVisibility(_ distance: String) -> String {
        // https://www.rapidtables.com/convert/length/mile-to-km.html
        let defaults = UserDefaults.standard
        var formattedVisibility = ""
        if (defaults.string(forKey: "distanceUnit")! == "0") {
            formattedVisibility += distance + " " + localizedString(forKey: "Miles_")
        } else if (defaults.string(forKey: "distanceUnit")! == "1") {
            formattedVisibility += String(Int((distance as NSString).doubleValue * 5280.0)) + " " + localizedString(forKey: "Feet_")
        } else if (defaults.string(forKey: "distanceUnit")! == "2") {
            formattedVisibility += String(Int((distance as NSString).doubleValue * 1.609344)) + " " + localizedString(forKey: "kilometers_")
        } else if (defaults.string(forKey: "distanceUnit")! == "3") {
            formattedVisibility += String(Int((distance as NSString).doubleValue * 1609.344)) + " " + localizedString(forKey: "meters_")
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
    
    func updateMenuWithPrimaryLocation(_ weatherFields: WeatherFields, cityName: String, displayCityName: String, menu: NSMenu, weatherDataSource: String, altitude: String) {
        
        var newItem = NSMenuItem()
        DebugLog(String(format:"in updateMenuWithPrimaryLocation: %@", cityName))
        
        var m = (15 as NSNumber)
        var font = NSFont(name: "Tahoma", size: 15)
        if ((defaults.string(forKey: "menuBarFont") != nil) &&
            (defaults.string(forKey: "menuBarFontsize") != nil))
        {
            m = NumberFormatter().number(from: defaults.string(forKey: "menuBarFontsize")!)!
            if (defaults.string(forKey: "menuBarFontDefault") == "1")
            {
                font = NSFont.systemFont(ofSize: CGFloat(truncating: m))
            }
            else
            {
                font = NSFont(name: defaults.string(forKey: "menuBarFont")!, size: CGFloat(truncating: m))
            }
        }
        
        if (isConnectedToNetwork())
        {
            NoInternetConnectivity = 0
            if (weatherFields.currentTemp != "")
            {
                var displayCity = displayCityName
                if (displayCity == "")
                {
                    displayCity = cityName
                }
                
                if (defaults.string(forKey: "displayWeatherIcon")! == "1")
                {
                    statusBarItem.image = nil
                    
                    statusBarItem.image = setImage(weatherFields.currentCode as String, weatherDataSource: weatherDataSource)
                }
                else
                {
                    if (loadTimer != nil)
                    {
                        loadTimer.invalidate()
                        loadTimer = nil
                    }
                    
                    statusBarItem.image = nil
                }
                
                var statusTitle = ""
                
                if (defaults.string(forKey: "displayCityName")! == "1")
                {
                    statusTitle = displayCity + " "
                }
                if (defaults.string(forKey: "displayFeelsLike") == "1") {
                    statusTitle = statusTitle + calculateFeelsLike(weatherFields.currentTemp, sWindspeed: weatherFields.windSpeed, sRH: weatherFields.humidity)
                } else
                {
                    statusTitle = statusTitle + formatTemp((weatherFields.currentTemp as String))
                }

                if (defaults.string(forKey: "displayHumidity")! == "1")
                {
                    statusTitle = statusTitle + "/" + formatHumidity((weatherFields.humidity as String))
                }
                
                if (defaults.string(forKey: "menuBarFontDefault") == "1")
                {
                    statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string: statusTitle,
                                                                                                                          attributes:[NSAttributedString.Key.font : font!]))
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
                        textColor = NSColor(red: CGFloat(Float(defaults.string(forKey: "menuBarFontRedText")!)!),
                                            green: CGFloat(Float(defaults.string(forKey: "menuBarFontGreenText")!)!),
                                            blue: CGFloat(Float(defaults.string(forKey: "menuBarFontBlueText")!)!),
                                            alpha: 1.0)
                    }
                    
                    if (defaults.string(forKey: "menuBarFontTransparency")! == "1")
                    {
                        statusBarItem.attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string: statusTitle,
                                                                                                                              attributes:[NSAttributedString.Key.font : font!,
                                                                                                                                          NSAttributedString.Key.foregroundColor : textColor]))
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
                                                                                                  attributes:[NSAttributedString.Key.font : font!,
                                                                                                              NSAttributedString.Key.foregroundColor : textColor,
                                                                                                              NSAttributedString.Key.backgroundColor : backgroundColor]))
                    }
                }
            }
        }
        else
        {
            if (NoInternetConnectivity == 0)
            {
                var textColor = NSColor()
                textColor = NSColor(red: CGFloat(1),
                                    green: CGFloat(1),
                                    blue: CGFloat(1),
                                    alpha: 1.0)
                
                var backgroundColor = NSColor()
                backgroundColor = NSColor(
                    red: CGFloat(0),
                    green: CGFloat(0),
                    blue: CGFloat(0),
                    alpha: 1.0)

                let attributedTitle: NSMutableAttributedString
                attributedTitle = NSMutableAttributedString(attributedString: NSMutableAttributedString(string:
                    localizedString(forKey: "NoInternetConnectivity_"),
                                                                                                        attributes:[NSAttributedString.Key.font : NSFont(name: defaults.string(forKey: "font")!, size: CGFloat(truncating: m))!,
                                                                                                                    NSAttributedString.Key.foregroundColor : textColor,
                                                                                                                    NSAttributedString.Key.backgroundColor : backgroundColor]))
                
                ErrorLog(self.appName + ": " + localizedString(forKey: "NoInternetConnectivity_"))
                
                let newItem = NSMenuItem()
                newItem.attributedTitle = attributedTitle
                newItem.target=self
                menu.addItem(newItem)
                
                NoInternetConnectivity = 1
            }
        }

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
            
            // Need to incorporate currentLink
            myMenuItem(city, url: "openWeatherURL:", key: "", newItem: &newItem)
            
            // http://stackoverflow.com/questions/24200888/any-way-to-replace-characters-on-swift-string
            var myURL = ""
            myURL = weatherFields.URL as String
            let replaced = myURL.replacingOccurrences(of: " ", with: "-")
            //let replaced = String(myURL.characters.map {
            //    $0 == " " ? "-" : $0
            //    })
            
            newItem.representedObject = replaced
            menu.addItem(newItem)
            
            var statusTitle = String()
            var sourceURL = ""
            if (weatherDataSource == YAHOO_WEATHER)
            {
                statusTitle = localizedString(forKey: "ProvidedBy_") + " Yahoo!"
            }
            else if (weatherDataSource == OPENWEATHERMAP)
            {
                statusTitle = localizedString(forKey: "ProvidedBy_") + " OpenWeather"
            }
            else if (weatherDataSource == THEWEATHER)
            {
                statusTitle = localizedString(forKey: "ProvidedBy_") + " TheWeather"
            }
            else if (weatherDataSource == WEATHERUNDERGROUND)
            {
                statusTitle = localizedString(forKey: "ProvidedBy_") + " WUnderground"
                sourceURL = "https://www.wunderground.com/weather/api/d/docs?d=resources/logo-usage-guide"
            }
            else if (weatherDataSource == DARKSKY)
            {
                statusTitle = localizedString(forKey: "PoweredBy_") + " Dark Sky"
                sourceURL = "https://darksky.net/poweredby/"
            }
            else if (weatherDataSource == AERISWEATHER)
            {
                statusTitle = localizedString(forKey: "ProvidedBy_") + " AERIS Weather"
                sourceURL = "https://www.aerisweather.com/attribution/"
            }
            else if (weatherDataSource == WORLDWEATHERONLINE)
            {
                statusTitle = localizedString(forKey: "ProvidedBy_") + " World Weather Online"
            }
            else if (weatherDataSource == APIXU)
            {
                statusTitle = localizedString(forKey: "PoweredBy_") + " APIXU"
                sourceURL = "https://www.apixu.com/weather/"
            }
            else if (weatherDataSource == CANADAGOV)
            {
                statusTitle = localizedString(forKey: "ProvidedBy_") + " Environment Canada"
            }
            else
            {
                statusTitle = "WeatherSource unknown"
            }
            if (sourceURL == "")
            {
                myMenuItem(statusTitle, url: nil, key: "", newItem: &newItem)
            }
            else
            {
                myMenuItem(statusTitle, url: "openWeatherURL:", key: "", newItem: &newItem)
                newItem.representedObject = sourceURL
            }
            menu.addItem(newItem)
            
            var currentForecastMenu = NSMenu()
            
            if (defaults.string(forKey: "currentWeatherInSubmenu")! == "1") {
                myMenuItem(localizedString(forKey: "currentConditions_") as String, url: nil, key: "", newItem: &newItem)
                menu.addItem(newItem)
                menu.setSubmenu(currentForecastMenu, for: newItem)
            } else {
                currentForecastMenu = menu
                menu.addItem(NSMenuItem.separator())
            }
            
            currentConditions(weatherFields, cityName: displayCityName, currentForecastMenu: currentForecastMenu, altitude: altitude)
            
            //newItem = myMenuItem(localizedString(forKey: "RadarImage_"), url: "showRadar:", key: "")
            newItem.representedObject = weatherFields.weatherTag as String
            //currentForecastMenu.addItem(newItem)
            
            if ((defaults.string(forKey: "viewExtendedForecast")! == "1") &&
                (weatherFields.forecastCounter > 0)) {
                var extendedForecastMenu = NSMenu()
                
                if (defaults.string(forKey: "extendedForecastInSubmenu")! == "1") {
                    myMenuItem(localizedString(forKey: "ExtendedForecast_"), url: nil, key: "", newItem: &newItem)
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
                                         weatherDataSource: String,
                                         altitude: String) {
        
        var newItem = NSMenuItem()
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
        if (defaults.string(forKey: "displayFeelsLike") == "1") {
            statusTitle = statusTitle + " " + calculateFeelsLike(weatherFields.currentTemp, sWindspeed: weatherFields.windSpeed, sRH: weatherFields.humidity)
        } else
        {
            statusTitle = statusTitle + " " + formatTemp((weatherFields.currentTemp as String))
        }
        if (defaults.string(forKey: "displayHumidity")! == "1") {
            if (weatherFields.humidity != "") {
                statusTitle = statusTitle + "/" + formatHumidity((weatherFields.humidity as String))
            }
        }

        myMenuItem(statusTitle, url: "openWeatherURL:", key: "", newItem: &newItem)
        if (weatherFields.currentCode != "") {
            newItem.image = setImage(weatherFields.currentCode as String, weatherDataSource: weatherDataSource)
        }
        
        // http://stackoverflow.com/questions/24200888/any-way-to-replace-characters-on-swift-string
        var myURL = ""
        myURL = weatherFields.URL as String
        let replaced = myURL.replacingOccurrences(of: " ", with: "-")
        //let replaced = String(myURL.characters.map {
        //    $0 == " " ? "-" : $0
        //    })
        
        newItem.representedObject = replaced
        menu.addItem(newItem)
        
        let newLocation = NSMenu()
        menu.setSubmenu(newLocation, for: newItem)
        
        var currentForecastMenu = NSMenu()
        
        if (defaults.string(forKey: "currentWeatherInSubmenu")! == "1") {
            myMenuItem(localizedString(forKey: "currentConditions_") as String, url: nil, key: "", newItem: &newItem)
            newItem.target=self
            newLocation.addItem(newItem)
            newLocation.setSubmenu(currentForecastMenu, for: newItem)
        } else {
            currentForecastMenu = newLocation
            newLocation.addItem(NSMenuItem.separator())
        }
        
        var sourceURL = ""
        if (weatherDataSource == YAHOO_WEATHER)
        {
            statusTitle = localizedString(forKey: "ProvidedBy_") + " Yahoo!"
        }
        else if (weatherDataSource == OPENWEATHERMAP)
        {
            statusTitle = localizedString(forKey: "ProvidedBy_") + " OpenWeather"
        }
        else if (weatherDataSource == THEWEATHER)
        {
            statusTitle = localizedString(forKey: "ProvidedBy_") + " TheWeather"
        }
        else if (weatherDataSource == WEATHERUNDERGROUND)
        {
            statusTitle = localizedString(forKey: "ProvidedBy_") + " WUnderground"
            sourceURL = "https://www.wunderground.com/weather/api/d/docs?d=resources/logo-usage-guide"
        }
        else if (weatherDataSource == DARKSKY)
        {
            statusTitle = localizedString(forKey: "PoweredBy_") + " Dark Sky"
            sourceURL = "https://darksky.net/poweredby/"
        }
        else if (weatherDataSource == AERISWEATHER)
        {
            statusTitle = localizedString(forKey: "ProvidedBy_") + " AERIS Weather"
            sourceURL = "https://www.aerisweather.com/attribution/"
        }
        else if (weatherDataSource == WORLDWEATHERONLINE)
        {
            statusTitle = localizedString(forKey: "ProvidedBy_") + " World Weather Online"
        }
        else if (weatherDataSource == APIXU)
        {
            statusTitle = localizedString(forKey: "PoweredBy_") + " APIXU"
            sourceURL = "https://www.apixu.com/weather/"
        }
        else if (weatherDataSource == CANADAGOV)
        {
            statusTitle = localizedString(forKey: "ProvidedBy_") + " Environment Canada"
        }
        else
        {
            statusTitle = "WeatherSource unknown"
        }
        
        if (sourceURL == "")
        {
            myMenuItem(statusTitle, url: nil, key: "", newItem: &newItem)
        }
        else
        {
            myMenuItem(statusTitle, url: "openWeatherURL:", key: "", newItem: &newItem)
            newItem.representedObject = sourceURL
        }
        currentForecastMenu.addItem(newItem)
        
        currentConditions(weatherFields, cityName: displayCityName, currentForecastMenu: currentForecastMenu, altitude: altitude)
        
        if ((defaults.string(forKey: "viewExtendedForecast")! == "1") &&
            (!weatherFields.forecastDay[0].isEqual(""))) {
            var extendedForecastMenu = NSMenu()
            
            if (defaults.string(forKey: "extendedForecastInSubmenu")! == "1") {
                myMenuItem(localizedString(forKey: "ExtendedForecast_"), url: nil, key: "", newItem: &newItem)
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
    
    func currentConditions(_ weatherFields: WeatherFields, cityName: String, currentForecastMenu: NSMenu, altitude: String) {

        var newItem = NSMenuItem()
        
        if (defaults.string(forKey: "displayFeelsLike") == "1") {
            // Feels like was display on the title
            myMenuItem(localizedString(forKey: "Temperature_") + ": " + formatTemp(weatherFields.currentTemp as String), url: "dummy:", key: "", newItem: &newItem)
        } else {
            // Feels like was not on the title
            if (weatherFields.windSpeed != "") {
                myMenuItem(localizedString(forKey: "FeelsLike_") + ": " + calculateFeelsLike(weatherFields.currentTemp, sWindspeed: weatherFields.windSpeed, sRH: weatherFields.humidity), url: "dummy:", key: "", newItem: &newItem)
            }
        }
        currentForecastMenu.addItem(newItem)

        if (weatherFields.humidity != "") {
            myMenuItem(localizedString(forKey: "Humidity_") + ": " + formatHumidity(weatherFields.humidity as String), url: "dummy:", key: "", newItem: &newItem)
            currentForecastMenu.addItem(newItem)
        }
        
        if (weatherFields.visibility != "") {
            myMenuItem(localizedString(forKey: "Visibility_") + ": " + formatVisibility(weatherFields.visibility as String), url: "dummy:", key: "", newItem: &newItem)
            currentForecastMenu.addItem(newItem)
        }
        
        if (weatherFields.pressure != "") {
            myMenuItem(localizedString(forKey: "Pressure_") + ": " + formatPressure(weatherFields.pressure as String, altitude: altitude), url: "dummy:", key: "", newItem: &newItem)
            currentForecastMenu.addItem(newItem)
        }
        
        if (weatherFields.windDirection != "") {
            myMenuItem(localizedString(forKey: "Wind_") + ": " + formatWindSpeed(weatherFields.windSpeed as String, direction: weatherFields.windDirection as String, gust: weatherFields.windGust as String), url: "dummy:", key: "", newItem: &newItem)
            currentForecastMenu.addItem(newItem)
        }
        
        if (weatherFields.latitude != "") {
            myMenuItem(localizedString(forKey: "LatLong_") + ": " + (weatherFields.latitude as String) + " " + (weatherFields.longitude as String), url: "dummy:", key: "", newItem: &newItem)
            currentForecastMenu.addItem(newItem)
        }
        
        if (weatherFields.sunrise != "") {
            myMenuItem(localizedString(forKey: "SunriseSunset_") + ": " + convertUTCtoHHMM(weatherFields.sunrise as String) + " / " + convertUTCtoHHMM(weatherFields.sunset as String), url: "dummy:", key: "", newItem: &newItem)
            currentForecastMenu.addItem(newItem)
        }
        
        if (weatherFields.UVIndex != "") {
            myMenuItem(localizedString(forKey: "UV_") + ": " + localizedString(forKey: (weatherFields.UVIndex as String)), url: "dummy:", key: "", newItem: &newItem)
            currentForecastMenu.addItem(newItem)
        }

        if (weatherFields.currentConditions != "") {
            myMenuItem(localizedString(forKey: "currentConditions_") + ": " + localizedString(forKey: (weatherFields.currentConditions as String)), url: "dummy:", key: "", newItem: &newItem)
            currentForecastMenu.addItem(newItem)
        }
        
        if (weatherFields.date != "") {
            myMenuItem(localizedString(forKey: "LastUpdate_") + ": " + convertUTCtoHHMM(weatherFields.date as String), url: "dummy:", key: "", newItem: &newItem)
            currentForecastMenu.addItem(newItem)
        }
        
    } // currentConditions
    
    // newItem = myMenuItem("", url: nil, key: "")
    func extendedForecasts(_ weatherFields: WeatherFields,
                           cityName: String,
                           extendedForecastMenu: NSMenu,
                           weatherDataSource: String) {
        
        var newItem = NSMenuItem()
        let defaults = UserDefaults.standard
        
        DebugLog(String(format:"in extendedForecasts: %@", cityName))
        
        var extendedForecast = NSMenu()
        
        var i = 0
        
        var maxForecastDays = Int(defaults.string(forKey: "forecastDays")!)! + 1
        if (maxForecastDays > weatherFields.forecastCounter)
        {
            maxForecastDays = weatherFields.forecastCounter
        }
        
        let maxHiLowTemps = formatTemp("888") + "/" + formatTemp("888") + " \t"
        
        while (i < maxForecastDays)
        {
            if (!weatherFields.forecastDay[i].isEqual("")) {
                extendedForecast = NSMenu()
                
                var Day = String()
                if (defaults.string(forKey: "extendedForecastDisplayDate")! == "1") {
                    Day = localizedString(forKey: formatDay(weatherFields.forecastDate[i] as String)) + " \t"
                    if (evaluateStringWidth(textToEvaluate: Day) < 45)
                    {
                        Day = Day + "\t"
                    }
                } else {
                    Day = localizedString(forKey: formatDay(weatherFields.forecastDay[i] as String)) + " \t"
                    if (evaluateStringWidth(textToEvaluate: Day) < 30)
                    {
                        Day = Day + "\t"
                    }
                }
                
                if (defaults.string(forKey: "extendedForecastSingleLine")! == "1") {
                    var menuString = ""
                    menuString = menuString + Day
                    var HiLowTemps = formatTemp(weatherFields.forecastHigh[i] as String) + "/" + formatTemp(weatherFields.forecastLow[i] as String) + " \t"
                    if (evaluateStringWidth(textToEvaluate: HiLowTemps) < evaluateStringWidth(textToEvaluate: maxHiLowTemps))
                    {
                        HiLowTemps = HiLowTemps + "\t"
                    }
                    menuString = menuString + HiLowTemps
                    menuString = menuString + localizedString(forKey: (weatherFields.forecastConditions[i] as String))
                    myMenuItem(menuString, url: "dummy:", key: "", newItem: &newItem)
                    if (defaults.string(forKey: "extendedForecastIcons")! == "1") {
                        if (weatherFields.forecastCode[i] == "") {
                            newItem.image = nil
                        } else {
                            newItem.image=setImage(weatherFields.forecastCode[i] as String, weatherDataSource: weatherDataSource)
                        }
                    } else {
                        newItem.image = nil
                    }
                    extendedForecastMenu.addItem(newItem)
                } else {
                    
                    myMenuItem(Day + formatTemp(weatherFields.forecastHigh[i] as String), url: nil, key: "", newItem: &newItem)
                    extendedForecastMenu.addItem(newItem)
                    if (defaults.string(forKey: "extendedForecastIcons")! == "1") {
                        if (weatherFields.forecastCode[i] == "") {
                            newItem.image = nil
                        } else {
                            newItem.image=setImage(weatherFields.forecastCode[i] as String, weatherDataSource: weatherDataSource)
                        }
                    } else {
                        newItem.image = nil
                    }
                    extendedForecastMenu.setSubmenu(extendedForecast, for: newItem)
                    
                    if (weatherFields.forecastDate[i] != "")
                    {
                        if (defaults.string(forKey: "extendedForecastDisplayDate")! == "1") {
                            // Note that this is backwards (on purpose)
                            myMenuItem(localizedString(forKey: "Day_") + ": " + (weatherFields.forecastDay[i] as String), url: "dummy:", key: "", newItem: &newItem)
                        } else {
                            myMenuItem(localizedString(forKey: "Date_") + ": " + (weatherFields.forecastDate[i] as String), url: "dummy:", key: "", newItem: &newItem)
                        }
                        extendedForecast.addItem(newItem)
                    }
                    
                    myMenuItem(localizedString(forKey: "Forecast_") + ": " + localizedString(forKey: (weatherFields.forecastConditions[i] as String)), url: "dummy:", key: "", newItem: &newItem)
                    extendedForecast.addItem(newItem)
                    
                    myMenuItem(localizedString(forKey: "High_") + ": " + formatTemp(weatherFields.forecastHigh[i] as String), url: "dummy:", key: "", newItem: &newItem)
                    extendedForecast.addItem(newItem)
                    
                    myMenuItem(localizedString(forKey: "Low_") + ": " + formatTemp(weatherFields.forecastLow[i] as String), url: "dummy:", key: "", newItem: &newItem)
                    extendedForecast.addItem(newItem)
                }
            }
            i = i + 1
        }
        
        DebugLog(String(format:"leaving extendedForecasts: %@", cityName))
    } // extendedForecasts
    
    @objc func dummy(_ sender: NSMenuItem)
    {
        //print("dummy", terminator: "\n")
    } // dummy
    
    @objc func openWeatherURL(_ menu:NSMenuItem)
    {
        let myUrl = menu.representedObject as! NSString
        
        if let checkURL = URL(string: myUrl as String)
        {
            if NSWorkspace.shared.open(checkURL)
            {
                InfoLog("Weather URL successfully opened:" + (myUrl as String))
            }
        }
        else
        {
            InfoLog("Weather Invalid url:" + (myUrl as String))
        }
    } // openWeatherURL
    
    @objc func showRadar(_ menu:NSMenuItem) {
        
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
        
        let defaults = UserDefaults.standard
        if (defaults.string(forKey: "preferenceVersion") == nil) {
            firstTime = true
        }
        
        var row  = 0
        while (row < MAX_LOCATIONS) {
            if (row == 0) {
                testAndSet("city", defaultValue: DEFAULT_CITY)
                testAndSet("displayCity", defaultValue: "")
            } else if (row == 1) {
                testAndSet("city" + String(describing: row + 1), defaultValue: DEFAULT_CITY2)
                testAndSet("displayCity" + String(describing: row + 1), defaultValue: "")
            } else {
                testAndSet("city" + String(describing: row + 1), defaultValue: "")
                testAndSet("displayCity" + String(describing: row + 1), defaultValue: "")
            }
            testAndSet("weatherSource_" + String(describing: row + 1), defaultValue: YAHOO_WEATHER)
            testAndSet("API_Key_Data1_" + String(describing: row + 1), defaultValue: "")
            testAndSet("API_Key_Data2_" + String(describing: row + 1), defaultValue: "")
            row = row + 1
        }

        testAndSet("updateFrequency", defaultValue: DEFAULT_INTERVAL)
        testAndSet("controlsInSubmenu", defaultValue: "1")
        testAndSet("displayHumidity", defaultValue: "1")
        testAndSet("displayDegreeType", defaultValue: "1")
        testAndSet("displayWeatherIcon", defaultValue: "1")
        testAndSet("displayCityName", defaultValue: "1")
        testAndSet("displayFeelsLike", defaultValue: "0")
        testAndSet("useNewWeatherIcons", defaultValue: "1")  //Use new weather icons
        testAndSet("currentWeatherInSubmenu", defaultValue: "0")
        testAndSet("viewExtendedForecast", defaultValue: "1")
        testAndSet("extendedForecastSingleLine", defaultValue: "1")
        testAndSet("rotateWeatherLocations", defaultValue: "0")
        testAndSet("extendedForecastInSubmenu", defaultValue: "1")
        testAndSet("extendedForecastIcons", defaultValue: "1")
        testAndSet("extendedForecastDisplayDate", defaultValue: "0")
        testAndSet("newVersion", defaultValue: "1")
        testAndSet("logMessages", defaultValue: "1")
        testAndSet("allowLocation", defaultValue: "1")
        testAndSet("launchDelay", defaultValue: "10")
        testAndSet("convertQFEtoQNH", defaultValue: "0")

        testAndSet("degreesUnit", defaultValue: "0")
        testAndSet("distanceUnit", defaultValue: "0")
        testAndSet("speedUnit", defaultValue: "0")
        testAndSet("pressureUnit", defaultValue: "0")
        testAndSet("directionUnit", defaultValue: "0")
        
        testAndSet("forecastDays", defaultValue: "4")
        
        defaults.setValue(DEFAULT_PREFERENCE_VERSION, forKey: "preferenceVersion")
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
        
        cityTextField.stringValue         = locationInformationArray[0][0]
        cityDisplayTextField.stringValue  = locationInformationArray[0][1]
        weatherSource_1.selectItem(at:  Int(locationInformationArray[0][2])!)
        API_Key_Data1_1.stringValue       = locationInformationArray[0][3]
        API_Key_Data2_1.stringValue       = locationInformationArray[0][4]

        cityTextField2.stringValue        = locationInformationArray[1][0]
        cityDisplayTextField2.stringValue = locationInformationArray[1][1]
        weatherSource_2.selectItem(at:  Int(locationInformationArray[1][2])!)
        API_Key_Data1_2.stringValue       = locationInformationArray[1][3]
        API_Key_Data2_2.stringValue       = locationInformationArray[1][4]
        
        cityTextField3.stringValue        = locationInformationArray[2][0]
        cityDisplayTextField3.stringValue = locationInformationArray[2][1]
        weatherSource_3.selectItem(at:  Int(locationInformationArray[2][2])!)
        API_Key_Data1_3.stringValue       = locationInformationArray[2][3]
        API_Key_Data2_3.stringValue       = locationInformationArray[2][4]
        
        cityTextField4.stringValue        = locationInformationArray[3][0]
        cityDisplayTextField4.stringValue = locationInformationArray[3][1]
        weatherSource_4.selectItem(at:  Int(locationInformationArray[3][2])!)
        API_Key_Data1_4.stringValue       = locationInformationArray[3][3]
        API_Key_Data2_4.stringValue       = locationInformationArray[3][4]
        
        cityTextField5.stringValue        = locationInformationArray[4][0]
        cityDisplayTextField5.stringValue = locationInformationArray[4][1]
        weatherSource_5.selectItem(at:  Int(locationInformationArray[4][2])!)
        API_Key_Data1_5.stringValue       = locationInformationArray[4][3]
        API_Key_Data2_5.stringValue       = locationInformationArray[4][4]
        
        cityTextField6.stringValue        = locationInformationArray[5][0]
        cityDisplayTextField6.stringValue = locationInformationArray[5][1]
        weatherSource_6.selectItem(at:  Int(locationInformationArray[5][2])!)
        API_Key_Data1_6.stringValue       = locationInformationArray[5][3]
        API_Key_Data2_6.stringValue       = locationInformationArray[5][4]
        
        cityTextField7.stringValue        = locationInformationArray[6][0]
        cityDisplayTextField7.stringValue = locationInformationArray[6][1]
        weatherSource_7.selectItem(at:  Int(locationInformationArray[6][2])!)
        API_Key_Data1_7.stringValue       = locationInformationArray[6][3]
        API_Key_Data2_7.stringValue       = locationInformationArray[6][4]
        
        cityTextField8.stringValue        = locationInformationArray[7][0]
        cityDisplayTextField8.stringValue = locationInformationArray[7][1]
        weatherSource_8.selectItem(at:  Int(locationInformationArray[7][2])!)
        API_Key_Data1_8.stringValue       = locationInformationArray[7][3]
        API_Key_Data2_8.stringValue       = locationInformationArray[7][4]
        
        updateFrequencyTextField.stringValue = defaults.string(forKey: "updateFrequency") ?? DEFAULT_INTERVAL
        delayFrequencyTextField.stringValue = defaults.string(forKey: "launchDelay") ?? "10"
        convertQFEtoQNH.stringValue         = defaults.string(forKey: "convertQFEtoQNH") ?? "0"
        controlsInSubmenu.stringValue       = defaults.string(forKey: "controlsInSubmenu") ?? "1"
        displayHumidity.stringValue         = defaults.string(forKey: "displayHumidity") ?? "1"
        displayDegreeType.stringValue       = defaults.string(forKey: "displayDegreeType") ?? "1"
        displayWeatherIcon.stringValue      = defaults.string(forKey: "displayWeatherIcon") ?? "1"
        displayCityName.stringValue         = defaults.string(forKey: "displayCityName") ?? "1"
        displayFeelsLike.stringValue        = defaults.string(forKey: "displayFeelsLike") ?? "0"
        useNewWeatherIcons.stringValue      = defaults.string(forKey: "useNewWeatherIcons") ?? "1"
        currentWeatherInSubmenu.stringValue = defaults.string(forKey: "currentWeatherInSubmenu") ?? "0"
        viewExtendedForecast.stringValue    = defaults.string(forKey: "viewExtendedForecast") ?? "1"
        extendedForecastSingleLine.stringValue = defaults.string(forKey: "extendedForecastSingleLine") ?? "1"
        rotateWeatherLocations.stringValue  = defaults.string(forKey: "rotateWeatherLocations") ?? "0"
        extendedForecastInSubmenu.stringValue = defaults.string(forKey: "extendedForecastInSubmenu") ?? "1"
        extendedForecastIcons.stringValue   = defaults.string(forKey: "extendedForecastIcons") ?? "1"
        extendedForecastDisplayDate.stringValue = defaults.string(forKey: "extendedForecastDisplayDate") ?? "0"
        newVersion.stringValue              = defaults.string(forKey: "newVersion") ?? "1"
        logMessages.stringValue             = defaults.string(forKey: "logMessages") ?? "1"
        allowLocation.stringValue           = defaults.string(forKey: "allowLocation") ?? "0"

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
        
        locationInformationArray[0][0] = cityTextField.stringValue
        locationInformationArray[0][1] = cityDisplayTextField.stringValue
        locationInformationArray[0][2] = String(weatherSource_1.indexOfSelectedItem)
        locationInformationArray[0][3] = API_Key_Data1_1.stringValue
        locationInformationArray[0][4] = API_Key_Data2_1.stringValue
        
        locationInformationArray[1][0] = cityTextField2.stringValue
        locationInformationArray[1][1] = cityDisplayTextField2.stringValue
        locationInformationArray[1][2] = String(weatherSource_2.indexOfSelectedItem)
        locationInformationArray[1][3] = API_Key_Data1_2.stringValue
        locationInformationArray[1][4] = API_Key_Data2_2.stringValue
        
        locationInformationArray[2][0] = cityTextField3.stringValue
        locationInformationArray[2][1] = cityDisplayTextField3.stringValue
        locationInformationArray[2][2] = String(weatherSource_3.indexOfSelectedItem)
        locationInformationArray[2][3] = API_Key_Data1_3.stringValue
        locationInformationArray[2][4] = API_Key_Data2_3.stringValue
        
        locationInformationArray[3][0] = cityTextField4.stringValue
        locationInformationArray[3][1] = cityDisplayTextField4.stringValue
        locationInformationArray[3][2] = String(weatherSource_4.indexOfSelectedItem)
        locationInformationArray[3][3] = API_Key_Data1_4.stringValue
        locationInformationArray[3][4] = API_Key_Data2_4.stringValue
        
        locationInformationArray[4][0] = cityTextField5.stringValue
        locationInformationArray[4][1] = cityDisplayTextField5.stringValue
        locationInformationArray[4][2] = String(weatherSource_5.indexOfSelectedItem)
        locationInformationArray[4][3] = API_Key_Data1_5.stringValue
        locationInformationArray[4][4] = API_Key_Data2_5.stringValue
        
        locationInformationArray[5][0] = cityTextField6.stringValue
        locationInformationArray[5][1] = cityDisplayTextField6.stringValue
        locationInformationArray[5][2] = String(weatherSource_6.indexOfSelectedItem)
        locationInformationArray[5][3] = API_Key_Data1_6.stringValue
        locationInformationArray[5][4] = API_Key_Data2_6.stringValue
        
        locationInformationArray[6][0] = cityTextField7.stringValue
        locationInformationArray[6][1] = cityDisplayTextField7.stringValue
        locationInformationArray[6][2] = String(weatherSource_7.indexOfSelectedItem)
        locationInformationArray[6][3] = API_Key_Data1_7.stringValue
        locationInformationArray[6][4] = API_Key_Data2_7.stringValue
        
        locationInformationArray[7][0] = cityTextField8.stringValue
        locationInformationArray[7][1] = cityDisplayTextField8.stringValue
        locationInformationArray[7][2] = String(weatherSource_8.indexOfSelectedItem)
        locationInformationArray[7][3] = API_Key_Data1_8.stringValue
        locationInformationArray[7][4] = API_Key_Data2_8.stringValue

        var row = 0
        while (row < MAX_LOCATIONS) {
            if (row == 0) {
                defaults.setValue(locationInformationArray[row][0], forKey: "city")
                defaults.setValue(locationInformationArray[row][1],  forKey: "displayCity")
            } else {
                defaults.setValue(locationInformationArray[row][0], forKey: "city" + String(describing: row + 1))
                defaults.setValue(locationInformationArray[row][1],  forKey: "displayCity" + String(describing: row + 1))
            }
            defaults.setValue(locationInformationArray[row][2], forKey: "weatherSource_" + String(describing: row + 1))
            defaults.setValue(locationInformationArray[row][3], forKey: "API_Key_Data1_" + String(describing: row + 1))
            defaults.setValue(locationInformationArray[row][4], forKey: "API_Key_Data2_" + String(describing: row + 1))
            row = row + 1
        }
        
        defaults.setValue(updateFrequencyTextField.stringValue, forKey: "updateFrequency")
        defaults.setValue(delayFrequencyTextField.stringValue, forKey: "launchDelay")
        defaults.setValue(controlsInSubmenu.stringValue, forKey: "controlsInSubmenu")
        defaults.setValue(convertQFEtoQNH.stringValue, forKey: "convertQFEtoQNH")
        defaults.setValue(displayHumidity.stringValue, forKey: "displayHumidity")
        defaults.setValue(displayDegreeType.stringValue, forKey: "displayDegreeType")
        defaults.setValue(displayWeatherIcon.stringValue, forKey: "displayWeatherIcon")
        defaults.setValue(displayCityName.stringValue, forKey: "displayCityName")
        defaults.setValue(displayFeelsLike.stringValue, forKey: "displayFeelsLike")
        defaults.setValue(useNewWeatherIcons.stringValue, forKey: "useNewWeatherIcons")
        defaults.setValue(currentWeatherInSubmenu.stringValue, forKey: "currentWeatherInSubmenu")
        defaults.setValue(viewExtendedForecast.stringValue, forKey: "viewExtendedForecast")
        defaults.setValue(extendedForecastSingleLine.stringValue, forKey: "extendedForecastSingleLine")
        defaults.setValue(rotateWeatherLocations.stringValue, forKey: "rotateWeatherLocations")
        defaults.setValue(extendedForecastInSubmenu.stringValue, forKey: "extendedForecastInSubmenu")
        defaults.setValue(extendedForecastIcons.stringValue, forKey: "extendedForecastIcons")
        defaults.setValue(extendedForecastDisplayDate.stringValue, forKey: "extendedForecastDisplayDate")
        defaults.setValue(newVersion.stringValue, forKey: "newVersion")
        defaults.setValue(logMessages.stringValue, forKey: "logMessages")
        defaults.setValue(allowLocation.stringValue, forKey: "allowLocation")
        defaults.setValue(degreesUnit.indexOfSelectedItem, forKey: "degreesUnit")
        defaults.setValue(distanceUnit.indexOfSelectedItem, forKey: "distanceUnit")
        defaults.setValue(speedUnit.indexOfSelectedItem, forKey: "speedUnit")
        defaults.setValue(pressureUnit.indexOfSelectedItem, forKey: "pressureUnit")
        defaults.setValue(directionUnit.indexOfSelectedItem, forKey: "directionUnit")
        defaults.setValue(forecastDays.indexOfSelectedItem, forKey: "forecastDays")
        defaults.setValue(DEFAULT_PREFERENCE_VERSION, forKey: "preferenceVersion")
        let i = NumberFormatter().number(from: defaults.string(forKey: "fontsize")!)
        menu.font = NSFont(name: defaults.string(forKey: "font")!, size: CGFloat(truncating: i!))
        
        updateWeather()
        
    } // windowWillClose
    
    
    func initDisplay()
    {
        self.window!.title = localizedString(forKey: "Preferences_")
        locationsTab.label = localizedString(forKey: "Locations_")
        optionsTab.label = localizedString(forKey: "Options_")
        globalTab.label = localizedString(forKey: "GlobalUnits_")
        keyTab.label = localizedString(forKey: "Keys_")
        helpTab.label = localizedString(forKey: "Help_")
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
        allowLocation.title = localizedString(forKey: "allowLocation_")

        weatherSourceLabel.stringValue = localizedString(forKey: "weatherSource_") + ":"
        
        InitWeatherSourceButton(weatherSourceButton: weatherSource_1)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_2)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_3)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_4)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_5)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_6)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_7)
        InitWeatherSourceButton(weatherSourceButton: weatherSource_8)
        
        displayHumidity.title = localizedString(forKey: "DisplayHumidity_")
        displayDegreeType.title = localizedString(forKey: "DisplayDegreeType_")
        displayWeatherIcon.title = localizedString(forKey: "DisplayWeatherIcon_")
        displayCityName.title = localizedString(forKey: "DisplayCityName_")
        displayFeelsLike.title = localizedString(forKey: "DisplayFeelsLike_")
        useNewWeatherIcons.title = localizedString(forKey: "UseNewWeatherIcons_")
        currentWeatherInSubmenu.title = localizedString(forKey: "CurrentWeather_")
        controlsInSubmenu.title = localizedString(forKey: "ControlsInSubmenu_")
        convertQFEtoQNH.title = localizedString(forKey: "convertQFEtoQNH_")
        viewExtendedForecast.title = localizedString(forKey: "ViewExtendedForecast_")
        extendedForecastInSubmenu.title = localizedString(forKey: "ExtendedForecastInSubmenu_")
        extendedForecastIcons.title = localizedString(forKey: "ExtendedForecastIcons_")
        extendedForecastDisplayDate.title = localizedString(forKey: "ExtendedForecastDisplayDate_")
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
        
        resetPrefsButton.title = localizedString(forKey: "resetPreferences_")
        
        latLongFormat.stringValue = localizedString(forKey: "LatLongFormat_")
        apiKeyLabel.stringValue = localizedString(forKey: "apiKeyLabel_")
        theWeatherLocation.stringValue = localizedString(forKey: "theWeatherLocation_")
        openWeatherMapLocation.stringValue = localizedString(forKey: "openWeatherMapLocation_")
        yahooLocation.stringValue = localizedString(forKey: "yahooLocation_")
        wundergroundLocation.stringValue = localizedString(forKey: "wundergroundLocation_")
        aerisLocation.stringValue = localizedString(forKey: "aerisLocation_") + ":"
        worldWeatherLocation.stringValue = localizedString(forKey: "worldWeatherLocation_")
        darkSkyLocation.stringValue = localizedString(forKey: "darkSkyLocation_")
        APIXULocation.stringValue = localizedString(forKey: "APIXULocation_")
        canadaGovLocation.stringValue = localizedString(forKey: "canadaGovLocation_")

        helpView.string = localizedString(forKey: "help_text_")

    } // initDisplay
    
    func showPreferencePane() {
        self.window!.delegate = self
        self.window!.orderOut(self)
        self.window!.makeKeyAndOrderFront(self.window!)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func DisplayFontPressed(_ sender: NSButton)
    {
        // https://translate.google.com/translate?sl=auto&tl=en&js=y&prev=_t&hl=en&ie=UTF-8&u=http%3A%2F%2Fcocoaapi.hatenablog.com%2Fentry%2FAppkit%2FNSWindow_class%2FbeginSheet%253AcompletionHandler%253A&edit-text=&act=url
        modalDisplay.setFont("font")
        self.window!.beginSheet (modalDisplay.window!, completionHandler: nil)
    } // DisplayFontPressed
    
    @IBAction func MenuBarFontPressed(_ sender: NSButton)
    {
        // https://translate.google.com/translate?sl=auto&tl=en&js=y&prev=_t&hl=en&ie=UTF-8&u=http%3A%2F%2Fcocoaapi.hatenablog.com%2Fentry%2FAppkit%2FNSWindow_class%2FbeginSheet%253AcompletionHandler%253A&edit-text=&act=url
        modalMenuBar.setFont("menuBarFont")
        self.window!.beginSheet (modalMenuBar.window!, completionHandler: nil)
    } // MenuBarFontPressed
    
    @IBAction func preferences(_ sender: NSMenuItem)
    {
        showPreferencePane()
    } // preferences
    
    @IBAction func launchLink(_ sender: NSButton)
    {
        if let url = URL(string: sender.title) {
            NSWorkspace.shared.open(url)
        }
    } // launchLink
    
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
        NSApplication.shared.terminate(nil)
    } // Relaunch
    
    @IBAction func weatherRefresh(_ sender: NSMenuItem)
    {
        updateWeather()
    } // weatherRefresh
    
    @IBAction func resetPreferences(_ sender: NSMenuItem)
    {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        defaultPreferences()
        
        initWindowPrefs()
        
    } // resetPreferences
    
        func InitWeatherSourceButton(weatherSourceButton: NSPopUpButton)
    {
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "Yahoo!_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "OpenWeatherMap_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "TheWeather.com_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "WeatherUnderground_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "AERISWeather_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "WorldWeatherOnline_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "DarkSky_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "APIXU_") )
        weatherSourceButton.addItem(withTitle: localizedString(forKey: "CanadaGov_") )
    } // InitWeatherSourceButton
    
    func initPrefs() {
        
        let defaults = UserDefaults.standard
        
        while (locationInformationArray.count < MAX_LOCATIONS)
        {
            locationInformationArray.append(["", "", "", "", ""])
            let base1 = String(describing: locationInformationArray.count)
            if (locationInformationArray.count == 1) {
                locationInformationArray[locationInformationArray.count-1][0] = defaults.string(forKey: "city") ?? DEFAULT_CITY
                locationInformationArray[locationInformationArray.count-1][1] = defaults.string(forKey: "displayCity") ?? ""
            } else if (locationInformationArray.count == 2) {
                locationInformationArray[locationInformationArray.count-1][0] = defaults.string(forKey: "city" + base1) ?? DEFAULT_CITY2
                locationInformationArray[locationInformationArray.count-1][1] = defaults.string(forKey: "displayCity" + base1) ?? ""
            } else {
                locationInformationArray[locationInformationArray.count-1][0] = defaults.string(forKey: "city" + base1) ?? ""
                locationInformationArray[locationInformationArray.count-1][1] = defaults.string(forKey: "displayCity" + base1) ?? ""
            }
            locationInformationArray[locationInformationArray.count-1][2] = defaults.string(forKey: "weatherSource_" + base1) ?? YAHOO_WEATHER
            locationInformationArray[locationInformationArray.count-1][3] = defaults.string(forKey: "API_Key_Data1_" + base1) ?? ""
            locationInformationArray[locationInformationArray.count-1][4] = defaults.string(forKey: "API_Key_Data2_" + base1) ?? ""
        }
    } // initPrefs
    
} // AppDelegate
