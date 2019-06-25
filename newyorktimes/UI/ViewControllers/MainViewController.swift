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
        let navigationController = UINavigationController(rootViewController: articleListViewController)
        present(navigationController, animated: true)
    }
    
}

