//
//  UIImageView+ImageCache.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/2.
//

import UIKit

class ImageCacheView: UIImageView {
    
    var dataTask: URLSessionDataTask?
    
    func setImage(string: String?, callback: ((UIImage?, Error?) -> Void)? = nil) {
        
        cancelImageLoad()
        
        if let string = string, let url = URL(string: string) {
            let key = NSString(string: url.absoluteString)
            
            if let cachedImage = ImageCache.instance.object(forKey: key) as? UIImage {
                image = cachedImage
                callback?(cachedImage, nil)
                return
            }
                
            dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let data = data, error == nil, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                        ImageCache.instance.setObject(image, forKey: key)
                        callback?(image, nil)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.image = nil
                        callback?(nil, error)
                    }
                }
            }
            
            dataTask?.resume()
        }
        else {
            image = nil
            DispatchQueue.main.async {
                callback?(nil, nil)
            }
        }
    }
    
    func cancelImageLoad() {
        dataTask?.cancel()
    }
}

class ImageCache: NSCache<AnyObject, AnyObject> {
    static let instance = ImageCache()
}
