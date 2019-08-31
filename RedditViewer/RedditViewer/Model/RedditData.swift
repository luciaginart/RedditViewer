//
//  RedditData.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import Foundation

struct RedditData: Decodable {
    let posts: [RedditPost]
    
    enum CodingKeys: String, CodingKey {
        case data
        case children
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try rootContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        posts = try dataContainer.decode([RedditPost].self, forKey: .children)
    }
}
