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
    private var currentPage : Int = 0
    private var isLoadingList : Bool = false
    
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

        setupSearchBar()
        setupTableView()
    }


    //MARK: - Initial Setup
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }

}

//MARK: - UITableViewDataSource
extension ArticleListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredArticlesBasedOnSearchBar().count
        } else {
            return articles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let article: Article
        if isFiltering(){
            article =  filteredArticlesBasedOnSearchBar()[indexPath.row]
        } else {
            article = articles[indexPath.row]
        }
        
        let abstract = article.abstract
        let multimedia: [ArticleImage] = article.multimedia
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
        tableView.deselectRow(at: indexPath, animated: true)
        let articleDetailsViewController = ArticleDetailsViewController(article: articles[indexPath.row])
        self.navigationController?.pushViewController(articleDetailsViewController, animated: true)
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


// MARK: - UISearchBarDelegate
extension ArticleListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //do nothing
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //update the filtered results on each keystroke
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func filteredArticlesBasedOnSearchBar() -> [Article] {
        guard let searchText = searchBar.text else {
            //no filtering, just return unfiltered list
            return articles
        }
        
        let filteredArticles = articles.filter({( article : Article) -> Bool in
            return article.abstract?.lowercased().contains(searchText.lowercased()) ?? false
        })
        
        return filteredArticles
    }
    
    private func isFiltering() -> Bool {
        let searchTermLength = searchBar.text?.count ?? 0
        return searchTermLength > 0
    }
}
