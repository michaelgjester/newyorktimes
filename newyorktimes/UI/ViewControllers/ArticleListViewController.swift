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
    
    private let dataProvider: ArticleListViewDataProvider
    private let articleCellReuseId = "ArticleTableViewCell"
    
    //MARK: - Initializers
    
    init(dataProvider: ArticleListViewDataProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    /*
    init(articles: [Article]) {
        self.articles = articles
        
        super.init(nibName: nil, bundle: nil)
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupTableView()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataProvider.requestInitialArticleList()
    }


    //MARK: - Initial Setup
    
    private func setupSearchBar() {
        searchBar.delegate = self
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
        /*
        if isFiltering() {
            return filteredArticlesBasedOnSearchBar().count
        } else {
            return articles.count
        }
        */
        return dataProvider.numberOfArticles()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*
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
        */
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !dataProvider.isLoading){
            dataProvider.requestNextPageOfArticles()
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

extension ArticleListViewController: ArticleListViewDataProviderDelegate {
    
    func articleListDidUpdate() {
        tableView.reloadData()
    }
}
