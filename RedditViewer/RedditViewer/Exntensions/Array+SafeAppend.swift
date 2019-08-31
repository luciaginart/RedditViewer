//
//  Array+SafeAppend.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    mutating func rv_safeAppend(object: Iterator.Element?) {
        if let unwrappedObject = object {
            append(unwrappedObject)
        }
    }
    
    mutating func rv_safeAppend(array: [Iterator.Element]?) {
        if let unwrappedArray = array {
            append(contentsOf: unwrappedArray)
        }
    }
}
