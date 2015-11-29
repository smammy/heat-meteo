//
//  PreferencesWindow.swift
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

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var prefWindows: NSWindow!
    @IBOutlet weak var newVersion: NSButton!
    @IBOutlet weak var logMessages: NSButton!
    @IBOutlet weak var cityTextField: NSTextField!
    @IBOutlet weak var cityNameLabel: NSTextField!
    @IBOutlet weak var cityTextField2: NSTextField!
    @IBOutlet weak var cityTextField3: NSTextField!
    @IBOutlet weak var cityTextField4: NSTextField!
    @IBOutlet weak var cityTextField5: NSTextField!
    @IBOutlet weak var cityTextField6: NSTextField!
    @IBOutlet weak var cityTextField7: NSTextField!
    @IBOutlet weak var cityTextField8: NSTextField!
    @IBOutlet weak var weatherSource: NSPopUpButton!
    @IBOutlet weak var weatherSourceLabel: NSTextField!
    @IBOutlet weak var controlsInSubmenu: NSButton!
    @IBOutlet weak var displayHumidity: NSButton!
    @IBOutlet weak var displayDegreeType: NSButton!
    @IBOutlet weak var displayWeatherIcon: NSButton!
    @IBOutlet weak var displayCityName: NSButton!
    @IBOutlet weak var displayLocationLabel: NSTextField!
    @IBOutlet weak var displayMenubar: NSButton!
    @IBOutlet weak var displayDock: NSButton!
    @IBOutlet weak var displayBoth: NSButton!
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
    @IBOutlet weak var fontSelection: NSPopUpButton!
    @IBOutlet weak var fontSize: NSPopUpButton!
    
    var delegate: PreferencesWindowDelegate?

    override var windowNibName : String! {
        return "PreferencesWindow"
    } // windowNibName
    
    override func windowDidLoad() {
        super.windowDidLoad()

        //self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.styleMask = NSTitledWindowMask | NSClosableWindowMask
        
        initDisplay()
        
        // https://www.youtube.com/watch?v=lJS4YWUT8Hk
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let build = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        versionTextLabel.stringValue = "Version " + version + " build " + build

        let defaults = NSUserDefaults.standardUserDefaults()
        
        fontSelection.addItemsWithTitles(NSFontManager.sharedFontManager().availableFontFamilies)
        let familyName = defaults.stringForKey("font") ?? "Tahoma"
        fontSelection.selectItemWithTitle(familyName)
        
        weatherSource.selectItemAtIndex(Int(defaults.stringForKey("weatherSource") ?? YAHOO_WEATHER)!)

        cityTextField.stringValue           = defaults.stringForKey("city") ?? DEFAULT_CITY
        cityTextField2.stringValue          = defaults.stringForKey("city2") ?? ""
        cityTextField3.stringValue          = defaults.stringForKey("city3") ?? ""
        cityTextField4.stringValue          = defaults.stringForKey("city4") ?? ""
        cityTextField5.stringValue          = defaults.stringForKey("city5") ?? ""
        cityTextField6.stringValue          = defaults.stringForKey("city6") ?? ""
        cityTextField7.stringValue          = defaults.stringForKey("city7") ?? ""
        cityTextField8.stringValue          = defaults.stringForKey("city8") ?? ""
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
        
        fontSize.selectItemWithTitle(defaults.stringForKey("fontsize") ?? "14")
        
        NSApp.activateIgnoringOtherApps(true)
    } // windowDidLoad
    
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
        
        defaults.setValue(fontSelection.selectedItem!.title, forKey: "font")
        defaults.setValue(fontSize.selectedItem!.title, forKey: "fontsize")
        
        defaults.setValue(DEFAULT_PREFERENCE_VERSION, forKey: "preferenceVersion")
        delegate?.preferencesDidUpdate()
    } // windowWillClose
    
    func initDisplay() {
        prefWindows.title = NSLocalizedString("Preferences_", // Unique key of your choice
            value:"Preferences", // Default (English) text
            comment:"Preferences")
        cityNameLabel.stringValue = NSLocalizedString("CityNames_", // Unique key of your choice
            value:"City Names", // Default (English) text
            comment:"City Names") + ":"
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
            value:"Log message to console", // Default (English) text
            comment:"Log message to console")
        
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
        
        fontLabel.stringValue = NSLocalizedString("Font_", // Unique key of your choice
            value:"Font", // Default (English) text
            comment:"Font") + ":"
        
    } // initDisplay

} // PreferencesWindow
