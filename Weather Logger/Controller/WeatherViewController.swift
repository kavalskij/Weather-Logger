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
    @IBOutlet weak var weatherBackgroundImage: UIImageView!
    @IBOutlet weak var savedWeatherSearchBar: UISearchBar!
    
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
        
        loadSavedWeather()
    }
    
    
    //MARK: - Networking
    
    func getWeatherData(url: String, parameters: [String:String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
               
                guard let data = response.data else {return}
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
            temperatureLabel.text = "\(String(weatherDataClass.temperature))°"
            weatherIcon.image = UIImage(named: weatherDataClass.weatherIconName)
            weatherBackgroundImage.image = UIImage(named: updateWeatherBackground(condition: weatherData.weather[0].id))
            
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
        cityLabel.text = "Make sure you allow Weather Logger to use your gps position"
        temperatureLabel.text = "Location Unavailable"
    }
    
    
    //MARK: - Saving/Loading Weather using CoreData
    
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
    
    func loadSavedWeather(with request: NSFetchRequest<SavedWeathedData> = SavedWeathedData.fetchRequest()) {
        
        do {
            weatherArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    
    //MARK: - Segue to ChangeCityViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
}


    //MARK: - Table View Data source and Delegate

extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return weatherArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
        
        cell.cityNameLabel?.text = weatherArray[indexPath.row].city
        cell.temperatureLabel?.text = String(weatherArray[indexPath.row].temperature)
        cell.dateAndTimeLabel?.text = Helper().formatDate(fromDate: weatherArray[indexPath.row].dateAndTime!)
        cell.weatherIconImage?.image = UIImage(named: weatherArray[indexPath.row].weatherIconName!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        context.delete(weatherArray[indexPath.row])
        weatherArray.remove(at: indexPath.row)
        
        saveWeatherDetails()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90
    }

}


    //MARK: - SearchBar delegate

extension WeatherViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<SavedWeathedData> = SavedWeathedData.fetchRequest()
        
        request.predicate = NSPredicate(format: "city CONTAINS[cd] %@", searchBar.text!)
    
        request.sortDescriptors = [NSSortDescriptor(key: "dateAndTime", ascending: true)]
        
        loadSavedWeather(with: request)
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
            loadSavedWeather()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


    //MARK: - ChangeCityDelegate methods

extension WeatherViewController: ChangeCityDelegate {
    
    func userEnteredANewCityName(city: String) {
        
        let params: [String: String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
}

