//
//  ImageCache.swift
//  restaurants
//
//  Created by Michael Jester on 6/23/19.
//  Copyright © 2019 Michael Jester. All rights reserved.
//

import UIKit

class ImageCache: NSCache<NSString, UIImage> {
    
    static let sharedInstance = ImageCache()
    
    private override init(){
        super.init()
    }
    
}
