//
//  ArticleTableViewCell.swift
//  newyorktimes
//
//  Created by Michael Jester on 6/23/19.
//  Copyright © 2019 Michael Jester. All rights reserved.
//

import UIKit

struct ArticleCellConfigurator: CellConfigurator {
    let cellIdentifier: String = "ArticleTableViewCell"
    
    var abstract: String?
    var thumbNailImageUrl: String?
}

class ArticleTableViewCell: UITableViewCell, CellConfigurable {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var abstractLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - CellConfigurable
    func configure(_ configurator: CellConfigurator) {
    
        guard let config = configurator as? ArticleCellConfigurator else {
            return
        }
        
        abstractLabel.text = config.abstract ?? ""
        
        if let thumbnailImageUrlString = config.thumbNailImageUrl {
            let baseUrlString = "https://www.nytimes.com/"
            thumbnailImageView.downloadImageFromNetworkAtURL(url: baseUrlString + thumbnailImageUrlString)
        } else {
            thumbnailImageView.image = UIImage(named: "ImageNotAvailable")
        }
    }
}
