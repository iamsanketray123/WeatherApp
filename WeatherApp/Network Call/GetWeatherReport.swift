//
//  GetWeatherReport.swift
//  WeatherApp
//
//  Created by Sanket Ray on 7/17/20.
//  Copyright © 2020 Sanket Ray. All rights reserved.
//

import Foundation
import MapKit



func getWeatherReport(coordinate: CLLocationCoordinate2D, completionForError: @escaping (_ errorMessage: String)-> Void, completionForWeatherData: @escaping(_ data: WeatherData)-> Void) {
    
    let apiKey = "8c1e240150949fb7bfe0bf0503c8a20e"
    
    guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)&units=metric") else {             completionForError(errorMessage)
        return
    }
    
    var request = URLRequest(url: url, timeoutInterval: Double.infinity)
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        
        guard error == nil else{
            print("error while requesting data", error?.localizedDescription as Any)
            completionForError(errorMessage)
            return
        }
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            print("status code was other than 2xx", (response as! HTTPURLResponse).statusCode,"🍅")
            completionForError(errorMessage)
            return
        }
        guard let data = data else {
            print("request for data failed")
            completionForError(errorMessage)
            return
        }
        
        let parsedResult : [String: AnyObject]!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
        } catch {
            print("error parsing data", error.localizedDescription)
            completionForError(errorMessage)
            return
        }
        
        
        let jsonString = stringify(json: parsedResult as Any)
        LocalDatabase.saveWeatherString(weatherString: jsonString)
        
        let weatherData =  generateWeatherData(parsedResult: parsedResult)
        
        if weatherData == nil {
            completionForError(errorMessage)
            return
        } else {
            completionForWeatherData(weatherData!)
        }
        
        
    }
    
    task.resume()
}


func generateWeatherData(parsedResult: [String: AnyObject]) -> WeatherData? {
    
    guard let weather = parsedResult["weather"] as? [[String: AnyObject]], let imageName = weather.first?["icon"] as? String, let description = weather.first?["description"] as? String, let main = parsedResult["main"] as? [String: AnyObject], let temperature = main["temp"] as? Double, let locationName = parsedResult["name"] as? String else { return nil }
    let weatherData =  WeatherData.init(imageName: imageName, locationName: locationName, description: description, temperature: temperature)
    
    return weatherData
}


class LocalDatabase : NSObject { // User Defaults
    
    static let defaults = UserDefaults.standard
    
    static func saveWeatherString(weatherString: String) {
        defaults.set(weatherString, forKey: "weatherString")
    }
    
    static func getWeatherString()-> String? {
        return defaults.string(forKey: "weatherString")
    }
    
}
