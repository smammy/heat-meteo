//
//  Forecast.Io.swift
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
// https://darksky.net/dev/
//
// This API Key belongs to me (Ed Danley).
//  It is part of their FREE package.
//  At some point in time, it's possible somebody else
//  will need to register another account
//  Depending on the load the Meteo community puts on this account,
//   it's possible individuals will need either own API Key.
//
// API Key = 1f76884583c747841b6dd66979a24b3e
// BASE_URL = https://api.forecast.io/forecast/APIKEY/LATITUDE,LONGITUDE
//            https://api.forecast.io/forecast/1f76884583c747841b6dd66979a24b3e/37.8267,-122.423?exclude=minutely,hourly,alerts,flags&lang=en&units=us
//

import Cocoa
import Foundation

class DarkSkyAPI: NSObject, XMLParserDelegate
{
    let QUERY_PREFIX1 = "https://api.forecast.io/forecast/"
    let QUERY_SUFFIX1 = "?exclude=minutely,hourly,alerts,flags&lang="
    let QUERY_SUFFIX2 = "&units=us"
    
    var escapedCity = String()
    var parseURL = String()
    
    var weatherFields = WeatherFields()

    var radarWindow = RadarWindow()
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String) -> WeatherFields
    {
        DebugLog(String(format:"in DarkSkyAPI beginParsing: %@", inputCity))
        
        let defaults = UserDefaults.standard
        let updateFrequency = Int(defaults.string(forKey: "updateFrequency")!)
        if ((updateFrequency! < 60) && (APIKey1 == ""))
        {
            defaults.setValue("60", forKey: "updateFrequency")
        }

        weatherFields.forecastCounter = 0
        
        var APIKey = APIKey1
        
        if (APIKey == "")
        {
            APIKey = "1f76884583c747841b6dd66979a24b3e"
        }
        
        AppDelegate().initWeatherFields(weatherFields: &weatherFields)
        
        parseURL = ""
        parseURL.append(QUERY_PREFIX1)
        parseURL.append(APIKey)     // For now, not using user key
        parseURL.append("/")
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
            //escapedCity = escapedCity
        }
        parseURL.append(escapedCity as String)
        parseURL.append(QUERY_SUFFIX1)
        let languageCode = (Locale.current as NSLocale).object(forKey: .languageCode) as? String
        parseURL.append(languageCode!)
        parseURL.append(QUERY_SUFFIX2)
        InfoLog(String(format:"URL for observations DarkSky: %@\n", parseURL))

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

        DebugLog(String(format:"leaving DarkSkyAPI beginParsing: %@", inputCity))
        
        return weatherFields
    } // beginParsing
    
    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // setRadarWind
    
    func readJSONObject(object: [String: AnyObject]) {
        guard
            let latitude = object["latitude"] as? Double,
            let longitude = object["longitude"] as? Double,
            let c = object["currently"] as? [String: AnyObject],
            let d = object["daily"] as? [String: AnyObject]
            else
        {
            _ = "error"
            return
        }
        weatherFields.latitude = NSString(format: "%.2f", latitude) as String
        weatherFields.longitude = NSString(format: "%.2f", longitude) as String
        
        let currently = [c] as [[String: AnyObject]]
        for current in currently {
            guard
                let time = current["time"] as? Double,
                let summary = current["summary"] as? String,
                let icon = current["icon"] as? String,
                let temperature = current["temperature"] as? Double,
                let humidity = current["humidity"] as? Double,
                let windSpeed = current["windSpeed"] as? Double,
                let windBearing = current["windBearing"] as? Double,
                let pressure = current["pressure"] as? Double
                else {
                    _ = "error"
                    return }

            // Convert epoch to UTC
            let unixdate: Int
            unixdate = Int(time)
            let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            
            weatherFields.date = dateFormatter.string(from: date as Date)

            weatherFields.windSpeed = NSString(format: "%.2f", windSpeed) as String
            weatherFields.windDirection = NSString(format: "%.2f", windBearing) as String
            weatherFields.humidity = NSString(format: "%.0f", humidity * 100.0) as String
            weatherFields.pressure = NSString(format: "%.2f", pressure) as String
            //weatherFields.visibility = NSString(format: "%.1f", visibility + 0.05) as String
            weatherFields.windSpeed = NSString(format: "%.2f", windSpeed) as String
            weatherFields.windSpeed = NSString(format: "%.2f", windSpeed) as String
            weatherFields.currentConditions = summary
            weatherFields.currentCode = icon
            weatherFields.currentTemp = NSString(format: "%.2f", temperature) as String

        } // readJSONObject
        
        let daily = [d] as [[String: AnyObject]]
        for day in daily {
            guard
                //let summary = day["summary"] as? String,
                //let icon = day["icon"] as? String,
                let datum = day["data"] as? [[String: AnyObject]]
                else
            {
                _ = "error"
                return
            }
            
            for dat in datum {
                guard
                    let time = dat["time"] as? Double,
                    let summary = dat["summary"] as? String,
                    let sunriseTime = dat["sunriseTime"] as? Double,
                    let sunsetTime = dat["sunsetTime"] as? Double,
                    let temperatureMin = dat["temperatureMin"] as? Double,
                    let temperatureMax = dat["temperatureMax"] as? Double,
                    //let pressure = dat["pressure"] as? Double,
                    let icon = dat["icon"] as? String
                    else
                {
                    _ = "error"
                    return
                }
                
                // This is for sunrise/sunset for today
                if (weatherFields.forecastCounter == 0)
                {
                    // Convert epoch to UTC
                    var unixdate: Int
                    unixdate = Int(sunriseTime)
                    var date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
                    var dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(identifier: "UTC")
                    
                    weatherFields.sunrise = dateFormatter.string(from: date as Date)

                    // Convert epoch to UTC
                    unixdate = Int(sunsetTime)
                    date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
                    dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(identifier: "UTC")
                    
                    weatherFields.sunset = dateFormatter.string(from: date as Date)
                }
                // Convert epoch to UTC
                let unixdate: Int
                unixdate = Int(time)
                let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E"
                //dateFormatter.timeZone = TimeZone(identifier: "UTC")
                dateFormatter.timeZone = TimeZone.ReferenceType.local

                weatherFields.forecastDay[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)
                
                // Convert epoch to DOW
                dateFormatter.dateFormat = "d MMM yyyy"
                //dateFormatter.timeZone = TimeZone(identifier: "UTC")
                dateFormatter.timeZone = TimeZone.ReferenceType.local

                weatherFields.forecastDate[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)
                
                //var forecastDate = [String]()
                weatherFields.forecastCode[weatherFields.forecastCounter] = icon
                weatherFields.forecastHigh[weatherFields.forecastCounter] = NSString(format: "%.2f", temperatureMax) as String
                weatherFields.forecastLow[weatherFields.forecastCounter] = NSString(format: "%.2f", temperatureMin) as String
                weatherFields.forecastConditions[weatherFields.forecastCounter] = summary
                
                weatherFields.forecastCounter = weatherFields.forecastCounter + 1
}
        }
    }
} // class DarkSkyAPI
