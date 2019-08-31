//
//  RedditPost.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import Foundation

enum RedditPostStatus {
    case read
    case unread
}

struct RedditPost: Decodable {
    let name: String
    let author: String
    let title: String
    let thumbnail: String?
    let comments: Int?
    let entryDate: TimeInterval
    let status: RedditPostStatus
    
    enum CodingKeys: String, CodingKey {
        case name
        case author
        case title
        case thumbnail
        case comments = "num_comments"
        case entryDate = "created"
        case data
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try rootContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        name = try dataContainer.decode(String.self, forKey: .name)
        author = try dataContainer.decode(String.self, forKey: .author)
        title = try dataContainer.decode(String.self, forKey: .title)
        entryDate = try dataContainer.decode(TimeInterval.self, forKey: .entryDate)
        thumbnail = try dataContainer.decodeIfPresent(String.self, forKey: .thumbnail)
        comments = try dataContainer.decodeIfPresent(Int.self, forKey: .comments)
        status = .unread
    }
}
