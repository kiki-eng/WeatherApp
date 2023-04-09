//
//  DailyForecastCell.swift
//  Weather App project 2
//
//  Created by mac on 06/04/2023.
//

import UIKit

class DailyForecastCell: UITableViewCell {
	
	static let identifier = "DailyForecastCell"

	@IBOutlet weak var dayLabel: UILabel!
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var weatherIconImageView: UIImageView!
	
	static func toNib() -> UINib {
		UINib(nibName: identifier, bundle: nil)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		weatherIconImageView.layer.cornerRadius = 7
	}
	
	func configure(with data: DailyForecast) {
		dayLabel.text = getDay(date: data.dtTxt!)
		temperatureLabel.text = convertToCelsius(val: (data.main?.temp)!)
		configureIcon(with: (data.weather?[0].main)!, temp: Int((data.main?.temp)! - 273.15))
	}
	
	func configureIcon(with desc: String, temp: Int) {
		switch desc {
			case "Clear": weatherIconImageView.image = UIImage(systemName: "sun.max")
			case "Clouds": weatherIconImageView.image = UIImage(systemName: "cloud")
			default: weatherIconImageView.image = UIImage(systemName: "cloud.rain")
		}
		
		if temp < 0 {
			weatherIconImageView.backgroundColor = .purple
			weatherIconImageView.tintColor = .white
		} else if temp < 12 {
			weatherIconImageView.backgroundColor = .blue
			weatherIconImageView.tintColor = .white
		} else if temp < 17 {
			weatherIconImageView.backgroundColor = .cyan
			weatherIconImageView.tintColor = .white
		} else if temp < 25 {
			weatherIconImageView.backgroundColor = .yellow
			weatherIconImageView.tintColor = .systemGreen
		} else if temp < 30 {
			weatherIconImageView.backgroundColor = .orange
			weatherIconImageView.tintColor = .white
		} else {
			weatherIconImageView.backgroundColor = .red
			weatherIconImageView.tintColor = .white
		}
	}
	
	func getDay(date: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale.current
		dateFormatter.timeZone = TimeZone.current
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let dateValue = date
		let date = dateFormatter.date(from: dateValue) ?? Date.now
		let dayOfWeek = Calendar.current.component(.weekday, from: date)
		let day = Calendar.current.weekdaySymbols[dayOfWeek - 1]
		return day
	}
	
	func convertToCelsius(val: Double) -> String {
		let deg = "\(Int(val - 273.15))°c"
		return deg
	}
}
