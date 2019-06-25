//
//  ArticleListViewController.swift
//  newyorktimes
//
//  Created by Michael Jester on 6/23/19.
//  Copyright © 2019 Michael Jester. All rights reserved.
//

import UIKit

class ArticleListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let dataProvider: ArticleListViewDataProvider
    private let articleCellReuseId = "ArticleTableViewCell"
    
    //MARK: - Initializers
    
    init(dataProvider: ArticleListViewDataProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupSearchBar()
        setupTableView()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataProvider.requestInitialArticleList()
    }

    //MARK: - Initial Setup
    
    private func setupNavBar() {
        title = "Politics"
    }
    
    private func setupSearchBar() {
        searchBar.delegate = dataProvider
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: articleCellReuseId, bundle: nil), forCellReuseIdentifier: articleCellReuseId)
        tableView.dataSource = self
        tableView.delegate = self
    }

}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension ArticleListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfArticles()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let articleCellConfig = dataProvider.configuratorForArticle(at: indexPath)
        
        //FIXME
        //should be a better way to grab the cellId
        let reuseIdentifier = articleCellConfig?.cellIdentifier ?? articleCellReuseId
        
        let cell: ArticleTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! ArticleTableViewCell
        
        if let config = articleCellConfig {
            cell.configure(config)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedArticle = dataProvider.didSelectArticle(at: indexPath)
        let articleDetailsViewController = ArticleDetailsViewController(article: selectedArticle)
        self.navigationController?.pushViewController(articleDetailsViewController, animated: true)
    }
    
}

// MARK: - UIScrollViewDelegate
extension ArticleListViewController: UIScrollViewDelegate {

    //used to enable infinite scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !dataProvider.isLoading){
            dataProvider.requestNextPageOfArticles()
        }
        
    }
}

// MARK: - ArticleListViewDataProviderDelegate
extension ArticleListViewController: ArticleListViewDataProviderDelegate {
    
    func articleListDidUpdate() {
        tableView.reloadData()
    }
}

