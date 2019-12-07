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
// http://openweathermap.org/api
//
// This API Key belongs to me (Ed Danley).
//  It is part of their FREE package.
//  Individuals will need either own API Key.
//
// APIID = d7ae7d44827777c67ab2c00bf9132070
// test APIID = 13f9b31f6eb45cd4940f43b995c92dca
// BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
// Price = http://openweathermap.org/price
//
// http://api.openweathermap.org/data/2.5/forecast/daily?lat=41.78&lon=-88.10&appid=d7ae7d44827777c67ab2c00bf9132070&mode=json&units=imperial
// http://api.openweathermap.org/data/2.5/forecast?lat=41.78&lon=-88.10&appid=13f9b31f6eb45cd4940f43b995c92dca&mode=json&units=imperial
// http://api.openweathermap.org/data/2.5/weather?q=IL,%20naperville&appid=d7ae7d44827777c67ab2c00bf9132070&mode=json&units=imperial
// http://api.openweathermap.org/data/2.5/weather?lat=41.735&lon=-88.2&appid=d7ae7d44827777c67ab2c00bf9132070&mode=json&units=imperial


import Cocoa
import Foundation

class OpenWeatherMapAPI: NSObject, XMLParserDelegate
{
    let QUERY_PREFIX1 = "http://api.openweathermap.org/data/2.5/weather?lat="
    let QUERY_SUFFIX1c = "&lon="
    let QUERY_SUFFIX1a = "&appid="
    let QUERY_SUFFIX1b = "&mode=json&units=imperial&lang=en"
    
    let QUERY_PREFIX2 = "http://api.openweathermap.org/data/2.5/forecast?lat="
    let QUERY_SUFFIX2c = "&lon="
    let QUERY_SUFFIX2a = "&appid="
    let QUERY_SUFFIX2b = "&mode=json&units=imperial&lang=en"
    
    var lat = NSString()
    var lon = NSString()
    var parseURL = String()
    
    var weatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()
    
    var saveMin = 0.0
    var saveMax = 0.0
    var saveDOW = ""
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String, weatherFields: inout WeatherFields) {
        
        DebugLog(String(format:"in beginParsing: %@", inputCity))
        
        // https://OpenWeatherMap.org
        
        // lat = inputCity before "," or " "
        // lon = inputCity after "," or " "
        let trimmed = inputCity.trimmingCharacters(in: .whitespacesAndNewlines)
        if (trimmed.contains(", ")) {
            let token = trimmed.components(separatedBy: ", ")
            lat = token[0] as NSString
            lon = token[1] as NSString
        } else if (trimmed.contains(" ,")) {
            let token = trimmed.components(separatedBy: " ,")
            lat = token[0] as NSString
            lon = token[1] as NSString
        } else if (trimmed.contains(" ")) {
            let token = trimmed.components(separatedBy: " ")
            lat = token[0] as NSString
            lon = token[1] as NSString
        } else if (trimmed.contains(",")) {
            let token = trimmed.components(separatedBy: ",")
            lat = token[0] as NSString
            lon = token[1] as NSString
        } else {
            lat = "0"
            lon = "0"
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
            weatherFields.currentTemp = "9999"
            weatherFields.latitude = error.localizedDescription
            ErrorLog("OpenWeatherMap1 " + error.localizedDescription)
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
            weatherFields.currentTemp = "9999"
            weatherFields.latitude = error.localizedDescription
            ErrorLog("OpenWeatherMap2 " + String(decoding: data!, as: UTF8.self))
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
            saveDOW = ""
            let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readJSONObjectF(object: dictionary, weatherFields: &weatherFields)
            }
        } catch {
            // Handle Error
            weatherFields.currentTemp = "9999"
            weatherFields.latitude = error.localizedDescription
            ErrorLog("OpenWeatherMap3 " + String(decoding: data!, as: UTF8.self))
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
        dateFormatter.timeZone = NSTimeZone.local
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
            dateFormatter.timeZone = NSTimeZone.local

            weatherFields.sunrise = dateFormatter.string(from: date as Date)
            
            unixdate = Int(sunset)
            date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            dateFormatter.timeZone = NSTimeZone.local

            weatherFields.sunset = dateFormatter.string(from: date as Date)
            
        }
        
    } // readJSONObject
    
    func readJSONObjectE(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        guard
        let cod = object["cod"] as? Double
        else
        {
            _ = "error"
            return
        }
        if (cod == 401)
        {
            weatherFields.currentTemp = "9999"
            weatherFields.latitude = object["message"] as! String
        } else {
            weatherFields.currentTemp = ""
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
            let temp = xyzzy["main"] as? [String: AnyObject]
            else {
                _ = "error"
                return }
            // Convert epoch to DOW
            let unixdate: Int
            unixdate = Int(dt)
            let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E"
            //dateFormatter.timeZone = TimeZone(identifier: "UTC")
            dateFormatter.timeZone = NSTimeZone.local
            
            let fDOW = dateFormatter.string(from: date as Date)
            if (saveDOW == "") {
                saveDOW = fDOW
                weatherFields.forecastDay[weatherFields.forecastCounter] = fDOW
                saveMin = 0.0
                saveMax = 0.0
            } else if (saveDOW != fDOW) {
                weatherFields.forecastCounter = weatherFields.forecastCounter + 1
                saveDOW = fDOW
                weatherFields.forecastDay[weatherFields.forecastCounter] = fDOW
                saveMin = 0.0
                saveMax = 0.0
            }

            // Convert epoch to d MMM yyyy
            dateFormatter.dateFormat = "d MMM yyyy"
            //dateFormatter.timeZone = TimeZone(identifier: "UTC")
            dateFormatter.timeZone = NSTimeZone.local

            weatherFields.forecastDate[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)
            
            for x in [temp] {
                guard
                let min = x["temp_min"] as? Double,
                let max = x["temp_max"] as? Double
                else {
                    _ = "error"
                    return }
                if ((saveMin == 0.0) || (saveMin > min)) {
                    saveMin = min
                    weatherFields.forecastLow[weatherFields.forecastCounter] = NSString(format: "%.0f", saveMin) as String
                }
                if ((saveMax == 0.0) || (saveMax < max)) {
                    saveMax = max
                    weatherFields.forecastHigh[weatherFields.forecastCounter] = NSString(format: "%.0f", saveMax) as String
                }
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
        }
    } // readJSONObjectF
    
} // class OpenWeatherMapAPI
