//
//  WeatherUnderground.swift
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
// http://www.wunderground.com/weather/api/
//
// referral URL: http://www.wunderground.com/?apiref=f4d4adc0812ab48d
// API Key = 97eaacd6a89f603b
//
// Sample Current: http://api.wunderground.com/api/97eaacd6a89f603b/conditions/q/IL/Naperville.json
// Sample 10 Day : http://api.wunderground.com/api/97eaacd6a89f603b/forecast10day/q/IL/Naperville.json
// Combined: http://api.wunderground.com/api/97eaacd6a89f603b/geolookup/conditions/forecast10day/q/IL/Naperville.json

import Foundation
import Cocoa
import Foundation

//let APIID = "97eaacd6a89f603b" // Ed's key

class WeatherUndergroundAPI: NSObject, XMLParserDelegate
{
    let QUERY_PREFIX1 = "http://api.wunderground.com/api/"
    let QUERY_SUFFIX1a = "/geolookup/conditions/forecast10day/q/"
    let QUERY_SUFFIX1b = ".json"
    
    var escapedCity = String()
    var parseURL = String()
    
    var weatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String) -> WeatherFields
    {
        
        DebugLog(String(format:"in beginParsing: %@", inputCity))
        
        AppDelegate().initWeatherFields(weatherFields: &weatherFields)
        weatherFields.forecastCounter = 0
        
        // https://www.wunderground.com
        
        // Should emit "Weather Underground", http://icons.wxug.com/graphics/wu2/logo_130x80.png
        //var weatherQuery = NSString()
        
        parseURL = ""
        parseURL.append(QUERY_PREFIX1)
        parseURL.append(APIKey1)
        parseURL.append(QUERY_SUFFIX1a)
        // lat = inputCity before "," or " "
        // lon = inputCity after "," or " "
        var token = [String]()
        escapedCity = inputCity.trimmingCharacters(in: .whitespacesAndNewlines)
        if (escapedCity.contains(" ")) {
            token = escapedCity.components(separatedBy: " ")
            escapedCity = token[0] + "," + token[1]
        } else if (escapedCity.contains(",")) {
            token = escapedCity.components(separatedBy: ",")
            escapedCity = token[0] + "," + token[1]
        } else {
            // escapedCity = "ME/pws:KMEmachi11"
            //escapedCity = escapedCity
        }
        parseURL.append(escapedCity as String)
        parseURL.append(QUERY_SUFFIX1b)
        InfoLog(String(format:"URL for Weather Underground: %@\n", parseURL))
        
        parseURL = ""
        parseURL.append(QUERY_PREFIX1)
        parseURL.append(APIKey1)
        parseURL.append(QUERY_SUFFIX1a)
        // lat = inputCity before "," or " "
        // lon = inputCity after "," or " "
        token = [String]()
        escapedCity = inputCity.trimmingCharacters(in: .whitespacesAndNewlines)
        if (escapedCity.contains(" ")) {
            token = escapedCity.components(separatedBy: " ")
            escapedCity = token[0] + "," + token[1]
        } else if (escapedCity.contains(",")) {
            token = escapedCity.components(separatedBy: ",")
            escapedCity = token[0] + "," + token[1]
        } else {
            //escapedCity = escapedCity
        }
        parseURL.append(escapedCity as String)
        parseURL.append(QUERY_SUFFIX1b)
        
        // TODO: Remove this dummy URL
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
                readJSONObjectF(object: dictionary)
            }
        } catch {
            // Handle Error
        }
                
        DebugLog(String(format:"leaving beginParsing: %@", inputCity))
        
        return weatherFields
    } // beginParsing
    
    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // setRadarWind
    
    func readJSONObject(object: [String: AnyObject]) {
        guard
            let current_observation = object["current_observation"] as? [String: AnyObject]
            else {
                _ = "error"
                return }
        
        for xyzzy in [current_observation] {
            guard
                let display_location = xyzzy["display_location"] as? [String: AnyObject],
                let observation_location = xyzzy["observation_location"] as? [String: AnyObject],
                let temp_f = xyzzy["temp_f"] as? Double,
                var wind_degrees = xyzzy["wind_degrees"] as? Double,
                let wind_mph = xyzzy["wind_mph"] as? Double,
                let pressure_mb = xyzzy["pressure_mb"] as? String,
                let weather = xyzzy["weather"] as? String,
                //let visibility_mi = xyzzy["visibility_mi"] as? String,
                let local_epoch = xyzzy["local_epoch"] as? String,
                let icon = xyzzy["icon"] as? String,
                let ob_url = xyzzy["ob_url"] as? String,
                let relative_humidity = xyzzy["relative_humidity"] as? String
                else {
                    _ = "error"
                    return }
            if (wind_degrees == -9999)
            {
                wind_degrees = 0
            }
            
            weatherFields.currentCode = icon
            weatherFields.currentConditions = weather
            weatherFields.currentTemp = NSString(format: "%.2f", temp_f) as String
            weatherFields.windSpeed = NSString(format: "%.2f", wind_mph) as String
            weatherFields.windDirection = NSString(format: "%.2f", wind_degrees) as String
            weatherFields.pressure = pressure_mb
            weatherFields.URL = ob_url
            
            // Convert epoch to UTC
            let unixdate: Int
            unixdate = Int((local_epoch as NSString).doubleValue)
            let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            weatherFields.date = dateFormatter.string(from: date as Date)
            
            // Remove trailing %
            let truncated = String(relative_humidity.prefix(upTo: relative_humidity.index(of: "%")!))
            weatherFields.humidity = truncated
            
            for xyzzy in [display_location] {
                guard
                    let city = xyzzy["city"] as? String
                    else {
                        _ = "error"
                        return }
                weatherFields.title1 = city
            }
            
            for xyzzy in [observation_location] {
                guard
                    let latitude = xyzzy["latitude"] as? String,
                    let longitude = xyzzy["longitude"] as? String
                    else {
                        _ = "error"
                        return }
                weatherFields.latitude = latitude
                weatherFields.longitude = longitude
            }
        }
    } // readJSONObject
    
    func readJSONObjectE(object: [String: AnyObject]) {
        guard
            let response = object["response"] as? [String: AnyObject]
            else
        {
            _ = "error"
            return
        }
        
        /*
        guard
            let location = object["location"] as? [String: AnyObject]
            else
        {
            _ = "error"
            return
        }
         */
        
        for xyzzy in [response] {
            guard
                let error = xyzzy["error"] as? [String: AnyObject]
                else {
                    _ = "error"
                    return }
            
            for x in [error] {
                guard
                    let description = x["description"] as? String
                    else {
                        _ = "error"
                        return }
                weatherFields.currentTemp = "9999"
                weatherFields.latitude = "API: " + description
            }
        }
    } // readJSONObjectE
    
    func readJSONObjectF(object: [String: AnyObject]) {
        guard
            let forecast = object["forecast"] as? [String: AnyObject]
            else
        {
            _ = "error"
            return
        }
        
        for f in [forecast] {
            guard
                let simpleforecast = f["simpleforecast"] as? [String: AnyObject]
                else {
                    _ = "error"
                    return }
            
            
            for xyzzy in [simpleforecast] {
                guard
                    let forecastday = xyzzy["forecastday"] as? [[String: AnyObject]]
                    else {
                        _ = "error"
                        return }
                
                for x in forecastday {
                    guard
                        let icon = x["icon"] as? String,
                        let conditions = x["conditions"] as? String,
                        let high = x["high"] as? [String: AnyObject],
                        let date = x["date"] as? [String: AnyObject],
                        let low = x["low"] as? [String: AnyObject]
                        else {
                            _ = "error"
                            return }
                    weatherFields.forecastConditions[weatherFields.forecastCounter] = conditions
                    weatherFields.forecastCode[weatherFields.forecastCounter] = icon
                    
                    for h in [high] {
                        guard
                            let max = h["fahrenheit"] as? String
                            else {
                                _ = "error"
                                return }
                        weatherFields.forecastHigh[weatherFields.forecastCounter] = max
                    }
                    
                    for l in [low] {
                        guard
                            let min = l["fahrenheit"] as? String
                            else {
                                _ = "error"
                                return }
                        weatherFields.forecastLow[weatherFields.forecastCounter] = min
                    }
                    
                    for d in [date] {
                        guard
                            let epoch = d["epoch"] as? String
                            else {
                                _ = "error"
                                return }
                        // Convert epoch to UTC
                        let unixdate: Int
                        unixdate = Int(epoch)!
                        let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "E"
                        dateFormatter.timeZone = TimeZone(identifier: "UTC")
                        
                        weatherFields.forecastDay[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)

                        // Convert epoch to DOW
                        dateFormatter.dateFormat = "d MMM yyyy"
                        dateFormatter.timeZone = TimeZone(identifier: "UTC")
                        
                        weatherFields.forecastDate[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)

                    }
                    weatherFields.forecastCounter = weatherFields.forecastCounter + 1
                }
            }
        }
    } // readJSONObjectF

} // class WeatherUndergroundAPI
