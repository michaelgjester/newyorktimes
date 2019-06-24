//
//  UIImageView+Networking.swift
//  restaurants
//
//  Created by Michael Jester on 6/23/19.
//  Copyright © 2019 Michael Jester. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{
    
    func downloadImageFromNetworkAtURL(url: String){
        
        //first check to see if we have a cached image, if so return early
        if let cachedImage = ImageCache.sharedInstance.object(forKey: url as NSString) {
            self.image = cachedImage
            return
        }
        
        //no cached image, so get ready for a network call
        //show activity spinner
        let activityIndicatorFrame: CGRect = CGRect.init(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView.init(frame: activityIndicatorFrame)
        spinner.color = UIColor.black
        spinner.backgroundColor = UIColor.lightGray
        spinner.hidesWhenStopped = true
        self.addSubview(spinner)
        spinner.startAnimating()
        
        
        let downloadImageCompletionHandler: ((Data) -> Void) = { [weak self] (imageData:Data) -> Void in
            
            if let imageFromData = UIImage.init(data:imageData){
                //populate the image in the image view and
                //cache the image for next time it is needed
                self?.image = imageFromData
                ImageCache.sharedInstance.setObject(imageFromData, forKey: url as NSString)
            }
            
            //stop spinner
            spinner.stopAnimating()
        }
        
        NetworkingManager.downloadImageAtURL(urlString: url, downloadCompletionHandler: downloadImageCompletionHandler)
        
    }
    
}
