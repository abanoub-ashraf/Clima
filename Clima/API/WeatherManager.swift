import Foundation
import CoreLocation

/**
 * contains a function that sends the weather data we get from the WeatherManager
   to the WeatherViewController to fill its UI with its properties
 * another function to pass any error happens in the WeatherManager to the WeatherViewController
 */
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {

    // MARK: - Properties -

    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(Config.apiKey)&units=metric"

    var delegate: WeatherManagerDelegate?

    // MARK: - Methods -
    
    // get the weather by the city name
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    // get the weather by the coordinates
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }

    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    let errorDescription = error?.localizedDescription
                    print(errorDescription!)
                    // pass the error to the weather controller
                    self.delegate?.didFailWithError(error!)
                    return
                }
                if let safeData = data {
                    // this weather we got from parseJSON() is an optional so unwrap it
                    if let weather = self.parseJSON(safeData) {
                         // send this weather data to the weather controller
                         self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }

    /**
     * parse the JSON response we got from the api into our Swift model
     * return the model as optional because in case we couldn't get data from the api
     */
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        // An object that decodes instances of a data type from JSON objects
        let decoder = JSONDecoder()
        do {
            // decode() convert the json data into our Model Struct and create an object from it
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            // get the properties we need from the api response we decoded
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            // then create a model object using those properties we got above
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            print(error.localizedDescription)
            // pass the error to the weather controller
            self.delegate?.didFailWithError(error)
            // in case we couldn't get a response, this is allowed cause the return type is an optional
            return nil
        }
    }
}
