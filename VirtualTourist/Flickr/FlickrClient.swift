//
//  FlickrClient.swift
//  VirtualTorist
//
//  Created by Nathan  on 2/24/18.
//  Copyright © 2018 Nathan . All rights reserved.
//

import UIKit
import MapKit

class FlickrClient: NSObject {
    
    static let shared = FlickrClient()
    
    func getPhotoList(coordinate: CLLocationCoordinate2D, completion:@escaping (_ photoResponse: [Photo]) ->(), failure:@escaping () ->()) {
        
        let pageNumber = Int(arc4random_uniform(UInt32(4))) + 1
        
        let methodParameters = [
            FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.APIKey: FlickrParameterValues.APIKey,
            FlickrParameterKeys.MediaType: FlickrParameterValues.MediaType,
            FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.Radius: FlickrParameterValues.Radius,
            FlickrParameterKeys.RadiusUnits: FlickrParameterValues.RadiusUnits,
            FlickrParameterKeys.Latitude: coordinate.latitude,
            FlickrParameterKeys.Longitude: coordinate.longitude,
            FlickrParameterKeys.PerPage: FlickrParameterValues.PerPage,
            FlickrParameterKeys.Page: String(pageNumber)
        ] as [String : AnyObject]
        
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
//        print("URL: \(flickrURLFromParameters(methodParameters))")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                failure()
                print("error")
                return
            }
            do {
                let photoResponse = try JSONDecoder().decode(FlickrImageResult.self, from: data!)
//                print("ITS HERE \(photoResponse.photos)")
//                self.sharedData.studentLocations = studentLocationStruct.results
                completion((photoResponse.photos?.photo)!)
                
            } catch {
                print("other error")
                failure()
                //couldn't parse into expected dictionary
            }
            
        }
        task.resume()
    }
    
    
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}
