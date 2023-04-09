//
//  WeatherViewModel.swift
//  Weather App project 2
//
//  Created by mac on 04/04/2023.
//

import Foundation

import MapKit

class WeatherViewModel {
	
	private let apiService: APIServiceDelegate = ApiService()
	private var locations = [Location]()
	
	func getCurrentWeatherData(for location: CLLocationCoordinate2D, completion: @escaping (Location?) -> Void) {
		apiService.getCurrentWeatherData(for: location) { result in
			switch result {
				case .success(let data):
					let name = "\(data.name ?? "") - \(data.sys?.country ?? "")"
					var coordinate = CLLocationCoordinate2D()
					coordinate.latitude = data.coord?.lat ?? 0
					coordinate.longitude = data.coord?.lon ?? 0
					let forecast = Forecast(currentTemperature: data.main?.temp, highestTemperature: data.main?.tempMax, lowestTemperature: data.main?.tempMin, feelsLike: data.main?.feelsLike, description: data.weather?[0].description)
					let location = Location(name: name, coordinate: coordinate, currentWeather: forecast)
					completion(location)
				case .failure(let error):
					print(error.localizedDescription)
					completion(nil)
			}
		}
	}
	
	func getForcastData(for location: CLLocationCoordinate2D, completion: @escaping (ForecastData?) -> Void) {
		apiService.getForecastData(for: location) { result in
			switch result {
			case .success(let data):
				completion(data)
					print("Data => ", data)
			case .failure(let error):
				print(error.localizedDescription)
				completion(nil)
			}
		}
	}
	
	func getLocation(for place: String, completion: @escaping (([Location]?) -> Void)) {
		apiService.getLocation(for: place) { result in
			switch result {
			case .success(let data):
					var places: [Location] = []
					data.forEach { place in
						let name = "\(place.name), \(place.state ?? "") - \(place.country)"
						var coordinate = CLLocationCoordinate2D()
						coordinate.latitude = place.lat
						coordinate.longitude = place.lon
						let location = Location(name: name, coordinate: coordinate, currentWeather: nil)
						places.append(location)
					}
					completion(places)
					print("Places => ", places)
			case .failure(let error):
				print(error.localizedDescription)
				completion(nil)
			}
		}
	}
}


struct CurrentWeather: Codable {
	let coord: Coord?
	let weather: [Weather]?
	let base: String?
	let main: Main?
	let visibility: Int?
	let dt: Int?
	let sys: Sys?
	let timezone, id: Int?
	let name: String?
	let cod: Int?
}

struct Coord: Codable {
	let lon, lat: Double?
}

struct Main: Codable {
	let temp, feelsLike, tempMin, tempMax: Double?
	let pressure, humidity, seaLevel, grndLevel: Int?

	enum CodingKeys: String, CodingKey {
		case temp
		case feelsLike = "feels_like"
		case tempMin = "temp_min"
		case tempMax = "temp_max"
		case pressure, humidity
		case seaLevel = "sea_level"
		case grndLevel = "grnd_level"
	}
}

struct Sys: Codable {
	let type, id: Int?
	let country: String?
	let sunrise, sunset: Int?
}

struct Weather: Codable {
	let id: Int?
	let main, description, icon: String?
}

struct ForecastData: Codable {
	let cod: String?
	let message, cnt: Int?
	let list: [DailyForecast]?
	let city: City?
}

struct City: Codable {
	let id: Int?
	let name: String?
	let coord: Coord?
	let country: String?
	let population, timezone, sunrise, sunset: Int?
}

struct DailyForecast: Codable {
	let dt: Int?
	let main: Main?
	let weather: [Weather]?
	let visibility: Int?
	let pop: Double?
	let sys: Sys?
	let dtTxt: String?

	enum CodingKeys: String, CodingKey {
		case dt, main, weather, visibility, pop, sys
		case dtTxt = "dt_txt"
	}
}

struct Place: Codable {
	let name: String
	let lat, lon: Double
	let country: String
	let state: String?

	enum CodingKeys: String, CodingKey {
		case name
		case lat, lon, country, state
	}
}

typealias PlaceResults = [Place]


struct Location {
	var name: String?
	var coordinate: CLLocationCoordinate2D?
	var currentWeather: Forecast?
}

struct Forecast {
	var currentTemperature: Double?
	var highestTemperature: Double?
	var lowestTemperature: Double?
	var feelsLike: Double?
	var description: String?
}
