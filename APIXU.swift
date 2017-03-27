//
//  APIXU.swift
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
// https://www.apixu.com/api.aspx
//
// Key: 8c67b21afb7d4184ba0235136171603
//
// Sample: http://api.apixu.com/v1/forecast.json?key=8c67b21afb7d4184ba0235136171603&q=Naperville,IL

import Cocoa
import Foundation

class APIXUAPI: NSObject, XMLParserDelegate
{
    ///*
    let QUERY_PREFIX1 = "http://api.apixu.com/v1/forecast.json?key="
    let QUERY_SUFFIX1 = "&days=10&q="
    
    var weatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()
    
    var escapedCity = NSString()
    var parseURL = String()
    
    func fixIcon(icon: String) -> String
    {
        var workingString = icon
        
        if (workingString.hasSuffix(" outbreaks in nearby"))
        {
            workingString = String(workingString.characters.dropLast(10))
        }
        
        if (workingString.hasSuffix(" at times"))
        {
            workingString = String(workingString.characters.dropLast(9))
        }
        
        if (workingString.hasSuffix(" in area with thunder"))
        {
            workingString = String(workingString.characters.dropLast(21))
        }
        
        if (workingString.hasSuffix(" of ice pellets"))
        {
            workingString = String(workingString.characters.dropLast(15))
        }
        
        if (workingString.hasSuffix(" shower"))
        {
            workingString = String(workingString.characters.dropLast(7))
        }
        
        if (workingString.hasSuffix(" showers"))
        {
            workingString = String(workingString.characters.dropLast(8))
        }
        
        if (workingString.hasSuffix(" nearby"))
        {
            workingString = String(workingString.characters.dropLast(7))
        }
        
        if (workingString.hasSuffix(" possible"))
        {
            workingString = String(workingString.characters.dropLast(9))
        }
        
        if (workingString.hasPrefix("Patchy "))
        {
            workingString = String(workingString.characters.dropFirst(7))
        }
        
        if (workingString.hasPrefix("Partly "))
        {
            workingString = String(workingString.characters.dropFirst(7))
        }
        
        if ((workingString.hasPrefix("freezing ")) ||
            (workingString.hasPrefix("Freezing ")))
        {
            workingString = String(workingString.characters.dropFirst(9))
        }
        
        if ((workingString.hasPrefix("heavy ")) ||
            (workingString.hasPrefix("Heavy ")))
        {
            workingString = String(workingString.characters.dropFirst(6))
        }
        
        if ((workingString.hasPrefix("light ")) ||
            (workingString.hasPrefix("Light ")))
        {
            workingString = String(workingString.characters.dropFirst(6))
        }
        
        if ((workingString.hasPrefix("strong ")) ||
            (workingString.hasPrefix("Strong ")))
        {
            workingString = String(workingString.characters.dropFirst(7))
        }
        
        if (workingString.hasPrefix("Moderate "))
        {
            workingString = String(workingString.characters.dropFirst(9))
        }
        
        if (workingString.hasPrefix("or "))
        {
            workingString = String(workingString.characters.dropFirst(3))
            workingString = fixIcon(icon: workingString) // Yes recursion
        }
        
        return workingString
    } // fixIcon
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String) -> WeatherFields
    {
        DebugLog(String(format:"in APIXU beginParsing: %@", inputCity))
        
        weatherFields.forecastCounter = 0
        
        AppDelegate().initWeatherFields(weatherFields: &weatherFields)

        escapedCity = inputCity.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
        escapedCity = escapedCity.replacingOccurrences(of: ",", with: "%3D") as NSString
        
        parseURL = QUERY_PREFIX1 + APIKey1 + QUERY_SUFFIX1 + (escapedCity as String)
        DebugLog(String(format:"URL for observations APIXU: %@\n", parseURL))
        
        let url = URL(string: parseURL)
        var data: NSData?
        data = nil
        if (url != nil)
        {
            data = NSData(contentsOf: url!)
        }
        if (data == nil)
        {
            weatherFields.currentTemp = "9999"
            weatherFields.latitude = localizedString(forKey: "InvalidKey_")
            return weatherFields
        }
        
        do {
            let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readJSONObject(object: dictionary)
            }
        } catch {
            // Handle Error
        }
        
        DebugLog(String(format:"leaving APIXU beginParsing: %@", inputCity))
        
        return weatherFields
    } // beginParsing
    
    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // setRadarWind
    
    func readJSONObject(object: [String: AnyObject]) {
        guard
            let location = object["location"] as? [String: AnyObject],
            let current = object["current"] as? [String: AnyObject],
            let forecast = object["forecast"] as? [String: AnyObject]
            else {
                _ = "error"
                return }
        
        for l in [location] {
            guard
                let city = l["name"] as? String,
                let lat = l["lat"] as? Float,
                let long = l["lon"] as? Float
                else {
                    _ = "error"
                    return }
            weatherFields.title1 = city
            weatherFields.latitude = NSString(format: "%.2f", lat) as String
            weatherFields.longitude = NSString(format: "%.2f", long) as String
        }
        
        for c in [current] {
            guard
                let unixdate = c["last_updated_epoch"] as? Int,
                let temp_F = c["temp_f"] as? Float,
                let vis_miles = c["vis_miles"] as? Float,
                let humidity = c["humidity"] as? Float,
                let pressure = c["pressure_mb"] as? Float,
                let windspeedMiles = c["wind_mph"] as? Float,
                let winddirDegree = c["wind_degree"] as? Float,
                let condition = c["condition"] as? [String: AnyObject]
                else {
                    _ = "error"
                    return }
            
            // Convert epoch to UTC
            let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            weatherFields.date = dateFormatter.string(from: date as Date)
            
            weatherFields.currentTemp = NSString(format: "%.0f", temp_F) as String
            weatherFields.humidity = NSString(format: "%.0f", humidity) as String
            weatherFields.pressure = NSString(format: "%.2f", pressure) as String
            weatherFields.windSpeed = NSString(format: "%.1f", windspeedMiles) as String
            weatherFields.windDirection = NSString(format: "%f", winddirDegree) as String
            weatherFields.visibility = NSString(format: "%.0f", vis_miles) as String
            
            for cond in [condition] {
                guard
                    let icon = cond["text"] as? String
                    else {
                        _ = "error"
                        return }
                weatherFields.currentConditions = icon
                weatherFields.currentCode = fixIcon(icon: icon)
            }
        }
        
        for f in [forecast] {
            guard
                let forecastday = f["forecastday"] as? [[String: AnyObject]]
                else {
                    _ = "error"
                    return }
            for f2 in forecastday {
                guard
                    let unixdate = f2["date_epoch"] as? Int,
                    let day = f2["day"] as? [String: AnyObject],
                    let astro = f2["astro"] as? [String: AnyObject]
                    else {
                        _ = "error"
                        return }
                
                let dateFormatter = DateFormatter()
                // Convert epoch to DOW
                let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
                
                dateFormatter.dateFormat = "E"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                weatherFields.forecastDay[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)
                
                // Convert epoch to UTC
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                weatherFields.forecastDate[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)
                
                for d in [day] {
                    guard
                        let maxtempF = d["maxtemp_f"] as? Float,
                        let mintempF = d["mintemp_f"] as? Float,
                        let condition = d["condition"] as? [String: AnyObject]
                        else {
                            _ = "error"
                            return }
                    for cond in [condition] {
                        guard
                            let icon = cond["text"] as? String
                            else {
                                _ = "error"
                                return }
                        weatherFields.forecastCode[weatherFields.forecastCounter] = icon
                        weatherFields.forecastConditions[weatherFields.forecastCounter] = icon
                    }
                    weatherFields.forecastLow[weatherFields.forecastCounter] = NSString(format: "%.0f", mintempF) as String
                    weatherFields.forecastHigh[weatherFields.forecastCounter] = NSString(format: "%.0f", maxtempF) as String
                }
                if (weatherFields.forecastCounter == 0)
                {
                    for a in [astro] {
                        guard
                            let sunrise = a["sunrise"] as? String,
                            let sunset = a["sunset"] as? String
                            else {
                                _ = "error"
                                return }
                        weatherFields.sunrise = sunrise
                        weatherFields.sunset = sunset
                    }
                }
                weatherFields.forecastCounter = weatherFields.forecastCounter + 1
            }
        }
    } // readJSONObject
    //*/
    
} // APIXUAPI
