//
//  MainViewController.swift
//  newyorktimes
//
//  Created by Michael Jester on 6/23/19.
//  Copyright © 2019 Michael Jester. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    let dataProvider = ArticleListViewDataProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //TODO:
        //this is just a mechanism to display a logo while
        //the initial load is occurring; probably could move
        //this into the ArticleListViewController and use
        //child VCs/loadIndicatorViews etc.
        dataProvider.delegate = self
        dataProvider.requestInitialArticleList()
    }
    
}

extension MainViewController: ArticleListViewDataProviderDelegate {
    func articleListDidUpdate() {
        
        let articleListViewController = ArticleListViewController(dataProvider: dataProvider)
        dataProvider.delegate = articleListViewController
        let navigationController = UINavigationController(rootViewController: articleListViewController)
        present(navigationController, animated: true)
    }
}

