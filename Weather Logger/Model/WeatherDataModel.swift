//
//  WeatherDataModel.swift
//  Weather Logger
//
//  Created by Aleksandrs Muravjovs on 08/02/2019.
//  Copyright © 2019 Aleksandrs Muravjovs. All rights reserved.
//

import Foundation

class WeatherDataClass {
    
    var weatherIconName: String = ""
    var weatherIconId: Int = 0
    var dateAndTimeSaved: Date = Date()
    var temperature: Int = 0
    var weatherId: Int = 0
    var cityName: String = ""
}

class WeatherDataModel: Decodable {
    
    var main: Main
    var weather: [Weather]
    var name: String
}

class Main: Decodable {
    
    var temp: Double
}

class Weather: Decodable {
    
    var id: Int
}


func updateWeatherIcon(condition: Int) -> String {
    
    switch (condition) {
        
    case 0...300 :
        return "tstorm1"
        
    case 301...500 :
        return "light_rain"
        
    case 501...600 :
        return "shower3"
        
    case 601...700 :
        return "snow4"
        
    case 701...771 :
        return "fog"
        
    case 772...799 :
        return "tstorm3"
        
    case 800 :
        return "sunny"
        
    case 801...804 :
        return "cloudy2"
        
    case 900...903, 905...1000  :
        return "tstorm3"
        
    case 903 :
        return "snow5"
        
    case 904 :
        return "sunny"
        
    default :
        return "dunno"
    }
}

func updateWeatherBackground(condition: Int) -> String {
    
    switch (condition) {
        
    case 0...300 :
        return "stormSky"
        
    case 301...500 :
        return "rainSky"
        
    case 501...600 :
        return "rainSky"
        
    case 601...700 :
        return "snowySky"
        
    case 701...771 :
        return "fogySky"
        
    case 772...799 :
        return "stormSky"
        
    case 800 :
        return "blueSky"
        
    case 801...804 :
        return "cloudySky"
        
    case 900...903, 905...1000  :
        return "stormSky"
        
    case 903 :
        return "snowySky"
        
    case 904 :
        return "blueSky"
        
    default :
        return "blueSky"
    }
}
