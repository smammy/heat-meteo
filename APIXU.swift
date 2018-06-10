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
// Sample: http://api.apixu.com/v1/forecast.json?key=8c67b21afb7d4184ba0235136171603&days=3&q=Naperville,IL

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
        
        if (workingString.hasPrefix("//cdn.apixu.com/weather/64x64/day"))
        {
            //workingString = String(workingString.characters.dropFirst(34))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 34)..<workingString.endIndex])
        }
        if (workingString.hasPrefix("//cdn.apixu.com/weather/64x64/night"))
        {
            //workingString = String(workingString.characters.dropFirst(36))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 36)..<workingString.endIndex])
        }
        if (workingString.hasSuffix(".png"))
        {
            //workingString = String(workingString.characters.dropLast(4))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -4)])
        }

        if (workingString == "113")
        {
            workingString = "Sun"
        }
        else if ((workingString == "119") ||
            (workingString == "122") ||
            (workingString == "143") ||
            (workingString == "248") ||
            (workingString == "269"))
        {
            workingString = "Cloudy"
        }
        else if ((workingString == "176") ||
            (workingString == "182") ||
            (workingString == "185") ||
            (workingString == "143") ||
            (workingString == "263") ||
            (workingString == "266") ||
            (workingString == "281") ||
            (workingString == "284") ||
            (workingString == "293") ||
            (workingString == "296") ||
            (workingString == "299") ||
            (workingString == "302") ||
            (workingString == "305") ||
            (workingString == "308") ||
            (workingString == "311") ||
            (workingString == "314") ||
            (workingString == "317") ||
            (workingString == "320") ||
            (workingString == "353") ||
            (workingString == "356") ||
            (workingString == "359") ||
            (workingString == "362") ||
            (workingString == "365"))
        {
            workingString = "Rain"
        }
        else if ((workingString == "179") ||
            (workingString == "227") ||
            (workingString == "230") ||
            (workingString == "323") ||
            (workingString == "326") ||
            (workingString == "329") ||
            (workingString == "332") ||
            (workingString == "335") ||
            (workingString == "338") ||
            (workingString == "350") ||
            (workingString == "368") ||
            (workingString == "371") ||
            (workingString == "374") ||
            (workingString == "377") ||
            (workingString == "392") ||
            (workingString == "395"))
        {
            workingString = "Snow"
        }
        else if ((workingString == "200") ||
            (workingString == "386") ||
            (workingString == "389"))
        {
            workingString = "Thunderstorm"
        }
        else if (workingString == "116")
        {
            workingString = "Sun-Cloud"
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
        InfoLog(String(format:"URL for observations APIXU: %@\n", parseURL))
        
        // https://www.hackingwithswift.com/example-code/strings/how-to-load-a-string-from-a-website-url
        let url = URL(string: parseURL)
        var data: NSData?
        data = nil
        if (url != nil)
        {
            do {
                // https://stackoverflow.com/questions/40812416/nsurl-url-and-nsdata-data?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
                data = try Data(contentsOf: url!) as NSData
            } catch {
                ErrorLog("\(error)")
            }
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
    
    func languageConverter(conditions: String) -> String {
        var intlConditions = conditions
        let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
        if (countryCode?.caseInsensitiveCompare("US") != ComparisonResult.orderedSame)
        {
            // parse http://www.apixu.com/doc/conditions.json
            // weatherFields.currentConditions
            // weatherFields.forecastConditions[weatherFields.forecastCounter]
            let url = URL(string: "http://www.apixu.com/doc/conditions.json")
            let data = NSData(contentsOf: url!)
            do {
                let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
                if let dictionary = object as? [[String: AnyObject]] {
                    intlConditions = readJSONObjectConditions(object: dictionary,
                                                              countryCode: "FR",
                                                              conditions: conditions)
                }
            } catch {
                // Handle Error
            }
        }
        return intlConditions
    }// languageConverter
    
    func readJSONObjectConditions(object: [[String: AnyObject]],
                                  countryCode: String,
                                  conditions: String) -> String {
        for o in object {
            guard
                let day_text = o["day"] as? String,
                let languages = o["languages"] as? [[String: AnyObject]]
                else {
                    _ = "error"
                    return conditions}
            if (conditions.caseInsensitiveCompare(day_text) == ComparisonResult.orderedSame)
            {
                for l in languages {
                    guard
                        let lang_iso = l["lang_iso"] as? String,
                        let day_text = l["day_text"] as? String
                        else {
                            _ = "error"
                            return conditions}
                    if (countryCode.caseInsensitiveCompare(lang_iso) == ComparisonResult.orderedSame)
                    {
                        return day_text
                    }
                }
            }
        }
        return conditions
    } // readJSONObjectConditions
    
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
                let lat = l["lat"] as? Double,
                let long = l["lon"] as? Double
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
                let temp_F = c["temp_f"] as? Double,
                let vis_miles = c["vis_miles"] as? Double,
                let humidity = c["humidity"] as? Double,
                let pressure = c["pressure_mb"] as? Double,
                let windspeedMiles = c["wind_mph"] as? Double,
                let winddirDegree = c["wind_degree"] as? Double,
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
                    let text = cond["text"] as? String,
                    let icon = cond["icon"] as? String
                    else {
                        _ = "error"
                        return }
                weatherFields.currentConditions = languageConverter(conditions: text)
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
                        let maxtempF = d["maxtemp_f"] as? Double,
                        let mintempF = d["mintemp_f"] as? Double,
                        let condition = d["condition"] as? [String: AnyObject]
                        else {
                            _ = "error"
                            return }
                    for cond in [condition] {
                        guard
                            let text = cond["text"] as? String,
                            let icon = cond["icon"] as? String
                            else {
                                _ = "error"
                                return }
                        weatherFields.forecastConditions[weatherFields.forecastCounter] = languageConverter(conditions: text)
                        weatherFields.forecastCode[weatherFields.forecastCounter] = fixIcon(icon: icon)
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
