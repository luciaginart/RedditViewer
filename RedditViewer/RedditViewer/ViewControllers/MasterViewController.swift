//
//  MasterViewController.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    var detailViewController: DetailViewController? = nil
    var model: [RedditPost] = []
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .gray)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailViewController()
        if model.isEmpty {
            tableView.backgroundView = activityIndicatorView
            fetchPosts()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let splitViewController = splitViewController {
            clearsSelectionOnViewWillAppear = splitViewController.isCollapsed
        }
    }
}

// MARK: - Service Caller
extension MasterViewController {
    fileprivate func fetchPosts(after name: String? = nil) {
        if model.isEmpty {
            activityIndicatorView.startAnimating()
        }
        
        RedditAPIService.fetchPost(after: name) { [weak self] result in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicatorView.stopAnimating()
            }
            
            switch result {
            case .success(let success):
                self.model.rv_safeAppend(array: success.posts)
                
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }

            case .failure(let error):
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}


// MARK: - Table View
extension MasterViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        return cell
    }
}

// MARK: SplitViewController
extension MasterViewController {
    fileprivate func configureDetailViewController() {
        guard let split = splitViewController else {
            return
        }
        
        let controllers = split.viewControllers
        detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
}

// MARK: - Segues
extension MasterViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.model = model[indexPath.row]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

