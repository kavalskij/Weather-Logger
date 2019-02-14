//
//  ChangeCityViewController.swift
//  Weather Logger
//
//  Created by Aleksandrs Muravjovs on 12/02/2019.
//  Copyright © 2019 Aleksandrs Muravjovs. All rights reserved.
//

import UIKit

protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}

class ChangeCityViewController: UIViewController {
    
    var delegate: ChangeCityDelegate?
    
    @IBOutlet weak var changeCityTextField: UISearchBar!
    @IBOutlet weak var getWeatherPressed: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func getWeatherPressed(_ sender: UIButton) {
        
        let cityName = changeCityTextField.text!
        
        delegate?.userEnteredANewCityName(city: cityName)
        
        navigationController?.popViewController(animated: true)
    }
}
