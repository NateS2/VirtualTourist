//
//  PhotoAlbumViewController.swift
//  VirtualTorist
//
//  Created by Nathan  on 2/9/18.
//  Copyright © 2018 Nathan . All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var photoMapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var coordinate2D: CLLocationCoordinate2D!
    var fetchedImages: [Photo] = [Photo]()
    
    private let flickrClient: FlickrClient = FlickrClient.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: coordinate2D, span: span)
        photoMapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.title = "Latitude: \(coordinate2D.latitude)"
        annotation.subtitle = "Longitude: \(coordinate2D.longitude)"
        annotation.coordinate = coordinate2D
        photoMapView.addAnnotation(annotation)
        populateData()

    }
    
    func populateData() {
        flickrClient.getPhotoList(coordinate: coordinate2D, completion: { (imageResult) in
            self.fetchedImages = imageResult
            performUIUpdatesOnMain {
                self.photoCollectionView.reloadData()
            }
        }) {
            
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
extension PhotoAlbumViewController: UICollectionViewDelegate {
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.photoCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        let photo = self.fetchedImages[indexPath.row]
        
        let imageView: UIImageView = UIImageView()
//        cell.imageView.backgroundColor = UIColor(patternImage: UIImage(named: "america-globe.png")!)
        
        ImageLoader().loadImage(forURLString: (photo.url_m)) { (imageData) in
            performUIUpdatesOnMain {
                let image = UIImage(data: imageData)
                imageView.image = image
                
            }
        }
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        cell.contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let viewsDict = [
            "image" : imageView,
            ] as [String : Any]
        
        cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[image]|", options: [], metrics: nil, views: viewsDict))
        cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[image]|", options: [], metrics: nil, views: viewsDict))
        
        return cell
    }
    
    
}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = (self.view.frame.size.width / 3.3)
        return CGSize(width: cellSize, height: cellSize)
    }
}
