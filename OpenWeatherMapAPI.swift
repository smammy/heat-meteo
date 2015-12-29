//
//  OpenWeatherMapAPI.swift
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
// http://home.openweathermap.org/api
//
// This API Key belongs to me (Ed Danley).
//  It is part of their FREE package.
//  At some point in time, it's possible somebody else
//  will need to register another account
//  Depending on the load the Meteo community puts on this account,
//   it's possible individuals will need either own API Key.
//
// API Key = 516da734a74ae400a4551c546567d5b7
// BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
// Price = http://openweathermap.org/price
//

import Cocoa
import Foundation

// http://stackoverflow.com/questions/24196689/how-to-get-the-power-of-some-integer-in-swift-language
// Put this at file level anywhere in your project
infix operator ** { associativity left precedence 160 }
func ** (radix: Double, power: Double) -> Double {
    return pow(radix, power)
}
func ** (radix: Int,    power: Int   ) -> Double {
    return pow(Double(radix), Double(power))
}
func ** (radix: Float,  power: Float ) -> Double {
    return pow(Double(radix), Double(power))
}

class OpenWeatherMapAPI: NSObject, NSXMLParserDelegate {
    
    let QUERY_PREFIX1 = "http://api.openweathermap.org/data/2.5/weather?q="
    let QUERY_SUFFIX1a = "&appid="
    let QUERY_SUFFIX1b = "&mode=xml&units=imperial"
    
    let QUERY_PREFIX2 = "http://api.openweathermap.org/data/2.5/forecast/daily?q="
    let QUERY_SUFFIX2a = "&appid="
    let QUERY_SUFFIX2b = "&mode=xml&units=imperial"
    
    let APIID = "516da734a74ae400a4551c546567d5b7"
    
    var Parser = NSXMLParser()
    var element = NSString()
    
    var iForecastCount = 0
    
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
        
        weatherFields.forecast6Code = ""
        weatherFields.forecast6Date = ""
        weatherFields.forecast6Day = ""
        weatherFields.forecast6High = ""
        weatherFields.forecast6Low = ""
        weatherFields.forecast6Conditions = ""
        
        weatherFields.forecast7Code = ""
        weatherFields.forecast7Date = ""
        weatherFields.forecast7Day = ""
        weatherFields.forecast7High = ""
        weatherFields.forecast7Low = ""
        weatherFields.forecast7Conditions = ""
        
        weatherFields.forecast8Code = ""
        weatherFields.forecast8Date = ""
        weatherFields.forecast8Day = ""
        weatherFields.forecast8High = ""
        weatherFields.forecast8Low = ""
        weatherFields.forecast8Conditions = ""
        
        weatherFields.forecast9Code = ""
        weatherFields.forecast9Date = ""
        weatherFields.forecast9Day = ""
        weatherFields.forecast9High = ""
        weatherFields.forecast9Low = ""
        weatherFields.forecast9Conditions = ""
        
        weatherFields.forecast10Code = ""
        weatherFields.forecast10Date = ""
        weatherFields.forecast10Day = ""
        weatherFields.forecast10High = ""
        weatherFields.forecast10Low = ""
        weatherFields.forecast10Conditions = ""
        
        weatherFields.forecast11Code = ""
        weatherFields.forecast11Date = ""
        weatherFields.forecast11Day = ""
        weatherFields.forecast11High = ""
        weatherFields.forecast11Low = ""
        weatherFields.forecast11Conditions = ""
        
        weatherFields.forecast12Code = ""
        weatherFields.forecast12Date = ""
        weatherFields.forecast12Day = ""
        weatherFields.forecast12High = ""
        weatherFields.forecast12Low = ""
        weatherFields.forecast12Conditions = ""
        
        weatherFields.forecast13Code = ""
        weatherFields.forecast13Date = ""
        weatherFields.forecast13Day = ""
        weatherFields.forecast13High = ""
        weatherFields.forecast13Low = ""
        weatherFields.forecast13Conditions = ""
        
        weatherFields.forecast14Code = ""
        weatherFields.forecast14Date = ""
        weatherFields.forecast14Day = ""
        weatherFields.forecast14High = ""
        weatherFields.forecast14Low = ""
        weatherFields.forecast14Conditions = ""
        
        weatherFields.forecast15Code = ""
        weatherFields.forecast15Date = ""
        weatherFields.forecast15Day = ""
        weatherFields.forecast15High = ""
        weatherFields.forecast15Low = ""
        weatherFields.forecast15Conditions = ""
        
        weatherFields.forecast16Code = ""
        weatherFields.forecast16Date = ""
        weatherFields.forecast16Day = ""
        weatherFields.forecast16High = ""
        weatherFields.forecast16Low = ""
        weatherFields.forecast16Conditions = ""
        
        locationCity = ""
        locationCountry = ""
        locationRegion = ""
        locationWOEID = ""
        
        Parser = NSXMLParser()
        
        iForecastCount = 1
        
        // https://OpenWeatherMap.org
        
        // Should emit "Powered by Yahoo!", https://poweredby.yahoo.com/purple.png
        //var weatherQuery = NSString()
        //weatherQuery = "SELECT * FROM weather.forecast WHERE u=c AND woeid = (SELECT woeid FROM geo.places(1) WHERE text='nome, ak')"
        
        parseURL = ""
        parseURL.appendString(QUERY_PREFIX1)
        parseURL.appendString(inputCity as String)
        parseURL.appendString(QUERY_SUFFIX1a)
        parseURL.appendString(APIID)
        parseURL.appendString(QUERY_SUFFIX1b)
        InfoLog(String(format:"URL for Current conditions OpenWeatherMap: %@\n", parseURL))
        
        parseURL = ""
        parseURL.appendString(QUERY_PREFIX1)
        escapedCity = inputCity.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        escapedCity = escapedCity.stringByReplacingOccurrencesOfString(",", withString: "%3D")
        parseURL.appendString(escapedCity as String)
        parseURL.appendString(QUERY_SUFFIX1a)
        parseURL.appendString(APIID)
        parseURL.appendString(QUERY_SUFFIX1b)
        Parser = NSXMLParser(contentsOfURL:(NSURL(string:parseURL as String))!)!
        
        // Find Current weather conditions
        Parser.delegate = self
        Parser.parse()
        
        parseURL = ""
        parseURL.appendString(QUERY_PREFIX2)
        parseURL.appendString(inputCity as String)
        parseURL.appendString(QUERY_SUFFIX2a)
        parseURL.appendString(APIID)
        parseURL.appendString(QUERY_SUFFIX2b)
        InfoLog(String(format:"URL for Forecast conditions OpenWeatherMap: %@\n", parseURL))
        
        parseURL = ""
        parseURL.appendString(QUERY_PREFIX2)
        escapedCity = inputCity.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        escapedCity = escapedCity.stringByReplacingOccurrencesOfString(",", withString: "%3D")
        parseURL.appendString(escapedCity as String)
        parseURL.appendString(QUERY_SUFFIX2a)
        parseURL.appendString(APIID)
        parseURL.appendString(QUERY_SUFFIX2b)
        Parser = NSXMLParser(contentsOfURL:(NSURL(string:parseURL as String))!)!
        
        // Find Forecast weather conditions
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
        // http://openweathermap.org/weather-conditions
        if (weatherCode == "") {
            return NSImage(named: "MB-Sun")!
        }
        else if (weatherCode == "01d") {
            return NSImage(named: "MB-Sun")!
        }
        else if (weatherCode == "01n") {
            return NSImage(named: "MB-Moon")!
        }
        else if (weatherCode == "02d") {
            return NSImage(named: "MB-Sun-Cloud-1")!
        }
        else if (weatherCode == "02n") {
            return NSImage(named: "MB-Moon-Cloud-1")!
        }
        else if ((weatherCode == "03d") ||
                 (weatherCode == "03n")) {
            return NSImage(named: "MB-Cloudy")!
        }
        else if (weatherCode == "04d") {
            return NSImage(named: "MB-Sun-Cloud-2")!
        }
        else if (weatherCode == "04n") {
            return NSImage(named: "MB-Moon-Cloud-2")!
        }
        else if ((weatherCode == "09d") ||
            (weatherCode == "09n") ||
            (weatherCode == "10d") ||
            (weatherCode == "10n")) {
                return NSImage(named: "MB-Rain")!
        }
        else if ((weatherCode == "50d") ||
            (weatherCode == "50n")) {
                return NSImage(named: "MB-Hazy")!
        }
        else if ((weatherCode == "11d") ||
            (weatherCode == "11n")) {
                return NSImage(named: "MB-Thunderstorm")!
        }
        else if ((weatherCode == "13d") ||
            (weatherCode == "13n")) {
                return NSImage(named: "MB-Snow")!
        }
        return NSImage(named: weatherCode)!
    } // setImage
    
    func formatDay(temp: String) -> String {
        var returnDay = temp
        if ((temp != "Mon") &&
            (temp != "Wed")) {
                returnDay.appendContentsOf(" ")
        }
        if (temp == "Fri") {
            returnDay.appendContentsOf(" ")
        }
        return returnDay
    } // formatDay
    
    func formatTemp(temp: String) -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        var formattedTemp = String(Int(((temp as NSString).doubleValue)))
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
    
    func calculateFeelsLike(sTemperature: String, sWindspeed: String, sRH: String) -> String {
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
        if (sTemperature != "") {
            temp = Double(sTemperature)!
        }
        if (sWindspeed != "") {
            windspeed = Double(sWindspeed)!
        }
        if (sRH != "") {
            rh = Double(sRH)!
        }

        var feelsLike = sTemperature

        if ((temp < 50) && (windspeed > 3)) {
            // Windchill (ºF) = 35.74 + 0.6215T - 35.75(V^0.16) + 0.4275T(V^0.16)
            let Windchill1 = (0.6215 * temp)
            let Windchill2 = (35.75 * (windspeed ** 0.16))
            let Windchill3 = (0.4275 * temp * (windspeed ** 0.16))
            let Windchill = 35.74 + Windchill1 - Windchill2 + Windchill3
            feelsLike = String(format:"%.0f", Windchill)
        } else if ((temp > 80) && (rh > 40)) {
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
    }

    func convertUTCtoHHMM(myTime: String) -> String {
        // create dateFormatter with UTC time format
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let date = dateFormatter.dateFromString(myTime)
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter.stringFromDate(date!)
    }
    
    func convertUTCtoEEE(myTime: String) -> String {
        // EEE is Mon, Tue, Wed, etc.
        // create dateFormatter with UTC time format
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let date = dateFormatter.dateFromString(myTime)
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "EEE"
        return formatDay(dateFormatter.stringFromDate(date!))
    }
    
    func formatWindSpeed(speed2: String, direction: String) -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        var formattedWindSpeed = String(Int(((direction as NSString).doubleValue))) + "° @ "
        let speed = String(Int(((speed2 as NSString).doubleValue)))
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
    
    func formatPressure(pressure2: String) -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        var formattedPressure = ""
        let pressure = String(format: "%.2f", (pressure2 as NSString).doubleValue / 33.8637526)
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
                value:"hp", // Default (English) text
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
            comment:"Feels Like") + ": " + calculateFeelsLike((weatherFields.currentTemp as String), sWindspeed: (weatherFields.windSpeed as String), sRH: (weatherFields.humidity as String)), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("Humidity_", // Unique key of your choice
            value:"Humidity", // Default (English) text
            comment:"Humidity_") + ": " + formatHumidity(weatherFields.humidity as String), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
        //newItem = NSMenuItem(title: NSLocalizedString("Visibility_", // Unique key of your choice
        //    value:"Visibility", // Default (English) text
        //    comment:"Visibility") + ": " + formatVisibility(weatherFields.visibility as String), action: Selector("dummy:"), keyEquivalent: "")
        //newItem.target=self
        //currentForecastMenu.addItem(newItem)
        
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
            comment:"Sunrise/sunset") + ": " + convertUTCtoHHMM(weatherFields.sunrise as String) + " / " + convertUTCtoHHMM(weatherFields.sunset as String), action: Selector("dummy:"), keyEquivalent: "")
        newItem.target=self
        currentForecastMenu.addItem(newItem)
        
        newItem = NSMenuItem(title: NSLocalizedString("LastUpdate_", // Unique key of your choice
            value:"Last Update", // Default (English) text
            comment:"Last Update") + ": " + convertUTCtoHHMM(weatherFields.date as String), action: Selector("dummy:"), keyEquivalent: "")
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
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast1Day as String) + " \t" + formatTemp(weatherFields.forecast1High as String) + "/" + formatTemp(weatherFields.forecast1Low as String) + " \t" + (weatherFields.forecast1Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast1Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast1Day as String) + ", " + formatTemp(weatherFields.forecast1High as String), action: nil, keyEquivalent: "")
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
                
                newItem = NSMenuItem(title: formatTemp(weatherFields.forecast1High as String), action: Selector("dummy:"), keyEquivalent: "")
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
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast2Day as String) + " \t" + formatTemp(weatherFields.forecast2High as String) + "/" + formatTemp(weatherFields.forecast2Low as String) + " \t" + (weatherFields.forecast2Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast2Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast2Day as String) + ", " + formatTemp(weatherFields.forecast2High as String), action: nil, keyEquivalent: "")
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
                
                newItem = NSMenuItem(title: formatTemp(weatherFields.forecast2High as String), action: Selector("dummy:"), keyEquivalent: "")
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
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast3Day as String) + " \t" + formatTemp(weatherFields.forecast3High as String) + "/" + formatTemp(weatherFields.forecast3Low as String) + " \t" + (weatherFields.forecast3Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast3Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast3Day as String) + ", " + formatTemp(weatherFields.forecast3High as String), action: nil, keyEquivalent: "")
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
                
                newItem = NSMenuItem(title: formatTemp(weatherFields.forecast3High as String), action: Selector("dummy:"), keyEquivalent: "")
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
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast4Day as String) + " \t" + formatTemp(weatherFields.forecast4High as String) + "/" + formatTemp(weatherFields.forecast4Low as String) + " \t" + (weatherFields.forecast4Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast4Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast4Day as String) + ", " + formatTemp(weatherFields.forecast4High as String), action: nil, keyEquivalent: "")
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
                
                newItem = NSMenuItem(title: formatTemp(weatherFields.forecast4High as String), action: Selector("dummy:"), keyEquivalent: "")
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
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast5Day as String) + " \t" + formatTemp(weatherFields.forecast5High as String) + "/" + formatTemp(weatherFields.forecast5Low as String) + " \t" + (weatherFields.forecast5Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast5Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast5Day as String) + ", " + formatTemp(weatherFields.forecast5High as String), action: nil, keyEquivalent: "")
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
                
                newItem = NSMenuItem(title: formatTemp(weatherFields.forecast5High as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Low_", // Unique key of your choice
                    value:"Low", // Default (English) text
                    comment:"Low") + ": " + formatTemp(weatherFields.forecast5Low as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
            }
        }
        
        if (!weatherFields.forecast6Day.isEqual("")) {
            extendedForecast = NSMenu()
            
            if (defaults.stringForKey("extendedForecastSingleLine")! == "1") {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast6Day as String) + " \t" + formatTemp(weatherFields.forecast6High as String) + "/" + formatTemp(weatherFields.forecast6Low as String) + " \t" + (weatherFields.forecast6Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast6Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast6Day as String) + ", " + formatTemp(weatherFields.forecast6High as String), action: nil, keyEquivalent: "")
                extendedForecastMenu.addItem(newItem)
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast6Code as String)
                } else {
                    newItem.image = nil
                }
                extendedForecastMenu.setSubmenu(extendedForecast, forItem: newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Date_", // Unique key of your choice
                    value:"Date", // Default (English) text
                    comment:"Date") + ": " + (weatherFields.forecast6Date as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Forecast_", // Unique key of your choice
                    value:"Forecast", // Default (English) text
                    comment:"Forecast") + ": " + (weatherFields.forecast6Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: formatTemp(weatherFields.forecast6High as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Low_", // Unique key of your choice
                    value:"Low", // Default (English) text
                    comment:"Low") + ": " + formatTemp(weatherFields.forecast6Low as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
            }
        }
        
        if (!weatherFields.forecast7Day.isEqual("")) {
            extendedForecast = NSMenu()
            
            if (defaults.stringForKey("extendedForecastSingleLine")! == "1") {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast7Day as String) + " \t" + formatTemp(weatherFields.forecast7High as String) + "/" + formatTemp(weatherFields.forecast7Low as String) + " \t" + (weatherFields.forecast7Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast7Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast7Day as String) + ", " + formatTemp(weatherFields.forecast7High as String), action: nil, keyEquivalent: "")
                extendedForecastMenu.addItem(newItem)
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast7Code as String)
                } else {
                    newItem.image = nil
                }
                extendedForecastMenu.setSubmenu(extendedForecast, forItem: newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Date_", // Unique key of your choice
                    value:"Date", // Default (English) text
                    comment:"Date") + ": " + (weatherFields.forecast7Date as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Forecast_", // Unique key of your choice
                    value:"Forecast", // Default (English) text
                    comment:"Forecast") + ": " + (weatherFields.forecast7Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: formatTemp(weatherFields.forecast7High as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Low_", // Unique key of your choice
                    value:"Low", // Default (English) text
                    comment:"Low") + ": " + formatTemp(weatherFields.forecast7Low as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
            }
        }
        
        if (!weatherFields.forecast8Day.isEqual("")) {
            extendedForecast = NSMenu()
            
            if (defaults.stringForKey("extendedForecastSingleLine")! == "1") {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast8Day as String) + " \t" + formatTemp(weatherFields.forecast8High as String) + "/" + formatTemp(weatherFields.forecast8Low as String) + " \t" + (weatherFields.forecast8Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast8Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast8Day as String) + ", " + formatTemp(weatherFields.forecast8High as String), action: nil, keyEquivalent: "")
                extendedForecastMenu.addItem(newItem)
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast8Code as String)
                } else {
                    newItem.image = nil
                }
                extendedForecastMenu.setSubmenu(extendedForecast, forItem: newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Date_", // Unique key of your choice
                    value:"Date", // Default (English) text
                    comment:"Date") + ": " + (weatherFields.forecast8Date as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Forecast_", // Unique key of your choice
                    value:"Forecast", // Default (English) text
                    comment:"Forecast") + ": " + (weatherFields.forecast8Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: formatTemp(weatherFields.forecast8High as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Low_", // Unique key of your choice
                    value:"Low", // Default (English) text
                    comment:"Low") + ": " + formatTemp(weatherFields.forecast8Low as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
            }
        }
        
        if (!weatherFields.forecast9Day.isEqual("")) {
            extendedForecast = NSMenu()
            
            if (defaults.stringForKey("extendedForecastSingleLine")! == "1") {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast9Day as String) + " \t" + formatTemp(weatherFields.forecast9High as String) + "/" + formatTemp(weatherFields.forecast9Low as String) + " \t" + (weatherFields.forecast9Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast9Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast9Day as String) + ", " + formatTemp(weatherFields.forecast9High as String), action: nil, keyEquivalent: "")
                extendedForecastMenu.addItem(newItem)
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast9Code as String)
                } else {
                    newItem.image = nil
                }
                extendedForecastMenu.setSubmenu(extendedForecast, forItem: newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Date_", // Unique key of your choice
                    value:"Date", // Default (English) text
                    comment:"Date") + ": " + (weatherFields.forecast9Date as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Forecast_", // Unique key of your choice
                    value:"Forecast", // Default (English) text
                    comment:"Forecast") + ": " + (weatherFields.forecast9Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: formatTemp(weatherFields.forecast9High as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Low_", // Unique key of your choice
                    value:"Low", // Default (English) text
                    comment:"Low") + ": " + formatTemp(weatherFields.forecast9Low as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
            }
        }
        
        if (!weatherFields.forecast10Day.isEqual("")) {
            extendedForecast = NSMenu()
            
            if (defaults.stringForKey("extendedForecastSingleLine")! == "1") {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast10Day as String) + " \t" + formatTemp(weatherFields.forecast10High as String) + "/" + formatTemp(weatherFields.forecast10Low as String) + " \t" + (weatherFields.forecast10Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast10Code as String)
                } else {
                    newItem.image = nil
                }
                newItem.target=self
                extendedForecastMenu.addItem(newItem)
            } else {
                newItem = NSMenuItem(title: convertUTCtoEEE(weatherFields.forecast10Day as String) + ", " + formatTemp(weatherFields.forecast10High as String), action: nil, keyEquivalent: "")
                extendedForecastMenu.addItem(newItem)
                if (defaults.stringForKey("extendedForecastIcons")! == "1") {
                    newItem.image=setImage(weatherFields.forecast10Code as String)
                } else {
                    newItem.image = nil
                }
                extendedForecastMenu.setSubmenu(extendedForecast, forItem: newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Date_", // Unique key of your choice
                    value:"Date", // Default (English) text
                    comment:"Date") + ": " + (weatherFields.forecast10Date as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Forecast_", // Unique key of your choice
                    value:"Forecast", // Default (English) text
                    comment:"Forecast") + ": " + (weatherFields.forecast10Conditions as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: formatTemp(weatherFields.forecast10High as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
                
                newItem = NSMenuItem(title: NSLocalizedString("Low_", // Unique key of your choice
                    value:"Low", // Default (English) text
                    comment:"Low") + ": " + formatTemp(weatherFields.forecast10Low as String), action: Selector("dummy:"), keyEquivalent: "")
                newItem.target=self
                extendedForecast.addItem(newItem)
            }
        }
        DebugLog(String(format:"leaving extendedForecasts: %@", cityName))
    } // extendedForecasts
    
    func setRadarWind(radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // extendedForecasts
    
    func updateMenuWithSecondaryLocation(weatherFields: WeatherFields, cityName: String, displayCityName: String, menu: NSMenu) {
        
        let newLocation = NSMenu()
        var newItem : NSMenuItem
        let defaults = NSUserDefaults.standardUserDefaults()
        
        DebugLog(String(format:"in updateMenuWithSecondaryLocation: %@", cityName))
        
        var city = displayCityName
        if (city == "") {
            city = weatherFields.title1 as String
        }
        
        var statusTitle = city + " " + formatTemp((weatherFields.currentTemp as String))
        if (defaults.stringForKey("displayHumidity")! == "1") {
            statusTitle = statusTitle + "/" + formatHumidity((weatherFields.humidity as String))
        }
        newItem = NSMenuItem(title: statusTitle, action: Selector("openWeatherURL:"), keyEquivalent: "")
        newItem.target=self
        newItem.image = setImage(weatherFields.currentCode as String)
        
        let replaced = String("http://openweathermap.org/city/" +  (locationWOEID as String))
        
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
        
        currentConditions(weatherFields, cityName: displayCityName, currentForecastMenu: currentForecastMenu)
        
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
            extendedForecasts(weatherFields, cityName: displayCityName, extendedForecastMenu: extendedForecastMenu)
        }
        DebugLog(String(format:"leaving updateMenuWithSecondaryLocation: %@", cityName))
    } // updateMenuWithSecondaryLocation
    
    func updateMenuWithPrimaryLocation(weatherFields: WeatherFields, cityName: String, displayCityName: String, menu: NSMenu) {
        
        var newItem : NSMenuItem
        DebugLog(String(format:"in updateMenuWithPrimaryLocation: %@", cityName))
        
        var city = displayCityName
        if (city == "") {
            city = weatherFields.title1 as String
        }

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
            newItem = NSMenuItem(title: "OpenWeatherMap.org - " + city, action: Selector("openWeatherURL:"), keyEquivalent: "")
            newItem.target=self
            
            let replaced = String("http://openweathermap.org/city/" +  (locationWOEID as String))
            
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
            
            currentConditions(weatherFields, cityName: displayCityName, currentForecastMenu: currentForecastMenu)
            
            var newItem : NSMenuItem
            newItem = NSMenuItem(title: NSLocalizedString("RadarImage_", // Unique key of your choice
                value:"Radar Image", // Default (English) text
                comment:"Radar Image"), action: Selector("showRadar:"), keyEquivalent: "")
            newItem.target=self
            let myURL = String("http://openweathermap.org/city/" +  (locationWOEID as String) + "#map")
            newItem.representedObject = myURL
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
                extendedForecasts(weatherFields, cityName: displayCityName, extendedForecastMenu: extendedForecastMenu)
            }
        }
        
        menu.addItem(NSMenuItem.separatorItem())
        
        DebugLog(String(format:"leaving updateMenuWithPrimaryLocation: %@", cityName))
    } // updateMenuWithPrimaryLocation
    
    // XMLParser Methods
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        DebugLog(String(format:"in didStartElement: %@", elementName))
        element = elementName
        
        if (elementName as NSString).isEqualToString("city") {
            weatherFields.title1.appendString(attributeDict["name"]!)
            locationCity.appendString(attributeDict["name"]!)
            locationWOEID.appendString(attributeDict["id"]!)
            
        } else if (elementName as NSString).isEqualToString("coord") {
            weatherFields.latitude.appendString(attributeDict["lat"]!)
            weatherFields.longitude.appendString(attributeDict["lon"]!)
            
        } else if (elementName as NSString).isEqualToString("speed") {
            weatherFields.windSpeed.appendString(attributeDict["value"]!)
            
        } else if (elementName as NSString).isEqualToString("lastupdate") {
            if (attributeDict["value"] != nil) {
                weatherFields.date.appendString(attributeDict["value"]!)
            }
            
        } else if (elementName as NSString).isEqualToString("gusts") {
            //let Gusts = attributeDict["value"]!
            //if (Gusts != "") {
            //    weatherFields.windSpeed.appendString("G")
            //    weatherFields.windSpeed.appendString(attributeDict["value"]!)
            //}
            
        } else if (elementName as NSString).isEqualToString("direction") {
            //weatherFields.windChill.appendString(attributeDict["code"]!)
            weatherFields.windDirection.appendString(attributeDict["value"]!)
            
        } else if (elementName as NSString).isEqualToString("humidity") {
            if (weatherFields.humidity == "") {
                weatherFields.humidity.appendString(attributeDict["value"]!)
            }
            
        } else if (elementName as NSString).isEqualToString("pressure") {
            if (weatherFields.pressure == "") {
                weatherFields.pressure.appendString(attributeDict["value"]!)
            }
            
        } else if (elementName as NSString).isEqualToString("sun") {
            if (weatherFields.sunrise == "") {
                weatherFields.sunrise.appendString(attributeDict["rise"]!)
                weatherFields.sunset.appendString(attributeDict["set"]!)
            }
            
        } else if (elementName as NSString).isEqualToString("temperature") {
            if (attributeDict["value"] != nil) {
                weatherFields.currentTemp.appendString(attributeDict["value"]!)
            }
            else
            {
                if (iForecastCount == 1) {
                    weatherFields.forecast1High.appendString(attributeDict["max"]!)
                    weatherFields.forecast1Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 2) {
                    weatherFields.forecast2High.appendString(attributeDict["max"]!)
                    weatherFields.forecast2Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 3) {
                    weatherFields.forecast3High.appendString(attributeDict["max"]!)
                    weatherFields.forecast3Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 4) {
                    weatherFields.forecast4High.appendString(attributeDict["max"]!)
                    weatherFields.forecast4Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 5) {
                    weatherFields.forecast5High.appendString(attributeDict["max"]!)
                    weatherFields.forecast5Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 6) {
                    weatherFields.forecast6High.appendString(attributeDict["max"]!)
                    weatherFields.forecast6Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 7) {
                    weatherFields.forecast7High.appendString(attributeDict["max"]!)
                    weatherFields.forecast7Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 8) {
                    weatherFields.forecast8High.appendString(attributeDict["max"]!)
                    weatherFields.forecast8Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 9) {
                    weatherFields.forecast9High.appendString(attributeDict["max"]!)
                    weatherFields.forecast9Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 10) {
                    weatherFields.forecast10High.appendString(attributeDict["max"]!)
                    weatherFields.forecast10Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 11) {
                    weatherFields.forecast11High.appendString(attributeDict["max"]!)
                    weatherFields.forecast11Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 12) {
                    weatherFields.forecast12High.appendString(attributeDict["max"]!)
                    weatherFields.forecast12Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 13) {
                    weatherFields.forecast13High.appendString(attributeDict["max"]!)
                    weatherFields.forecast13Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 14) {
                    weatherFields.forecast14High.appendString(attributeDict["max"]!)
                    weatherFields.forecast14Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 15) {
                    weatherFields.forecast15High.appendString(attributeDict["max"]!)
                    weatherFields.forecast15Low.appendString(attributeDict["min"]!)
                } else if (iForecastCount == 16) {
                    weatherFields.forecast16High.appendString(attributeDict["max"]!)
                    weatherFields.forecast16Low.appendString(attributeDict["min"]!)
                }
            }
            
        } else if (elementName as NSString).isEqualToString("weather") {
            weatherFields.currentCode.appendString(attributeDict["icon"]!)
            
        } else if (elementName as NSString).isEqualToString("clouds") {
            if (attributeDict["name"] != nil) {
                weatherFields.currentConditions.appendString(attributeDict["name"]!)
            }
            
        } else if (elementName as NSString).isEqualToString("visibility") {
            //weatherFields.visibility.appendString(attributeDict["id"]!)
            
        } else if (elementName as NSString).isEqualToString("time") {
            if (iForecastCount == 1) {
                weatherFields.forecast1Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 2) {
                weatherFields.forecast2Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 3) {
                weatherFields.forecast3Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 4) {
                weatherFields.forecast4Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 5) {
                weatherFields.forecast5Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 6) {
                weatherFields.forecast6Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 7) {
                weatherFields.forecast7Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 8) {
                weatherFields.forecast8Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 9) {
                weatherFields.forecast9Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 10) {
                weatherFields.forecast10Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 11) {
                weatherFields.forecast11Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 12) {
                weatherFields.forecast12Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 13) {
                weatherFields.forecast13Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 14) {
                weatherFields.forecast14Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 15) {
                weatherFields.forecast15Day.appendString(attributeDict["day"]!)
            } else if (iForecastCount == 16) {
                weatherFields.forecast16Day.appendString(attributeDict["day"]!)
            }
            
        } else if (elementName as NSString).isEqualToString("symbol") {
            if (iForecastCount == 1) {
                weatherFields.forecast1Code.appendString(attributeDict["var"]!)
                weatherFields.forecast1Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 2) {
                weatherFields.forecast2Code.appendString(attributeDict["var"]!)
                weatherFields.forecast2Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 3) {
                weatherFields.forecast3Code.appendString(attributeDict["var"]!)
                weatherFields.forecast3Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 4) {
                weatherFields.forecast4Code.appendString(attributeDict["var"]!)
                weatherFields.forecast4Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 5) {
                weatherFields.forecast5Code.appendString(attributeDict["var"]!)
                weatherFields.forecast5Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 6) {
                weatherFields.forecast6Code.appendString(attributeDict["var"]!)
                weatherFields.forecast6Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 7) {
                weatherFields.forecast7Code.appendString(attributeDict["var"]!)
                weatherFields.forecast7Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 8) {
                weatherFields.forecast8Code.appendString(attributeDict["var"]!)
                weatherFields.forecast8Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 9) {
                weatherFields.forecast9Code.appendString(attributeDict["var"]!)
                weatherFields.forecast9Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 10) {
                weatherFields.forecast10Code.appendString(attributeDict["var"]!)
                weatherFields.forecast10Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 11) {
                weatherFields.forecast11Code.appendString(attributeDict["var"]!)
                weatherFields.forecast11Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 12) {
                weatherFields.forecast12Code.appendString(attributeDict["var"]!)
                weatherFields.forecast12Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 13) {
                weatherFields.forecast13Code.appendString(attributeDict["var"]!)
                weatherFields.forecast13Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 14) {
                weatherFields.forecast14Code.appendString(attributeDict["var"]!)
                weatherFields.forecast14Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 15) {
                weatherFields.forecast15Code.appendString(attributeDict["var"]!)
                weatherFields.forecast15Conditions.appendString(attributeDict["name"]!)
            } else if (iForecastCount == 16) {
                weatherFields.forecast16Code.appendString(attributeDict["var"]!)
                weatherFields.forecast16Conditions.appendString(attributeDict["name"]!)
            }
            
        }
        DebugLog(String(format:"leaving didStartElement: %@", elementName))
    } // parser parser:didStartElement
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        DebugLog(String(format:"in didEndElement: %@", elementName))
        
        if (elementName as NSString).isEqualToString("time") {
            iForecastCount++;
        }
        DebugLog(String(format:"leaving didEndElement: %@", elementName))
    } // parser parser:didEndElement
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        DebugLog(String(format:"in foundCharacters: %@\n", string))
        
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
    
} // class OpenWeatherMapAPI
