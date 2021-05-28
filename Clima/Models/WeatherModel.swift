import UIKit

// this struct stores the parsed json i got from the api
struct WeatherModel {

    // MARK: - Properties -

    let conditionId: Int
    let cityName: String
    let temperature: Double

    /** a computed property */
    // its value is set based on the code inside its block
    var conditionName: String {
        // the conditionId will be set when i create an object from this struct
        switch conditionId {
            case 200...232:
                return "cloud.bolt"
            case 300...321:
                return "cloud.drizzle"
            case 500...531:
                return "cloud.rain"
            case 600...622:
                return "cloud.snow"
            case 701...781:
                return "cloud.fog"
            case 800:
                return "sun.max"
            default:
                return "cloud"
        }
    }

    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
}
