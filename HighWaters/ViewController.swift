//
//  ViewController.swift
//  HighWaters
//
//  Created by Firat on 24.02.2022.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    private var rootRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rootRef = Database.database().reference()
        setupUI()
        populateFloodedRegions()
    }
    
    func populateFloodedRegions() {
        let floodedRegionsRef = rootRef.child("flooded-regions")
        floodedRegionsRef.observe(.value) { snapshot in
            
            self.mapView.removeAnnotations(self.mapView.annotations)
        
            let floodDictionaries = snapshot.value as? [String:Any] ?? [:]
            
            for (key, _) in floodDictionaries {
                if let floodDict = floodDictionaries[key] as? [String:Any] {
                    if let flood = Flood(dictionary: floodDict) {
                        DispatchQueue.main.async {
                            let floodAnnotation = MKPointAnnotation()
                            floodAnnotation.coordinate = CLLocationCoordinate2D(latitude: flood.latitude, longitude: flood.longitude)
                            
                            self.mapView.addAnnotation(floodAnnotation)
                        }
                    }
                }
            }
        }
    }
    
    func setupUI() {
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        if let location = locationManager.location {
            
            let floodAnnotation = MKPointAnnotation()
            floodAnnotation.coordinate = location.coordinate
            mapView.addAnnotation(floodAnnotation)
            
            let coordinate = location.coordinate
            let flood = Flood(longitude: coordinate.longitude, latitude: coordinate.latitude)
            
            let floodedRegionRef = rootRef.child("flooded-regions")
            let floodedRegion = floodedRegionRef.childByAutoId()
            floodedRegion.setValue(flood.toDictionary())
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude , longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
}

