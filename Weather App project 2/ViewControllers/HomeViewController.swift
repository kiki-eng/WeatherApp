//
//  HomeViewController.swift
//  Weather App project 2
//
//  Created by mac on 04/04/2023.
//

import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var locationListTableView: UITableView!
	@IBOutlet weak var addLocationButton: UIButton!
	
	
	var viewModel = WeatherViewModel()
	let locationManager = CLLocationManager()
	var locations: [Location]? = [Location]() {
		didSet {
			if let locations = locations {
				
				setupAnnotations(locations: locations)
				locationListTableView.reloadData()
			}
		}
	}
	
	var selectedCoordinate: CLLocationCoordinate2D?

	override func viewDidLoad() {
		super.viewDidLoad()

		configureMapView()
		configureTableView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		mapView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "AddLocationSegue" {
			let vc: AddLocationViewController = segue.destination as! AddLocationViewController
			vc.delegate = self
		}
	}

	// MARK: - Private Functions
	private func configureMapView() {
		locationManager.requestWhenInUseAuthorization()
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.distanceFilter = kCLDistanceFilterNone
		
		mapView.showsUserLocation = false
		
		mapView.delegate = self
		locationManager.delegate = self
	}


	private func configureTableView() {
		locationListTableView.delegate = self
		locationListTableView.dataSource = self
		locationListTableView.register(LocationListTableCell.toNib(), forCellReuseIdentifier: LocationListTableCell.identifier)
	}

	@IBAction func AddLocationButtonAction(_ sender: Any) {
		print("Button tapped")
	}

}

extension HomeViewController: AddLocationDelegate {
	func saveLocation(location: Location) {
		// add location to locations array
		locations?.append(location)
		if let coordinate = location.coordinate {
			let weatherAnnotation = WeatherAnnotation(coordinate: coordinate, title: location.name, weatherCondition: location.currentWeather?.description ?? "", temperature: location.currentWeather?.currentTemperature ?? 0, feelsLikeTemperature: location.currentWeather?.feelsLike ?? 0)
			let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
			mapView.setRegion(region, animated: true)
			addAnnotation(location: location)
		}
	}
	
	
}

extension HomeViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		locations?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LocationListTableCell.self), for: indexPath) as? LocationListTableCell else { return UITableViewCell() }
		if let location = locations?[indexPath.row] {
			cell.configure(with: location)
		}
		return cell
	}

}

extension HomeViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let location = locations?[indexPath.row] {
			addAnnotation(location: location)
			mapView.setCenter(location.coordinate!, animated: true)
		}
	}
}

extension HomeViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
			case .authorizedWhenInUse:
				locationManager.requestLocation()
			case .notDetermined, .restricted, .denied, .authorizedAlways:
				break
			@unknown default:
				break
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.last?.coordinate {
			viewModel.getCurrentWeatherData(for: location) { [weak self] location in
				if let coordinate = location?.coordinate {
					self?.addAnnotation(location: location!)
					let region = MKCoordinateRegion(center: (location?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
					self?.mapView.setRegion(region, animated: true)
				}
				
			}
		}
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("error:: \(error.localizedDescription)")
	}
	
}

extension HomeViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard let annotation = annotation as? WeatherAnnotation else { return nil }
		
		let identifier = "custom"
		var annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
		
		if annotationView == nil {
			annotationView = CalloutView(annotation: annotation, reuseIdentifier: identifier)
		} else {
			annotationView.annotation = annotation
		}
		annotationView.canShowCallout = true
		setPinColor(view: (annotationView), temp: annotation.temp ?? 0)
		
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
		guard view.annotation is WeatherAnnotation else { return }
		if let annotation = view.annotation as? WeatherAnnotation {
			mapView.removeAnnotation(annotation)
		}
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard let annotation = view.annotation as? WeatherAnnotation else { return }
		let calloutView = Bundle.main.loadNibNamed("CalloutView", owner: self)?.first as? CalloutView
		calloutView?.backgroundColor = .white
		calloutView?.configure(with: annotation)
		selectedCoordinate = annotation.coordinate
		view.detailCalloutAccessoryView = calloutView?.desc
		view.rightCalloutAccessoryView = calloutView?.moreDetailButton
		view.leftCalloutAccessoryView = calloutView?.iconImage
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMoreInfo))
		view.rightCalloutAccessoryView?.addGestureRecognizer(tapGesture)
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
	
	@objc func didTapMoreInfo() {
		if let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsScreenViewController {
			vc.location = selectedCoordinate
			navigationController?.present(vc, animated: true)
		}
	}
}


