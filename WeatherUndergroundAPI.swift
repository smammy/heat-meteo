//
//  WeatherUnderground.swift
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
// http://www.wunderground.com/weather/api/
//
// referral URL: http://www.wunderground.com/?apiref=f4d4adc0812ab48d
// API Key = 97eaacd6a89f603b
// API Key belonging to Mitch Greenfield = baa5bb35245a4047a5bb35245a10474f
// PWS ID = KKYPROSP19
// https://docs.google.com/document/d/1KGb8bTVYRsNgljnNH67AMhckY8AQT2FVwZ9urj8SWBs/edit
// https://docs.google.com/document/d/1eKCnKXI9xnoMGRRzOL1xPCBihNV2rOet08qpE_gArAY/edit
//
// Old
// Sample Current: http://api.wunderground.com/api/97eaacd6a89f603b/conditions/q/IL/Naperville.json
// Sample 10 Day : http://api.wunderground.com/api/97eaacd6a89f603b/forecast10day/q/IL/Naperville.json
// Combined: http://api.wunderground.com/api/97eaacd6a89f603b/geolookup/conditions/forecast10day/q/IL/Naperville.json
// Danger Will Robinson: https://apicommunity.wunderground.com/weatherapi/topics/end-of-service-for-the-weather-underground-api
//
// New:
// Sample Current: https://api.weather.com/v2/pws/observations/current?stationId=KKYPROSP19&format=json&units=e&apiKey=baa5bb35245a4047a5bb35245a10474f
// Sample 5 day:   https://api.weather.com/v3/wx/forecast/daily/5day?geocode=38.32564545,-85.56961823&format=json&units=e&language=en-US&apiKey=baa5bb35245a4047a5bb35245a10474f



import Foundation
import Cocoa
import Foundation

//let APIID = "97eaacd6a89f603b" // Ed's key

class WeatherUndergroundAPI: NSObject, XMLParserDelegate
{
    let QUERY_PREFIX1 = "https://api.weather.com/v2/pws/observations/current?stationId="
    let QUERY_SUFFIX1a = "&format=json&units=e&apiKey="
    let QUERY_PREFIX2 = "https://api.weather.com/v3/wx/forecast/daily/5day?geocode="
    let QUERY_SUFFIX2a = "&format=json&units=e&language=en-US&apiKey="

    var weatherFields = WeatherFields()
    
    var radarWindow = RadarWindow()
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String, weatherFields: inout WeatherFields) {
        
        var parseURL = String()
        
        DebugLog(String(format:"in beginParsing: %@", inputCity))
        
        // https://www.wunderground.com
        
        // Should emit "Weather Underground", http://icons.wxug.com/graphics/wu2/logo_130x80.png
        //var weatherQuery = NSString()
        
        parseURL = ""
        parseURL.append(QUERY_PREFIX1)
        parseURL.append(inputCity)
        parseURL.append(QUERY_SUFFIX1a)
        parseURL.append(APIKey1)
        InfoLog(String(format:"URL for Weather Underground: %@\n", parseURL))
        
        var url = URL(string: parseURL)
        var data: NSData?
        data = nil
        if (url != nil)
        {
            do {
                // https://stackoverflow.com/questions/40812416/nsurl-url-and-nsdata-data?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
                data = try Data(contentsOf: url!) as NSData
            } catch {
                ErrorLog("WeatherUnderground \(error)")
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
                readJSONObjectE(object: dictionary, weatherFields: &weatherFields)
            }
        } catch {
            // Handle Error
            weatherFields.currentTemp = "9999"
            weatherFields.latitude = error.localizedDescription
            ErrorLog("WeatherUnderground2 " + String(decoding: data!, as: UTF8.self))
        }
        if (weatherFields.currentTemp == "9999")
        {
            return
        }
        
        parseURL = ""
        parseURL.append(QUERY_PREFIX2)
        parseURL.append(weatherFields.latitude + "," + weatherFields.longitude)
        parseURL.append(QUERY_SUFFIX2a)
        parseURL.append(APIKey1)
        InfoLog(String(format:"URL for Weather Underground: %@\n", parseURL))
        
        url = URL(string: parseURL)
        data = nil
        if (url != nil)
        {
            do {
                // https://stackoverflow.com/questions/40812416/nsurl-url-and-nsdata-data?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
                data = try Data(contentsOf: url!) as NSData
            } catch {
                ErrorLog("WeatherUnderground \(error)")
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
                readJSONObjectF(object: dictionary, weatherFields: &weatherFields)
            }
        } catch {
            // Handle Error
            weatherFields.currentTemp = "9999"
            weatherFields.latitude = error.localizedDescription
            ErrorLog("WeatherUnderground3 " + String(decoding: data!, as: UTF8.self))
        }
                
        DebugLog(String(format:"leaving beginParsing: %@", inputCity))
        
        return
    } // beginParsing
    
    func convert_Inches_mbar(_ temp: String) -> String
    {
        // millibar value = kPa val ue x 33.8637526
        let answer = String(Int((temp as NSString).doubleValue * 33.8637526))
        
        return answer
    } // convert_Inches_mbar() -> String
    
    func setRadarWind(_ radarWindow1: RadarWindow) {
        radarWindow = radarWindow1
    } // setRadarWind
    
    func readJSONObjectE(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        /*
{"observations":[{"stationID":"KKYPROSP19","obsTimeUtc":"2019-06-08T03:33:00Z","obsTimeLocal":"2019-06-07 23:33:00","neighborhood":"Norton Commons","softwareType":"myAcuRite","country":"US","solarRadiation":null,"lon":-85.56961823,"realtimeFrequency":null,"epoch":1559964780,"lat":38.32564545,"uv":null,"winddir":23,"humidity":96,"qcStatus":1,"imperial":{"temp":68,"heatIndex":68,"dewpt":66,"windChill":68,"windSpeed":4,"windGust":6,"pressure":29.85,"precipRate":0.16,"precipTotal":0.60,"elev":472}}]}
         */
        guard
            let observations = object["observations"] as? [[String: AnyObject]]
            else
        {
            _ = "error"
            return
        }

        for o in observations {
                guard
                    //let neighborhood = o["neighborhood"] as? String,
                    let imperial = o["imperial"] as? [String: AnyObject],
                    //let uv = o["uv"] as? String, // <-- Has a value of null
                    let winddir = o["winddir"] as? Int,
                    let humidity = o["humidity"] as? Int,
                    let lat = o["lat"] as? Double,
                    let long = o["lon"] as? Double
            else {
                weatherFields.currentTemp = "9999"
                weatherFields.latitude = "Observations data missing"
                        return }
            //inputCity = neighborhood
            weatherFields.latitude = String(describing: lat)
            weatherFields.longitude = String(describing: long)
            weatherFields.windDirection = String(describing: winddir)
            weatherFields.humidity = String(describing: humidity)
            //weatherFields.UVIndex = uv
            
            for i in [imperial] {
                guard
                    let temp = i["temp"] as? Int,
                    let windSpeed = i["windSpeed"] as? Int,
                    let windGust = i["windGust"] as? Int,
                    let pressure = i["pressure"] as? Double
                    else {
                        weatherFields.currentTemp = "9999"
                        weatherFields.latitude = "Imperial data missing"
                        return }
            weatherFields.currentTemp = String(describing: temp)
            weatherFields.windSpeed = String(describing: windSpeed)
            weatherFields.windGust = String(describing: windGust)
            weatherFields.pressure = convert_Inches_mbar(String(describing: pressure))  // Convert Inches to millibars
            }
        }
    } // readJSONObjectE
    
    func readJSONObjectF(object: [String: AnyObject], weatherFields: inout WeatherFields) {
        /*
{"dayOfWeek":["Friday","Saturday","Sunday","Monday","Tuesday","Wednesday"],"expirationTimeUtc":[1559964363,1559964363,1559964363,1559964363,1559964363,1559964363],"moonPhase":["Waxing Crescent","Waxing Crescent","First Quarter","Waxing Gibbous","Waxing Gibbous","Waxing Gibbous"],"moonPhaseCode":["WXC","WXC","FQ","WXG","WXG","WXG"],"moonPhaseDay":[4,5,7,8,9,10],"moonriseTimeLocal":["2019-06-07T10:33:39-0400","2019-06-08T11:43:56-0400","2019-06-09T12:53:35-0400","2019-06-10T14:02:34-0400","2019-06-11T15:10:38-0400","2019-06-12T16:17:26-0400"],"moonriseTimeUtc":[1559918019,1560008636,1560099215,1560189754,1560280238,1560370646],"moonsetTimeLocal":["2019-06-07T00:21:36-0400","2019-06-08T01:07:52-0400","2019-06-09T01:47:59-0400","2019-06-10T02:23:09-0400","2019-06-11T02:56:08-0400","2019-06-12T03:27:58-0400"],"moonsetTimeUtc":[1559881296,1559970472,1560059279,1560147789,1560236168,1560324478],"narrative":["Cloudy with rain. Lows overnight in the upper 60s.","Thunderstorms. Highs in the upper 70s and lows in the upper 60s.","Thunderstorms. Highs in the low 80s and lows in the upper 60s.","Thunderstorms. Highs in the upper 70s and lows in the mid 50s.","Times of sun and clouds. Highs in the mid 70s and lows in the upper 50s.","Chance of afternoon showers. Highs in the mid 70s and lows in the upper 50s."],"qpf":[0.22,0.52,0.42,0.26,0.0,0.03],"qpfSnow":[0.0,0.0,0.0,0.0,0.0,0.0],"sunriseTimeLocal":["2019-06-07T06:18:25-0400","2019-06-08T06:18:13-0400","2019-06-09T06:18:04-0400","2019-06-10T06:17:56-0400","2019-06-11T06:17:51-0400","2019-06-12T06:17:47-0400"],"sunriseTimeUtc":[1559902705,1559989093,1560075484,1560161876,1560248271,1560334667],"sunsetTimeLocal":["2019-06-07T21:03:58-0400","2019-06-08T21:04:31-0400","2019-06-09T21:05:03-0400","2019-06-10T21:05:34-0400","2019-06-11T21:06:04-0400","2019-06-12T21:06:31-0400"],"sunsetTimeUtc":[1559955838,1560042271,1560128703,1560215134,1560301564,1560387991],"temperatureMax":[null,78,80,78,75,74],"temperatureMin":[67,67,68,55,57,59],"validTimeLocal":["2019-06-07T07:00:00-0400","2019-06-08T07:00:00-0400","2019-06-09T07:00:00-0400","2019-06-10T07:00:00-0400","2019-06-11T07:00:00-0400","2019-06-12T07:00:00-0400"],"validTimeUtc":[1559905200,1559991600,1560078000,1560164400,1560250800,1560337200],"daypart":[{"cloudCover":[null,98,97,97,91,95,93,27,52,53,62,48],"dayOrNight":[null,"N","D","N","D","N","D","N","D","N","D","N"],"daypartName":[null,"Tonight","Tomorrow","Tomorrow night","Sunday","Sunday night","Monday","Monday night","Tuesday","Tuesday night","Wednesday","Wednesday night"],"iconCode":[null,12,4,4,4,4,4,29,30,29,39,29],"iconCodeExtend":[null,1200,400,400,400,400,400,2900,3000,9000,7103,2900],"narrative":[null,"A steady rain this evening. Showers continuing overnight. Low 67F. Winds ENE at 10 to 15 mph. Chance of rain 90%. Rainfall around a quarter of an inch.","Scattered thunderstorms in the morning becoming more widespread in the afternoon. High 78F. Winds E at 10 to 15 mph. Chance of rain 80%.","Thunderstorms during the evening giving way to periods of light rain overnight. Low 67F. Winds E at 10 to 15 mph. Chance of rain 80%.","Scattered thunderstorms in the morning, then mainly cloudy during the afternoon with thunderstorms likely. High near 80F. Winds ESE at 5 to 10 mph. Chance of rain 80%.","Thunderstorms. Low 68F. Winds light and variable. Chance of rain 80%.","Thunderstorms likely. High 78F. Winds NW at 10 to 20 mph. Chance of rain 90%.","A few clouds. Low near 55F. Winds N at 10 to 20 mph.","Partly cloudy skies. High near 75F. Winds NE at 5 to 10 mph.","Cloudy early, becoming mostly clear after midnight. Low 57F. Winds ENE at 5 to 10 mph.","Partly cloudy skies early. A few showers developing later in the day. Thunder possible. High 74F. Winds E at 5 to 10 mph. Chance of rain 30%.","A few clouds from time to time. Low 59F. Winds light and variable."],"precipChance":[null,90,80,80,80,80,90,20,0,10,30,20],"precipType":[null,"rain","rain","rain","rain","rain","rain","rain","rain","rain","rain","rain"],"qpf":[null,0.22,0.25,0.26,0.21,0.21,0.26,0.0,0.0,0.0,0.02,0.0],"qpfSnow":[null,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],"qualifierCode":[null,null,null,null,null,null,null,null,null,null,"Q8003",null],"qualifierPhrase":[null,null,null,null,null,null,null,null,null,null,"Thunder possible.",null],"relativeHumidity":[null,88,83,88,81,91,83,72,53,65,63,77],"snowRange":[null,"","","","","","","","","","",""],"temperature":[null,67,78,67,80,68,78,55,75,57,74,59],"temperatureHeatIndex":[null,70,81,75,84,83,80,75,74,72,73,72],"temperatureWindChill":[null,68,69,69,68,69,70,55,55,57,57,60],"thunderCategory":[null,"No thunder","Thunder expected","Thunder expected","Thunder expected","Thunder expected","Thunder expected","No thunder","No thunder","No thunder","Thunder possible","No thunder"],"thunderIndex":[null,0,2,2,2,2,2,0,0,0,1,0],"uvDescription":[null,"Low","Moderate","Low","Moderate","Low","Moderate","Low","Very High","Low","Very High","Low"],"uvIndex":[null,0,4,0,5,0,5,0,9,0,8,0],"windDirection":[null,70,88,96,116,110,308,356,39,63,98,196],"windDirectionCardinal":[null,"ENE","E","E","ESE","ESE","NW","N","NE","ENE","E","SSW"],"windPhrase":[null,"Winds ENE at 10 to 15 mph.","Winds E at 10 to 15 mph.","Winds E at 10 to 15 mph.","Winds ESE at 5 to 10 mph.","Winds light and variable.","Winds NW at 10 to 20 mph.","Winds N at 10 to 20 mph.","Winds NE at 5 to 10 mph.","Winds ENE at 5 to 10 mph.","Winds E at 5 to 10 mph.","Winds light and variable."],"windSpeed":[null,11,11,11,8,5,13,13,8,7,7,5],"wxPhraseLong":[null,"Rain","Thunderstorms","Thunderstorms","Thunderstorms","Thunderstorms","Thunderstorms","Partly Cloudy","Partly Cloudy","Clouds Early/Clearing Late","PM Showers","Partly Cloudy"],"wxPhraseShort":[null,"Rain","T-Storms","T-Storms","T-Storms","T-Storms","T-Storms","P Cloudy","P Cloudy","Clear Late","PM Showers","P Cloudy"]}]}         */
        for o in object {
            var index = 0
            if (o.key == "sunriseTimeUtc") {
                let Array = o.value as? NSArray

                let sunrise = Array?[0] as! Int
                
                // Convert epoch to UTC
                let date = NSDate(timeIntervalSince1970: TimeInterval(sunrise))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                dateFormatter.timeZone = NSTimeZone.local
                
                weatherFields.sunrise = dateFormatter.string(from: date as Date)
            }
            if (o.key == "sunsetTimeUtc") {
                let Array = o.value as? NSArray
                let sunset = Array?[0] as! Int
                
                // Convert epoch to UTC
                let date = NSDate(timeIntervalSince1970: TimeInterval(sunset))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                dateFormatter.timeZone = NSTimeZone.local
                
                weatherFields.sunset = dateFormatter.string(from: date as Date)
            }
            if (o.key == "temperatureMin") {
                let Array = o.value as? NSArray
                while (index < Array!.count) {
                    if (String(describing: Array?[index] as? Int ?? -9999) == "-9999") {
                        weatherFields.forecastLow[index] = "-"
                    } else {
                        weatherFields.forecastLow[index] = String(describing: Array?[index] as? Int ?? 0)
                    }
                    index = index + 1
                }
            }
            if (o.key == "temperatureMax") {
                let Array = o.value as? NSArray
                while (index < Array!.count) {
                    if (String(describing: Array?[index] as? Int ?? -9999) == "-9999") {
                        weatherFields.forecastHigh[index] = "-"
                    } else {
                        weatherFields.forecastHigh[index] = String(describing: Array?[index] as? Int ?? 0)
                    }
                    index = index + 1
                }
            }
            if (index > weatherFields.forecastCounter) {
                weatherFields.forecastCounter = index
            }
            if (o.key == "dayOfWeek") {
                let Array = o.value as? NSArray
                while (index < Array!.count) {
                    let longDay = Array?[index] as! String
                    weatherFields.forecastDay[index] = longDay[0..<3]
                    index = index + 1
                }
            }
            if (o.key == "narrative") {
                let Array = o.value as? NSArray
                while (index < Array!.count) {
                    weatherFields.forecastConditions[index] = Array?[index] as! String
                    index = index + 1
                }
            }
            if (o.key == "daypart") {
                guard
                    let daypart = o.value as? NSArray
                    else {
                        _ = "error"
                        return
                }
                let daypartDataArray = daypart[0] as! [String: AnyObject]
                for da in daypartDataArray {
                    if (da.key == "iconCode") {
                        let Array = da.value as? NSArray
                        while (index < Array!.count) {
                            weatherFields.forecastCode[(index/2)] = String(describing: Array?[index] as? Int ?? 0)
                            if (index == 0) {
                                weatherFields.forecastCode[(index/2)] = String(describing: Array?[index+1] as? Int ?? 0)
                                weatherFields.currentCode = String(describing: Array?[index+1] as? Int ?? 0)
                            }
                            index = index + 2
                        }
                    }
                }
                
            }
            if (index > weatherFields.forecastCounter) {
                weatherFields.forecastCounter = index
            }
        }
    } // readJSONObjectF
    
    /* iconCode
     https://github.com/SmartThingsCommunity/SmartThingsPublic/blob/master/devicetypes/smartthings/smartweather-station-tile.src/smartweather-station-tile.groovy#L72
     https://smartthings-twc-icons.s3.amazonaws.com/xx.png
     00 = windy?
     01 = hurricane
     02 = hurricane
     03 = thunderstorm
     04 = thunderstorm
     05 = snow
     06 = sleet
     07 = snow
     08 = sleet
     09 = rain
     10 = sleet
     11 = rain
     12 = rain
     13 = snow
     14 = snow
     15 = blowing snow
     16 = snow
     17 = sleet
     18 = sleet
     19 = (wavy lines?)
     20 = (wavy lines?)
     21 = (wavy lines?)
     22 = (wavy lines?)
     23 = windy
     24 = windy
     25 = blowing snow
     26 = cloudy
     27 = partly cloudy
     28 = partly cloudy
     29 = partly cloudy
     30 = partly cloudy
     31 = moon (clear)
     32 = sunny (clear)
     33 = partly cloudy
     34 = partly cloudy
     35 = sleet
     36 = sunny
     37 = thunderstorm
     38 = thunderstorm
     39 = rain
     40 = rain
     41 = snow
     42 = snow
     43 = snow
     44 = ??
     45 = rain
     46 = snow
     47 = thunderstorm
     na = ??
     
     Alert
     Cloudy
     Flurries
     Hazy
     Hurricane
     Moon-Cloud
     Moon
     Rain
     Sleet
     Snow
     Sun-Cloud
     Sun
     Thunderstorm
     Tornado
     Unavailable
     Unknown
     Wind
     */

} // class WeatherUndergroundAPI
