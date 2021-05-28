import Foundation

/**
 * Decodable: a type that can decode itself from an external representation
 * its structure must be the same as the structure of the json response we wanna decode
 * use JSONDecoder to decode the json response into an object from this struct Decodable type
 * decode() must be inside a do try block cause it throws
 */

/**
 * Codable is a typealias, a combination of Decodable and Encodable protocols
 * Encodable: encode itself into json object
 */

/** this struct is used to parse the upcoming json response from the api */
struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let id: Int
}
