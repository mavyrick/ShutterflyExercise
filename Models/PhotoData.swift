//
//  PhotoData.swift
//  ShutterflyExercise
//
//  Created by Josh Sorokin on 13/05/2019.
//  Copyright © 2019 Josh Sorokin. All rights reserved.
//

import Foundation

struct PhotoData : Codable {
    
    let id : String?
    let link : String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case link = "link"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        link = try values.decodeIfPresent(String.self, forKey: .link)
    }
    
    //  Dictionary to be appended to links.plist
    var photoDataDictionary : [String : String] {
        
        return ["id": id ?? "", "link": link ?? ""]
        
    }
    
}
