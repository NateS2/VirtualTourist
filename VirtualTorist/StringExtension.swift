//
//  StringExtension.swift
//  VirtualTorist
//
//  Created by Nathan  on 2/24/18.
//  Copyright © 2018 Nathan . All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func isURL() -> Bool {
        
        if let url = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
            
        } else {
            return false
        }
    }
    
    var data: Data {
        return Data(utf8)
    }
}
