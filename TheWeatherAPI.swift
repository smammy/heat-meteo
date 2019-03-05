//
//  TheWeather.swift
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
// http://api.theweather.com
//
// edwardd20@danleys.org/P@ssw0rd
// affiliate_id = 4p1m5jb7mnyt
// localidad for Naperville = 157281
// http://api.theweather.com/index.php?api_lang=eu&localidad=157281&affiliate_id=4p1m5jb7mnyt

import Cocoa
import Foundation

class TheWeatherAPI: NSObject, XMLParserDelegate
{
    let QUERY_PREFIX1 = "http://api.theweather.com/index.php?api_lang=eu&localidad="
    let QUERY_SUFFIX1 = "&affiliate_id="
    
    var Parser = XMLParser()
    var element = NSString()
    
    var escapedCity = NSString()
    var parseURL = String()
    
    var weatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String, weatherFields: inout WeatherFields) {
        
        DebugLog(String(format:"in beginParsing: %@", inputCity))
        
        Parser = XMLParser()
        
        // https://TheWeather.com
        
        // Should emit "Powered by Yahoo!", https://poweredby.yahoo.com/purple.png
        //var weatherQuery = NSString()
        //weatherQuery = "http://api.openweathermap.org/data/2.5/weather?q=&appid=XYZZY&mode=xml&units=imperial"
        
        parseURL = ""
        parseURL.append(QUERY_PREFIX1)
        parseURL.append(inputCity as String)
        parseURL.append(QUERY_SUFFIX1)
        parseURL.append(APIKey1)
        InfoLog(String(format:"URL for OpenWeatherMap: %@\n", parseURL))
        
        parseURL = ""
        parseURL.append(QUERY_PREFIX1)
        escapedCity = inputCity.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
        escapedCity = escapedCity.replacingOccurrences(of: ",", with: "%3D") as NSString
        parseURL.append(escapedCity as String)
        parseURL.append(QUERY_SUFFIX1)
        parseURL.append(APIKey1)
        Parser = XMLParser(contentsOf:(URL(string:parseURL as String))!)!
        
        // Find Current weather conditions
        Parser.delegate = self
        Parser.parse()
        
        DebugLog(String(format:"leaving beginParsing: %@", inputCity))
        
        return
    } // beginParsing
    
    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // extendedForecasts
    
    // XMLParser Methods
    
    // For testing: http://api.theweather.com/index.php?api_lang=eu&localidad=157281&affiliate_id=4p1m5jb7mnyt
    
    var inName = 0
    var inMinTemp = 0
    var inMaxTemp = 0
    var inDay = 0
    var inSymbol = 0
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        DebugLog(String(format:"in didStartElement: %@", elementName))
        element = elementName as NSString
        
        if (elementName as NSString).isEqual(to: "location") {
            weatherFields.title1.append(attributeDict["city"]!)
            
        } else if (elementName as NSString).isEqual(to: "name") {
            inName = 1
            
        } else if (elementName as NSString).isEqual(to: "forecast") {
            if (inMinTemp == 1)
            {
                let F = Int((attributeDict["value"]! as NSString).doubleValue * 9/5) + 32
                weatherFields.forecastLow[weatherFields.forecastCounter].append(String(describing: F))
                weatherFields.forecastCounter = weatherFields.forecastCounter + 1
            }
            else if (inMaxTemp == 1)
            {
                let F = Int((attributeDict["value"]! as NSString).doubleValue * 9/5) + 32
                weatherFields.forecastHigh[weatherFields.forecastCounter].append(String(describing: F))
                weatherFields.forecastCounter = weatherFields.forecastCounter + 1
            }
            else if (inDay == 1)
            {
                var string = attributeDict["value"]!
                let index = string.index(string.startIndex, offsetBy: 3)
                string = String(string.prefix(upTo: index))
                weatherFields.forecastDay[weatherFields.forecastCounter].append(string)
                weatherFields.forecastCounter = weatherFields.forecastCounter + 1
            }
            else if (inSymbol == 1)
            {
                weatherFields.forecastConditions[weatherFields.forecastCounter].append(attributeDict["value"]!)
                weatherFields.forecastCode[weatherFields.forecastCounter].append(attributeDict["id"]!)
                weatherFields.forecastCounter = weatherFields.forecastCounter + 1
            }
        }
        DebugLog(String(format:"leaving didStartElement: %@", elementName))
    } // parser parser:didStartElement
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        DebugLog(String(format:"in didEndElement: %@", elementName))
        
        if (elementName as NSString).isEqual(to: "name") {
            inName = 0
        }
        if (elementName as NSString).isEqual(to: "data") {
            inMinTemp = 0
            inMaxTemp = 0
            inDay = 0
        }
        DebugLog(String(format:"leaving didEndElement: %@", elementName))
    } // parser parser:didEndElement
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        DebugLog(String(format:"in foundCharacters: %@\n", string))

        if (element as NSString).isEqual(to: "url") {
            weatherFields.URL = string
        } else if (element as NSString).isEqual(to: "error") {
            weatherFields.currentTemp = "9999"
            weatherFields.latitude = string
        } else if (inName == 1) {
            if (string == "Minimum temperature") {
                weatherFields.forecastCounter = 0
                inMinTemp = 1
            }
            else if (string == "Maximum temperature") {
                weatherFields.forecastCounter = 0
                inMaxTemp = 1
            }
            else if (string == "Day symbol") {
                weatherFields.forecastCounter = 0
                inDay = 1
            }
            else if (string == "Symbol") {
                weatherFields.forecastCounter = 0
                inSymbol = 1
            }
            else
            {
                inSymbol = 0
            }
        }
        
        DebugLog(String(format:"leaving foundCharacters: %@\n", string))
    } // parser parser:foundCharacters
    
}
