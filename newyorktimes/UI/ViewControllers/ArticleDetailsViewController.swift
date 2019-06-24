//
//  ArticleDetailsViewController.swift
//  newyorktimes
//
//  Created by Michael Jester on 6/23/19.
//  Copyright © 2019 Michael Jester. All rights reserved.
//

import UIKit

struct ArticleDetailsConfigurator {
    
}

class ArticleDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var abstractLabel: UILabel!
    @IBOutlet weak var leadParagraphTextView: UITextView!
    @IBOutlet weak var webLinkTextView: UITextView!
    
    let article: Article
    
    init(article: Article) {
        self.article = article
        super.init(nibName: "ArticleDetailsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    private func setupUI() {
        abstractLabel.text = article.abstract
        leadParagraphTextView.text = article.lead_paragraph
        
        let multimedia: [ArticleImage] = article.multimedia
        let detailImage: ArticleImage? = multimedia.filter { $0.crop_name == "square320"}.first
        if let detailImageUrl = detailImage?.url {
            let baseUrlString = "https://www.nytimes.com/"
            imageView.downloadImageFromNetworkAtURL(url: baseUrlString + detailImageUrl)
        } else {
            imageView.image = UIImage(named: "ImageNotAvailable")
        }
        
        webLinkTextView.delegate = self
        webLinkTextView.dataDetectorTypes = .all
        if let webUrl = article.web_url {
            let displayString = "Click here for the full article"
            let attributedString = NSMutableAttributedString(string: displayString)
            attributedString.addAttribute(.link, value: webUrl, range: NSRange(location: 0, length: displayString.count))
            webLinkTextView.attributedText = attributedString
        }
    }

}


extension ArticleDetailsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}