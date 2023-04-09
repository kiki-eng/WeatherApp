//
//  LocationDetailViewModel.swift
//  Weather App project 2
//
//  Created by mac on 04/04/2023.
//

import Foundation

class LocationDetailViewModel {
	var location: Location
	
	init(location: Location) {
		self.location = location
	}
	
	func getTemperature(completion: @escaping (Double?) -> Void) {
		// Make an API request to get the temperature for this location
		// Call the completion handler with the temperature once it's available
	}
}
