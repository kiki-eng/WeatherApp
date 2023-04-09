//
//  LocationListTableCell.swift
//  Weather App project 2
//
//  Created by mac on 04/04/2023.
//

import UIKit

class LocationListTableCell: UITableViewCell {

	static let identifier = "LocationListTableCell"
	
	@IBOutlet weak var locationNameLabel: UILabel!
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var weatherConditionImageView: UIImageView!
	
	var currentTemperature: Double? = 20.0
	var highestTemperature: Double? = 22.0
	var lowestTemperature: Double? = 18.0
	
	static func toNib() -> UINib {
		UINib(nibName: identifier, bundle: nil)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		weatherConditionImageView.layer.cornerRadius = 10
	}
	
	func configure(with location: Location) {
		let current = convertToCelsius(val: (location.currentWeather?.currentTemperature)!)
		let high = convertToCelsius(val: (location.currentWeather?.highestTemperature)!)
		let low = convertToCelsius(val: (location.currentWeather?.lowestTemperature)!)
		
		if let name = location.name {
			locationNameLabel.text = name
		}
		
		temperatureLabel.text = "\(current)C (H:\(high) L:\(low))"
		configureIcon(with: location.currentWeather?.description ?? "", temp: Int((location.currentWeather?.currentTemperature)! - 273.15))
	}

	func configureIcon(with desc: String, temp: Int) {
		switch desc {
			case "Clear": weatherConditionImageView.image = UIImage(systemName: "sun.max")
			case "Clouds": weatherConditionImageView.image = UIImage(systemName: "cloud")
			default: weatherConditionImageView.image = UIImage(systemName: "cloud.rain")
		}
		
		if temp < 0 {
			weatherConditionImageView.backgroundColor = .purple
			weatherConditionImageView.tintColor = .white
		} else if temp < 12 {
			weatherConditionImageView.backgroundColor = .blue
			weatherConditionImageView.tintColor = .white
		} else if temp < 17 {
			weatherConditionImageView.backgroundColor = .cyan
			weatherConditionImageView.tintColor = .white
		} else if temp < 25 {
			weatherConditionImageView.backgroundColor = .yellow
			weatherConditionImageView.tintColor = .systemGreen
		} else if temp < 30 {
			weatherConditionImageView.backgroundColor = .orange
			weatherConditionImageView.tintColor = .white
		} else {
			weatherConditionImageView.backgroundColor = .red
			weatherConditionImageView.tintColor = .white
		}
	}
	
	func convertToCelsius(val: Double) -> String {
		let deg = "\(Int(val - 273.15))°"
		return deg
	}
}
