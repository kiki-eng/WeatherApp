//
//  CalloutView.swift
//  Weather App project 2
//
//  Created by mac on 07/04/2023.
//

import Foundation
import MapKit

class WeatherAnnotation: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	var title: String?
	var weatherCondition: String?
	var desc: String?
	var temp: Int?
	
	init(coordinate: CLLocationCoordinate2D, title: String?, weatherCondition: String, temperature: Double, feelsLikeTemperature: Double) {
		self.coordinate = coordinate
		self.title = title
		self.weatherCondition = weatherCondition
		super.init()
		self.desc = "\(self.convertToCelsius(val: temperature)) feels like \(self.convertToCelsius(val: feelsLikeTemperature))"
		self.temp = Int(temperature - 273.15)
	}
	
	
	func convertToCelsius(val: Double) -> String {
		let deg = "\(Int(val - 273.15))°c"
		return deg
	}
}

class CalloutView: MKAnnotationView {
	@IBOutlet weak var iconImage: UIImageView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var desc: UILabel!
	@IBOutlet weak var moreDetailButton: UIButton!
	
	let identifier = "custom"
	var navigationController: UINavigationController?
	var coordinate: CLLocationCoordinate2D?

	@IBAction func didTapMoreInfo(_ sender: Any) {
//		if let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsScreenViewController {
//			vc.location = coordinate!
//			navigationController?.present(vc, animated: true)
//		}
	}
	
	func configure(with data: WeatherAnnotation) {
		title.text = data.title!
		desc.text = data.desc ?? ""
		configureIcon(with: data.weatherCondition ?? "", temp: data.temp)
	}
	
	func configureIcon(with desc: String, temp: Int?) {
		switch desc {
			case "Clear": iconImage.image = UIImage(systemName: "sun.max")
			case "Clouds": iconImage.image = UIImage(systemName: "cloud")
			default: iconImage.image = UIImage(systemName: "cloud.rain")
		}
		
		if let temp = temp {
			if temp < 0 {
				iconImage.backgroundColor = .purple
				iconImage.tintColor = .white
			} else if temp < 12 {
				iconImage.backgroundColor = .blue
				iconImage.tintColor = .white
			} else if temp < 17 {
				iconImage.backgroundColor = .cyan
				iconImage.tintColor = .white
			} else if temp < 25 {
				iconImage.backgroundColor = .yellow
				iconImage.tintColor = .systemGreen
			} else if temp < 30 {
				iconImage.backgroundColor = .orange
				iconImage.tintColor = .white
			} else {
				iconImage.backgroundColor = .red
				iconImage.tintColor = .white
			}
		}
	}
}
