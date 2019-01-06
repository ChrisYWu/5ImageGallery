//
//  ImageItem.swift
//  5ImageGallery
//
//  Created by Chris Wu on 1/5/19.
//  Copyright © 2019 Wu Personal Team. All rights reserved.
//

import Foundation
import UIKit

struct ImageItem: Codable {
    var url: URL
    var aspectRatio: CGFloat
    
    // this object is Codable with no other effort
    // than saying it implements Codable
    // since all of its vars' data types are Codable
    // if that weren't true, you could still make it Codable
    // by adding init and encode methods
    
    // if you wanted the JSON keys for this to be different
    // you'd uncomment this out (as an example) ...
    // private enum CodingKeys: String, CodingKey {
    //    case url = "background_url"
    //    case emojis
    // }
    
    init?(json: Data) // take some JSON and try to init an ImageItem from it
    {
        if let newValue = try? JSONDecoder().decode(ImageItem.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    init?(_ string: NSString) {
        if let json = (string as String).data(using: String.Encoding.utf8), let newValue = ImageItem(json: json) {
            self = newValue
        }
        else {
            return nil
        }
    }
    
    var json: Data? // return this ImageItem as a JSON data
    {
        return try? JSONEncoder().encode(self)
    }
    
    var string: NSString? {
        if let data = json {
            return String(data: data, encoding: String.Encoding.utf8) as NSString?
        }
        else {
            return nil
        }
    }
    
    init(url: URL, aspectRatio: CGFloat) {
        self.url = url
        self.aspectRatio = aspectRatio
    }
}
