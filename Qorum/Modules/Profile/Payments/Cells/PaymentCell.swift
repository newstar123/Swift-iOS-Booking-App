//
//  PaymentNibCell.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/27/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

final class PaymentCell: UITableViewCell {
    
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var checkmark: UIImageView!
    
    var cardNumber: String? {
        didSet {
            cardNumberLabel.text = cardNumber
        }
    }
    
    var cardImage: UIImage? {
        didSet {
            cardImageView.image = cardImage
        }
    }
    
    var isCardDefault: Bool? {
        didSet {
            checkmark.isHidden = !isCardDefault!
        }
    }
    
}
