//
//  MasterViewController.swift
//  RedditViewer
//
//  Created by Lucia Belen Ginart on 8/31/19.
//  Copyright © 2019 Lucia Belen Ginart. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    private var detailViewController: DetailViewController? = nil
    private var showPagingCell = true
    private var model: [RedditPost] = []
    lazy private var activityIndicatorView: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .gray)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailViewController()
        registerCells()
        configureRefreshControl()
        configureNotification()
        loadSavedModel()
        
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

// MARK: User defaults
extension MasterViewController {
    fileprivate func configureNotification() {
        NotificationCenter.default.addObserver(self, selector:#selector(saveModel), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    fileprivate func loadSavedModel() {
        model.rv_load()
    }
    
    @objc fileprivate func saveModel() {
        model.rv_save()
    }
}

// MARK: Service Caller
extension MasterViewController {
    fileprivate func fetchPosts(after name: String? = nil, refresh: Bool = false) {
        if !refresh {
            view.isUserInteractionEnabled = false
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
                
                if !refresh {
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicatorView.stopAnimating()
                }
                
                self.tableView.refreshControl?.endRefreshing()
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
            
            self.showPagingCell = self.model.count < 50
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
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        
        let deleteButton = UIButton(type: .custom)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteAllAction), for: .touchUpInside)
        deleteButton.setTitle("Dismiss All", for: .normal)
        deleteButton.setTitleColor(.orange, for: .normal)
        deleteButton.backgroundColor = .black
        
        stackView.addArrangedSubview(deleteButton)
        
        return stackView
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
    fileprivate func registerCells() {
        tableView.register(RedditLoadingTableViewCell.rv_loadNib(), forCellReuseIdentifier: "loading.identifier")
        tableView.register(RedditPostTableViewCell.rv_loadNib(), forCellReuseIdentifier: "reddit.post")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard !model.isEmpty else {
            return 0
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showPagingCell ? model.count + 1 : model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoadingCell(indexPath: indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loading.identifier", for: indexPath)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "reddit.post", for: indexPath) as? RedditPostTableViewCell else {
                return UITableViewCell()
            }
            
            cell.model = model[indexPath.row]
            cell.dismissActionClosure = { [weak self] cellModel in
                guard let self = self else {
                    return
                }
                
                guard let index = self.model.firstIndex(where: { (post) -> Bool in
                    guard let cellModel = cellModel else {
                        return false
                    }
                    
                    return cellModel.name == post.name
                }) else {
                    return
                }
                
                self.tableView.beginUpdates()
                
                self.model.remove(at: index)
                
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
                self.tableView.endUpdates()
            }
            
            return cell
        }
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard isLoadingCell(indexPath: indexPath) else {
            return
        }
        
        fetchPosts(after: model[indexPath.count - 1].name)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
    fileprivate func isLoadingCell(indexPath: IndexPath) -> Bool {
        guard showPagingCell else {
            return false
        }
        return indexPath.row == model.count
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
                var selectedModel = model[indexPath.row]
                
                controller.model = selectedModel
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                selectedModel.status = .read
                model[indexPath.row] = selectedModel
            }
        }
    }
}

