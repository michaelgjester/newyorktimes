//
//  MainViewController.swift
//  newyorktimes
//
//  Created by Michael Jester on 6/23/19.
//  Copyright © 2019 Michael Jester. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let dataProvider = ArticleListViewDataProvider()
        
        let articleListViewController = ArticleListViewController(dataProvider: dataProvider)
        dataProvider.delegate = articleListViewController
        self.navigationController?.pushViewController(articleListViewController, animated: true)
//        self.navigationController?.pushViewController(ArticleListViewController, animated: true)
//
        /*
        NetworkingManager.loadArticlesWithCompletion { (articles) in
            let articlesListViewController = ArticleListViewController(articles: articles)
            self.navigationController?.pushViewController(articlesListViewController, animated: true)
            //self.present(articlesListViewController, animated: true, completion: nil)
        }
        */
    }


}

