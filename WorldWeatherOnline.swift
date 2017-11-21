//
//  WorldWeatherOnline.swift
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
// https://developer.worldweatheronline.com
//
// Key: fee570cfd0d84387ab431117160408 (disabled)
// Key: 0e512c7a9d6248a7a1e44457171202
//
// Sample: http://api.worldweatheronline.com/free/v2/weather.ashx?q=London,united+kingdom&key=0e512c7a9d6248a7a1e44457171202&num_of_days=10&tp=24&format=json

import Cocoa
import Foundation

class WorldWeatherOnlineAPI: NSObject, XMLParserDelegate
{
    //let QUERY_PREFIX1 = "http://api.worldweatheronline.com/free/v2/weather.ashx?q="
    let QUERY_PREFIX1 = "http://api.worldweatheronline.com/premium/v1/weather.ashx?q="
    let QUERY_SUFFIX1 = "&num_of_days=10&tp=24&format=json&mca=no&date_format=unix&key="
    
    var weatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()
    
    var escapedCity = NSString()
    var parseURL = String()
    
    func fixIcon(icon: String) -> String
    {
        var workingString = icon
        
        if (workingString.hasSuffix(" outbreaks in nearby"))
        {
            //workingString = String(workingString.characters.dropLast(10))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -10)])
        }
        
        if (workingString.hasSuffix(" at times"))
        {
            //workingString = String(workingString.characters.dropLast(9))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -9)])
        }
        
        if (workingString.hasSuffix(" in area with thunder"))
        {
            //workingString = String(workingString.characters.dropLast(21))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -12)])
        }
        
        if (workingString.hasSuffix(" of ice pellets"))
        {
            //workingString = String(workingString.characters.dropLast(15))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -15)])
        }
        
        if (workingString.hasSuffix(" shower"))
        {
            //workingString = String(workingString.characters.dropLast(7))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -7)])
        }
        
        if (workingString.hasSuffix(" showers"))
        {
            //workingString = String(workingString.characters.dropLast(8))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -8)])
        }
        
        if (workingString.hasSuffix(" nearby"))
        {
            //workingString = String(workingString.characters.dropLast(7))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -7)])
        }
        
        if (workingString.hasSuffix(" possible"))
        {
            //workingString = String(workingString.characters.dropLast(9))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -9)])
        }
        
        if (workingString.hasPrefix("Patchy "))
        {
            //workingString = String(workingString.characters.dropFirst(7))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 7)..<workingString.endIndex])
        }
        
        if (workingString.hasPrefix("Partly "))
        {
            //workingString = String(workingString.characters.dropFirst(7))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 7)..<workingString.endIndex])
        }
        
        if ((workingString.hasPrefix("freezing ")) ||
            (workingString.hasPrefix("Freezing ")))
        {
            //workingString = String(workingString.characters.dropFirst(9))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 9)..<workingString.endIndex])
        }
        
        if ((workingString.hasPrefix("heavy ")) ||
            (workingString.hasPrefix("Heavy ")))
        {
            //workingString = String(workingString.characters.dropFirst(6))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 6)..<workingString.endIndex])
        }
        
        if ((workingString.hasPrefix("light ")) ||
            (workingString.hasPrefix("Light ")))
        {
            //workingString = String(workingString.characters.dropFirst(6))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 6)..<workingString.endIndex])
        }
        
        if ((workingString.hasPrefix("strong ")) ||
            (workingString.hasPrefix("Strong ")))
        {
            //workingString = String(workingString.characters.dropFirst(7))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 7)..<workingString.endIndex])
        }
        
        if (workingString.hasPrefix("Moderate "))
        {
            //workingString = String(workingString.characters.dropFirst(9))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 9)..<workingString.endIndex])
        }
        
        if (workingString.hasPrefix("or "))
        {
            //workingString = String(workingString.characters.dropFirst(3))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 3)..<workingString.endIndex])
            workingString = fixIcon(icon: workingString) // Yes recursion
        }
        
        return workingString
    } // fixIcon
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String) -> WeatherFields
    {
        DebugLog(String(format:"in WorldWeatherOnline beginParsing: %@", inputCity))
        
        weatherFields.forecastCounter = 0
        
        AppDelegate().initWeatherFields(weatherFields: &weatherFields)

        escapedCity = inputCity.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
        escapedCity = escapedCity.replacingOccurrences(of: ",", with: "%3D") as NSString
        
        parseURL = QUERY_PREFIX1 + (escapedCity as String) + QUERY_SUFFIX1 + APIKey1
        InfoLog(String(format:"URL for observations WorldWeatherOnline: %@\n", parseURL))
        
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
                readJSONObjectE(object: dictionary)
            }
        } catch {
            // Handle Error
        }
        if (weatherFields.currentTemp == "9999")
        {
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
        
        DebugLog(String(format:"leaving WorldWeatherOnline beginParsing: %@", inputCity))
        
        return weatherFields
    } // beginParsing
    
    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // setRadarWind
    
    func readJSONObject(object: [String: AnyObject]) {
        guard
            let data = object["data"] as? [String: AnyObject]
            else {
                _ = "error"
                return }
        
        for d in [data] {
            guard
                let request = d["request"] as? [[String: AnyObject]],
                let current_condition = d["current_condition"] as? [[String: AnyObject]],
                let weather = d["weather"] as? [[String: AnyObject]]
                else {
                    _ = "error"
                    return }
            for r in request {
                guard
                    let city = r["query"] as? String
                    else {
                        _ = "error"
                        return }
                
                for cc in current_condition {
                    guard
                        //let date = cc["observation_time"] as? String,
                        let temp_F = cc["temp_F"] as? String,
                        let humidity = cc["humidity"] as? String,
                        let pressure = cc["pressure"] as? String,
                        let windspeedMiles = cc["windspeedMiles"] as? String,
                        let winddirDegree = cc["winddirDegree"] as? String,
                        let weatherDesc = cc["weatherDesc"] as? [[String: AnyObject]]
                        else {
                            _ = "error"
                            return }
                    for wd in weatherDesc {
                        guard
                            let icon = wd["value"] as? String
                            else {
                                _ = "error"
                                return }
                        weatherFields.title1 = city
                        weatherFields.currentConditions = icon
                        weatherFields.currentCode = fixIcon(icon: icon)
                        weatherFields.currentTemp = temp_F
                        weatherFields.humidity = humidity
                        weatherFields.pressure = pressure
                        weatherFields.windSpeed = windspeedMiles
                        weatherFields.windDirection = winddirDegree
                    }
                }
                
                for w in weather {
                    guard
                        let date = w["date"] as? String,
                        let maxtempF = w["maxtempF"] as? String,
                        let mintempF = w["mintempF"] as? String,
                        let astronomy = w["astronomy"] as? [[String: AnyObject]],
                        let hourly = w["hourly"] as? [[String: AnyObject]]
                        else {
                            _ = "error"
                            return }
                    for a in astronomy {
                        guard
                            let sunrise = a["sunrise"] as? String,
                            let sunset = a["sunset"] as? String
                            else {
                                _ = "error"
                                return }
                        for h in hourly {
                            guard
                                let weatherDesc = h["weatherDesc"] as? [[String: AnyObject]]
                                else {
                                    _ = "error"
                                    return }
                            for wd in weatherDesc {
                                guard
                                    let icon = wd["value"] as? String
                                    else {
                                        _ = "error"
                                        return }

                                // Convert YYYY-MM-dd to DDD
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "YYYY-MM-dd"
                                let date2 = dateFormatter.date(from: date)

                                dateFormatter.dateFormat = "E"
                                dateFormatter.timeZone = TimeZone(identifier: "UTC")
 
                                weatherFields.forecastDay[weatherFields.forecastCounter] = dateFormatter.string(from: date2! as Date)

                                // Convert epoch to DOW
                                dateFormatter.dateFormat = "d MMM yyyy"
                                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                                
                                weatherFields.forecastDate[weatherFields.forecastCounter] = dateFormatter.string(from: date2! as Date)
                                
                                weatherFields.forecastLow[weatherFields.forecastCounter] = mintempF
                                weatherFields.forecastHigh[weatherFields.forecastCounter] = maxtempF
                                weatherFields.forecastCode[weatherFields.forecastCounter] = fixIcon(icon: icon)
                                weatherFields.forecastConditions[weatherFields.forecastCounter] = icon

                                if (weatherFields.forecastCounter == 0)
                                {
                                    weatherFields.sunrise = sunrise
                                    weatherFields.sunset = sunset
                                }
                            }
                        }
                    }
                    weatherFields.forecastCounter = weatherFields.forecastCounter + 1
                }
            }
        }
    } // readJSONObject
    
    func readJSONObjectE(object: [String: AnyObject]) {
        guard
            let data = object["data"] as? [[String: AnyObject]]
            else {
                _ = "error"
                return }
        for d in data {
            guard
                let error = d["error"] as? [[String: AnyObject]]
                else {
                    _ = "error"
                    return }
            for e in error {
                guard
                    let msg = e["msg"] as? String
                    else {
                        _ = "error"
                        return }
                weatherFields.currentTemp = "9999"
                weatherFields.latitude = msg
            }
        }
    } // readJSONObjectE
        
} // WorldWeatherOnlineAPI
