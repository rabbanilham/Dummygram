//
//  FeedSharer.swift
//  Dummygram
//
//  Created by Bagas Ilham on 21/05/22.
//

import Foundation
import UIKit
import Kingfisher
import LinkPresentation

struct FeedSharer {
    
    static func share(
        in viewController: UIViewController,
        feedCaption: String,
        feedOwner: String,
        feedImageUrlString: String
    ) {

        let feedToShare: [Any] = [
            ActivityItemSource(title: feedCaption, text: feedOwner, imageUrl: feedImageUrlString),
            URL(string: feedImageUrlString)!
        ]
        
        let activityViewController = UIActivityViewController(activityItems: feedToShare, applicationActivities: nil)
    
    viewController.present(activityViewController, animated: true, completion: nil)
  }
  
}

class ActivityItemSource: NSObject, UIActivityItemSource {
    var title: String
    var text: String
    var imageUrl: String
    
    init(title: String, text: String, imageUrl: String) {
        self.title = title
        self.text = text
        self.imageUrl = imageUrl
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        let image = UIImageView()
        image.kf.setImage(with: URL(string: imageUrl))
        metadata.title = title
        metadata.iconProvider = NSItemProvider(object: image.image!)
        metadata.originalURL = URL(fileURLWithPath: text)
        return metadata
    }

}
