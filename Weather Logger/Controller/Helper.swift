//
//  Helper.swift
//  Weather Logger
//
//  Created by Aleksandrs Muravjovs on 12/02/2019.
//  Copyright © 2019 Aleksandrs Muravjovs. All rights reserved.
//

import Foundation

class Helper {
    
    func formatDate(fromDate date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let formattedDate = formatter.string(from: date)
        
        return formattedDate
    }
    
}
