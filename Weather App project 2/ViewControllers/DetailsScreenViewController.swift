//
//  DetailsScreenViewController.swift
//  Weather App project 2
//
//  Created by mac on 04/04/2023.
//

import UIKit
import CoreLocation

struct DailyForecastCellModel {
	let day: String?
	let temperature: String?
	let icon: String?
}

class DetailsScreenViewController: UIViewController {

	@IBOutlet weak var locationNameLabel: UILabel!
	@IBOutlet weak var currentTemperatureLabel: UILabel!
	@IBOutlet weak var weatherConditionLabel: UILabel!
	@IBOutlet weak var lowwestTemperature: UILabel!
	@IBOutlet weak var highestTemperature: UILabel!
	@IBOutlet weak var forecastTableView: UITableView!
	
	var viewModel: WeatherViewModel? = WeatherViewModel()
	var location: CLLocationCoordinate2D?
	var dailyForecasts: [DailyForecast]? = [DailyForecast]() {
		didSet {
			forecastTableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		configureTableView()
		viewModel?.getCurrentWeatherData(for: location ?? CLLocationCoordinate2D(), completion: { [weak self] location in
			if let location = location {
				self?.configureCurrentWeather(with: location)
			}
		})
		viewModel?.getForcastData(for: location ?? CLLocationCoordinate2D(), completion: { [weak self] data in
			if let data = data {
				print("Cout => ", data.list!)
				let forecasts = data.list?.sorted(by: { curr, next in
					(curr.dt?.dateValue)! < (next.dt?.dateValue)!
				})
				self?.dailyForecasts = self?.getOneForecastPerDay(forecasts: forecasts ?? [])
			}
		})
	}

	private func configureTableView() {
		forecastTableView.dataSource = self
		forecastTableView.register(DailyForecastCell.toNib(), forCellReuseIdentifier: DailyForecastCell.identifier)
	}
	
	func configureCurrentWeather(with location: Location) {
		if let name = location.name?.capitalized {
			locationNameLabel.text = name
			print(name)
		}
		
		currentTemperatureLabel.text = "\(convertToCelsius(val: (location.currentWeather?.currentTemperature)!))"
		weatherConditionLabel.text = location.currentWeather?.description?.capitalized
		
		lowwestTemperature.text = "\(convertToCelsius(val: (location.currentWeather?.lowestTemperature)!))"
		highestTemperature.text = "\(convertToCelsius(val: (location.currentWeather?.highestTemperature)!))"
	}
	
	func getOneForecastPerDay(forecasts: [DailyForecast]) -> [DailyForecast] {
		var result = [DailyForecast]()
		var previousDate: String?
		
		for forecast in forecasts {
			guard let dateText = forecast.dtTxt else { continue }
			
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let date = dateFormatter.date(from: dateText)
			
			guard let currentDate = date else { continue }
			let currentDateText = dateFormatter.string(from: currentDate)
			
			if previousDate != nil && String(previousDate!.prefix(10)) == String(currentDateText.prefix(10)) {
				continue
			}
			
			previousDate = String(currentDateText.prefix(10))
			result.append(forecast)
		}
		
		return result
	}

}

extension DetailsScreenViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		(dailyForecasts?.count)!
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyForecastCell.identifier, for: indexPath) as? DailyForecastCell else {
			return UITableViewCell()
		}
		print("forecasts count => ", dailyForecasts?.count)
		if let forecast =  dailyForecasts?[indexPath.row] {
			cell.configure(with: forecast)
		}
		
		return cell
	}
	
	func convertToCelsius(val: Double) -> String {
		let deg = "\(Int(val - 273.15))°c"
		return deg
	}
}

extension Int {
	var dateValue: String? {
		let date = Date(timeIntervalSince1970: TimeInterval(self / 1000))
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM dd, yyyy"
		return formatter.string(from: date)
	}
}
