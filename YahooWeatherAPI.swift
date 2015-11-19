//
//  YahooWeatherAPI.swift
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
import Foundation

class YahooWeatherAPI: NSObject, NSXMLParserDelegate {
    
    let QUERY_PREFIX1 = "https://query.yahooapis.com/v1/public/yql?q=SELECT%20woeid%20FROM%20geo.places(1)%20WHERE%20text%3D'"
    let QUERY_SUFFIX1 = "'&format=xml&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
    
    let QUERY_PREFIX2 = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20IN("
    let QUERY_SUFFIX2 = ")"
    
    let QUERY_PREFIX3 = "https://query.yahooapis.com/v1/public/yql?q=select * from weather.forecast where woeid IN("
    let QUERY_SUFFIX3 = ")"
    
    var Parser = NSXMLParser()
    var element = NSString()
    
    var iForecastCount = 0
    var inChannel = false
    var inTitle = false
    
    var locationCountry = NSMutableString()
    var locationRegion = NSMutableString()
    var locationCity = NSMutableString()
    var locationWOEID = NSMutableString()
    
    var escapedCity = NSString()
    var parseURL = NSMutableString()
    
    var weatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()
    
    func beginParsing(inputCity: String) -> WeatherFields {
        
        DebugLog(String(format:"in beginParsing: %@", inputCity))

        weatherFields.title1 = ""
        weatherFields.date = ""
        weatherFields.latitude = ""
        weatherFields.longitude = ""
        weatherFields.title1 = ""
        weatherFields.windChill = ""
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
        
        weatherFields.forecast1Code = ""
        weatherFields.forecast1Date = ""
        weatherFields.forecast1Day = ""
        weatherFields.forecast1High = ""
        weatherFields.forecast1Low = ""
        weatherFields.forecast1Conditions = ""
        
        weatherFields.forecast2Code = ""
        weatherFields.forecast2Date = ""
        weatherFields.forecast2Day = ""
        weatherFields.forecast2High = ""
        weatherFields.forecast2Low = ""
        weatherFields.forecast2Conditions = ""
        
        weatherFields.forecast3Code = ""
        weatherFields.forecast3Date = ""
        weatherFields.forecast3Day = ""
        weatherFields.forecast3High = ""
        weatherFields.forecast3Low = ""
        weatherFields.forecast3Conditions = ""
        
        weatherFields.forecast4Code = ""
        weatherFields.forecast4Date = ""
        weatherFields.forecast4Day = ""
        weatherFields.forecast4High = ""
        weatherFields.forecast4Low = ""
        weatherFields.forecast4Conditions = ""
        
        weatherFields.forecast5Code = ""
        weatherFields.forecast5Date = ""
        weatherFields.forecast5Day = ""
        weatherFields.forecast5High = ""
        weatherFields.forecast5Low = ""
        weatherFields.forecast5Conditions = ""
        
        locationCity = ""
        locationCountry = ""
        locationRegion = ""
        locationWOEID = ""

        Parser = NSXMLParser()
        
        iForecastCount = 1
        inChannel = false
        inTitle = false
        
        // https://developer.yahoo.com/weather/
        
        // Should emit "Powered by Yahoo!", https://poweredby.yahoo.com/purple.png
        //var weatherQuery = NSString()
        //weatherQuery = "SELECT * FROM weather.forecast WHERE u=c AND woeid = (SELECT woeid FROM geo.places(1) WHERE text='nome, ak')"
        
        parseURL = ""
        parseURL.appendString(QUERY_PREFIX1)
        escapedCity = inputCity.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        escapedCity = escapedCity.stringByReplacingOccurrencesOfString(",", withString: "%3D")
        parseURL.appendString(escapedCity as String)
        parseURL.appendString(QUERY_SUFFIX1)
        DebugLog(String(format:"URL for WOEID: %@\n", parseURL))
        Parser = NSXMLParser(contentsOfURL:(NSURL(string:parseURL as String))!)!
        
        // Find WOEID (Yahoo's Where On Earth ID)
        Parser.delegate = self
        Parser.parse()
        
        parseURL = ""
        parseURL.appendString(QUERY_PREFIX3)
        parseURL.appendString((locationWOEID as String))
        parseURL.appendString(QUERY_SUFFIX3)
        InfoLog(String(format:"URL for Yahoo Weather: %@\n", parseURL))

        parseURL = ""
        parseURL.appendString(QUERY_PREFIX2)
        parseURL.appendString((locationWOEID as String))
        parseURL.appendString(QUERY_SUFFIX2)
        Parser = NSXMLParser(contentsOfURL:(NSURL(string:parseURL as String))!)!
        
        // Get the XML feed for the city in question
        Parser.delegate = self
        Parser.parse()
        
        weatherFields.URL = "https://weather.yahoo.com/"
        weatherFields.URL.appendString(locationCountry as String)
        weatherFields.URL.appendString("/")
        weatherFields.URL.appendString(locationRegion as String)
        weatherFields.URL.appendString("/")
        weatherFields.URL.appendString(locationCity as String)
        weatherFields.URL.appendString("-")
        weatherFields.URL.appendString(locationWOEID as String)
        weatherFields.URL.appendString("/")
        //locationCountry = locationCountry.stringByReplacingOccurrencesOfString(" ", withString: "-")

        DebugLog(String(format:"leaving beginParsing: %@", inputCity))

        return weatherFields
    } // beginParsing
    
    func setImage(weatherCode: String) -> NSImage
    {
        /*
        6	mixed rain and sleet
        7	mixed snow and sleet
        8	freezing drizzle
        10	freezing rain
        13	snow flurries               MB-Flurries
        14	light snow showers
        17	hail
        18	sleet                       MB-Sleet
        19	dust
        20	foggy
        21	haze                        MB-Hazy
        22	smoky
        23	blustery
        24	windy                       MB-Wind
        25	cold                        Temperature-2
        35	mixed rain and hail
        36	hot                         Temperature-9
        3200	not available
        
        */
        
        if (weatherCode == "0")
        {
            return NSImage(named: "Tornado")!
        }
        else if ((weatherCode == "1") ||
            (weatherCode == "2"))
        {
            return NSImage(named: "Hurricane")!
        }
        else if ((weatherCode == "3") ||
            (weatherCode == "37") ||
            (weatherCode == "38") ||
            (weatherCode == "39") ||
            (weatherCode == "45") ||
            (weatherCode == "47") ||
            (weatherCode == "4"))
        {
            return NSImage(named: "MB-Thunderstorm")!
        }
        else if ((weatherCode == "9") ||
            (weatherCode == "11") ||
            (weatherCode == "40") ||
            (weatherCode == "12"))
        {
            return NSImage(named: "MB-Rain")!
        }
        else if ((weatherCode == "5") ||
            (weatherCode == "16") ||
            (weatherCode == "15") ||
            (weatherCode == "41") ||
            (weatherCode == "42") ||
            (weatherCode == "43") ||
            (weatherCode == "46"))
        {
            return NSImage(named: "MB-Snow")!
        }
        else if ((weatherCode == "5") ||
            (weatherCode == "16") ||
            (weatherCode == "15") ||
            (weatherCode == "41") ||
            (weatherCode == "42") ||
            (weatherCode == "43") ||
            (weatherCode == "46"))
        {
            return NSImage(named: "MB-Snow")!
        }
        else if ((weatherCode == "32") ||
            (weatherCode == "34"))
        {
            return NSImage(named: "MB-Sun")!
        }
        else if ((weatherCode == "23") ||
            (weatherCode == "24"))
        {
            return NSImage(named: "MB-Wind")!
        }
        else if ((weatherCode == "31") ||
            (weatherCode == "33"))
        {
            return NSImage(named: "MB-Moon")!
        }
        else if ((weatherCode == "30") ||
            (weatherCode == "44"))
        {
            return NSImage(named: "MB-Sun-Cloud-1")!
        }
        else if ((weatherCode == "20") ||
            (weatherCode == "21"))
        {
            return NSImage(named: "MB-Hazy")!
        }
        else if ((weatherCode == "26"))
        {
            return NSImage(named: "MB-Cloudy")!
        }
        else if ((weatherCode == "27"))
        {
            return NSImage(named: "MB-Moon-Cloud-2")!
        }
        else if ((weatherCode == "28"))
        {
            return NSImage(named: "MB-Sun-Cloud-2")!
        }
        else if ((weatherCode == "29"))
        {
            return NSImage(named: "MB-Moon-Cloud-2")!
        }
        else if ((weatherCode == "3200"))
        {
            // Yahoo! doesn't have a code so this really isn't an error
        }
        else
        {
            print(NSLocalizedString("InvalidWeatherCode_", // Unique key of your choice
                value:"Invalid weatherCode", // Default (English) text
                comment:"Invalid weatherCode") + ":", weatherCode, terminator: "\n")
        }
        return NSImage()
    } // setImage
    
    func formatTemp(temp: String) -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        var formattedTemp = temp
        if (defaults.stringForKey("degreesUnit")! == "1") {
            // http://www.rapidtables.com/convert/temperature/how-fahrenheit-to-celsius.htm
            formattedTemp = String(Int(((temp as NSString).doubleValue - 32) / 1.8))
        }
        formattedTemp += "°"
        if (defaults.stringForKey("displayDegreeType")! == "1") {
            if (defaults.stringForKey("degreesUnit")! == "0") {
                formattedTemp += "F"
            } else {
                formattedTemp += "C"
            }
        }
        return formattedTemp
    } // formatTemp
    
    func formatWindSpeed(speed: String, direction: String) -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        var formattedWindSpeed = direction + "° @ "
        if (defaults.stringForKey("directionUnit")! == "1") {
            var windDirection = direction
            let iDirection = Int((direction as NSString).doubleValue)
            if (iDirection <= 22) {
                windDirection = "N"
            } else if (iDirection <= 67) {
                windDirection = "NE"
            } else if (iDirection <= 112) {
                windDirection = "E"
            } else if (iDirection <= 147) {
                windDirection = "SE"
            } else if (iDirection <= 202) {
                windDirection = "S"
            } else if (iDirection <= 247) {
                windDirection = "SW"
            } else if (iDirection <= 292) {
                windDirection = "W"
            } else if (iDirection <= 337) {
                windDirection = "NW"
            } else {
                windDirection = "N"
            }
            formattedWindSpeed = windDirection + " @ "
        }
        if (defaults.stringForKey("speedUnit")! == "0") {
            formattedWindSpeed += speed + " " + NSLocalizedString("MPH_", // Unique key of your choice
                        value:"MPH", // Default (English) text
                        comment:"Miles Per Hour")
        } else if (defaults.stringForKey("speedUnit")! == "1") {
            formattedWindSpeed += String(Int((speed as NSString).doubleValue * 1.6094)) + " " + NSLocalizedString("KPH_", // Unique key of your choice
                        value:"KPH", // Default (English) text
                        comment:"Kilometers Per Second")
        } else if (defaults.stringForKey("speedUnit")! == "2") {
            formattedWindSpeed += String(Int((speed as NSString).doubleValue * 0.44704)) + " " + NSLocalizedString("MPS_", // Unique key of your choice
                        value:"MPS", // Default (English) text
                        comment:"Meters Per Second")
        } else if (defaults.stringForKey("speedUnit")! == "3") {
            formattedWindSpeed += String(Int((speed as NSString).doubleValue * 1.15077944802)) + " " + NSLocalizedString("Knots_", // Unique key of your choice
                        value:"Knots", // Default (English) text
                        comment:"Knots")
        }
        return formattedWindSpeed
    } // formatWindSpeed
    
    func formatPressure(pressure: String) -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        var formattedPressure = ""
        if (defaults.stringForKey("pressureUnit")! == "0") {
            formattedPressure += pressure + " " + NSLocalizedString("Inches_", // Unique key of your choice
                        value:"Inches", // Default (English) text
                        comment:"Inches")
        } else if (defaults.stringForKey("pressureUnit")! == "1") {
            formattedPressure += String(Int((pressure as NSString).doubleValue * 33.8637526)) + " " + NSLocalizedString("mb_", // Unique key of your choice
                        value:"mb", // Default (English) text
                        comment:"Millibars")
        } else if (defaults.stringForKey("pressureUnit")! == "2") {
            formattedPressure += String(Int((pressure as NSString).doubleValue * 3.39)) + " " + NSLocalizedString("kp_", // Unique key of your choice
                        value:"Kb", // Default (English) text
                        comment:"KiloPascals")
        } else if (defaults.stringForKey("pressureUnit")! == "3") {
            // Meters/second
            formattedPressure += String(Int((pressure as NSString).doubleValue * 33.8637526)) + " " + NSLocalizedString("hp_", // Unique key of your choice
                        value:"hb", // Default (English) text
                        comment:"HectorPascals")
        }
        return formattedPressure
    } // formatPressure
    
    func formatVisibility(distance: String) -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        var formattedVisibility = ""
        if (defaults.stringForKey("distanceUnit")! == "0") {
            formattedVisibility += distance + " " + NSLocalizedString("Miles_", // Unique key of your choice
                value:"Miles", // Default (English) text
                comment:"Miles (disance)")
        } else if (defaults.stringForKey("distanceUnit")! == "1") {
            formattedVisibility += String(Int((distance as NSString).doubleValue * 5280.0)) + " " + NSLocalizedString("Ft_", // Unique key of your choice
                value:"Feet", // Default (English) text
                comment:"Feet (disance)")
        } else if (defaults.stringForKey("distanceUnit")! == "2") {
            formattedVisibility += String(Int((distance as NSString).doubleValue * 0.621371192237)) + " " + NSLocalizedString("km_", // Unique key of your choice
                value:"KiloMeters", // Default (English) text
                comment:"KiloMeters (disance)")
        } else if (defaults.stringForKey("distanceUnit")! == "3") {
            // Meters/second
            formattedVisibility += String(Int((distance as NSString).doubleValue * 0.000621371192237)) + " " + NSLocalizedString("m_", // Unique key of your choice
                value:"Meters", // Default (English) text
                comment:"Meters (disance)")
        } else {
            // Knots
        }
        return formattedVisibility
    } // formatVisibility
    
    func formatHumidity(humidity: String) -> String {
        return humidity + "%"
    } // formatHumidity
    
    func extendedWeatherIcon(weatherCode: String) -> NSImage {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("extendedForecastIcons")! == "1") {
            return setImage(weatherCode)
        } else {
            return NSImage()
        }
    } // extendedWeatherIcon
    
    func currentConditions(weatherFields: WeatherFields, cityName: String, currentForecastMenu: NSMenu) {
        
        var newItem : NSMenuItem
        
        newItem = NSMenuItem(title: NSLocalizedString("Temperature_", // Unique key of your choice
            value:"Temperature", // Default (English) text
            comment:"Temperature") + ": " + formatTemp(weatherFields.currentTemp as String), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("FeelsLike_", // Unique key of your choice
            value:"Feels Like", // Default (English) text
            comment:"Feels Like") + ": " + formatTemp(weatherFields.windChill as String), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("Humidity_", // Unique key of your choice
            value:"Humidity", // Default (English) text
            comment:"Humidity_") + ": " + formatHumidity(weatherFields.humidity as String), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("Visibility_", // Unique key of your choice
            value:"Visibility", // Default (English) text
            comment:"Visibility") + ": " + formatVisibility(weatherFields.visibility as String), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("Pressure_", // Unique key of your choice
            value:"Pressure", // Default (English) text
            comment:"Pressure") + ": " + formatPressure(weatherFields.pressure as String), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("Wind_", // Unique key of your choice
            value:"Wind", // Default (English) text
            comment:"Wind") + ": " + formatWindSpeed(weatherFields.windSpeed as String, direction: weatherFields.windDirection as String), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("LatLong_", // Unique key of your choice
            value:"Lat/Long", // Default (English) text
            comment:"Lat/Long") + ": " + (weatherFields.latitude as String) + " " + (weatherFields.longitude as String), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("SunriseSunset_", // Unique key of your choice
            value:"Sunrise/sunset", // Default (English) text
            comment:"Sunrise/sunset") + ": " + (weatherFields.sunrise as String) + " / " + (weatherFields.sunset as String), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("LastUpdate_", // Unique key of your choice
            value:"Last Update", // Default (English) text
            comment:"Last Update") + ": " + (weatherFields.date as String), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
    } // currentConditions
    
    func extendedForecasts(weatherFields: WeatherFields, cityName: String, extendedForecastMenu: NSMenu) {
        
        var newItem : NSMenuItem
        let defaults = NSUserDefaults.standardUserDefaults()
        
        DebugLog(String(format:"in extendedForecasts: %@", cityName))

        var extendedForecast = NSMenu()
        
        if (!weatherFields.forecast1Day.isEqual("")) {
            extendedForecast = NSMenu()
            
            if (defaults.stringForKey("extendedForecastSingleLine")! == "1") {
                newItem = NSMenuItem(title: (weatherFields.forecast1Day as String) + " \t" + NSLocalizedString("High_", // Unique key of your choice
                    value:"High", // Default (English) text
                    comment:"High") + ": " + formatTemp(weatherFields.forecast1High as String) + " \t" + NSLocalizedString("Low_", // Unique key of your choice
                        value:"Low", // Default (English) text
                        comment:"Low") + ": " + formatTemp(weatherFields.forecast1Low as String) + " \t" + (weatherFields.forecast1Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast1Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: (weatherFields.forecast1Day as String) + ", " + formatTemp(weatherFields.forecast1High as String), action: nil, keyEquivalent: "")
                extendedForecastMenu.addItem(newItem)
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast1Code as String)
                } else {
                    newItem.image = nil
                }
                extendedForecastMenu.setSubmenu(extendedForecast, forItem: newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Date_", // Unique key of your choice
                    value:"Date", // Default (English) text
                    comment:"Date") + ": " + (weatherFields.forecast1Date as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Forecast_", // Unique key of your choice
                    value:"Forecast", // Default (English) text
                    comment:"Forecast") + ": " + (weatherFields.forecast1Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("High_", // Unique key of your choice
                    value:"High", // Default (English) text
                    comment:"High") + ": " + formatTemp(weatherFields.forecast1High as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Low_", // Unique key of your choice
                    value:"Low", // Default (English) text
                    comment:"Low") + ": " + formatTemp(weatherFields.forecast1Low as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
            }
        }
        
        if (!weatherFields.forecast2Day.isEqual("")) {
            extendedForecast = NSMenu()
            
            if (defaults.stringForKey("extendedForecastSingleLine")! == "1") {
                newItem = NSMenuItem(title: (weatherFields.forecast2Day as String) + " \t" + NSLocalizedString("High_", // Unique key of your choice
                    value:"High", // Default (English) text
                    comment:"High") + ": " + formatTemp(weatherFields.forecast2High as String) + " \t" + NSLocalizedString("Low_", // Unique key of your choice
                        value:"Low", // Default (English) text
                        comment:"Low") + ": " + formatTemp(weatherFields.forecast2Low as String) + " \t" + (weatherFields.forecast2Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast2Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: (weatherFields.forecast2Day as String) + ", " + formatTemp(weatherFields.forecast2High as String), action: nil, keyEquivalent: "")
                extendedForecastMenu.addItem(newItem)
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast2Code as String)
                } else {
                    newItem.image = nil
                }
                extendedForecastMenu.setSubmenu(extendedForecast, forItem: newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Date_", // Unique key of your choice
                    value:"Date", // Default (English) text
                    comment:"Date") + ": " + (weatherFields.forecast2Date as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Forecast_", // Unique key of your choice
                    value:"Forecast", // Default (English) text
                    comment:"Forecast") + ": " + (weatherFields.forecast2Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("High_", // Unique key of your choice
                    value:"High", // Default (English) text
                    comment:"High") + ": " + formatTemp(weatherFields.forecast2High as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Low_", // Unique key of your choice
                    value:"Low", // Default (English) text
                    comment:"Low") + ": " + formatTemp(weatherFields.forecast2Low as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
            }
        }
        
        if (!weatherFields.forecast3Day.isEqual("")) {
            extendedForecast = NSMenu()
            
            if (defaults.stringForKey("extendedForecastSingleLine")! == "1") {
                newItem = NSMenuItem(title: (weatherFields.forecast3Day as String) + " \t" + NSLocalizedString("High_", // Unique key of your choice
                    value:"High", // Default (English) text
                    comment:"High") + ": " + formatTemp(weatherFields.forecast3High as String) + " \t" + NSLocalizedString("Low_", // Unique key of your choice
                        value:"Low", // Default (English) text
                        comment:"Low") + ": " + formatTemp(weatherFields.forecast3Low as String) + " \t" + (weatherFields.forecast3Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast3Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: (weatherFields.forecast3Day as String) + ", " + formatTemp(weatherFields.forecast3High as String), action: nil, keyEquivalent: "")
                extendedForecastMenu.addItem(newItem)
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast3Code as String)
                } else {
                    newItem.image = nil
                }
                extendedForecastMenu.setSubmenu(extendedForecast, forItem: newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Date_", // Unique key of your choice
                    value:"Date", // Default (English) text
                    comment:"Date") + ": " + (weatherFields.forecast3Date as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Forecast_", // Unique key of your choice
                    value:"Forecast", // Default (English) text
                    comment:"Forecast") + ": " + (weatherFields.forecast3Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("High_", // Unique key of your choice
                    value:"High", // Default (English) text
                    comment:"High") + ": " + formatTemp(weatherFields.forecast3High as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Low_", // Unique key of your choice
                    value:"Low", // Default (English) text
                    comment:"Low") + ": " + formatTemp(weatherFields.forecast3Low as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
            }
        }
        
        if (!weatherFields.forecast4Day.isEqual("")) {
            extendedForecast = NSMenu()
            
            if (defaults.stringForKey("extendedForecastSingleLine")! == "1") {
                newItem = NSMenuItem(title: (weatherFields.forecast4Day as String) + " \t" + NSLocalizedString("High_", // Unique key of your choice
                    value:"High", // Default (English) text
                    comment:"High") + ": " + formatTemp(weatherFields.forecast4High as String) + " \t" + NSLocalizedString("Low_", // Unique key of your choice
                        value:"Low", // Default (English) text
                        comment:"Low") + ": " + formatTemp(weatherFields.forecast4Low as String) + " \t" + (weatherFields.forecast4Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast4Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: (weatherFields.forecast4Day as String) + ", " + formatTemp(weatherFields.forecast4High as String), action: nil, keyEquivalent: "")
                extendedForecastMenu.addItem(newItem)
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast4Code as String)
                } else {
                    newItem.image = nil
                }
                extendedForecastMenu.setSubmenu(extendedForecast, forItem: newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Date_", // Unique key of your choice
                    value:"Date", // Default (English) text
                    comment:"Date") + ": " + (weatherFields.forecast4Date as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Forecast_", // Unique key of your choice
                    value:"Forecast", // Default (English) text
                    comment:"Forecast") + ": " + (weatherFields.forecast4Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("High_", // Unique key of your choice
                    value:"High", // Default (English) text
                    comment:"High") + ": " + formatTemp(weatherFields.forecast4High as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Low_", // Unique key of your choice
                    value:"Low", // Default (English) text
                    comment:"Low") + ": " + formatTemp(weatherFields.forecast4Low as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
            }
        }
        
        if (!weatherFields.forecast5Day.isEqual("")) {
            extendedForecast = NSMenu()
            
            if (defaults.stringForKey("extendedForecastSingleLine")! == "1") {
                newItem = NSMenuItem(title: (weatherFields.forecast5Day as String) + " \t" + NSLocalizedString("High_", // Unique key of your choice
                    value:"High", // Default (English) text
                    comment:"High") + ": " + formatTemp(weatherFields.forecast5High as String) + " \t" + NSLocalizedString("Low_", // Unique key of your choice
                        value:"Low", // Default (English) text
                        comment:"Low") + ": " + formatTemp(weatherFields.forecast5Low as String) + " \t" + (weatherFields.forecast5Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast5Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: (weatherFields.forecast5Day as String) + ", " + formatTemp(weatherFields.forecast5High as String), action: nil, keyEquivalent: "")
                extendedForecastMenu.addItem(newItem)
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast5Code as String)
                } else {
                    newItem.image = nil
                }
                extendedForecastMenu.setSubmenu(extendedForecast, forItem: newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Date_", // Unique key of your choice
                    value:"Date", // Default (English) text
                    comment:"Date") + ": " + (weatherFields.forecast5Date as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Forecast_", // Unique key of your choice
                    value:"Forecast", // Default (English) text
                    comment:"Forecast") + ": " + (weatherFields.forecast5Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("High_", // Unique key of your choice
                    value:"High", // Default (English) text
                    comment:"High") + ": " + formatTemp(weatherFields.forecast5High as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Low_", // Unique key of your choice
                    value:"Low", // Default (English) text
                    comment:"Low") + ": " + formatTemp(weatherFields.forecast5Low as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
            }
        }
        DebugLog(String(format:"leaving extendedForecasts: %@", cityName))
    } // extendedForecasts
    
    func setRadarWind(radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // extendedForecasts
    
    func updateMenuWithSecondaryLocation(weatherFields: WeatherFields, cityName: String, menu: NSMenu) {
        
        let newLocation = NSMenu()
        var newItem : NSMenuItem
        let defaults = NSUserDefaults.standardUserDefaults()
        
        DebugLog(String(format:"in updateMenuWithSecondaryLocation: %@", cityName))

        let city = weatherFields.title1.substringFromIndex(16)
        var statusTitle = city as String + " " + formatTemp((weatherFields.currentTemp as String))
        if (defaults.stringForKey("displayHumidity")! == "1") {
            statusTitle = statusTitle + "/" + formatHumidity((weatherFields.humidity as String))
        }
        newItem = NSMenuItem(title: statusTitle, action: Selector("openWeatherURL:"), keyEquivalent: "")
        newItem.target=self
        newItem.image = setImage(weatherFields.currentCode as String)

        // http://stackoverflow.com/questions/24200888/any-way-to-replace-characters-on-swift-string
        var myURL = ""
        myURL = weatherFields.URL as String
        let replaced = String(myURL.characters.map {
            $0 == " " ? "-" : $0
            })
        
        newItem.representedObject = replaced
        menu.addItem(newItem)
        menu.setSubmenu(newLocation, forItem: newItem)
        
        var currentForecastMenu = NSMenu()
        
        if (defaults.stringForKey("currentWeatherInSubmenu")! == "1") {
            newItem = NSMenuItem(title: NSLocalizedString("CurrentConditions_", value:"Current Conditions", comment: "Current Conditions") as String, action: nil, keyEquivalent: "")
            newLocation.addItem(newItem)
            newLocation.setSubmenu(currentForecastMenu, forItem: newItem)
        } else {
            currentForecastMenu = newLocation
            newLocation.addItem(NSMenuItem.separatorItem())
        }
        
        currentConditions(weatherFields, cityName: cityName, currentForecastMenu: currentForecastMenu)
        
        if (defaults.stringForKey("viewExtendedForecast")! == "1") {
            var extendedForecastMenu = NSMenu()
            
            if (defaults.stringForKey("extendedForecastInSubmenu")! == "1") {
                newItem = NSMenuItem(title: NSLocalizedString("ExtendedForecast_", // Unique key of your choice
                    value:"Extended Forecast", // Default (English) text
                    comment:"Extended Forecast"), action: nil, keyEquivalent: "")
                newLocation.addItem(newItem)
                newLocation.setSubmenu(extendedForecastMenu, forItem: newItem)
            } else {
                extendedForecastMenu = newLocation
                newLocation.addItem(NSMenuItem.separatorItem())
            }
            extendedForecasts(weatherFields, cityName: cityName, extendedForecastMenu: extendedForecastMenu)
        }
        DebugLog(String(format:"leaving updateMenuWithSecondaryLocation: %@", cityName))
    } // updateMenuWithSecondaryLocation
    
    func updateMenuWithPrimaryLocation(weatherFields: WeatherFields, cityName: String, menu: NSMenu) {
        
        var newItem : NSMenuItem
        DebugLog(String(format:"in updateMenuWithPrimaryLocation: %@", cityName))

        menu.removeAllItems()
        if (weatherFields.currentTemp.isEqual(nil) || weatherFields.currentTemp.isEqual(""))
        {
            menu.title = NSLocalizedString("Failed_", // Unique key of your choice
                value:"Failed", // Default (English) text
                comment:"Failed")
        }
        else
        {
            let defaults = NSUserDefaults.standardUserDefaults()

            // Need to incorporate currentLink
            newItem = NSMenuItem(title: (weatherFields.title1 as String), action: Selector("openWeatherURL:"), keyEquivalent: "")
            newItem.target=self
            
            // http://stackoverflow.com/questions/24200888/any-way-to-replace-characters-on-swift-string
            var myURL = ""
            myURL = weatherFields.URL as String
            let replaced = String(myURL.characters.map {
                $0 == " " ? "-" : $0
                })
            
            newItem.representedObject = replaced
            menu.addItem(newItem)
            
            var currentForecastMenu = NSMenu()
            
            if (defaults.stringForKey("currentWeatherInSubmenu")! == "1") {
                newItem = NSMenuItem(title: NSLocalizedString("CurrentConditions_", value:"Current Conditions", comment: "Current Conditions") as String, action: nil, keyEquivalent: "")
                menu.addItem(newItem)
                menu.setSubmenu(currentForecastMenu, forItem: newItem)
            } else {
                currentForecastMenu = menu
                menu.addItem(NSMenuItem.separatorItem())
            }
            
            currentConditions(weatherFields, cityName: cityName, currentForecastMenu: currentForecastMenu)
            
            var newItem : NSMenuItem
            newItem = NSMenuItem(title: NSLocalizedString("RadarImage_", // Unique key of your choice
                value:"Radar Image", // Default (English) text
                comment:"Radar Image"), action: Selector("showRadar:"), keyEquivalent: "")
            newItem.target=self
            newItem.representedObject = weatherFields.weatherTag as String
            currentForecastMenu.addItem(newItem)
            
            if (defaults.stringForKey("viewExtendedForecast")! == "1") {
                var extendedForecastMenu = NSMenu()
                
                if (defaults.stringForKey("extendedForecastInSubmenu")! == "1") {
                    newItem = NSMenuItem(title: NSLocalizedString("ExtendedForecast_", // Unique key of your choice
                        value:"Extended Forecast", // Default (English) text
                        comment:"Extended Forecast"), action: nil, keyEquivalent: "")
                    menu.addItem(newItem)
                    menu.setSubmenu(extendedForecastMenu, forItem: newItem)
                } else {
                    extendedForecastMenu = menu
                    menu.addItem(NSMenuItem.separatorItem())
                }
                extendedForecasts(weatherFields, cityName: cityName, extendedForecastMenu: extendedForecastMenu)
            }
        }
        
        menu.addItem(NSMenuItem.separatorItem())
        
        DebugLog(String(format:"leaving updateMenuWithPrimaryLocation: %@", cityName))
    } // updateMenuWithPrimaryLocation
    
    // XMLParser Methods
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        DebugLog(String(format:"in didStartElement: %@", elementName))
        element = elementName

        if (elementName as NSString).isEqualToString("channel") {
            inChannel = true
        }
        else if (elementName as NSString).isEqualToString("title") {
            if (inChannel) {
                inTitle = true
            }
        }  else if (elementName as NSString).isEqualToString("yweather:wind")
        {
            weatherFields.windChill.appendString(attributeDict["chill"]!)
            weatherFields.windDirection.appendString(attributeDict["direction"]!)
            weatherFields.windSpeed.appendString(attributeDict["speed"]!)
        }  else if (elementName as NSString).isEqualToString("yweather:atmosphere")
        {
            weatherFields.humidity.appendString(attributeDict["humidity"]!)
            weatherFields.pressure.appendString(attributeDict["pressure"]!)
            weatherFields.visibility.appendString(attributeDict["visibility"]!)
        }  else if (elementName as NSString).isEqualToString("yweather:astronomy")
        {
            weatherFields.sunrise.appendString(attributeDict["sunrise"]!)
            weatherFields.sunset.appendString(attributeDict["sunset"]!)
        }  else if (elementName as NSString).isEqualToString("yweather:condition")
        {
            weatherFields.currentCode.appendString(attributeDict["code"]!)
            weatherFields.currentTemp.appendString(attributeDict["temp"]!)
            weatherFields.currentConditions.appendString(attributeDict["text"]!)
        }  else if (elementName as NSString).isEqualToString("yweather:location")
        {
            locationCity.appendString(attributeDict["city"]!)
            locationCountry.appendString(attributeDict["country"]!)
            locationRegion.appendString(attributeDict["region"]!)
        } else if (elementName as NSString).isEqualToString("yweather:forecast")
        {
            if (iForecastCount == 1) {
                weatherFields.forecast1Code.appendString(attributeDict["code"]!)
                weatherFields.forecast1Date.appendString(attributeDict["date"]!)
                weatherFields.forecast1Day.appendString(attributeDict["day"]!)
                weatherFields.forecast1High.appendString(attributeDict["high"]!)
                weatherFields.forecast1Low.appendString(attributeDict["low"]!)
                weatherFields.forecast1Conditions.appendString(attributeDict["text"]!)
                iForecastCount++;
            } else if (iForecastCount == 2) {
                weatherFields.forecast2Code.appendString(attributeDict["code"]!)
                weatherFields.forecast2Date.appendString(attributeDict["date"]!)
                weatherFields.forecast2Day.appendString(attributeDict["day"]!)
                weatherFields.forecast2High.appendString(attributeDict["high"]!)
                weatherFields.forecast2Low.appendString(attributeDict["low"]!)
                weatherFields.forecast2Conditions.appendString(attributeDict["text"]!)
                iForecastCount++;
            } else if (iForecastCount == 3) {
                weatherFields.forecast3Code.appendString(attributeDict["code"]!)
                weatherFields.forecast3Date.appendString(attributeDict["date"]!)
                weatherFields.forecast3Day.appendString(attributeDict["day"]!)
                weatherFields.forecast3High.appendString(attributeDict["high"]!)
                weatherFields.forecast3Low.appendString(attributeDict["low"]!)
                weatherFields.forecast3Conditions.appendString(attributeDict["text"]!)
                iForecastCount++;
            } else if (iForecastCount == 4) {
                weatherFields.forecast4Code.appendString(attributeDict["code"]!)
                weatherFields.forecast4Date.appendString(attributeDict["date"]!)
                weatherFields.forecast4Day.appendString(attributeDict["day"]!)
                weatherFields.forecast4High.appendString(attributeDict["high"]!)
                weatherFields.forecast4Low.appendString(attributeDict["low"]!)
                weatherFields.forecast4Conditions.appendString(attributeDict["text"]!)
                iForecastCount++;
            } else if (iForecastCount == 5) {
                weatherFields.forecast5Code.appendString(attributeDict["code"]!)
                weatherFields.forecast5Date.appendString(attributeDict["date"]!)
                weatherFields.forecast5Day.appendString(attributeDict["day"]!)
                weatherFields.forecast5High.appendString(attributeDict["high"]!)
                weatherFields.forecast5Low.appendString(attributeDict["low"]!)
                weatherFields.forecast5Conditions.appendString(attributeDict["text"]!)
                iForecastCount++;
            }
        }
        DebugLog(String(format:"leaving didStartElement: %@", elementName))
    } // parser parser:didStartElement
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        DebugLog(String(format:"in didEndElement: %@", elementName))
        
        if (elementName as NSString).isEqualToString("lastBuildDate") {
            inChannel = false
        }
        else if (elementName as NSString).isEqualToString("title") {
            inTitle = false
            inChannel = false
        } else if (elementName as NSString).isEqualToString("geo:long") {
        } else if (elementName as NSString).isEqualToString("yweather:atmosphere") {
        } else if (elementName as NSString).isEqualToString("yweather:astronomy") {
        } else if (elementName as NSString).isEqualToString("yweather:condition") {
        } else if (elementName as NSString).isEqualToString("yweather:location") {
        } else if (elementName as NSString).isEqualToString("yweather:forecast") {
        }
        DebugLog(String(format:"leaving didEndElement: %@", elementName))
    } // parser parser:didEndElement
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        DebugLog(String(format:"in foundCharacters: %@\n", string))
        
        if (inTitle) {
            if (weatherFields.title1.isEqual("")) {
                weatherFields.title1.appendString(string)
            }
        } else if element.isEqualToString("geo:lat") {
            if (weatherFields.latitude.isEqual("")) {
                weatherFields.latitude.appendString(string)
            }
        } else if element.isEqualToString("geo:long") {
            if (weatherFields.longitude.isEqual("")) {
                weatherFields.longitude.appendString(string)
            }
        } else if element.isEqualToString("lastBuildDate") {
            if (weatherFields.date.isEqual("")) {
                weatherFields.date.appendString(string)
            }
        } else if element.isEqualToString("woeid") {
            if (locationWOEID.isEqual("")) {
                locationWOEID.appendString(string)
            }
        } else if element.isEqualToString("guid") {
            if (weatherFields.weatherTag.isEqual("")) {
                if (string.characters.count > 8) {
                    let stringB = string.substringToIndex(string.startIndex.advancedBy(8))
                    weatherFields.weatherTag.appendString(stringB)
                } else if (string.characters.count == 8) {
                    weatherFields.weatherTag.appendString(string)
                }
            }
        }
        DebugLog(String(format:"leaving foundCharacters: %@\n", string))
    } // parser parser:foundCharacters
    
    func dummy(menu: NSMenuItem) {
        //print("dummy", terminator: "\n")
    } // dummy
    
    func openWeatherURL(menu:NSMenuItem) {
        
        let myUrl = menu.representedObject as! NSString
        DebugLog(String(format:"in openWeatherURL\n"))
        
        if let checkURL = NSURL(string: myUrl as String) {
            InfoLog(String(format:"URL: %@\n", myUrl))
            if NSWorkspace.sharedWorkspace().openURL(checkURL) {
                //print("URL successfully opened:", myUrl, terminator: "\n")
            }
        } else {
            print(NSLocalizedString("InvalidURL_", // Unique key of your choice
                value:"Invalid url", // Default (English) text
                comment:"Invalid url") + ":", myUrl, terminator: "\n")
        }
        DebugLog(String(format:"leaving openWeatherURL\n"))
    } // openWeatherURL
    
    func showRadar(menu:NSMenuItem) {

        DebugLog(String(format:"in showRadar\n"))
        
        let radarURL = menu.representedObject as! String
        InfoLog(String(format:"URL: %@\n", radarURL))
        radarWindow.radarDisplay(radarURL)
        radarWindow.showWindow(nil)
        
        DebugLog(String(format:"in showRadar\n"))
    } // showRadar
    
} // class YahooWeatherAPI
