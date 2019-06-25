//
//  ArticleListViewDataProvider.swift
//  newyorktimes
//
//  Created by Michael Jester on 6/25/19.
//  Copyright © 2019 Michael Jester. All rights reserved.
//

import Foundation

protocol ArticleListViewDataProviderDelegate: class {
    func articleListDidUpdate()
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
    
    
    private(set) var isLoading: Bool = false
    private var articles: [Article] = []
    private var currentPage : Int = 0
}

extension ArticleListViewDataProvider: ArticleListViewDataProviderProtocol {
    
    func requestInitialArticleList() {
        NetworkingManager.loadArticlesWithCompletion { [weak self] (articles) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.articles = articles
        
            strongSelf.delegate?.articleListDidUpdate()
        }
        
    }
    
    func requestNextPageOfArticles() {
        
        currentPage += 1
        isLoading = true
        NetworkingManager.loadArticlesWithCompletion(pageNumber: currentPage) { [weak self] nextPageOfArticles in
            
            guard let self = self else { return }
            
            self.articles.append(contentsOf: nextPageOfArticles)
            //self.isLoadingList = false
            //self.tableView.reloadData()
            self.isLoading = false
            self.delegate?.articleListDidUpdate()
        }
    }
    
    func numberOfArticles() -> Int {
        return articles.count
    }
    
    func configuratorForArticle(at indexPath: IndexPath) -> CellConfigurator? {
        
        let article: Article
//        if isFiltering(){
//            article =  filteredArticlesBasedOnSearchBar()[indexPath.row]
//        } else {
//            article = articles[indexPath.row]
//        }
        article = articles[indexPath.row]
        
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
        return articles[indexPath.row]
    }
}
