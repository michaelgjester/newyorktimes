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
        
        NetworkingManager.loadArticlesWithCompletion { (articles) in
            let articlesListViewController = ArticleListViewController(articles: articles)
            //self.navigationController?.pushViewController(articlesListViewController, animated: true)
            self.present(articlesListViewController, animated: true, completion: nil)
        }
    }


}

