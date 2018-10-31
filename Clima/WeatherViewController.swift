//
//  ViewController.swift
//  WeatherApp
//
//  Created by Alex Leong on 10/16/18 

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, changeCityDelegate {
    
    enum tempFormat {
        case celsius
        case fahrenheit
    }
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "3f00f465d78adf08f140824a3300485d"
    let weatherDataModel = WeatherDataModel()
    var tempFormat : tempFormat?
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var tempFormatButton: UIButton!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.tempFormat = .fahrenheit
    }
    
    @IBAction func changeTempFormat(_ sender: Any) {
        if self.tempFormat == .celsius {
            tempFormatButton.setTitle("F", for: .normal)
            self.tempFormat = .fahrenheit
            updateUIWithWeatherData()
        } else if self.tempFormat == .fahrenheit {
            tempFormatButton.setTitle("C", for: .normal)
            self.tempFormat = .celsius
            updateUIWithWeatherData()
        }
    }
    
    
    //MARK: - Networking
    /***************************************************************/

    func getWeatherData(url: String, parameters: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Data gather successful")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                if let responseError = response.result.error {
                    print("Error: \(responseError)")
                }
                self.cityLabel.text = "No Connection"
            }
        }
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    func updateWeatherData(json: JSON) {
        
        if let currentTemp = json["main"]["temp"].double {
            weatherDataModel.celsius = Int(currentTemp - 273.15)
            weatherDataModel.fahrenheit = Int(((currentTemp - 273.15) * 2.2) + 32)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
            
        } else {
            cityLabel.text = "Weather Unavailable"
            weatherIcon.image = UIImage(named: "dunno")
            temperatureLabel.text = ""
        }
    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        if self.tempFormat == .celsius {
            temperatureLabel.text = "\(weatherDataModel.celsius)°"
        } else {
            temperatureLabel.text = "\(weatherDataModel.fahrenheit)°"
        }
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            let params : [String : String] = ["lat" : lat, "lon" : lon, "appid" : APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
}
