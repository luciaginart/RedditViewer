//
//  DetailViewController.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel! //FIXME: (Lucy) borrar

    var model: RedditPost? {
        didSet {
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {
        //FIXME: (Lucy) implementar
    }

}

