//
//  ViewController.swift
//  WeatherApp
//
//  Created by Sanket Ray on 7/17/20.
//  Copyright © 2020 Sanket Ray. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var bottomContainer: UIView!
    @IBOutlet var map: MKMapView!
    
    let geoCoder = CLGeocoder()
    var currentCoordiante : CLLocationCoordinate2D?
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        setUpMapView()
        setupShadow()
    }
    
    @IBAction func displayWeatherDetails(_ sender: Any) {
        
        let weatherDetailsController = WeatherDetailsController()
        weatherDetailsController.coordinate = currentCoordiante
        self.navigationController?.pushViewController(weatherDetailsController, animated: true)
    }
    
    fileprivate func setupShadow() {
        bottomContainer.layer.cornerRadius = 8
        bottomContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomContainer.layer.shadowColor = UIColor.rgb(180,180,180).cgColor
        bottomContainer.layer.shadowOpacity = 8
        bottomContainer.layer.shadowRadius = 6
        bottomContainer.layer.shadowOffset = .zero

    }
    
    fileprivate func setupGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.delegate = self
        map.addGestureRecognizer(gestureRecognizer)
    }
    
    func setUpMapView() {
        map.showsUserLocation = true
        map.showsCompass = true
        map.showsScale = true
        setupGestureRecognizer()
        getCurrentLocation()
    }
    
    func getCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.startUpdatingLocation()
    }
    
    fileprivate func removePreviousMapAnnotations() {
        let allAnnotations = map.annotations
        map.removeAnnotations(allAnnotations)
    }
    
    fileprivate func addNewAnnotation(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: map)
        let coordinate = map.convert(location, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Current Location"
        currentCoordiante = coordinate
        map.addAnnotation(annotation)
        
        displayWeatherDetails(self)
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        
        removePreviousMapAnnotations()
        addNewAnnotation(gestureRecognizer)

    }
    
    
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        let coordinate = location.coordinate
        currentCoordiante = coordinate
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        map.showsUserLocation = false
        map.setRegion(coordinateRegion, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Current Location"
        map.addAnnotation(annotation)
        locationManager.stopUpdatingLocation()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

