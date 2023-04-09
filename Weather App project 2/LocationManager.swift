//
//  LocationManager.swift
//  Weather App project 2
//
//  Created by mac on 04/04/2023.
//

import Foundation
import MapKit

//struct Location {
//	var locationName: String?
//	var latitude: Double?
//	var longitude: Double?
//	
//	func saveLocation() {
//		// Save the location to the database
//	}
//}


class LocationManager: NSObject, CLLocationManagerDelegate {
	static let shared = LocationManager()
	
	private var locationManager = CLLocationManager()
	private var currentLocation: CLLocation?
	
	var location: Location? //{
//		guard let currentLocation = currentLocation else { return nil }
//		return Location(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
//	}
	
	var locations: [Location] = []
	
	override init() {
		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
	}
	
	func requestLocation() {
		locationManager.requestWhenInUseAuthorization()
		locationManager.requestLocation()
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		currentLocation = locations.last
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Failed to get user's location: \(error.localizedDescription)")
	}

	
	func loadLocations() {
		// Load the locations from the database
	}
	
	func deleteLocation(at index: Int) {
		// Delete the location at the specified index
	}
	
	func getAnnotationColor(for location: Location) -> UIColor {
		// Determine the color of the annotation based on the temperature at this location
		return .red
	}
}
