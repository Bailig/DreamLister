//
//  ItemTableViewCell.swift
//  DreamLister
//
//  Created by Bailig Abhanar on 2017-04-04.
//  Copyright © 2017 Bailig Abhanar. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func updateContent(item: Item) {
        priceLabel.text = "$\(item.price)"
        titleLabel.text = item.toItemDetail?.title
        detailLabel.text = item.toItemDetail?.detail
        thumbnailImage.image = item.toItemDetail?.image as? UIImage
    }
}
