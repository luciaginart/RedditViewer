//
//  RedditPost.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import Foundation

enum RedditPostStatus: String, Codable {
    case read
    case unread
}

struct RedditPost: Codable {
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
        case status
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
        
        if let statusRawValue = try dataContainer.decodeIfPresent(String.self, forKey: .status) {
            status = RedditPostStatus(rawValue: statusRawValue) ?? .unread
        } else {
           status = .unread
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var dataContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        try dataContainer.encode(name, forKey: .name)
        try dataContainer.encode(author, forKey: .author)
        try dataContainer.encode(title, forKey: .title)
        try dataContainer.encode(entryDate, forKey: .entryDate)
        try dataContainer.encode(thumbnail, forKey: .thumbnail)
        try dataContainer.encode(thumbnail, forKey: .thumbnail)
        try dataContainer.encode(comments, forKey: .comments)
        try dataContainer.encode(status.rawValue, forKey: .status)
        
        
    }
}
