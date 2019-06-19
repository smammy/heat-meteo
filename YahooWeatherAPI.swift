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

// aka APIKey1/Client ID (Consumer Key)
let ConsumerKey = "dj0yJmk9ZGZ6MVN0a1BYUnF0JmQ9WVdrOVRVbEJXV2RWTkc4bWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD1mOA--"
// aka APIKey2/Client Secret (Consumer Secret)
let ConsumerSecret = "5ccc0d61e58514d24eac2f95fad475e270b97b84"
// App ID
let appID = "MIAYgU4o"

class YahooWeatherAPI: NSObject, XMLParserDelegate {
    
    
    let QUERY_PREFIX1 = "https://weather-ydn-yql.media.yahoo.com/forecastrss?location="
    let QUERY_PREFIX1A = "https://weather-ydn-yql.media.yahoo.com/forecastrss?lat="
    let QUERY_PREFIX1B = "&lon="
    let QUERY_PREFIX1A1 = "https://weather-ydn-yql.media.yahoo.com/forecastrss?woeid="
    let QUERY_SUFFIX1 = "&u=f&format=json"
    // Optionally &lat=12.345,&lon=123.456 instead of location=
    
    var element = NSString()

    var localWeatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()

    var data: Data?
    
    func beginParsing(_ inputCity: String, displayCity: String, APIKey1: String, APIKey2: String, weatherFields: inout WeatherFields) {

        DebugLog(String(format:"in beginParsing: %@", inputCity))

        var escapedCity = String()
        var parseURL = String()
        
        //var Parser = XMLParser()

        // https://developer.yahoo.com/weather/
        
        localWeatherFields = weatherFields
        
        parseURL = ""
        escapedCity = inputCity.replacingOccurrences(of: ", ", with: ",")
        escapedCity = escapedCity.replacingOccurrences(of: " ,", with: ",")
        escapedCity = escapedCity.replacingOccurrences(of: " ", with: "-")
        escapedCity = escapedCity.replacingOccurrences(of: "&", with: "")

        // Is escapedCity a city, state or a lat,long or a woeid?
        let arr = escapedCity.components(separatedBy: ",")
        if (arr.count == 1) {
            let n1 = arr[0]
            let f1 = Int(n1)
            let s1 = f1?.description
            if ((arr[0] == s1) && (escapedCity.count != 5)) {
                parseURL.append(QUERY_PREFIX1A1)
                parseURL.append(n1)
            } else {
                parseURL.append(QUERY_PREFIX1)
                parseURL.append(escapedCity)
            }
        } else if (arr.count == 2) {
            let n1 = arr[0]
            let f1 = Double(n1)
            let s1 = f1?.description
            let n2 = arr[1]
            let f2 = Double(n2)
            let s2 = f2?.description
            if ((arr[0] == s1) && (arr[1] == s2)) {
                parseURL.append(QUERY_PREFIX1A)
                parseURL.append(n1)
                parseURL.append(QUERY_PREFIX1B)
                parseURL.append(n2)
            } else {
                parseURL.append(QUERY_PREFIX1)
                parseURL.append(escapedCity)
            }
        } else {
            parseURL.append(QUERY_PREFIX1)
            parseURL.append(escapedCity)
        }

        parseURL.append(QUERY_SUFFIX1)
        InfoLog(String(format:"URL for Yahoo: %@\n", parseURL))
        //print(String(format:"URL for Yahoo: %@\n", parseURL))
        var ak1 = APIKey1
        var ak2 = APIKey2
        if (ak1 == "") {
            ak1 = ConsumerKey
        }
        if (ak2 == "") {
            ak2 = ConsumerSecret
        }
        
        // https://github.com/mw99/OhhAuth
        //let uc = (key: "", secret: "")
        let myURL = URL(string: parseURL)
        if (myURL == nil) {
            self.localWeatherFields.currentTemp = "9999"
            self.localWeatherFields.latitude = "Invalid Location"
        } else {
            let cc = (key: ak1, secret: ak2)
            var req = URLRequest(url: myURL!)
            let paras = ["X-Yahoo-App-Id": appID, "Content-Type": "application/json"]
            //let paras = ["": ""]
            
            req.oAuthSign(method: "POST", urlFormParameters: paras, consumerCredentials: cc, userCredentials: nil)
            req.timeoutInterval = 3.0
            
            let group = DispatchGroup()
            group.enter()
            let task = URLSession(configuration: .ephemeral).dataTask(with: req) { (data, response, error) in
                if let error = error {
                    print(error)
                    self.localWeatherFields.currentTemp = "9999"
                    self.localWeatherFields.latitude = error.localizedDescription
                }
                else if let data = data {
                    //print(String(data: data, encoding: .utf8) ?? "Does not look like a utf8 response :(")
                    //let sData = String(decoding: data, as: UTF8.self)
                    self.data = data
                    //InfoLog("Data for: " + parseURL)
                    //InfoLog(String(decoding: data, as: UTF8.self))
                    //print(String(decoding: data, as: UTF8.self))
                    
                    self.processWeatherData(data)
                    
                    if (self.localWeatherFields.forecastCounter == -1) {
                        self.localWeatherFields.forecastCounter = 0
                    }
                }
                group.leave()
            }
            task.resume()
            group.wait()
        }
        
        //self.localWeatherFields.currentTemp = "9999"
        //self.localWeatherFields.latitude = localizedString(forKey: "Unknown Error")
        
        if (self.localWeatherFields.forecastCounter == -1) {
            self.localWeatherFields.forecastCounter = 0
        }
        
        weatherFields = self.localWeatherFields
        
        DebugLog(String(format:"leaving beginParsing: %@", inputCity))
    } // beginParsing
    
    func processWeatherData(_ data: Data) {
        localWeatherFields.forecastCounter = 0
        do {
            let object = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readJSONObject(object: dictionary, weatherFields: &localWeatherFields)
            }
        } catch {
            // Handle Error
            self.localWeatherFields.currentTemp = "9999"
            self.localWeatherFields.latitude = error.localizedDescription
            ErrorLog("Yahoo2 " + String(decoding: data, as: UTF8.self))
        }
    } // processWeatherData
    
    func convert_Inches_mbar(_ temp: String) -> String
    {
        // millibar value = kPa val ue x 33.8637526
        let answer = String(Int((temp as NSString).doubleValue * 33.8637526))
        
        return answer
    } // convert_Inches_mbar() -> String

    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // extendedForecasts
 
    // MARK: - XML support
    // XMLParser Methods
    
    var inLat = 0
    var inLong = 0
    var inLink = 0

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        DebugLog(String(format:"in didStartElement: %@", elementName))
        element = elementName as NSString
        
        // This is for City name lookup
        if (elementName as NSString).isEqual(to: "yweather:location") {
            localWeatherFields.title1 = attributeDict["city"]! + attributeDict["region"]!
        } else if (elementName as NSString).isEqual(to: "yweather:wind") {
            localWeatherFields.windSpeed = attributeDict["speed"]!
            localWeatherFields.windDirection = attributeDict["direction"]!
        } else if (elementName as NSString).isEqual(to: "yweather:atmosphere") {
            localWeatherFields.humidity = attributeDict["humidity"]!
            localWeatherFields.pressure = convert_Inches_mbar(attributeDict["pressure"]!)  // Convert Inches to millibars
            localWeatherFields.visibility = attributeDict["visibility"]!
        } else if (elementName as NSString).isEqual(to: "yweather:astronomy") {
            localWeatherFields.sunrise = attributeDict["sunrise"]!
            localWeatherFields.sunset = attributeDict["sunset"]!
        } else if (elementName as NSString).isEqual(to: "yweather:condition") {
            localWeatherFields.date = attributeDict["date"]!
            localWeatherFields.currentTemp = attributeDict["temp"]!
            localWeatherFields.currentCode = attributeDict["code"]!
            localWeatherFields.currentConditions = attributeDict["text"]!
        } else if (elementName as NSString).isEqual(to: "yweather:forecast") {
            localWeatherFields.forecastCounter = localWeatherFields.forecastCounter + 1
            localWeatherFields.forecastDate[localWeatherFields.forecastCounter] = attributeDict["date"]!
            localWeatherFields.forecastDay[localWeatherFields.forecastCounter] = attributeDict["day"]!
            localWeatherFields.forecastHigh[localWeatherFields.forecastCounter] = attributeDict["high"]!
            localWeatherFields.forecastLow[localWeatherFields.forecastCounter] = attributeDict["low"]!
            localWeatherFields.forecastCode[localWeatherFields.forecastCounter] = attributeDict["code"]!
            localWeatherFields.forecastConditions[localWeatherFields.forecastCounter] = attributeDict["text"]!
        } else if (elementName as NSString).isEqual(to: "link") {
            inLink = 1
        } else if (elementName as NSString).isEqual(to: "geo:lat") {
            inLat = 1
        } else if (elementName as NSString).isEqual(to: "geo:long") {
            inLong = 1

        }
        
        DebugLog(String(format:"leaving didStartElement: %@", elementName))
    } // parser parser:didStartElement
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        DebugLog(String(format:"in didEndElement: %@", elementName))
        
        // This is for City name lookup
        if (elementName as NSString).isEqual(to: "link") {
            inLink = 0
        } else if (elementName as NSString).isEqual(to: "geo:lat") {
            inLat = 0
        } else if (elementName as NSString).isEqual(to: "geo:long") {
            inLong = 0

        }
        
        DebugLog(String(format:"leaving didEndElement: %@", elementName))
    } // parser parser:didEndElement
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        DebugLog(String(format:"in foundCharacters: %@\n", string))
        
        if (inLink == 1) {
            let regex = try! NSRegularExpression(pattern: "^(.*?)\\s*https:\\s*(.*)$", options: .caseInsensitive)
            if let match = regex.firstMatch(in: string, range: NSRange(string.startIndex ..< string.endIndex, in: string)) {
                localWeatherFields.URL = "https:" + String(string[Range(match.range(at: 2), in: string)!])
            }
        } else if (inLat == 1) {
            localWeatherFields.latitude = string
        } else if (inLong == 1) {
            localWeatherFields.longitude = string

        }
        
        DebugLog(String(format:"leaving foundCharacters: %@\n", string))
    } // parser parser:foundCharacters
    
    
    // MARK: - JSON support
    func readJSONObject(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        guard
            let location = object["location"] as? [String: AnyObject],
            let co = object["current_observation"] as? [String: AnyObject],
            let forecasts = object["forecasts"] as? [[String: AnyObject]]
            else {
                _ = "error"
                return }
        
        for l in [location] {
            guard
                //let city = l["city"] as? String,
                //let region = l["region"] as? String,
                //let country = l["country"] as? String,
                let lat = l["lat"] as? Double,
                let long = l["long"] as? Double,
                //let timezone_id = l["timezone_id"] as? String,
                let iWoeid = l["woeid"] as? Int
                else {
                    _ = "error"
                    return
            }
            weatherFields.latitude = String(describing: lat)
            weatherFields.longitude = String(describing: long)
            weatherFields.URL = "https://www.yahoo.com/news/weather/forecast/" + String(describing: iWoeid)
        }
        
        for c in [co] {
            guard
                let wind = c["wind"] as? [String: AnyObject],
                let atmosphere = c["atmosphere"] as? [String: AnyObject],
                let astronomy = c["astronomy"] as? [String: AnyObject],
                let pubDate = c["pubDate"] as? Int,
                let condition = c["condition"] as? [String: AnyObject]
                else {
                    _ = "error"
                    return }
            for w in [wind] {
                guard
                    let direction = w["direction"] as? Int,
                    //let chill = w["chill"] as? Int,
                    let speed = w["speed"] as? Double
                    else {
                        _ = "error"
                        return }
                weatherFields.windSpeed = String(describing: speed)
                weatherFields.windDirection = String(describing: direction)
            }
            for atmo in [atmosphere] {
                guard
                    let humidity = atmo["humidity"] as? Int,
                    //let visiblity = atmo["visiblity"] as? Int,
                    let pressure = atmo["pressure"] as? Double
                    else {
                        _ = "error"
                        return }
                weatherFields.humidity = String(describing: humidity)
                weatherFields.pressure = convert_Inches_mbar(String(describing: pressure))
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
            for cond in [condition] {
                guard
                    let cText = cond["text"] as? String,
                    let cTemperature = cond["temperature"] as? Int,
                    let cCode = cond["code"] as? Int
                    else {
                        _ = "error"
                        return }
                weatherFields.currentCode = String(describing: cCode)
                weatherFields.currentTemp = String(describing: cTemperature)
                //weatherFields.currentLink = cLink
                weatherFields.currentConditions = cText
            }
            // Convert epoch to m DDD yyyy
            let time = NSDate(timeIntervalSince1970: TimeInterval(pubDate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            weatherFields.date = dateFormatter.string(from: time as Date)
        }
        for f in forecasts {
            guard
                let fDay = f["day"] as? String,
                let fDate = f["date"] as? Int,
                let fLow = f["low"] as? Int,
                let fHigh = f["high"] as? Int,
                let fText = f["text"] as? String,
                let fCode = f["code"] as? Int
                else {
                    _ = "error"
                    return }
            weatherFields.forecastCode[weatherFields.forecastCounter] = String(describing: fCode)
            weatherFields.forecastLow[weatherFields.forecastCounter] = String(describing: fLow)
            weatherFields.forecastHigh[weatherFields.forecastCounter] = String(describing: fHigh)
            weatherFields.forecastDay[weatherFields.forecastCounter] = fDay
            
            // Convert epoch to m DDD yyyy
            let date = NSDate(timeIntervalSince1970: TimeInterval(fDate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy"
            weatherFields.forecastDate[weatherFields.forecastCounter] = dateFormatter.string(from: date as Date)

            weatherFields.forecastConditions[weatherFields.forecastCounter] = fText
            
            weatherFields.forecastCounter = weatherFields.forecastCounter + 1
            }

        } // readJSONObject

} // class YahooWeatherAPI
