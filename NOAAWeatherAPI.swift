//
//  NOAAWeatherAPI.swift
//  Meteorologist
//
//  Created by Sam Hathaway on 12/5/19.
//  Copyright © 2019 The Meteorologist Group, LLC. All rights reserved.
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
// https://www.weather.gov/
//
// BASE_URL = https://api.weather.gov/points/LATITUDE,LONGITUDE
//            https://api.weather.gov/points/37.8267,-122.423
//

import Cocoa
import Foundation

struct Observation: Decodable {
    let geometry: ObservationGeometry
    let properties: ObservationProperties
}

struct ObservationGeometry: Decodable {
    let coordinates: [Double]
}

struct ObservationProperties: Decodable {
    let timestamp: String

    let windSpeed: ObservationDoubleProperty
    let windGust: ObservationDoubleProperty
    let windDirection: ObservationDoubleProperty

    let elevation: ObservationIntProperty
    let relativeHumidity: ObservationDoubleProperty
    let barometricPressure: ObservationIntProperty
    let visibility: ObservationIntProperty

    let temperature: ObservationDoubleProperty
    let icon: URL
    let textDescription: String
}

struct ObservationIntProperty: Decodable {
    let value: Int?
    let unitCode: String
}

struct ObservationDoubleProperty: Decodable {
    let value: Double?
    let unitCode: String
}

struct Forecast: Decodable {
    let properties: ForecastProperties
}

struct ForecastProperties: Decodable {
    let periods: [ForecastPeriod]
}

struct ForecastPeriod: Decodable {
    let name: String
    let icon: URL
    let temperature: Int
    let shortForecast: String
    let isDaytime: Bool
    let startTime: String
}

class NOAAWeatherAPI
{
    let POINTS_URL = "https://api.weather.gov/points/"

    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String, weatherFields: inout WeatherFields)
    {
        DebugLog("NOAAWeatherAPI: beginParsing: entering " + inputCity)

        weatherFields.currentTemp = "9999"
        weatherFields.latitude = "not implemented"

        let (stationsUrl, forecastUrl) = getGridpointUrls(inputCity)

        if let stationsUrl = stationsUrl {
            //DebugLog("NOAAWeatherAPI: beginParsing: got stationsUrl: " + stationsUrl.absoluteString)
            if let currentConditionsUrl = getNearestStationCurrentConditionsUrl(stationsUrl) {
                //DebugLog("NOAAWeatherAPI: beginParsing: got currentConditionsUrl: " + currentConditionsUrl.absoluteString)
                if let currentConditionsJson = fetch(currentConditionsUrl) {
                    populateCurrentConditions(currentConditionsJson, weatherFields: &weatherFields)
                } else {
                    ErrorLog("NOAAWeatherAPI: getGridpointUrls: no currentConditionsData")
                }
            }
        }

        if let forecastUrl = forecastUrl {
            //DebugLog("NOAAWeatherAPI: beginParsing: got forecastUrl: " + forecastUrl.absoluteString)
            if let forecastJson = fetch(forecastUrl) {
                populateForecast(forecastJson, weatherFields: &weatherFields)
            } else {
                ErrorLog("NOAAWeatherAPI: getGridpointUrls: no forecastData")
            }
        }

        DebugLog("NOAAWeatherAPI: beginParsing: exiting " + inputCity)
    }

    func getGridpointUrls(_ latlng: String) -> (URL?, URL?)
    {
        var stationsUrl: URL?
        var forecastUrl: URL?

        var pointsUrl = URL(string: "https://api.weather.gov/points/")!
        let cleanLatLong = latlng.replacingOccurrences(of: ", ", with: ",")
        pointsUrl.appendPathComponent(cleanLatLong)
        InfoLog("NOAAWeatherAPI: getGridpointUrls: going to fetch " + pointsUrl.absoluteString)

        if let response = fetch(pointsUrl) {
            //DebugLog("NOAAWeatherAPI: getGridpointUrls: got response " + response)
            do {
                if let json = try JSONSerialization.jsonObject(with: Data(response.utf8), options: []) as? [String: Any] {
                    if let props = json["properties"] as? [String: Any] {
                        if let forecast = props["forecast"] as? String {
                            forecastUrl = URL(string: forecast)
                        } else {
                            ErrorLog("NOAAWeatherAPI: getGridpointUrls: no forecast")
                        }
                        if let observationStations = props["observationStations"] as? String {
                            stationsUrl = URL(string: observationStations)
                        } else {
                            ErrorLog("NOAAWeatherAPI: getGridpointUrls: no observationStations")
                        }
                    } else {
                        ErrorLog("NOAAWeatherAPI: getGridpointUrls: no props")
                    }
                } else {
                    ErrorLog("NOAAWeatherAPI: getGridpointUrls: no json")
                }
            } catch let error as NSError {
                ErrorLog("NOAAWeatherAPI: getGridpointUrls: json parsing error: \(error.localizedDescription)")
            }
        } else {
            ErrorLog("NOAAWeatherAPI: getGridpointUrls: got no response")

        }

        return (stationsUrl, forecastUrl)
    }

    func getNearestStationCurrentConditionsUrl(_ stationsUrl: URL) -> URL?
    {
        var currentConditionsUrl: URL?

        //DebugLog("NOAAWeatherAPI: getNearestStationCurrentConditionsUrl: going to fetch " + stationsUrl.absoluteString)

        if let response = fetch(stationsUrl) {
            //DebugLog("NOAAWeatherAPI: getNearestStationCurrentConditionsUrl: got response " + response)
            do {
                if let json = try JSONSerialization.jsonObject(with: Data(response.utf8), options: []) as? [String: Any] {
                    if let observationStations = json["observationStations"] as? [String] {
                        currentConditionsUrl = URL(string: observationStations[0] + "/observations/latest")
                    } else {
                        ErrorLog("NOAAWeatherAPI: getNearestStationCurrentConditionsUrl: no observationStations")
                    }
                } else {
                    ErrorLog("NOAAWeatherAPI: getNearestStationCurrentConditionsUrl: no json")
                }
            } catch let error as NSError {
                ErrorLog("NOAAWeatherAPI: getNearestStationCurrentConditionsUrl: json parsing error: \(error.localizedDescription)")
            }
        } else {
            ErrorLog("NOAAWeatherAPI: getNearestStationCurrentConditionsUrl: got no response")
        }

        return currentConditionsUrl
    }

    func populateCurrentConditions(_ json: String, weatherFields: inout WeatherFields)
    {
        //DebugLog("NOAAWeatherAPI: populateCurrentConditions: json = " + json)
        guard let observation = try? JSONDecoder().decode(Observation.self, from: Data(json.utf8)) else {
            ErrorLog("NOAAWeatherAPI: populateCurrentConditions: json parse error")
            return
        }
        //let observation = try! JSONDecoder().decode(Observation.self, from: Data(json.utf8))

        //weatherFields.title1 = "?title1?"
        weatherFields.date = convertTimestamp(observation.properties.timestamp)

        weatherFields.latitude = formatDouble(observation.geometry.coordinates[1])
        weatherFields.longitude = formatDouble(observation.geometry.coordinates[0])

        weatherFields.windSpeed = formatDouble(mps_to_mph(observation.properties.windSpeed.value ?? 0))
        if let windGust = observation.properties.windGust.value {
            weatherFields.windGust = formatDouble(mps_to_mph(windGust))
        }
        if let windDirection = observation.properties.windDirection.value {
            weatherFields.windDirection = formatDouble(windDirection)
        }

        if let elevation = observation.properties.elevation.value {
            weatherFields.altitude = formatInt(elevation)
        }
        if let humidity = observation.properties.relativeHumidity.value {
            weatherFields.humidity = String(format: "%.0f", humidity)
        }
        if let barometricPressure = observation.properties.barometricPressure.value {
            weatherFields.pressure = formatDouble(pa_to_mb(barometricPressure))
        }
        if let visibility = observation.properties.visibility.value {
            weatherFields.visibility = String(format: "%.1f", m_to_mi(visibility))
        }
        //weatherFields.UVIndex = "?UVIndex?"

        //weatherFields.sunrise = "?sunrise?"
        //weatherFields.sunset = "?sunset?"

        //weatherFields.currentLink = "?currentLink"
        if let temperature = observation.properties.temperature.value {
            weatherFields.currentTemp = formatDouble(c_to_f(temperature))
        }
        weatherFields.currentCode = convertIconUrl(observation.properties.icon);
        weatherFields.currentConditions = observation.properties.textDescription
    }

    func populateForecast(_ json: String, weatherFields: inout WeatherFields)
    {
        DebugLog("NOAAWeatherAPI: populateForecast: json = " + json)
        //let forecast = try! JSONDecoder().decode(Forecast.self, from: Data(json.utf8))
        guard let forecast = try? JSONDecoder().decode(Forecast.self, from: Data(json.utf8)) else {
            ErrorLog("NOAAWeatherAPI: populateForecast: json parse error")
            return
        }

        var firstPeriod = true;
        for period in forecast.properties.periods {
            DebugLog("NOAAWeatherAPI: populateForecast: got period with name " + period.name)
            if (period.isDaytime) {
                weatherFields.forecastDay[weatherFields.forecastCounter] = periodDay(period.startTime)
                weatherFields.forecastCode[weatherFields.forecastCounter] = convertIconUrl(period.icon)
                weatherFields.forecastHigh[weatherFields.forecastCounter] = formatInt(period.temperature)
                weatherFields.forecastConditions[weatherFields.forecastCounter] = "☀\u{fe0e} " + period.shortForecast
            } else {
                if (firstPeriod) {
                    weatherFields.forecastDay[weatherFields.forecastCounter] = periodDay(period.startTime)
                    weatherFields.forecastCode[weatherFields.forecastCounter] = convertIconUrl(period.icon)
                } else {
                    weatherFields.forecastConditions[weatherFields.forecastCounter] += "; ";
                }
                weatherFields.forecastLow[weatherFields.forecastCounter] = formatInt(period.temperature)
                weatherFields.forecastConditions[weatherFields.forecastCounter] += "☾\u{fe0e} " + period.shortForecast
                weatherFields.forecastCounter += 1
            }
            firstPeriod = false
        }
    }

    func convertTimestamp(_ dateString: String) -> String
    {
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        inFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        inFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        inFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let date = inFormatter.date(from: dateString) {
            return outFormatter.string(from: date)
        } else {
            return ""
        }
    }

    func formatInt(_ value: Int) -> String
    {
        return String(format: "%d", value);
    }

    func formatDouble(_ value: Double) -> String
    {
        return String(format: "%.2f", value)
    }

    func mps_to_mph(_ mps: Double) -> Double
    {
        return mps * 2.236936
    }

    func c_to_f(_ c: Double) -> Double
    {
        return c * 1.8 + 32
    }

    func pa_to_mb(_ pa: Int) -> Double
    {
        return Double(pa) / 100.00
    }

    func m_to_mi(_ m: Int) -> Double
    {
        return Double(m) * 0.00062137
    }

    func convertIconUrl(_ iconUrl: URL) -> String
    {
        let tod = iconUrl.pathComponents[3];
        let con = iconUrl.pathComponents[4].split(separator: ",")[0];

        //DebugLog("NOAAWeatherAPI: convertIconUrl: iconUrl = \(iconUrl) tod = \(tod) con = \(con)")

        switch (tod, con) {
            case ("day",   "skc"):       return "Sun"; /* Fair/clear */
            case ("night", "skc"):       return "Moon"; /* Fair/clear */
            case ("day",   "few"):       return "Sun-Cloud"; /* A few clouds */
            case ("day",   "sct"):       return "Sun-Cloud"; /* Partly cloudy */
            case ("day",   "bkn"):       return "Sun-Cloud"; /* Mostly cloudy */
            case ("night", "few"):       return "Moon-Cloud"; /* A few clouds */
            case ("night", "sct"):       return "Moon-Cloud"; /* Partly cloudy */
            case ("night", "bkn"):       return "Moon-Cloud"; /* Mostly cloudy */
            case (_, "ovc"):             return "Cloudy"; /* Overcast */
            case (_, "wind_skc"):        return "Wind"; /* Fair/clear and windy */
            case (_, "wind_few"):        return "Wind"; /* A few clouds and windy */
            case (_, "wind_sct"):        return "Wind"; /* Partly cloudy and windy */
            case (_, "wind_bkn"):        return "Wind"; /* Mostly cloudy and windy */
            case (_, "wind_ovc"):        return "Wind"; /* Overcast and windy */
            case (_, "snow"):            return "Snow"; /* Snow */
            case (_, "rain_snow"):       return "Sleet"; /* Rain/snow */
            case (_, "rain_sleet"):      return "Sleet"; /* Rain/sleet */
            case (_, "snow_sleet"):      return "Sleet"; /* Rain/sleet */
            case (_, "fzra"):            return "Sleet"; /* Freezing rain */
            case (_, "rain_fzra"):       return "Sleet"; /* Rain/freezing rain */
            case (_, "snow_fzra"):       return "Sleet"; /* Freezing rain/snow */
            case (_, "sleet"):           return "Sleet"; /* Sleet */
            case (_, "rain"):            return "Rain"; /* Rain */
            case (_, "rain_showers"):    return "Rain"; /* Rain showers (high cloud cover) */
            case (_, "rain_showers_hi"): return "Rain"; /* Rain showers (low cloud cover) */
            case (_, "tsra"):            return "Thunderstorm"; /* Thunderstorm (high cloud cover) */
            case (_, "tsra_sct"):        return "Thunderstorm"; /* Thunderstorm (medium cloud cover) */
            case (_, "tsra_hi"):         return "Thunderstorm"; /* Thunderstorm (low cloud cover) */
            case (_, "tornado"):         return "Tornado"; /* Tornado */
            case (_, "hurricane"):       return "Hurricane"; /* Hurricane conditions */
            case (_, "tropical_storm"):  return "Hurricane"; /* Tropical storm conditions */
            case (_, "dust"):            return "Hazy"; /* Dust */
            case (_, "smoke"):           return "Hazy"; /* Smoke */
            case (_, "haze"):            return "Hazy"; /* Haze */
            case (_, "hot"):             return "Unavailable"; /* Hot */
            case (_, "cold"):            return "Unavailable"; /* Cold */
            case (_, "blizzard"):        return "Snow"; /* Blizzard */
            case (_, "fog"):             return "Hazy"; /* Fog/mist */
            default:                     return "Unknown";
        }
    }

    func periodDay(_ dateString: String) -> String
    {
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        // Per https://developer.apple.com/documentation/foundation/dateformatter#2528261
        inFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        inFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "EEE"

        if let date = inFormatter.date(from: dateString) {
            return outFormatter.string(from: date)
        } else {
            return "???"
        }
    }

    func fetch(_ url: URL) -> String?
    {
        let semaphore = DispatchSemaphore(value: 0)

        var result: String?

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            result = String(data: data!, encoding: String.Encoding.utf8)!
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()
        return result
    }
}
