import Cocoa
import Foundation
import XMLCoder

class NOAAWeatherAPI
{
    let POINTS_URL = "https://api.weather.gov/points/"
    let CURR_OBS_XML_URL = "https://w1.weather.gov/xml/current_obs/"
    
    struct Point: Decodable {
        let properties: PointProperties
    }
    
    struct PointProperties: Decodable {
        let forecast: URL
        let observationStations: URL
    }
    
    struct Stations: Decodable {
        let features: [StationFeature]
        let observationStations: [URL]
    }
    
    struct StationFeature: Decodable {
        let properties: StationFeatureProperties
    }
    
    struct StationFeatureProperties: Decodable {
        let stationIdentifier: String
    }
    
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
    
    struct XMLCurrentObservations: Decodable {
        let observation_time_rfc822: String
        let latitude: String
        let longitude: String
        let wind_mph: String
        let wind_degrees: String
        let relative_humidity: String
        let pressure_mb: String
        let visibility_mi: String
        let temp_f: String
        let icon_url_name: String
        let weather: String
    }
    
    func beginParsing(_ inputCity: String, APIKey1: String, APIKey2: String, weatherFields: inout WeatherFields)
    {
        DebugLog("NOAAWeatherAPI: beginParsing: entering " + inputCity)
        
        let (stationsUrl, forecastUrl) = getGridpointUrls(inputCity)
        
        if let stationsUrl = stationsUrl {
            DebugLog("NOAAWeatherAPI: beginParsing: got stationsUrl: " + stationsUrl.absoluteString)
            /*if let currentConditionsUrl = getNearestStationCurrentConditionsUrl(stationsUrl) {
                DebugLog("NOAAWeatherAPI: beginParsing: got currentConditionsUrl: " + currentConditionsUrl.absoluteString)
                if let currentConditionsJson = fetch(currentConditionsUrl) {
                    populateCurrentConditions(currentConditionsJson, weatherFields: &weatherFields)
                } else {
                    ErrorLog("NOAAWeatherAPI: getGridpointUrls: no currentConditionsData")
                }
            }*/
            if let stationID = getNearestStationID(stationsUrl) {
                DebugLog("NOAAWeatherAPI: beginParsing: got stationID: " + stationID)
                let currentConditionsXMLUrl = URL(string: CURR_OBS_XML_URL)!.appendingPathComponent(stationID + ".xml")
                DebugLog("NOAAWeatherAPI: beginParsing: got currentConditionsXMLUrl: " + currentConditionsXMLUrl.absoluteString)
                if let currentConditionsXML = fetch(currentConditionsXMLUrl) {
                    populateCurrentConditionsXML(currentConditionsXML, weatherFields: &weatherFields)
                } else {
                    ErrorLog("NOAAWeatherAPI: getGridpointUrls: no currentConditionsXML")
                }
            }
        }
        
        if let forecastUrl = forecastUrl {
            DebugLog("NOAAWeatherAPI: beginParsing: got forecastUrl: " + forecastUrl.absoluteString)
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
        var pointsUrl = URL(string: POINTS_URL)!
        pointsUrl.appendPathComponent(latlng)
        
        DebugLog("NOAAWeatherAPI: getGridpointUrls: going to fetch " + pointsUrl.absoluteString)
        guard let json = fetch(pointsUrl) else {
            ErrorLog("NOAAWeatherAPI: getGridpointUrls: got no response")
            return (nil, nil)
        }
        
        guard let point = try? JSONDecoder().decode(Point.self, from: Data(json.utf8)) else {
            ErrorLog("NOAAWeatherAPI: getGridpointUrls: json parse error")
            return (nil, nil)
        }
        
        return (point.properties.observationStations, point.properties.forecast)
    }
    
    func getNearestStationCurrentConditionsUrl(_ stationsUrl: URL) -> URL?
    {
        return getGridpointStations(stationsUrl)?.observationStations[0].appendingPathComponent("observations/latest")
    }
    
    func getNearestStationID(_ stationsUrl: URL) -> String?
    {
        return getGridpointStations(stationsUrl)?.features[0].properties.stationIdentifier
    }
    
    func getGridpointStations(_ stationsUrl: URL) -> Stations?
    {
        guard let json = fetch(stationsUrl) else {
            ErrorLog("NOAAWeatherAPI: getNearestStationCurrentConditionsUrl: got no response")
            return nil
        }
        
        guard let stations = try? JSONDecoder().decode(Stations.self, from: Data(json.utf8)) else {
            ErrorLog("NOAAWeatherAPI: getNearestStationCurrentConditionsUrl: json parse error")
            return nil
        }
        
        return stations
    }
    
    func populateCurrentConditions(_ json: String, weatherFields: inout WeatherFields)
    {
        guard let observation = try? JSONDecoder().decode(Observation.self, from: Data(json.utf8)) else {
            ErrorLog("NOAAWeatherAPI: populateCurrentConditions: json parse error")
            return
        }
        
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
        //weatherFields.UVIndex
        //weatherFields.sunrise
        //weatherFields.sunset
        //weatherFields.currentLink
        if let temperature = observation.properties.temperature.value {
            weatherFields.currentTemp = formatDouble(c_to_f(temperature))
        }
        weatherFields.currentCode = convertIconUrl(observation.properties.icon);
        weatherFields.currentConditions = observation.properties.textDescription
    }
    
    func populateCurrentConditionsXML(_ xml: String, weatherFields: inout WeatherFields)
    {
        guard let observation = try? XMLDecoder().decode(XMLCurrentObservations.self, from: Data(xml.utf8)) else {
            ErrorLog("NOAAWeatherAPI: populateCurrentConditionsXML: xml parse error")
            return
        }
        
        weatherFields.date = convertRfc822Date(observation.observation_time_rfc822)
        weatherFields.latitude = observation.latitude
        weatherFields.longitude = observation.longitude
        weatherFields.windSpeed = observation.wind_mph
        //weatherFields.windGust
        weatherFields.windDirection = observation.wind_degrees
        //weatherFields.altitude
        weatherFields.humidity = observation.relative_humidity
        weatherFields.pressure = observation.pressure_mb
        weatherFields.visibility = observation.visibility_mi
        //weatherFields.UVIndex
        //weatherFields.sunrise
        //weatherFields.sunset
        //weatherFields.currentLink
        weatherFields.currentTemp = observation.temp_f
        weatherFields.currentCode = convertXmlIconUrlName(observation.icon_url_name);
        weatherFields.currentConditions = observation.weather
    }
    
    func populateForecast(_ json: String, weatherFields: inout WeatherFields)
    {
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
                    DebugLog("NOAAWeatherAPI: populateForecast: first period is nighttime")
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
        let con = String(iconUrl.pathComponents[4].split(separator: ",")[0])
        
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
            default:
                DebugLog("NOAAWeatherAPI: convertIconUrl: unrecognized icon URL: " + iconUrl.absoluteString)
                return "Unknown";
        }
    }
    
    func convertXmlIconUrlName(_ iconUrlName: String) -> String
    {
        let name = String(iconUrlName.split(separator: ".")[0])
        
        switch (name) {
            case "bkn":       return "Sun-Cloud";
            case "nbkn":      return "Moon-Cloud";
            case "skc":       return "Sun";
            case "nskc":      return "Moon";
            case "few":       return "Sun-Cloud";
            case "nfew":      return "Moon-Cloud";
            case "sct":       return "Sun-Cloud";
            case "nsct":      return "Moon-Cloud";
            case "ovc":       return "Cloudy";
            case "novc":      return "Cloudy";
            case "fg":        return "Hazy";
            case "nfg":       return "Hazy";
            case "smoke":     return "Hazy";
            case "fzra":      return "Sleet";
            case "ip":        return "Snow";
            case "mix":       return "Sleet";
            case "nmix":      return "Sleet";
            case "raip":      return "Sleet";
            case "rasn":      return "Sleet";
            case "nrasn":     return "Sleet";
            case "shra":      return "Rain";
            case "tsra":      return "Thunderstorm";
            case "ntsra":     return "Thunderstorm";
            case "sn":        return "Snow";
            case "nsn":       return "Snow";
            case "wind":      return "Wind";
            case "nwind":     return "Wind";
            case "hi_shwrs":  return "Rain";
            case "hi_nshwrs": return "Rain";
            case "fzrara":    return "Sleet";
            case "hi_tsra":   return "Thunderstorm";
            case "hi_ntsra":  return "Thunderstorm";
            case "ra":        return "Rain";
            case "ra1":       return "Rain";
            case "nra":       return "Rain";
            case "nsvrtsra":  return "Tornado";
            case "dust":      return "Hazy";
            case "mist":      return "Hazy";
            default:
            DebugLog("NOAAWeatherAPI: convertXmlIconUrlName: unrecognized icon URL name: " + iconUrlName)
            return "Unknown";
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
    
    func convertRfc822Date(_ dateString: String) -> String
    {
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        
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
