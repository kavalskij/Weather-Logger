//
//  WeatherDataModel.swift
//  Weather Logger
//
//  Created by Aleksandrs Muravjovs on 08/02/2019.
//  Copyright © 2019 Aleksandrs Muravjovs. All rights reserved.
//

import Foundation

struct WeatherDataModel: Decodable {
    
    var temmperature: Int
    var conditions: Int
    var city: String
    var weatherIconName: String
    var dateAndTimeSaved: Date
}
