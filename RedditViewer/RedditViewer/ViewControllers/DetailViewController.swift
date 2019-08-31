//
//  DetailViewController.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!

    var model: RedditPost? {
        didSet {
            if isViewLoaded {
                configureView()
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {
        guard isViewLoaded else {
            return
        }
        
        if let url = model?.thumbnail {
            postImage.downloaded(from: url)
        } else {
            postImage.isHidden = true
        }
        
        descriptionLabel.text = model?.title
    }

    @IBAction func saveAction(_ sender: Any) {
        //FIXME (Lucy) save to library
    }
}

