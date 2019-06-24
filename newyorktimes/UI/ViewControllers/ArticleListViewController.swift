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
    
    
    private var articles: [Article] = []
    
    var currentPage : Int = 0
    var isLoadingList : Bool = false
    
    //MARK: - Lifecycle overrides
    
    init(articles: [Article]) {
        self.articles = articles
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }


    //MARK: - Initial Setup
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

}

//MARK: - UITableViewDataSource
extension ArticleListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let abstract = articles[indexPath.row].abstract
        let multimedia: [ArticleImage] = articles[indexPath.row].multimedia
        let articleImage: ArticleImage? = multimedia.filter { $0.crop_name == "thumbStandard"}.first
        let thumbnailImageUrl = articleImage?.url
        
        let articleCellConfig = ArticleCellConfigurator(abstract: abstract,
                                                        thumbNailImageUrl: thumbnailImageUrl)
        
        let reuseIdentifier = articleCellConfig.cellIdentifier
        
        let cell: ArticleTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! ArticleTableViewCell
        
        cell.configure(articleCellConfig)
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ArticleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: probably want to push a detail vc when user makes a selection
        //for now just animate the selection action
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension ArticleListViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.isLoadingList = true
            self.loadNextPageOfArticles()
        }
    }
    
    private func loadNextPageOfArticles() {
        currentPage += 1
        NetworkingManager.loadArticlesWithCompletion(pageNumber: currentPage) { [weak self] nextPageOfArticles in
            
            guard let self = self else { return }
            
            self.articles.append(contentsOf: nextPageOfArticles)
            self.isLoadingList = false
            self.tableView.reloadData()
        }
    }
}
