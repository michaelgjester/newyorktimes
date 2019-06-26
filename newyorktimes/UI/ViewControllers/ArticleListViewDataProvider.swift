//
//  ArticleListViewDataProvider.swift
//  newyorktimes
//
//  Created by Michael Jester on 6/25/19.
//  Copyright © 2019 Michael Jester. All rights reserved.
//

import Foundation
import UIKit

protocol ArticleListViewDataProviderDelegate: class {
    func articleListDidUpdate()
    func articleListFailedToUpdate(with error:Error)
}

protocol ArticleListViewDataProviderProtocol {

    func requestInitialArticleList()
    
    func requestNextPageOfArticles()
    
    func numberOfArticles() -> Int
    
    func configuratorForArticle(at indexPath: IndexPath) -> CellConfigurator?
    
    func didSelectArticle(at indexPath: IndexPath) -> Article
    
}

final class ArticleListViewDataProvider: NSObject {
    
    weak var delegate: ArticleListViewDataProviderDelegate?
    
    public let searchController = UISearchController(searchResultsController: nil)
    
    private(set) var isLoading: Bool = false
    //TODO: investigate using an enum for filtering/non-filtering state
    //rather than boolean flag
    private var isFiltering: Bool = false
    private var articles: [Article] = []
    private var filteredArticles: [Article] = []
    private var currentPage : Int = 0
}

extension ArticleListViewDataProvider: ArticleListViewDataProviderProtocol {
    
    func requestInitialArticleList() {
        NetworkingManager.loadArticlesWithCompletion { [weak self] (articles, error)  in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                print("error = \(error.localizedDescription)")
                strongSelf.delegate?.articleListFailedToUpdate(with: error)
                return
            }
            
            guard let articles = articles else {
                let error = NSError(domain: NetworkErrors.Domains.NYTimes, code: NetworkErrors.Codes.NilArticlesArrayCode, userInfo: [NetworkErrors.Keys.DescriptionKey : NetworkErrors.Descriptions.NilDataDescription])
                strongSelf.delegate?.articleListFailedToUpdate(with: error)
                return
            }
            
            strongSelf.articles = articles
            strongSelf.delegate?.articleListDidUpdate()
        }
        
    }
    
    func requestNextPageOfArticles() {
        
        currentPage += 1
        isLoading = true
        NetworkingManager.loadArticlesWithCompletion(pageNumber: currentPage) { [weak self] (nextPageOfArticles, error) in
            
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                print("error = \(error.localizedDescription)")
                self.delegate?.articleListFailedToUpdate(with: error)
                return
            }
            
            guard let nextPageOfArticles = nextPageOfArticles else {
                let error = NSError(domain: NetworkErrors.Domains.NYTimes, code: NetworkErrors.Codes.NilNextPageOfArticlesArrayCode, userInfo: [NetworkErrors.Keys.DescriptionKey : NetworkErrors.Descriptions.NilNextPageOfArticlesArrayDescription])
                self.delegate?.articleListFailedToUpdate(with: error)
                return
            }
            
            self.articles.append(contentsOf: nextPageOfArticles)
            self.delegate?.articleListDidUpdate()
        }
    }
    
    func numberOfArticles() -> Int {
        if isFiltering {
            return filteredArticles.count
        } else {
            return articles.count
        }
    }
    
    func configuratorForArticle(at indexPath: IndexPath) -> CellConfigurator? {
        
        let article: Article
        if isFiltering{
            article =  filteredArticles[indexPath.row]
        } else {
            article = articles[indexPath.row]
        }

        let abstract = article.abstract
        let multimedia: [ArticleImage] = article.multimedia
        let articleImage: ArticleImage? = multimedia.filter { $0.crop_name == "thumbStandard"}.first
        let thumbnailImageUrl = articleImage?.url
        
        let articleCellConfig = ArticleCellConfigurator(abstract: abstract,
                                                        thumbNailImageUrl: thumbnailImageUrl)
        
        return articleCellConfig
    }
 
    //TODO: make this protocol method help with the navigation flow
    //rather than just returning the Article object
    func didSelectArticle(at indexPath: IndexPath) -> Article {
        if isFiltering {
            return filteredArticles[indexPath.row]
        } else {
            return articles[indexPath.row]
        }
    }
}

// MARK: - UISearchBarDelegate
extension ArticleListViewDataProvider: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //do nothing
        //relying on 'textDidChange' method
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //set the filtering state and filteredArticles array
        //based upon the search term
        let searchTermLength = searchBar.text?.count ?? 0
        isFiltering = searchTermLength > 0
        filteredArticles = filteredArticlesBasedOnSearchBar(searchBar)
        
        //update the filtered results on each keystroke
        delegate?.articleListDidUpdate()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func filteredArticlesBasedOnSearchBar(_ searchBar: UISearchBar) -> [Article] {
        guard let searchText = searchBar.text else {
            //no filtering, just return unfiltered list
            return articles
        }
        
        let filteredArticles = articles.filter({( article : Article) -> Bool in
            return article.abstract?.lowercased().contains(searchText.lowercased()) ?? false
        })
        
        return filteredArticles
    }
    
}
