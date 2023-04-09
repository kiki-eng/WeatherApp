//
//  MapViewModel.swift
//  Weather App project 2
//
//  Created by mac on 04/04/2023.
//

import Foundation

class MapViewModel {
	var locations: [Location] = []
	
	func loadLocations() {
		// Load the locations from the database
	}
	
	func getAnnotationColor(for location: Location) -> UIColor {
		// Determine the color of the annotation based on the temperature at this location
		return .red
	}
}
