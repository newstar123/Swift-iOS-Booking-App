//
//  UberProductCell.swift
//  Qorum
//
//  Created by Dima Tsurkan on 2/21/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import Foundation
import SDWebImage

class UberProductCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(iconBackground)
        iconBackground.addSubview(productIcon)
        self.addSubview(productName)
        self.addSubview(estimateLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    lazy var iconBackground: UIView = {
        let view = UIView(frame: CGRect(x: 10.0, y: 21, width: 65, height: 65))
        view.layer.cornerRadius = 65.0/2.0
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 214/255.0, green: 214/255.0, blue: 213/255.0, alpha: 1.0)
        return view
    }()

    lazy var productIcon: UIImageView = {
        let imgView = UIImageView(frame: CGRect(x: 12.5, y: 22.5, width: 40, height: 20))
        imgView.tintColor = .white
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()

    lazy var productName: UILabel = {
        let label = UILabel(frame: CGRect(x: 10.0, y: 91, width: 64, height: 20))
        label.textColor = .black
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        label.text = "uberXL"
        label.textAlignment = .center
        return label
    }()

    lazy var estimateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 10.0, y: 111, width: self.frame.width - 20, height: 20))
        label.textColor = .gray
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.text = "$22-28"
        label.textAlignment = .center
        return label
    }()

    override var isSelected: Bool {
        didSet {
            if isSelected {
                iconBackground.backgroundColor = UIColor(red: 18/255.0, green: 147/255.0, blue: 154/255.0, alpha: 1.0)
                productName.textColor = UIColor(red: 18/255.0, green: 147/255.0, blue: 154/255.0, alpha: 1.0)
            } else {
                iconBackground.backgroundColor = UIColor(red: 214/255.0, green: 214/255.0, blue: 213/255.0, alpha: 1.0)
                productName.textColor = .black
            }
        }
    }

    func updateProduct(icon: UIImage) {
        productIcon.image = icon.withRenderingMode(.alwaysTemplate)
    }

    func updateProduct(imageURL url: String?, name: String?) {
        if let icon_url = URL(string: url!) {
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: icon_url, options: [], progress: nil, completed: { (image, data, error, finished) in
                DispatchQueue.main.async {
                    self.productIcon.image = image?.withRenderingMode(.alwaysTemplate)
                }
            })
        }

        if let name = name {
            productName.text = name
        }
    }


    func adjustWithEstimate(_ uberEstimate: UberEstimate?) {
        if let price = uberEstimate?.priceRange /*, hasLocation */ {
                estimateLabel.text = price
        }
    }

}
