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
        configureRefreshControl()
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
    fileprivate func fetchPosts(after name: String? = nil, refresh: Bool = false) {
        if model.isEmpty, !refresh {
            activityIndicatorView.startAnimating()
        }
        
        RedditAPIService.fetchPost(after: name) { [weak self] result in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.tableView.refreshControl?.endRefreshing()
                self.activityIndicatorView.stopAnimating()
            }
            
            switch result {
            case .success(let success):
                if refresh {
                    self.model = success.posts
                } else {
                    self.model.rv_safeAppend(array: success.posts)
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }

            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: Pull To Refresh
extension MasterViewController {
    fileprivate func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        
        tableView.refreshControl = refreshControl
    }
    
    @objc func refreshAction() {
        fetchPosts(refresh: true)
    }
}

// MARK: - Footer view
extension MasterViewController {
    fileprivate func createFooterView() -> UIView {
        let deleteButton = UIButton(type: .custom)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteAllAction), for: .touchUpInside)
        deleteButton.setTitle("Dismiss All", for: .normal)
        deleteButton.titleLabel?.textColor = .red
        deleteButton.backgroundColor = .black
        
        return deleteButton
    }
    
    @objc func deleteAllAction() {
        tableView.beginUpdates()
        model.removeAll()
        tableView.deleteSections(IndexSet(integer: 0), with: .left)
        tableView.endUpdates()
    }
}

// MARK: - Table View
extension MasterViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard !model.isEmpty else {
            return 0
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard !model.isEmpty else {
            return nil
        }
        
        return createFooterView()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard !model.isEmpty else {
            return 0
        }
        
        return UITableView.automaticDimension
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

