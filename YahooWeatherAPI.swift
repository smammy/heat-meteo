//
//  YahooWeatherAPI.swift
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
// http://developer.yahoo.com/weather
//

import Cocoa
import Foundation

// aka APIKey1
let ConsumerKey = "dj0yJmk9ZGZ6MVN0a1BYUnF0JmQ9WVdrOVRVbEJXV2RWTkc4bWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD1mOA--"
// aka APIKey2
let ConsumerSecret = "5ccc0d61e58514d24eac2f95fad475e270b97b84"

// Help: https://www.raywenderlich.com/99431/oauth-2-with-swift-tutorial
//       http://swiftquickstart.blogspot.com/2016/02/oauthswift-tutorial.html
//       http://samwilskey.com/swift-oauth/
//
//       http://stackoverflow.com/questions/36186538/making-yahoo-weather-api-request-with-oauth-1
//

class YahooWeatherAPI: NSObject, XMLParserDelegate {
    
    let QUERY_PREFIX1 = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22"
    let QUERY_SUFFIX1 = "%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
    
    var escapedCity = String()
    var parseURL = String()
    
    var weatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()
    
    func beginParsing(_ inputCity: String, displayCity: String, APIKey1: String, APIKey2: String, weatherFields: inout WeatherFields) {

        DebugLog(String(format:"in beginParsing: %@", inputCity))

        // https://developer.yahoo.com/weather/
        
        // Should emit "Powered by Yahoo!", https://poweredby.yahoo.com/purple.png
        //var weatherQuery = NSString()
        //weatherQuery = "SELECT * FROM weather.forecast WHERE u=c AND woeid = (SELECT woeid FROM geo.places(1) WHERE text='nome, ak')"
        
        parseURL = ""
        parseURL.append(QUERY_PREFIX1)
        escapedCity = inputCity.replacingOccurrences(of: ", ", with: ",")
        escapedCity = escapedCity.replacingOccurrences(of: " ", with: "-")
        parseURL.append(escapedCity)
        parseURL.append(QUERY_SUFFIX1)
        parseURL = parseURL.replacingOccurrences(of: "%20", with: " ")
        parseURL = parseURL.replacingOccurrences(of: "%22", with: "\"")
        parseURL = parseURL.replacingOccurrences(of: "%2F", with: "/")
        parseURL = parseURL.replacingOccurrences(of: "%3A", with: ":")
        parseURL = parseURL.replacingOccurrences(of: "%3D", with: "=")
        InfoLog(String(format:"URL for Yahoo: %@\n", parseURL))
        
        parseURL = ""
        parseURL.append(QUERY_PREFIX1)
        escapedCity = inputCity.replacingOccurrences(of: ", ", with: ",")
        escapedCity = escapedCity.replacingOccurrences(of: " ", with: "-")
        parseURL.append(escapedCity)
        parseURL.append(QUERY_SUFFIX1)
        
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
                readJSONObject(object: dictionary, weatherFields: &weatherFields)
            }
        } catch {
            // Handle Error
        }
        
        DebugLog(String(format:"leaving beginParsing: %@", inputCity))

        return
    } // beginParsing
    
    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // extendedForecasts
 
    func readJSONObject(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        guard
            let query = object["query"] as? [String: AnyObject]
            else {
                _ = "error"
                return }
        
        for q in [query] {
            guard
                let created = q["created"] as? String,
                let results = q["results"] as? [String: AnyObject]
                else {
                    _ = "error"
                    return }
            weatherFields.date = String(created.prefix(upTo: created.index(before: created.endIndex)))

            for r in [results] {
                guard
                    let channel = r["channel"] as? [String: AnyObject]
                    else {
                        _ = "error"
                        return }
                for c in [channel] {
                    guard
                        let wind = c["wind"] as? [String: AnyObject],
                        let atmosphere = c["atmosphere"] as? [String: AnyObject],
                        let astronomy = c["astronomy"] as? [String: AnyObject],
                        let item = c["item"] as? [String: AnyObject],
                        let link = c["link"] as? String,
                        let title = c["title"] as? String
                        else {
                            _ = "error"
                            return }
                    weatherFields.title1 = title
                    weatherFields.URL = link
                    let index = link.index(link.startIndex, offsetBy: 63)
                    if (String(weatherFields.URL.prefix(upTo: index)) == "http://us.rd.yahoo.com/dailynews/rss/weather/Country__Country/*") {
                        weatherFields.URL = String(link.suffix(from: index))
                    }
                    
                    for w in [wind] {
                        guard
                            let direction = w["direction"] as? String,
                            let speed = w["speed"] as? String
                            else {
                                _ = "error"
                                return }
                        weatherFields.windSpeed = speed
                        weatherFields.windDirection = direction
                    }
                    
                    for atmo in [atmosphere] {
                        guard
                            let humidity = atmo["humidity"] as? String,
                            let pressure = atmo["pressure"] as? String
                            else {
                                _ = "error"
                                return }
                        weatherFields.humidity = humidity
                        weatherFields.pressure = pressure
                    }
                    
                    for astro in [astronomy] {
                        guard
                            let sunrise = astro["sunrise"] as? String,
                            let sunset = astro["sunset"] as? String
                            else {
                                _ = "error"
                                return }
                        weatherFields.sunrise = sunrise
                        weatherFields.sunset = sunset
                    }
                    
                    for i in [item] {
                        guard
                            let condition = i["condition"] as? [String: AnyObject],
                            let forecast = i["forecast"] as? [[String: AnyObject]],
                            let link = i["link"] as? String,
                            let lat = i["lat"] as? String,
                            let long = i["long"] as? String
                            else {
                                _ = "error"
                                return }
                        weatherFields.currentLink = link
                        weatherFields.latitude = lat
                        weatherFields.longitude = long
                        
                        for cond in [condition] {
                            guard
                                let current = cond["text"] as? String,
                                let code = cond["code"] as? String,
                                let temp = cond["temp"] as? String
                                else {
                                    _ = "error"
                                    return }
                            weatherFields.currentCode = code
                            weatherFields.currentTemp = temp
                            weatherFields.currentLink = link
                            weatherFields.currentConditions = current
                        }
                        
                        for f in forecast {
                            guard
                                let fDay = f["day"] as? String,
                                let fDate = f["date"] as? String,
                                let fText = f["text"] as? String,
                                let fCode = f["code"] as? String,
                                let fHigh = f["high"] as? String,
                                let fLow = f["low"] as? String
                                else {
                                    _ = "error"
                                    return }
                            weatherFields.forecastCode[weatherFields.forecastCounter] = fCode
                            weatherFields.forecastLow[weatherFields.forecastCounter] = fLow
                            weatherFields.forecastHigh[weatherFields.forecastCounter] = fHigh
                            weatherFields.forecastDay[weatherFields.forecastCounter] = fDay
                            weatherFields.forecastDate[weatherFields.forecastCounter] = fDate
                            weatherFields.forecastConditions[weatherFields.forecastCounter] = fText

                            weatherFields.forecastCounter = weatherFields.forecastCounter + 1
                        }
                    }
                }
            }
        }
    } // readJSONObject
} // class YahooWeatherAPI
