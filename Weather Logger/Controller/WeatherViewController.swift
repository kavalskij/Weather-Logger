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
import CoreData

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var weatherArray = [SavedWeathedData]()
    
    
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
                
                self.updateWeatherData(using: data)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    
    
    //MARK: - JSON Parsing
    
    func updateWeatherData(using data: Data) {

        do {
            let weatherData = try JSONDecoder().decode(WeatherDataModel.self, from: data)
            
            weatherDataClass.cityName = weatherData.name
            weatherDataClass.dateAndTimeSaved = Date()
            weatherDataClass.temperature = Int((weatherData.main.temp) - 273.15)
            weatherDataClass.weatherIconName = updateWeatherIcon(condition: weatherData.weather[0].id)
            
            
            cityLabel.text = weatherDataClass.cityName
            temperatureLabel.text = String(weatherDataClass.temperature)
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
    
    //MARK: - Saving Weather in Core Data
    
    @IBAction func saveWeatherData(_ sender: UIBarButtonItem) {
        
        let newWeatherData = SavedWeathedData(context: self.context)
        
        newWeatherData.city = weatherDataClass.cityName
        newWeatherData.dateAndTime = weatherDataClass.dateAndTimeSaved
        newWeatherData.temperature = Double(weatherDataClass.temperature)
        newWeatherData.weatherIconName = weatherDataClass.weatherIconName
        
        weatherArray.append(newWeatherData)
        
        self.saveWeatherDetails()


        self.tableView.reloadData()
    }
    
    func saveWeatherDetails() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }

    
}

extension WeatherViewController: UITableViewDataSource {
    
    //MARK: - Table View Data source and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return weatherArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedDataCell", for: indexPath)
        
        cell.textLabel?.text = String(weatherArray[indexPath.row].temperature)
        cell.detailTextLabel?.text = Helper().formatDate(fromDate: weatherArray[indexPath.row].dateAndTime!)
            
        print(weatherArray[indexPath.row])
        
        return cell
    }
    
    
}

