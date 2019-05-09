//
//  ViewController.swift
//  LocationTracker
//
//  Created by Gokhan Demirer on 4.12.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        
        view.addSubview(mapView)
        
        setupMapViewConstraints()
        
        fetchLocations()
    }
    
    fileprivate func setupNavigationItem() {
        navigationItem.title = "Location Tracker"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearLocationHistory))
    }
    
    fileprivate func setupMapViewConstraints() {
        let constraints = [
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc fileprivate func clearLocationHistory() {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                mapView.removeAnnotations(mapView.annotations)
                print("Deleted.")
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func fetchLocations() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
            request.returnsDistinctResults = true
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try context.fetch(request)
                
                for location in result as! [Location] {
                    setAnnotation(location: location, date: location.date)
                }
                
//                drawPolyline()
                
            } catch let err {
                print(err.localizedDescription)
            }
            
        }
    }
    
    func drawPolyline() {
        
        let annotations = mapView.annotations
        var coordinates = [CLLocationCoordinate2D]()
        
        for annotation in annotations {
            coordinates.append(annotation.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
    }
    
    func setAnnotation(location: Location, date: Date?) {
        let point = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        point.coordinate = coordinate
        
        if let _date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, h:mm:ss a"
            point.title = dateFormatter.string(from: _date)
        }
        
        mapView.addAnnotation(point)
    }
    
    func recordLocation(location: CLLocation) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            
            let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context) as? Location
            
            newLocation?.latitude = location.coordinate.latitude
            newLocation?.longitude = location.coordinate.longitude
            newLocation?.date = Date()
            
            do {
                try context.save()
                print("Saved")
            } catch let err {
                print(err.localizedDescription)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func setRegionToMap(location: CLLocation) {
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    fileprivate let annotationId = "annotationId"
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
        pinView.pinTintColor = .red
        pinView.canShowCallout = true

        return pinView
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
            
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }


}

