import UIKit
import CoreLocation

/**
 * UITextFieldDelegate is A set of optional methods that you use
   to manage the editing and validation of text in a text field
 */
class WeatherViewController: UIViewController {

    // MARK: - Variables -
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()

    // MARK: - IBOutlets -

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!

    // MARK: - IBActions -

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        // tells the search field that we done with editing and you can dismiss the keyboard now
        searchTextField.endEditing(true)
    }

    @IBAction func locationButtonPressed(_ sender: UIButton) {
        /**
         * this method calls the didUpdateLocations() to get the location
           then send it to the api then the api send us data we use to fill the ui with
         */
        locationManager.requestLocation()
    }
    
    // MARK: - LifeCycle -

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        // requests a permission to use the device's location while the app is in use
        locationManager.requestWhenInUseAuthorization()
        /**
         * requests the one-time delivery of the device’s current location
         * once this method gets hold of the location it'll trigger the didUpdateLocations() method
         */
        locationManager.requestLocation()

        weatherManager.delegate = self
        searchTextField.delegate = self
    }
}

// MARK: - UITextFieldDelegate -

extension WeatherViewController: UITextFieldDelegate {
    // this is called whenever the user pressed the return button of the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // tells the search field that we done with editing and you can dismiss the keyboard now
        searchTextField.endEditing(true)
        return true
    }

    // this is called when the user stop typing in the text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        // call the api function here to get the weather data
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        // reset the search field to nothing
        searchTextField.text = ""
    }

    // this is called when i wanna force the user to stop editing if the validation is wrong
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // if the user typed in the text field
        if textField.text != "" {
            return true
        } else {
            // if the text field is empty
            textField.placeholder = "Type something"
            return false
        }
    }
}

// MARK: - WeatherManagerDelegate -

extension WeatherViewController: WeatherManagerDelegate {
    // the protocol's function that gets the weather data from the weather manager
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        /**
         * this function is getting called from within a completion handler
           which means we're trying to update the UI from a completion handler
           (background thread) so that should happen only in the main thread
         */
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            // systemName allow the image to change dynamically based on the name we give to the image
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            // cityName is the name property we get from the api response when we send the coordinates to the api
            self.cityLabel.text = weather.cityName
        }
    }

    // the protocol's function that gets any error happens inside the weather manager
    func didFailWithError(_ error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - CLLocationManagerDelegate -

extension WeatherViewController: CLLocationManagerDelegate {
    // tells the delegate that the new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // the last location is the most accurate one so that's what we want
        if let location = locations.last {
            /**
             * 1- when the app starts it requests the device location, call didUpdateLocations()
               then send the location to the api then the api send data we use to fill the ui
               but this function stop getting locations after we send the one we got to the api
             * 2- when we search by the city name, send it to the api and get data to fill the ui with again
             * 3- when we press on the location button it ask for the device location and same as step 1
             */
            locationManager.stopUpdatingLocation()
            // get the long and lat of that location
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            // send them to the api to get the weather data of that location coordinates
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    // if requestLocation() failed at getting the location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
