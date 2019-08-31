//
//  RedditPostTableViewCell.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import UIKit

class RedditPostTableViewCell: UITableViewCell {
    typealias onDismissButtonActionAlias = (RedditPost?) -> Void

    @IBOutlet fileprivate weak var readStatusView: UIView!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var postImage: UIImageView!
    @IBOutlet fileprivate weak var authorLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var dismissButton: UIButton!
    @IBOutlet fileprivate weak var commentLabel: UILabel!
    
    var dismissActionClosure: onDismissButtonActionAlias?
    
    var model: RedditPost? {
        didSet {
            configureView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        readStatusView.layer.cornerRadius = readStatusView.frame.size.width/2
        readStatusView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            readStatusView.isHidden = true
        }
    }
    
    @IBAction fileprivate func dismissAction(_ sender: Any) {
        dismissActionClosure?(model)
    }
    
    fileprivate func configureView() {
        guard let model = model else {
            return
        }
        
        readStatusView.isHidden = model.status == .read
        dateLabel.text = Date(timeIntervalSince1970: model.entryDate).rv_timeAgoSinceDate()
        
        if let url = model.thumbnail {
            postImage.downloaded(from: url)
        } else {
            postImage.isHidden = true
        }
        
        authorLabel.text = model.author
        titleLabel.text = model.title
        
        if let comments = model.comments {
            commentLabel.text = String(comments) + " comments"
        }
    }
}
