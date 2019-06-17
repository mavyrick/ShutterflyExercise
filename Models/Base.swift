//
//  Base.swift
//  ShutterflyExercise
//
//  Created by Josh Sorokin on 13/05/2019.
//  Copyright © 2019 Josh Sorokin. All rights reserved.
//

import Foundation

struct Base : Codable {
    
    let data : PhotoData?
    let success : Bool?
    let status : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case data = "data"
        case success = "success"
        case status = "status"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent(PhotoData.self, forKey: .data)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
    }
    
}
