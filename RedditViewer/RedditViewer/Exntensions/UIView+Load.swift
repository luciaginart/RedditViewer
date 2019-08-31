//
//  UIView+Load.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import UIKit

extension UIView {
    static func rv_loadNib() -> UINib? {
        return UINib(nibName: String(describing: self), bundle: Bundle.main)
    }
}
