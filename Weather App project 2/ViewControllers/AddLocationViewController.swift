//
//  AddLocationScreenViewController.swift
//  Weather App project 2
//
//  Created by mac on 04/04/2023.
//

import UIKit
import CoreLocation
import MapKit

protocol AddLocationDelegate {
	func saveLocation(location: Location)
}


class AddLocationViewController: UIViewController {
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var searchResultTableView: UITableView!
	
	var viewModel = WeatherViewModel()
	var delegate: AddLocationDelegate?
	var location: Location?
	
	var locationResults: [Location]? = [Location]() {
		didSet {
			if locationResults?.count != 0 {
				let initialRegion = MKCoordinateRegion(center: locationResults?[0].coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: 10000, longitudinalMeters: 10000)
				mapView.setRegion(initialRegion, animated: true)
				addAnnotation(location: (locationResults?[0])!)
				searchResultTableView.reloadData()
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureTableView()
		configureSearchBar()
		mapView.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		mapView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
	}
	
	private func configureTableView() {
		searchResultTableView.delegate = self
		searchResultTableView.dataSource = self
		searchResultTableView.register(LocationListTableCell.toNib(), forCellReuseIdentifier: LocationListTableCell.identifier)
	}

	private func configureSearchBar() {
		searchBar.delegate = self
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		view.endEditing(true)
		self.navigationController?.isNavigationBarHidden = false
	}
	
	@IBAction func cancelButton(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func Save(_ sender: Any) {
		if delegate != nil, location != nil {
			self.delegate?.saveLocation(location: location!)
			navigationController?.popViewController(animated: true)
		}
	}
}

extension AddLocationViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		print(searchText)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		dismissKeyboard()
		self.navigationController?.isNavigationBarHidden = false
		locationResults = []
		let text = searchBar.text
		let place = text?.trimmingCharacters(in: .whitespaces)

		searchBar.text = place
		if let place = place, !place.isEmpty {
			viewModel.getLocation(for: place) { [weak self] places in
				places?.forEach({ location in
					self?.viewModel.getCurrentWeatherData(for: location.coordinate!) { location in
						if let location = location {
							self?.locationResults?.append(location)
						}
					}
				})
			}
		}
	}
	
}

extension AddLocationViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		locationResults?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LocationListTableCell.self), for: indexPath) as? LocationListTableCell else { return UITableViewCell() }
		if let location = locationResults?[indexPath.row] {
			cell.configure(with: location)
		}
		return cell
	}
}

extension AddLocationViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let coordinate = locationResults?[indexPath.row].coordinate {
			let initialRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
			mapView.setRegion(initialRegion, animated: true)
			addAnnotation(location: (locationResults?[indexPath.row])!)
			location = locationResults?[indexPath.row]
		}
	}
}


extension AddLocationViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard let annotation = annotation as? WeatherAnnotation else { return nil }
		
		let identifier = "custom"
		var annotationView = CalloutView(annotation: annotation, reuseIdentifier: identifier)
		
		if annotationView == nil {
			annotationView = CalloutView(annotation: annotation, reuseIdentifier: identifier)
		} else {
			annotationView.annotation = annotation
		}
		annotationView.canShowCallout = true
		setPinColor(view: (annotationView), temp: annotation.temp ?? 0)
		
		return annotationView
	}
	
	func addAnnotation(location: Location) {
		let annotation = WeatherAnnotation(coordinate: location.coordinate!, title: location.currentWeather?.description ?? "", weatherCondition: location.currentWeather?.description ?? "", temperature: location.currentWeather?.currentTemperature ?? 0, feelsLikeTemperature: location.currentWeather?.feelsLike ?? 0)
		mapView.addAnnotations([annotation])
	}
	
	func setPinColor(view: MKAnnotationView, temp: Int) {
		let image = UIImage(named: "location-pin")
		if temp < 0 {
			view.tintColor = .purple
			view.image = image?.withTintColor(.purple, renderingMode: .alwaysTemplate)
		} else if temp < 12 {
			view.tintColor = .blue
			view.image = image?.withTintColor(.blue, renderingMode: .alwaysTemplate)
		} else if temp < 17 {
			view.tintColor = .cyan
			view.image = image?.withTintColor(.cyan, renderingMode: .alwaysTemplate)
		} else if temp < 25 {
			view.tintColor = .yellow
			view.image = image?.withTintColor(.yellow, renderingMode: .alwaysTemplate)
		} else if temp < 30 {
			view.tintColor = .orange
			view.image = image?.withTintColor(.orange, renderingMode: .alwaysTemplate)
		} else {
			view.tintColor = .red
			view.image = image?.withTintColor(.red, renderingMode: .alwaysTemplate)
		}
	}
	
	func setupAnnotations(locations: [Location]) {
		for location in locations {
			addAnnotation(location: location)
		}
	}
	
	func convertToCelsius(val: Double) -> String {
		let deg = "\(Int(val - 273.15))°c"
		return deg
	}
}
