//
//  AERISWeather.swift
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
// http://www.aerisweather.com/develop/
//
// EdwardD20@danleys.org/aNX-e5y-5NB-f7y
// APIKey1
// ID:QFNxQi4uU8aCkQuboGCG5
// APIKey2
// SECRET:KwWWG9JoGs9Q8I80VXAtQ7Ktsxanq0P1sNGU59hd
//
// Sample: http://api.aerisapi.com/batch/seattle,wa?&requests=/:observations,/:forecasts&client_id=QFNxQi4uU8aCkQuboGCG5&client_secret=KwWWG9JoGs9Q8I80VXAtQ7Ktsxanq0P1sNGU59hd

import Cocoa
import Foundation

class AerisWeatherAPI: NSObject, XMLParserDelegate
{
    let QUERY_PREFIX1 = "http://api.aerisapi.com/observations/"
    let QUERY_SUFFIX1a = "?&client_id="
    let QUERY_SUFFIX1b = "&client_secret="
    
    let QUERY_PREFIX2 = "http://api.aerisapi.com/forecasts/"
    let QUERY_SUFFIX2a = "?&client_id="
    let QUERY_SUFFIX2b = "&client_secret="
    
    var weatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()

    var escapedCity = NSString()
    var parseURL = String()
    
    func fixIcon(icon: String) -> String
    {
        var workingString = icon
        
        // Remove trailing .png
        //workingString = String(workingString.characters.dropLast(4))
        workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -4)])

        // Remove possible trailing n (rainn vs. rain)
        if (workingString.hasSuffix("rain"))
        {
        }
        else if (workingString.hasSuffix("n"))
        {
            //workingString = String(workingString.characters.dropLast(1))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -1)])
        }
        
        // Remove possible trailing w (snoww vs. snow)
        if (workingString.hasSuffix("snow"))
        {
        }
        else if (workingString.hasSuffix("w"))
        {
            //workingString = String(workingString.characters.dropLast(1))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -1)])
        }
        
        // Remove possible leading am_ (am_showers)
        if ((workingString.hasPrefix("am_")) ||
            (workingString.hasPrefix("pm_")))
        {
            //workingString = String(workingString.characters.dropFirst(3))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 3)..<workingString.endIndex])
        }
        
        // Convert pcloudy or mcloudy to cloudy
        if ((workingString.hasPrefix("pcloudy")) ||
            (workingString.hasPrefix("mcloudy")))
        {
            //workingString = String(workingString.characters.dropFirst(1))
            workingString = String(workingString[workingString.index(workingString.startIndex, offsetBy: 1)..<workingString.endIndex])
        }

        // mcloudysf (light snow vs. snow)
        if (workingString.hasSuffix("sf"))
        {
            //workingString = String(workingString.characters.dropLast(1))
            workingString = String(workingString[workingString.startIndex..<workingString.index(workingString.endIndex, offsetBy: -1)])
        }

        return workingString
    } // fixIcon
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String, weatherFields: inout WeatherFields) {
        DebugLog(String(format:"in AerisWeatherAPI beginParsing: %@", inputCity))
        
        //escapedCity = inputCity.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
        //escapedCity = escapedCity.replacingOccurrences(of: ",", with: "%3D") as NSString

        //parseURL = QUERY_PREFIX1 + (escapedCity as String) + QUERY_SUFFIX1a + APIKey1 + QUERY_SUFFIX1b + APIKey2
        parseURL = QUERY_PREFIX1 + inputCity + QUERY_SUFFIX1a + APIKey1 + QUERY_SUFFIX1b + APIKey2
        InfoLog(String(format:"URL for observations AerisWeather: %@\n", parseURL))

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
            return
        }
        
        do {
            let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readJSONObjectE(object: dictionary, weatherFields: &weatherFields)
            }
        } catch {
            // Handle Error
        }
        if (weatherFields.currentTemp == "9999")
        {
            return
        }
        
        do {
            let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readJSONObject(object: dictionary, weatherFields: &weatherFields)
            }
        } catch {
            // Handle Error
        }
        
        parseURL = QUERY_PREFIX2 + inputCity + QUERY_SUFFIX2a + APIKey1 + QUERY_SUFFIX2b + APIKey2
        InfoLog(String(format:"URL for forecasts AerisWeather: %@\n", parseURL))

        
        data = NSData(contentsOf: URL(string: parseURL)!)
        
        do {
            let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readJSONObjectF(object: dictionary, weatherFields: &weatherFields)
            }
        } catch {
            // Handle Error
        }
        
        DebugLog(String(format:"leaving AerisWeatherAPI beginParsing: %@", inputCity))
        
        return
    } // beginParsing
    
    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // setRadarWind
    
    func readJSONObject(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        guard
            let response = object["response"] as? [String: AnyObject]
            else {
                _ = "error"
                return }
        
        for r2 in [response] {
            guard
                let id = r2["id"] as? String,
                let ob2 = r2["ob"] as? [String: AnyObject],
                let place = r2["place"] as? [String: AnyObject],
                let loc = r2["loc"] as? [String: AnyObject]
                else {
                    _ = "error"
                    return }
            for ob in [ob2] {
                guard
                    let timestamp = ob["timestamp"] as? Double,
                    let tempF = ob["tempF"] as? Double,
                    let humidity = ob["humidity"] as? Double,
                    let pressureMB = ob["pressureMB"] as? Double,
                    let windMPH = ob["windMPH"] as? Double,
                    let windDirDEG = ob["windDirDEG"] as? Double,
                    let weather = ob["weather"] as? String,
                    //let weatherShort = ob["weatherShort"] as? String,
                    let icon = ob["icon"] as? String,
                    let sunrise = ob["sunrise"] as? Double,
                    let sunset = ob["sunset"] as? Double
                    else {
                        _ = "error"
                        return }
                weatherFields.URL = "https://wx.aerisweather.com/?pands=" + id
                weatherFields.currentConditions = weather
                weatherFields.currentCode = fixIcon(icon: icon)
                weatherFields.currentTemp = NSString(format: "%.2f", tempF) as String
                weatherFields.humidity = NSString(format: "%.0f", humidity) as String
                weatherFields.pressure = NSString(format: "%.0f", pressureMB) as String
                weatherFields.windSpeed = NSString(format: "%.2f", windMPH) as String
                weatherFields.windDirection = NSString(format: "%.2f", windDirDEG) as String

                // Convert epoch to UTC
                var unixdate: Int
                unixdate = Int(sunrise)
                var date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
                var dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                
                weatherFields.sunrise = dateFormatter.string(from: date as Date)
                
                unixdate = Int(sunset)
                date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
                dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                
                weatherFields.sunset = dateFormatter.string(from: date as Date)
                
                // Convert epoch to UTC
                unixdate = Int(timestamp)
                date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
                dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                
                weatherFields.forecastDay[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)

                // Convert epoch to DOW
                dateFormatter.dateFormat = "d MMM yyyy"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                
                weatherFields.forecastDate[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)
                
                for l2 in [loc] {
                    guard
                        let lat = l2["lat"] as? Double,
                        let long = l2["long"] as? Double
                        else {
                            _ = "error"
                            return }
                    weatherFields.latitude = NSString(format: "%.2f", lat) as String
                    weatherFields.longitude = NSString(format: "%.2f", long) as String
                }

                for p in [place] {
                    guard
                        let name = p["name"] as? String
                        else {
                            _ = "error"
                            return }
                    weatherFields.title1 = name
                }
            }
        }
    } // readJSONObject
    
    func readJSONObjectE(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        guard
            let error = object["error"] as? [String: AnyObject]
            else {
                _ = "error"
                return }
        for e in [error] {
            guard
                let description = e["description"] as? String
                else {
                    _ = "error"
                    return }
            weatherFields.currentTemp = "9999"
            weatherFields.latitude = description
        }
    } // readJSONObjectE
    
    func readJSONObjectF(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        guard
            let response = object["response"] as? [[String: AnyObject]]
            else {
                _ = "error"
                return }
        
        for r2 in response {
            guard
                let periods = r2["periods"] as? [[String: AnyObject]]
                else {
                    _ = "error"
                    return }
            for p in periods {
                guard
                    let timestamp = p["timestamp"] as? Double,
                    let maxTempF = p["maxTempF"] as? Double,
                    let minTempF = p["minTempF"] as? Double,
                    let weather = p["weather"] as? String,
                    let icon = p["icon"] as? String
                    else {
                        _ = "error"
                        return }
                
                // Convert epoch to UTC
                let unixdate: Int
                unixdate = Int(timestamp)
                let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                
                weatherFields.forecastDay[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)
                weatherFields.forecastLow[weatherFields.forecastCounter] = NSString(format: "%.0f", minTempF) as String
                weatherFields.forecastHigh[weatherFields.forecastCounter] = NSString(format: "%.0f", maxTempF) as String
                weatherFields.forecastConditions[weatherFields.forecastCounter] = weather
                let truncated = fixIcon(icon: icon)
                weatherFields.forecastCode[weatherFields.forecastCounter] = truncated

                weatherFields.forecastCounter = weatherFields.forecastCounter + 1
            }
        }
    } // readJSONObjectF
    
} // class AerisWeatherAPI
