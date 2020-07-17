//
//  WeatherDetailsController.swift
//  WeatherApp
//
//  Created by Sanket Ray on 7/17/20.
//  Copyright © 2020 Sanket Ray. All rights reserved.
//

import UIKit
import MapKit

struct WeatherData {
    let imageName: String
    let locationName: String
    let description: String
    let temperature: Double
}

class WeatherDetailsController: UIViewController {
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var dayTimeLabel: UILabel!
    @IBOutlet var conditionImageView: UIImageView!
    @IBOutlet var conditionLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var background: UIView!
    @IBOutlet var ai: UIActivityIndicatorView!
    
    let reachability = Reachability()!
    
    var coordinate: CLLocationCoordinate2D?
    let gradientLayer = CAGradientLayer()
    
    
    fileprivate func fetchOldData() {
        // no Internet --> display previous data
        if let weatherString = LocalDatabase.getWeatherString() {
            guard let data = weatherString.data(using: .utf8) else { return }
            guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:AnyObject] else { return }
            guard let weatherData = generateWeatherData(parsedResult: json) else { return }
            self.updateUI(details: weatherData)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if reachability.connection == .none {
            Alert.showBasic(title: nil, message: "Please check your internet connectivity. Displaying previously saved data.", vc: self, style: .actionSheet)
            fetchOldData()
        } else {
            ai.isHidden = false
            fetchNewData()
        }

    }
    
    fileprivate func fetchNewData() {
        guard let coordinate = coordinate else { return }
        
        getWeatherReport(coordinate: coordinate, completionForError: { (errorMessage) in
            DispatchQueue.main.async {
                self.ai.stopAnimating()
                Alert.showBasic(title: "Error", message: errorMessage, vc: self)
            }
        }) { (weatherData) in
            DispatchQueue.main.async {
                self.ai.stopAnimating()
                self.updateUI(details: weatherData)
            }
        }
    }
    
    @IBAction func popViewController(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func updateUI(details: WeatherData) {
        locationLabel.text = details.locationName
        conditionImageView.image = UIImage(named: details.imageName)
        conditionLabel.text = details.description
        temperatureLabel.text = "\(Int(round(details.temperature)))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, h:mm a"
        dayTimeLabel.text = dateFormatter.string(from: Date())
        
//        MARK: TODO
        let isDay = details.imageName.suffix(1) == "n"
        isDay ? (setBlueGradientBackground()) : (setGreyGradientBackground())
    }
    
    
    func setBlueGradientBackground() {
        let topColor = UIColor.rgb(95, 165, 0).cgColor
        let bottomColor = UIColor.rgb(72, 114, 184).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func setGreyGradientBackground() {
        let topColor = UIColor.rgb(150, 150, 150)
        let bottomColor = UIColor.rgb(72, 72, 72)
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
}
