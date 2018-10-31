//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Alex Leong on 10/18/18.

import UIKit

protocol changeCityDelegate {
    func userEnteredANewCityName (city: String)
}

class ChangeCityViewController: UIViewController {
    
    var delegate : changeCityDelegate?

    @IBOutlet weak var changeCityTextField: UITextField!
    
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        
        let cityName = changeCityTextField.text!
        delegate?.userEnteredANewCityName(city: cityName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
