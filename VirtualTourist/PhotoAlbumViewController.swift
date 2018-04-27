//
//  PhotoAlbumViewController.swift
//  VirtualTorist
//
//  Created by Nathan  on 2/9/18.
//  Copyright © 2018 Nathan . All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var photoMapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var coordinate2D: CLLocationCoordinate2D!
    var fetchedImages: [Photo] = [Photo]()
    var coreDataPhotos: [PhotoEntity] = [PhotoEntity]()
    
    private let flickrClient: FlickrClient = FlickrClient.shared
    
    var dataController: DataController!
    var pin: PinEntity!
    var fetchedResultsController:NSFetchedResultsController<PhotoEntity>!

    @IBOutlet weak var newCollectionButton: UIButton!
    @IBAction func newCollectionPressed(_ sender: Any) {
        deleteAllPhotos {
            performUIUpdatesOnMain {
                self.setUpPhotos()
            }
        }
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.allowsMultipleSelection = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let safeCoordinate = coordinate2D else { print("coordinate2D nil"); return }
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: safeCoordinate, span: span)
        photoMapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.title = "Latitude: \(safeCoordinate.latitude)"
        annotation.subtitle = "Longitude: \(safeCoordinate.longitude)"
        annotation.coordinate = safeCoordinate
        photoMapView.addAnnotation(annotation)
        setUpPhotos()

    }
    
    fileprivate func fetchPhotos() {
        let fetchRequest = NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        //3
        do {
            coreDataPhotos = try dataController.viewContext.fetch(fetchRequest) as! [PhotoEntity]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllPhotos(completion:@escaping () ->()) {
        for entity in coreDataPhotos {
            dataController.viewContext.delete(entity)
            do {
                try dataController.viewContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        completion()
    }
    
    func setUpPhotos() {
        fetchPhotos()
        if coreDataPhotos.count == 0 {
            populateData()
        }
    }
    
    func populateData() {
        flickrClient.getPhotoList(coordinate: coordinate2D, completion: { (imageResult) in
            self.fetchedImages = imageResult
            self.addPhotoEntities()
            
        }) {
            
        }
    }
    
    fileprivate func savePhoto() {
        do {
            try dataController.viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func addPhotoEntities() {
        for image in fetchedImages {
            let photo = PhotoEntity(context: dataController.viewContext)
            photo.url = image.url_m
            photo.pin = pin
            coreDataPhotos.append(photo)
            savePhoto()
        }
        performUIUpdatesOnMain {
            self.photoCollectionView.reloadData()
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.init(type: UIButtonType.detailDisclosure)
        
        return annotationView
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coreDataPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.photoCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        cell.setUpCell(coreDataPhotos[indexPath.row], dataController)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
        
        let photoToDelete = cell.photoEntity
        dataController.viewContext.delete(photoToDelete!)
        do {
            try dataController.viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        coreDataPhotos.remove(at: indexPath.row)
        photoCollectionView.deleteItems(at: [indexPath])
        
    }
    
    
}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = (self.view.frame.size.width / 3.3)
        return CGSize(width: cellSize, height: cellSize)
    }
}
