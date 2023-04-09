//
//  ApiService.swift
//  Weather App project 2
//
//  Created by mac on 04/04/2023.
//

import Foundation
import CoreLocation

protocol APIServiceDelegate: AnyObject {
	func getCurrentWeatherData(for location: CLLocationCoordinate2D, completion: @escaping ((Result<CurrentWeather, Error>) -> Void))
	func getForecastData(for location: CLLocationCoordinate2D, completion: @escaping ((Result<ForecastData, Error>) -> Void))
	func getLocation(for place: String, completion: @escaping ((Result<PlaceResults, Error>) -> Void))
}

class ApiService: APIServiceDelegate {
	
	let apiKey = "25fa0decdf5b5508bafca6bcbd56b062"
	let baseUrl = "https://api.openweathermap.org/data/2.5/"
	let geoCodingBaseUrl = "https://api.openweathermap.org/geo/1.0/"
	
	
	func getLocation(for place: String, completion: @escaping ((Result<PlaceResults, Error>) -> Void)) {
		let urlString: String = "\(geoCodingBaseUrl)direct?q=\(place)&limit=5&appid=\(apiKey)"
		guard let url: URL = URL(string: urlString) else {
			print("Error : \(ApiError.invalidUrl)")
			completion(.failure(ApiError.invalidUrl))
			return
		}
		let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			DispatchQueue.main.async {
				if let error = error {
					print("Error : \(error.localizedDescription)")
					completion(.failure(error))
				}
				
				guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
					print("Error : HTTP Response Code Error")
					completion(.failure(error!))
					return
				}
				
				guard let data = data else {
					print("Error : No Response")
					completion(.failure(ApiError.invalidData))
					return
				}
				self?.decodePlacesData(JSONData: data, completion: completion)
			}
		}
		task.resume()
	}
	
	func getCurrentWeatherData(for location: CLLocationCoordinate2D, completion: @escaping ((Result<CurrentWeather, Error>) -> Void)) {
		let lat = location.latitude
		let long = location.longitude
		let urlString: String = "\(baseUrl)weather?lat=\(lat)&lon=\(long)&appid=\(apiKey)"
		guard let url: URL = URL(string: urlString) else {
			print("Error : \(ApiError.invalidUrl)")
			completion(.failure(ApiError.invalidUrl))
			return
		}
		let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			DispatchQueue.main.async {
				if let error = error {
					print("Error : \(error.localizedDescription)")
					completion(.failure(error))
				}
				
				guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
					print("Error : HTTP Response Code Error")
					completion(.failure(error!))
					return
				}
				
				guard let data = data else {
					print("Error : No Response")
					completion(.failure(ApiError.invalidData))
					return
				}
				self?.decodeCurrentWeatherData(JSONData: data, completion: completion)
			}
		}
		task.resume()
	}
	
	func getForecastData(for location: CLLocationCoordinate2D, completion: @escaping ((Result<ForecastData, Error>) -> Void)) {
		let lat = location.latitude
		let long = location.longitude
		let urlString: String = "\(baseUrl)forecast?lat=\(lat)&lon=\(long)&appid=\(apiKey)"
		guard let url: URL = URL(string: urlString) else {
			print("Error : \(ApiError.invalidUrl)")
			completion(.failure(ApiError.invalidUrl))
			return
		}
		let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			DispatchQueue.main.async {
				if let error = error {
					print("Error : \(error.localizedDescription)")
					completion(.failure(error))
				}
				
				guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
					print("Error : HTTP Response Code Error")
					completion(.failure(error!))
					return
				}
				
				guard let data = data else {
					print("Error : No Response")
					completion(.failure(ApiError.invalidData))
					return
				}
				self?.decodeForecastData(JSONData: data, completion: completion)
			}
		}
		task.resume()
	}
	
	func decodeCurrentWeatherData(JSONData: Data, completion: (Result<CurrentWeather, Error>) -> Void) {
		do {
			let response = try JSONDecoder().decode(CurrentWeather.self, from: JSONData)
			completion(.success(response))
		} catch let error {
			completion(.failure(error))
		}
	}
	
	func decodeForecastData(JSONData: Data, completion: (Result<ForecastData, Error>) -> Void) {
		do {
			print(JSONData)
			let response = try JSONDecoder().decode(ForecastData.self, from: JSONData)
			completion(.success(response))
			var res = [String]()
			response.list?.forEach { elem in
				res.append(elem.dtTxt ?? "")
			}
			print(res)
		} catch let error {
			completion(.failure(error))
		}
	}
	
	func decodePlacesData(JSONData: Data, completion: (Result<PlaceResults, Error>) -> Void) {
		do {
			let response = try JSONDecoder().decode(PlaceResults.self, from: JSONData)
			completion(.success(response))
		} catch let error {
			completion(.failure(error))
		}
	}
}


enum WeatherType: String {
	case currentWeather = "weather"
	case weatherForcast = "forecast"
}

enum ApiError: Error {
	case invalidUrl
	case invalidData
}
