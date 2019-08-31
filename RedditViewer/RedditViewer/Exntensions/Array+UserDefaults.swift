//
//  Array+Save.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import Foundation

extension Array where Element == RedditPost {
    mutating func rv_load() {
        guard let elements = UserDefaults.standard.object(forKey: "reddit.post.key") as? Data  else {
            self = []
            return
        }
        let decoder = JSONDecoder()
        self = (try? decoder.decode([Element].self, from: elements)) ?? []
    }
    
    func rv_save() {
        guard let encoded = try? JSONEncoder().encode(self) else {
            return
        }
        
        UserDefaults.standard.set(encoded, forKey: "reddit.post.key")
        UserDefaults.standard.synchronize()
    }
}
