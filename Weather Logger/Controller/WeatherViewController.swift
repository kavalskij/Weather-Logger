//
//  ViewController.swift
//  Weather Logger
//
//  Created by Aleksandrs Muravjovs on 08/02/2019.
//  Copyright © 2019 Aleksandrs Muravjovs. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e093d3753e16fc1049bc73e08ff837f4"
    
    let locationManager = CLLocationManager()
    let weatherDataClass = WeatherDataClass()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        temperatureLabel.adjustsFontSizeToFitWidth = true
        cityLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    
    //MARK: - Networking
    
    func getWeatherData(url: String, parameters: [String:String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Got the weather data")
               
                guard let data = response.data else {return}
                //print(String(data: data, encoding: .utf8)!)
                
                self.updateWeatherData(data: data)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    
    
    //MARK: - JSON Parsing
    
    func updateWeatherData(data: Data) {

        do {
            var weatherData = try JSONDecoder().decode(WeatherDataModel.self, from: data)
            
            cityLabel.text = weatherData.name
            temperatureLabel.text = String(Int((weatherData.main.temp) - 273.15))
            weatherDataClass.weatherIconName = updateWeatherIcon(condition: weatherData.weather[0].id)
            weatherIcon.image = UIImage(named: weatherDataClass.weatherIconName)
            
        } catch {
            print(error)
            self.temperatureLabel.text = "Weather Unavailable"
            self.cityLabel.text = "Check your internet connection"
        }
    }

    
    //MARK: - Location Manager Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
}

