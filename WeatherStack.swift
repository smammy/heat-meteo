//
//  WEATHERSTACK.swift
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
// https://weatherstack.com/documentation
//
// Key: 8e3ce6a8ee20935f8ac78b20c420ed00
//
// WEATHERSTACK was APIXU
// API Access Key: 8e3ce6a8ee20935f8ac78b20c420ed00
//
// Sample: http://api.weatherstack.com/current?access_key=8e3ce6a8ee20935f8ac78b20c420ed00&query=40.7831,-73.9712&units=f
//
// Forecast (below) not available with FREE account
// Sample: http://api.weatherstack.com/forecast?forecast_days=14&hourly=0&units=f&access_key=8e3ce6a8ee20935f8ac78b20c420ed00&query=Naperville%20IL

import Cocoa
import Foundation

class WeatherStackAPI: NSObject, XMLParserDelegate
{
    ///*
    let QUERY_PREFIX1 = "http://api.weatherstack.com/current?&access_key="
    let QUERY_SUFFIX1a = "&query="
    let QUERY_SUFFIX1b = "&units=f"
    let QUERY_PREFIX2 = "http://api.weatherstack.com/forecast?access_key="
    let QUERY_SUFFIX2a = "&query="
    let QUERY_SUFFIX2b = "&forecast_days=14&hourly=0&units=f"

    var weatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()
    
    var escapedCity = NSString()
    var parseURL = String()
    
    func convertCode(code: Int) -> String
    {
        var currentCode = "Unknown"
        let workingString = String(code)
        
        if (workingString == "113")
        {
            currentCode = "Sun"
        }
        else if ((workingString == "260") ||
            (workingString == "248"))
        {
            currentCode = "Hazy"
        }
        else if ((workingString == "119") ||
            (workingString == "122") ||
            (workingString == "269"))
        {
            currentCode = "Cloudy"
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
            currentCode = "Rain"
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
            currentCode = "Snow"
        }
        else if ((workingString == "200") ||
            (workingString == "386") ||
            (workingString == "389"))
        {
            currentCode = "Thunderstorm"
        }
        else if (workingString == "116")
        {
            currentCode = "Sun-Cloud"
        }
        
        return currentCode
    } // convertCode
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String, weatherFields: inout WeatherFields) {
        DebugLog(String(format:"in WEATHERSTACK beginParsing: %@", inputCity))
        
        escapedCity = inputCity.replacingOccurrences(of: ", ", with: ",") as NSString
        //escapedCity = escapedCity.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
        //escapedCity = escapedCity.replacingOccurrences(of: ",", with: "%3D") as NSString

        // Current weather
        parseURL = QUERY_PREFIX1 + APIKey1 + QUERY_SUFFIX1a + (escapedCity as String) + QUERY_SUFFIX1b
        InfoLog(String(format:"URL for WEATHERSTACK: %@\n", parseURL))
        
        // https://www.hackingwithswift.com/example-code/strings/how-to-load-a-string-from-a-website-url
        var url = URL(string: parseURL)
        var data: NSData?
        data = nil
        if (url != nil)
        {
            do {
                // https://stackoverflow.com/questions/40812416/nsurl-url-and-nsdata-data?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
                data = try Data(contentsOf: url!) as NSData
            } catch {
                ErrorLog("WEATHERSTACK \(error)")
                weatherFields.currentTemp = "9999"
                weatherFields.latitude = "\(error)"
                return
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
                readJSONObjectCurrent(object: dictionary, weatherFields: &weatherFields)
            }
        } catch {
            // Handle Error
            weatherFields.currentTemp = "9999"
            weatherFields.latitude = error.localizedDescription
            ErrorLog("AERIS1 " + String(decoding: data!, as: UTF8.self))
        }

        // Forecast weather
        parseURL = QUERY_PREFIX2 + APIKey1 + QUERY_SUFFIX2a + (escapedCity as String) + QUERY_SUFFIX2b
        InfoLog(String(format:"URL (forecast) for WEATHERSTACK: %@\n", parseURL))

        url = URL(string: parseURL)
        data = nil
        if (url != nil)
        {
            do {
                // https://stackoverflow.com/questions/40812416/nsurl-url-and-nsdata-data?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
                data = try Data(contentsOf: url!) as NSData
                if (data != nil) {
                    let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
                    if let dictionary = object as? [String: AnyObject] {
                        readJSONObjectForecast(object: dictionary, weatherFields: &weatherFields)
                    }
                }
            } catch {
                // Handle error (ignore)
            }
        }

        DebugLog(String(format:"leaving WEATHERSTACK beginParsing: %@", inputCity))
        
        return
    } // beginParsing
    
    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // setRadarWind
    
    func readJSONObjectCurrent(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        guard
            let location = object["location"] as? [String: AnyObject],
            let current = object["current"] as? [String: AnyObject]
            else {
                _ = "error"
                return }
        
        for l in [location] {
            guard
                let unixdate = l["localtime_epoch"] as? Int,
                let localtime = l["localtime"] as? String,
                let city = l["name"] as? String,
                let lat = l["lat"] as? String,
                let long = l["lon"] as? String
                else {
                    _ = "error"
                    return }
            weatherFields.title1 = city
            weatherFields.latitude = lat
            weatherFields.longitude = long
            // Convert epoch to UTC
            let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            //dateFormatter.timeZone = TimeZone(identifier: "UTC")
            dateFormatter.timeZone = NSTimeZone.local
            weatherFields.date = dateFormatter.string(from: date as Date)
            weatherFields.date = localtime
        }
        
        for c in [current] {
            guard
                let temp_F = c["temperature"] as? Double,
                let vis_miles = c["visibility"] as? Double,
                let uv = c["uv_index"] as? Double,
                let humidity = c["humidity"] as? Double,
                let pressure = c["pressure"] as? Double,
                let windspeedMiles = c["wind_speed"] as? Double,
                let winddirDegree = c["wind_degree"] as? Double,
                let code = c["weather_code"] as? Int
                else {
                    _ = "error"
                    return }
            
            weatherFields.currentTemp = NSString(format: "%.0f", temp_F) as String
            weatherFields.humidity = NSString(format: "%.0f", humidity) as String
            weatherFields.pressure = NSString(format: "%.2f", pressure) as String
            weatherFields.windSpeed = NSString(format: "%.1f", windspeedMiles) as String
            weatherFields.windDirection = NSString(format: "%f", winddirDegree) as String
            weatherFields.visibility = NSString(format: "%.0f", vis_miles) as String
            weatherFields.UVIndex = NSString(format: "%.0f", uv) as String

            //weatherFields.currentConditions = languageConverter(conditions: text)
            weatherFields.currentCode = convertCode(code: code)
        }
        
    } // readJSONObjectCurrent
    
    func readJSONObjectForecast(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        guard
            let forecast = object["forecast"] as? [String: AnyObject]
            else {
                _ = "error"
                return }
        
        
        for f in [forecast] {
            let key = f.first?.key
            
            guard
                let forecastday = f[key!] as? [String: AnyObject]
                else {
                    _ = "error"
                    return }
            for fd in [forecastday] {
                guard
                    let hourly = fd["hourly"] as? [[String: AnyObject]],
                    let date_epoch = fd["date_epoch"] as? Int,
                    let maxtempF = fd["maxtemp"] as? Int,
                    let mintempF = fd["mintemp"] as? Int
                else {
                    _ = "error"
                    return }
                weatherFields.forecastLow[weatherFields.forecastCounter] = String(describing: mintempF)
                weatherFields.forecastHigh[weatherFields.forecastCounter] = String(describing: maxtempF)
                
                let date = NSDate(timeIntervalSince1970: TimeInterval(date_epoch))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E"
                dateFormatter.timeZone = NSTimeZone.local
                weatherFields.forecastDay[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)
                dateFormatter.dateFormat = "d"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                dateFormatter.timeZone = NSTimeZone.local
                weatherFields.forecastDate[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)

                for h in hourly {
                    guard
                        let code = h["weather_code"] as? Int
                        else {
                        _ = "error"
                        return }
                        weatherFields.forecastCode[weatherFields.forecastCounter] = String(describing: convertCode(code: code))
                    }
                }
             weatherFields.forecastCounter = weatherFields.forecastCounter + 1
         }
    } // readJSONObjectForecast
    
} // weatherstackAPI

