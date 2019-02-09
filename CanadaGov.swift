//
//  CanadaGov
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
// https://weather.gc.ca/city/pages/on-146_metric_e.html?unit=imperial
// https://www.canada.ca/en/environment-climate-change/services/weather-general-tools-resources/weather-tools-specialized-data/geospatial-web-services.html
// http://www.opengeospatial.org/standards/wms
// http://dd.weatheroffice.ec.gc.ca/citypage_weather/xml/siteList.xml
// http://dd.weatheroffice.ec.gc.ca/citypage_weather/xml/ON/s0000458_e.xml <-- Sample URL (Toronto)
//
// http://www.canada-city.ca/duplicate-cities.php
//
// http://dd.weather.gc.ca/doc/README_AMQP.txt
//

import Cocoa
import Foundation

class CanadaWeatherAPI: NSObject, XMLParserDelegate
{
    let QUERY_PREFIX0 = "http://dd.weatheroffice.ec.gc.ca/citypage_weather/xml/siteList.xml"
    let QUERY_PREFIX1 = "http://dd.weatheroffice.ec.gc.ca/citypage_weather/xml/"
    let QUERY_SUFFIX1 = "_e.xml"

    var Parser = XMLParser()
    var element = NSString()
    
    var parseURL = String()
    
    var localWeatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()
    
    var provinceCode = ""
    var siteCode = ""
    var cityIn = ""
    var provinceIn = ""
    var inCity = ""
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String, weatherFields: inout WeatherFields) {
        
        DebugLog(String(format:"in beginParsing: %@", inputCity))
        
        siteCode = ""
        provinceCode = ""
        
        Parser = XMLParser()
        
        parseURL = QUERY_PREFIX0
        // Look for InputCity as either nameEn or nameFr or Name, Province (if comma found, we need to parse)
        // Once found grab "site code" value and "provinceCode" value and use in the next URL
        // Caution: Windsor - Nova Scotia, Ontario, Quebec
        //
        InfoLog(String(format:"Canada.ca city lookup: %@ (%a)\n", parseURL, inputCity))
        cityIn = inputCity

        let regex = try! NSRegularExpression(pattern: "^(.*?)\\s*,\\s*(.*)$", options: .caseInsensitive)
        if let match = regex.firstMatch(in: inputCity, range: NSRange(inputCity.startIndex ..< inputCity.endIndex, in: inputCity)) {
            cityIn = String(inputCity[Range(match.range(at: 1), in: inputCity)!])
            provinceIn = String(inputCity[Range(match.range(at: 2), in: inputCity)!])
        }
        cityIn = cityIn.lowercased()
        provinceIn = provinceIn.lowercased()

        Parser = XMLParser(contentsOf:(URL(string:parseURL as String))!)!

        // Find InputCity
        Parser.delegate = self
        Parser.parse()

        parseURL = ""
        parseURL.append(QUERY_PREFIX1)
        parseURL.append(provinceCode as String)
        parseURL.append("/")
        parseURL.append(siteCode as String)
        parseURL.append(QUERY_SUFFIX1)
        InfoLog(String(format:"URL Canada.ca Weather: %@\n", parseURL))

        // No enhanced Encoding required
        // <?xml version="1.0" encoding="iso-8859-1"?>
        Parser = XMLParser(contentsOf:(URL(string:parseURL as String))!)!
        
        localWeatherFields = weatherFields
        localWeatherFields.forecastCounter = 0

        // Find Current weather conditions
        Parser.delegate = self
        Parser.parse()
        
        localWeatherFields.forecastCounter = localWeatherFields.forecastCounter - 1 // Remove last one
        weatherFields = localWeatherFields
        
        DebugLog(String(format:"leaving beginParsing: %@", inputCity))
        
        return
    } // beginParsing
    
    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // extendedForecasts
    
    func convertCtoF(_ temp: String) -> String
    {
        // https://www.rapidtables.com/convert/temperature/celsius-to-fahrenheit.html
        // T(°F) = T(°C) × 1.8 + 32
        let answer = String(Int(((temp as NSString).doubleValue * 1.8) + 32))
        
        return answer
    } // convertCtoF() -> String
    
    func convert_kPa_mbar(_ temp: String) -> String
    {
        // https://www.unitjuggler.com/convert-pressure-from-kPa-to-mbar.html
        // millibar value = kPa value x 10.0
        let answer = String(Int((temp as NSString).doubleValue * 10.0) )
        
        return answer
    } // convert_kPa_mbar() -> String
    
    func convert_km_miles(_ temp: String) -> String
    {
        // https://www.rapidtables.com/convert/length/km-to-mile.html
        // d(mi) = d(km) * 0.62137119
        let answer = String(Int((temp as NSString).doubleValue * 0.62137119) )
        
        return answer
    } // convert_km_miles() -> String
    
    func convert_kph_mph(_ temp: String) -> String
    {
        // https://www.unitconverters.net/speed/kph-to-mph.htm
        // 1 mi/h = 1.609344 km/h
        let answer = String(Int((temp as NSString).doubleValue * 0.6213711922) )
        
        return answer
    } // convert_kph_mph() -> String
    
    // XMLParser Methods
    
    var inNameEn = 0
    var inNameFr = 0
    var inProvinceCode = 0
    var saveSiteCode = ""
    var saveName = ""
    var saveCity = ""
    
    var inXS = 0
    var utcDate = 0
    var localDate = 0
    var inStation = 0
    var inDateTime = 0
    var inHour = 0
    var inMinute = 0
    var inCurrentConditions = 0
    var inTemp = 0
    var inRelativeHumidity = 0
    var inPressure = 0
    var inVisibility = 0
    var inBearing = 0
    var inSpeed = 0
    var inGust = 0
    var inCondition = 0
    var inRiseSet = 0
    var inSunrise = 0
    var inSunset = 0
    var inForecastGroup = 0
    var inForecast = 0
    var inIconCode = 0
    var inCurrentDate = 0
    var inForecastDate = 0
    var inDay = 0
    var first = true
    var timeZone = ""
    var inPeriod = 0
    var nightForecast = 0
    var inAbbreviatedForecast = 0
    var inTextSummary = 0

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        DebugLog(String(format:"in didStartElement: %@", elementName))
        element = elementName as NSString
        
        // This is for City name lookup
        if (elementName as NSString).isEqual(to: "site") {
            saveSiteCode = attributeDict["code"]!;
        } else if (elementName as NSString).isEqual(to: "nameEn") {
            inNameEn = 1
            inCity = ""
        } else if (elementName as NSString).isEqual(to: "nameFr") {
            inNameFr = 1
            inCity = ""
        } else if ((elementName as NSString).isEqual(to: "provinceCode") &&
            (cityIn == inCity.lowercased())) {
            inProvinceCode = 1
        
        // This is for the weather feed itself
        } else if (elementName as NSString).isEqual(to: "currentConditions") {
            inCurrentConditions = 1
        } else if ((inCurrentConditions == 1) &&
            (elementName as NSString).isEqual(to: "station")) { // Lat/Lon
            localWeatherFields.latitude = attributeDict["lat"]!;
            localWeatherFields.longitude = attributeDict["lon"]!;
            inStation = 1
        } else if ((elementName as NSString).isEqual(to: "dateTime")) {
            inDateTime = 1
            timeZone = attributeDict["zone"] ?? "???"
            if (attributeDict["zone"] == "UTC") {
                utcDate = 1
            } else {
                localDate = 1
            }
            if (attributeDict["name"] == "observation") {
                inCurrentDate = 1
            } else if (attributeDict["name"] == "forecastIssue") {
                inForecastDate = 1
            } else if (attributeDict["name"] == "sunrise") {
                inSunrise = 1
                inSunset = 0
            } else if (attributeDict["name"] == "sunset") {
                inSunset = 1
                inSunrise = 0
            }
        } else if (elementName as NSString).isEqual(to: "hour") {
            inHour = 1
        } else if (elementName as NSString).isEqual(to: "minute") {
            inMinute = 1
        } else if (elementName as NSString).isEqual(to: "day") {
            inDay = 1
       } else if (elementName as NSString).isEqual(to: "wind") {
            inXS = 1
        } else if (elementName as NSString).isEqual(to: "speed") { // km/h
            inSpeed = 1
        } else if (elementName as NSString).isEqual(to: "gust") { // put together?
            inGust = 1
        } else if (elementName as NSString).isEqual(to: "bearing") {
            inBearing = 1
        } else if (elementName as NSString).isEqual(to: "relativeHumidity") {
            inRelativeHumidity = 1
        } else if (elementName as NSString).isEqual(to: "pressure") { // kPa
            inPressure = 1
        } else if (elementName as NSString).isEqual(to: "visibility") { // km
            inVisibility = 1
        } else if (elementName as NSString).isEqual(to: "temperature") { // C
            inTemp = 1
        } else if (elementName as NSString).isEqual(to: "iconCode") {
            inIconCode = 1
        } else if (elementName as NSString).isEqual(to: "condition") {
            inCondition = 1
            
        // Sunrise then sunset, UTC then local
        } else if (elementName as NSString).isEqual(to: "riseSet") {
            inRiseSet = 1

        // 12 hour segments so 2 calls for high/low
        } else if (elementName as NSString).isEqual(to: "forecastGroup") {
            inForecastGroup = 1
        } else if (elementName as NSString).isEqual(to: "forecast") {
            inForecast = 1
        } else if (elementName as NSString).isEqual(to: "period") {
            inPeriod = 1
        } else if (elementName as NSString).isEqual(to: "forecast") {
            inXS = 1
        } else if (elementName as NSString).isEqual(to: "temperatures") {
            inXS = 1
        } else if (elementName as NSString).isEqual(to: "temperature") { // C
            inXS = 1
        } else if (elementName as NSString).isEqual(to: "abbreviatedForecast") {
            inAbbreviatedForecast = 1
        } else if (elementName as NSString).isEqual(to: "textSummary") {
            inTextSummary = 1

        }

        DebugLog(String(format:"leaving didStartElement: %@", elementName))
    } // parser parser:didStartElement
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        DebugLog(String(format:"in didEndElement: %@", elementName))
        
        // This is for City name lookup
        if (elementName as NSString).isEqual(to: "nameEn") {
            inNameEn = 0
        } else if (elementName as NSString).isEqual(to: "nameFr") {
            inNameFr = 0
        } else if (elementName as NSString).isEqual(to: "provinceCode") {
            inProvinceCode = 0
            
            // This is for the weather feed itself
        } else if (elementName as NSString).isEqual(to: "currentConditions") {
            inCurrentConditions = 0
        } else if ((elementName as NSString).isEqual(to: "station")) { // Lat/Lon
            inStation = 0
        } else if ((elementName as NSString).isEqual(to: "dateTime")) { // UTC then local
            inDateTime = 0
            utcDate = 0
            localDate = 0
            inCurrentDate = 0
            inForecastDate = 0
        } else if (elementName as NSString).isEqual(to: "hour") {
            inHour = 0
        } else if (elementName as NSString).isEqual(to: "minute") {
            inMinute = 0
        } else if (elementName as NSString).isEqual(to: "day") {
            inDay = 0
        } else if (elementName as NSString).isEqual(to: "wind") {
            inXS = 0
        } else if (elementName as NSString).isEqual(to: "speed") { // km/h
            inSpeed = 0
        } else if (elementName as NSString).isEqual(to: "gust") { // put together?
            inGust = 0
        } else if (elementName as NSString).isEqual(to: "bearing") {
            inBearing = 0
        } else if (elementName as NSString).isEqual(to: "relativeHumidity") {
            inRelativeHumidity = 0
        } else if (elementName as NSString).isEqual(to: "pressure") { // kPa
            inPressure = 0
        } else if (elementName as NSString).isEqual(to: "visibility") { // km
            inVisibility = 0
            
        } else if (elementName as NSString).isEqual(to: "temperature") { // C
            inTemp = 0
        } else if (elementName as NSString).isEqual(to: "iconCode") {
            inIconCode = 0
        } else if (elementName as NSString).isEqual(to: "condition") {
            inCondition = 0
            
        // Sunrise then sunset, UTC then local
        } else if (elementName as NSString).isEqual(to: "riseSet") {
            inRiseSet = 0
            
        // 12 hour segments so 2 calls for high/low
        } else if (elementName as NSString).isEqual(to: "forecastGroup") {
            inForecastGroup = 0
            first = true
        } else if (elementName as NSString).isEqual(to: "forecast") {
            inForecast = 0
            if (first == true) {
                localWeatherFields.forecastCounter = localWeatherFields.forecastCounter + 1 // Count ever other one (12 hour windows)
            }
            first = !first
        } else if (elementName as NSString).isEqual(to: "period") {
            inPeriod = 0
        } else if (elementName as NSString).isEqual(to: "abbreviatedForecast") {
            inAbbreviatedForecast = 0
        } else if (elementName as NSString).isEqual(to: "textSummary") {
            inTextSummary = 0

        }
        
        DebugLog(String(format:"leaving didEndElement: %@", elementName))
    } // parser parser:didEndElement
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        DebugLog(String(format:"in foundCharacters: %@\n", string))
        
        // This is for City name lookup
        if ((inNameEn == 1) || (inNameFr == 1)) {
            inCity = inCity + string
            if (cityIn == inCity.lowercased()) {
                saveCity = inCity
                if (provinceIn == "") {
                    siteCode = saveSiteCode
                }
            }
        } else if ((inProvinceCode == 1) && (saveCity != "") && (siteCode == "") && (provinceCode == "")) {
            if (provinceIn == string.lowercased()) {
                siteCode = saveSiteCode
                provinceCode = string
            }
        } else if ((inProvinceCode == 1) && (saveCity != "") && (siteCode != "") && (provinceCode == "")) {
            provinceCode = string

        // This is for the weather feed itself
        // CurrentConditions
        } else if ((inCurrentConditions == 1) && (inStation == 1)) {
            localWeatherFields.title1 = string
        } else if ((inCurrentDate == 1) && (inHour == 1) && (utcDate == 1)) {
            localWeatherFields.date = string
        } else if ((inCurrentDate == 1) && (inMinute == 1) && (utcDate == 1)) {
            localWeatherFields.date = localWeatherFields.date + ":" + string + " UTC"
        } else if ((inCurrentConditions == 1) && (inTemp == 1)) {
            localWeatherFields.currentTemp = convertCtoF(string) // Convert C to F
        } else if ((inCurrentConditions == 1) && (inRelativeHumidity == 1)) {
            localWeatherFields.humidity = string
        } else if ((inCurrentConditions == 1) && (inPressure == 1)) {
            localWeatherFields.pressure = convert_kPa_mbar(string) // Convert kPa to mmHg
        } else if ((inCurrentConditions == 1) && (inVisibility == 1)) {
            localWeatherFields.visibility = convert_km_miles(string) // Convert km to miles
        } else if ((inCurrentConditions == 1) && (inBearing == 1)) {
            localWeatherFields.windDirection = String(describing: Int(Float(string) ?? 0)) // Remove decimal
        } else if ((inCurrentConditions == 1) && (inSpeed == 1)) {
            localWeatherFields.windSpeed = convert_kph_mph(string) // kph to mph
//        } else if ((inCurrentConditions == 1) && (inGust == 1)) {
//            localWeatherFields.windSpeed = localWeatherFields.windSpeed + "G" + convert_kph_mph(String(describing: Int(string))) // kph to mph
        } else if ((inCurrentConditions == 1) && (inCondition == 1)) {
            localWeatherFields.currentConditions = string
            //localWeatherFields.currentCode = string // Cloudy/Fog, etc -> but not always single word
        } else if ((inCurrentConditions == 1) && (inIconCode == 1)) {
            localWeatherFields.currentCode = string

        // Sunrise
        } else if ((inSunrise == 1) && (inHour == 1) && (localDate == 1)) {
            localWeatherFields.sunrise = string
        } else if ((inSunrise == 1) && (inMinute == 1) && (localDate == 1)) {
            localWeatherFields.sunrise = localWeatherFields.sunrise + ":" + string
        // Sunset
        } else if ((inSunset == 1) && (inHour == 1) && (localDate == 1)) {
            localWeatherFields.sunset = string
        } else if ((inSunset == 1) && (inMinute == 1) && (localDate == 1)) {
            localWeatherFields.sunset = localWeatherFields.sunset + ":" + string

        // Forecast
        } else if ((inForecastGroup == 1) && (inPeriod == 1)) {
            localWeatherFields.forecastDate[localWeatherFields.forecastCounter] = String(string.prefix(3))
            localWeatherFields.forecastDay[localWeatherFields.forecastCounter] = String(string.prefix(3))
            nightForecast = 0
            if (String(string.suffix(5)) == "night") {
                nightForecast = 1
            }
        } else if ((inForecast == 1) && (inTemp == 1) && (nightForecast == 0)) {
            localWeatherFields.forecastHigh[localWeatherFields.forecastCounter] = convertCtoF(string) // Convert C to F
        } else if ((inForecast == 1) && (inTemp == 1) && (nightForecast == 1)) {
            localWeatherFields.forecastLow[localWeatherFields.forecastCounter] = convertCtoF(string) // Convert C to F
        } else if ((inForecast == 1) && (inAbbreviatedForecast == 1) && (inTextSummary == 1)) {
            localWeatherFields.forecastConditions[localWeatherFields.forecastCounter] = string
            //localWeatherFields.forecastCode[localWeatherFields.forecastCounter] = string
        } else if ((inForecast == 1) && (inIconCode == 1)) {
            localWeatherFields.forecastCode[localWeatherFields.forecastCounter] = string

        }

        DebugLog(String(format:"leaving foundCharacters: %@\n", string))
    } // parser parser:foundCharacters
    
} // CanadaWeatherAPI
