//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTorist
//
//  Created by Nathan  on 3/29/18.
//  Copyright © 2018 Nathan . All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    
    func setUpCell(_ photo: PhotoEntity,_ dataController: DataController) {
        
        if photo.photoData != nil {
            cellImageView.image = UIImage(data: photo.photoData!)
        } else {
            ImageLoader().loadImage(forURLString: photo.url!, completion: { (data) in
                photo.photoData = data
                self.saveImage(_photo: photo, dataController)
                performUIUpdatesOnMain {
                    self.cellImageView.image = UIImage(data: photo.photoData!)
                }
            })
        }
    }
    
    func saveImage(_photo: PhotoEntity,_ dataController: DataController) {
        do {
            try dataController.viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
