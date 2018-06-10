//
//  OpenWeatherMapAPI.swift
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
// http://home.openweathermap.org/api
//
// This API Key belongs to me (Ed Danley).
//  It is part of their FREE package.
//  Individuals will need either own API Key.
//
// APIID = d7ae7d44827777c67ab2c00bf9132070
// BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
// Price = http://openweathermap.org/price
//

import Cocoa
import Foundation

class OpenWeatherMapAPI: NSObject, XMLParserDelegate
{
    let QUERY_PREFIX1 = "http://api.openweathermap.org/data/2.5/weather?lat="
    let QUERY_SUFFIX1c = "&lon="
    let QUERY_SUFFIX1a = "&appid="
    let QUERY_SUFFIX1b = "&mode=json&units=imperial"
    
    let QUERY_PREFIX2 = "http://api.openweathermap.org/data/2.5/forecast/daily?lat="
    let QUERY_SUFFIX2c = "&lon="
    let QUERY_SUFFIX2a = "&appid="
    let QUERY_SUFFIX2b = "&mode=json&units=imperial"
    
    var lat = NSString()
    var lon = NSString()
    var parseURL = String()
    
    var weatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String, weatherFields: inout WeatherFields) {
        
        DebugLog(String(format:"in beginParsing: %@", inputCity))
        
        // https://OpenWeatherMap.org
        
        //weatherQuery = http://api.openweathermap.org/data/2.5/weather?q=IL,%20naperville&appid=d7ae7d44827777c67ab2c00bf9132070&mode=json&units=imperial
        //weatherQuery = http://api.openweathermap.org/data/2.5/weather?lat=41.735&lon=-88.2&appid=d7ae7d44827777c67ab2c00bf9132070&mode=json&units=imperial
        
        // lat = inputCity before "," or " "
        // lon = inputCity after "," or " "
        let trimmed = inputCity.trimmingCharacters(in: .whitespacesAndNewlines)
        if (trimmed.contains(" ")) {
            var token = trimmed.components(separatedBy: " ")
            lat = token[0] as NSString
            lon = token[1] as NSString
        } else {
            var token = trimmed.components(separatedBy: ",")
            lat = token[0] as NSString
            lon = token[1] as NSString
        }

        parseURL = ""
        parseURL.append(QUERY_PREFIX1)
        parseURL.append(lat as String)
        parseURL.append(QUERY_SUFFIX1c)
        parseURL.append(lon as String)
        parseURL.append(QUERY_SUFFIX1a)
        parseURL.append(APIKey1)
        parseURL.append(QUERY_SUFFIX1b)
        InfoLog(String(format:"URL for Current conditions OpenWeatherMap: %@\n", parseURL))
        
        // https://www.hackingwithswift.com/example-code/strings/how-to-load-a-string-from-a-website-url
        var url = URL(string: parseURL)
        var data: NSData?
        data = nil
        url = URL(string: parseURL as String)
        data = nil
        if (url != nil)
        {
            data = NSData(contentsOf: url!)
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

        parseURL = ""
        parseURL.append(QUERY_PREFIX2)
        parseURL.append(lat as String)
        parseURL.append(QUERY_SUFFIX2c)
        parseURL.append(lon as String)
        parseURL.append(QUERY_SUFFIX2a)
        parseURL.append(APIKey1)
        parseURL.append(QUERY_SUFFIX2b)
        InfoLog(String(format:"URL for Forecast conditions OpenWeatherMap: %@\n", parseURL))
        
        url = URL(string: parseURL as String)
        data = nil
        if (url != nil)
        {
            data = NSData(contentsOf: url!)
        }
        if (data == nil)
        {
            return
        }
        do {
            let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readJSONObjectF(object: dictionary, weatherFields: &weatherFields)
            }
        } catch {
            // Handle Error
        }
        
        DebugLog(String(format:"leaving beginParsing: %@", inputCity))
        
        return
    } // beginParsing
    
    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // setRadarWind
    
    func readJSONObject(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        guard
        let id = object["id"] as? Double,
        let name = object["name"] as? String,
        let coord = object["coord"] as? [String: AnyObject],
        let main = object["main"] as? [String: AnyObject],
        let wind = object["wind"] as? [String: AnyObject],
        let sys = object["sys"] as? [String: AnyObject],
        let dt = object["dt"] as? Double,
        let weather = object["weather"] as? [[String: AnyObject]]
        else
        {
            _ = "error"
            return
        }
        weatherFields.title1 = name
        weatherFields.URL = "http://openweathermap.org/city/" + (NSString(format: "%.0f", id) as String)
        // Convert epoch to DOW
        let unixdate: Int
        unixdate = Int(dt)
        let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        weatherFields.date = dateFormatter.string(from: date as Date)
        
        for xyzzy in [coord] as [[String: AnyObject]] {
            guard
            let latitude = xyzzy["lat"] as? Double,
            let longitude = xyzzy["lon"] as? Double
            else {
                _ = "error"
                return }
            weatherFields.latitude = NSString(format: "%.2f", latitude) as String
            weatherFields.longitude = NSString(format: "%.2f", longitude) as String
        }
        
        for xyzzy in weather {
            guard
            //let id = xyzzy["id"] as? Double,
            //let main = xyzzy["main"] as? String,
            let description = xyzzy["description"] as? String,
            let icon = xyzzy["icon"] as? String
            else {
                _ = "error"
                return }
            weatherFields.currentConditions = description
            weatherFields.currentCode = icon
        }
        
        for xyzzy in [main] {
            guard
            let temp = xyzzy["temp"] as? Double,
            let humidity = xyzzy["humidity"] as? Double,
            //let temp_min = xyzzy["temp_min"] as? Double,
            //let temp_max = xyzzy["temp_max"] as? Double,
            //let sea_level = xyzzy["sea_level"] as? Double,
            //let grnd_level = xyzzy["grnd_level"] as? Double,
            let pressure = xyzzy["pressure"] as? Double
            else {
                _ = "error"
                return }
            weatherFields.currentTemp = NSString(format: "%.2f", temp) as String
            weatherFields.humidity = NSString(format: "%.0f", humidity) as String
            weatherFields.pressure = NSString(format: "%.0f", pressure) as String
        }
        
        for xyzzy in [wind] {
            guard
            let speed = xyzzy["speed"] as? Double,
            let deg = xyzzy["deg"] as? Double
            else {
                _ = "error"
                return }
            weatherFields.windSpeed = NSString(format: "%.2f", speed) as String
            weatherFields.windDirection = NSString(format: "%.2f", deg) as String
        }
        
        for xyzzy in [sys] {
            guard
            let sunrise = xyzzy["sunrise"] as? Double,
            let sunset = xyzzy["sunset"] as? Double
            else {
                _ = "error"
                return }
            
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
            
        }
        
    } // readJSONObject
    
    func readJSONObjectE(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        guard
        let cod = object["cod"] as? Double,
        let message = object["message"] as? String
        else
        {
            _ = "error"
            return
        }
        if (cod == 401)
        {
            weatherFields.currentTemp = "9999"
            weatherFields.latitude = message
        }
        
    } // readJSONObjectE
    
    func readJSONObjectF(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        guard
        let list = object["list"] as? [[String: AnyObject]]
        else
        {
            _ = "error"
            return
        }
        
        for xyzzy in list {
            guard
            let dt = xyzzy["dt"] as? Double,
            let weather = xyzzy["weather"] as? [[String: AnyObject]],
            let temp = xyzzy["temp"] as? [String: AnyObject]
            else {
                _ = "error"
                return }
            // Convert epoch to DOW
            let unixdate: Int
            unixdate = Int(dt)
            let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            
            weatherFields.forecastDay[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)
            
            // Convert epoch to DOW
            dateFormatter.dateFormat = "d MMM yyyy"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            
            weatherFields.forecastDate[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)
            
            for x in [temp] {
                guard
                let min = x["min"] as? Double,
                let max = x["max"] as? Double
                else {
                    _ = "error"
                    return }
                weatherFields.forecastLow[weatherFields.forecastCounter] = NSString(format: "%.0f", min) as String
                weatherFields.forecastHigh[weatherFields.forecastCounter] = NSString(format: "%.0f", max) as String
            }
            
            for x in weather {
                guard
                //let main = x["main"] as? String,
                let description = x["description"] as? String,
                let icon = x["icon"] as? String
                else {
                    _ = "error"
                    return }
                weatherFields.forecastConditions[weatherFields.forecastCounter] = description
                weatherFields.forecastCode[weatherFields.forecastCounter] = icon
            }
            weatherFields.forecastCounter = weatherFields.forecastCounter + 1
        }
    } // readJSONObjectF
    
} // class OpenWeatherMapAPI
