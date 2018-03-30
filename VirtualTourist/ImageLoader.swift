//
//  ImageLoader.swift
//  VirtualTorist
//
//  Created by Nathan  on 2/24/18.
//  Copyright © 2018 Nathan . All rights reserved.
//

import Foundation

class ImageLoader {
    
    func loadImage(forURLString urlString: String, completion:@escaping (_ data: Data) -> ()) {
        
        if urlString.isURL() {
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                DispatchQueue.main.async {
                    if data != nil {
                        completion(data!)
                    }
                }
                
            }).resume()
        }
    }
}
