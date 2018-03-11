//
//  ViewController.swift
//  VirtualTorist
//
//  Created by Nathan  on 2/9/18.
//  Copyright © 2018 Nathan . All rights reserved.
//
// https://stackoverflow.com/questions/40844336/create-long-press-gesture-recognizer-with-annotation-pin
// https://stackoverflow.com/questions/15292318/mkmapview-mkpointannotation-tap-event

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController {
    
    @IBOutlet weak var travelMapView: MKMapView!
    var coordinate2D: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    var dataController:DataController!
    
    var pins: [PinEntity]!
    
//    var fetchedResultsController:NSFetchedResultsController<Notebook>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(gestureRecognized:)))
        
        //long press (2 sec duration)
        longPress.minimumPressDuration = 2
        travelMapView.addGestureRecognizer(longPress)
        setUpPins()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    fileprivate func addPin(_ location: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.title = "Latitude: \(location.latitude)"
        annotation.subtitle = "Longitude: \(location.longitude)"
        annotation.coordinate = location
        travelMapView.addAnnotation(annotation)
    }
    
    @objc func longPressed(gestureRecognized: UIGestureRecognizer){
        let touchpoint = gestureRecognized.location(in: self.travelMapView)
        let location = travelMapView.convert(touchpoint, toCoordinateFrom: self.travelMapView)
        addPin(location)
        savePin(location)
    }
    
    func savePin(_ location: CLLocationCoordinate2D) {
        let pin = PinEntity(context: dataController.viewContext)
        pin.latitude = Double(location.latitude)
        pin.longitude = Double(location.longitude)
        do {
            try dataController.viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    fileprivate func fetchPins() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PinEntity")
        
        //3
        do {
            pins = try dataController.viewContext.fetch(fetchRequest) as! [PinEntity]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func setUpPins() {
        fetchPins()
        for pin in pins {
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
            addPin(coordinate)
        }
    }
    
    func lookUpPin(_ location: CLLocationCoordinate2D) -> PinEntity? {
        for pin in pins {
            if (pin.latitude == location.latitude && pin.longitude == location.longitude) {
                return pin
            }
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoAlbumViewController" {
            guard let safePin = lookUpPin(coordinate2D) else { print("safePin nil"); return }
            if let vc = segue.destination as? PhotoAlbumViewController {
                vc.coordinate2D = coordinate2D
                vc.dataController = dataController
                vc.pin = safePin
                print(safePin)
            }
        }
    }

}

extension TravelLocationsViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.init(type: UIButtonType.detailDisclosure)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        guard let annotation = view.annotation else
        {
            return
        }
        coordinate2D.longitude = annotation.coordinate.longitude
        coordinate2D.latitude = annotation.coordinate.latitude
        
        self.performSegue(withIdentifier: "photoAlbumViewController", sender: nil)
        
    }
}
