//
//  FlickrDataModel.swift
//  VirtualTorist
//
//  Created by Nathan  on 2/24/18.
//  Copyright © 2018 Nathan . All rights reserved.
//

import Foundation

struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let url_m: String
}

struct ResponseObject: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}

struct FlickrImageResult: Codable {
    let photos : ResponseObject?
    let stat: String
}

