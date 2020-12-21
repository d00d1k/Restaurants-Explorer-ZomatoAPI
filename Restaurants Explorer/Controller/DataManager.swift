//
//  Data Model.swift
//  Restaurants Explorer
//
//  Created by Nikita Kalyuzhnyy on 16.12.2020.
//

import Foundation

class DataManager {
    
    class func getData(from url: String, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        
        let imageURL: String = url
        
        let imgURL = URL(string: imageURL)
        
        URLSession.shared.dataTask(with: imgURL!, completionHandler: completion).resume()
    }
}
