//
//  DetailButton.swift
//  Button with title and detail, icon image and accessory image -- all nicely laid out, similar to UITableViewCell builtin styles.
//
//  Created by Yonat Sharon on 2016-05-24.
//

import UIKit

/// Button with UITableViewCellStyle layout including title, detail, icon, and accesorry.
class DetailButton: UIButton {
    let icon = UIImageView()
    let accessory = UIImageView()
    let title = UILabel()
    let detail = UILabel()

    var margin: CGFloat = 5 {
        didSet {
            layoutMargins = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
            iconToTitleConstraint?.constant = margin
        }
    }

    fileprivate var iconToTitleConstraint: NSLayoutConstraint?

    init(font: UIFont? = nil, detailFont: UIFont? = nil, title: String = "", detail: String = "", icon: UIImage? = nil, accessory: UIImage? = nil, style: UITableViewCellStyle = .subtitle) {
        super.init(frame: CGRect.zero)

        layoutMargins = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)

        setupIcon(image: icon)
        setupImageView(self.accessory, image: accessory, at: .trailingMargin)

        setupLabel(self.title, font: font, title: title, at: .centerY)
        setupLabel(self.detail, font: detailFont, title: detail, at: .centerY)
        self.detail.textAlignment = .right
        self.detail.numberOfLines = 0

        switch style {
        case .default:
            self.detail.removeFromSuperview()
            _ = constrain(self.title, at: .bottomMargin)
        case .subtitle:
            _ = constrain(self.icon, at: .bottom, diff: margin * -2)
            _ = constrain(self.icon, at: .top, diff: margin * 2)
            _ = constrain(self.icon, at: .leading, diff: 17)
            _ = self.icon.constrain(.width, to: 18)
            _ = constrain(self.detail, at: .trailing, diff: margin * -3)
        case .value1:
            _ = constrain(self.title, at: .bottomMargin)
            _ = constrain(self.detail, at: .topMargin)
            _ = constrain(self.detail, at: .trailing, to: self.accessory, at: .leading)
            _ = constrain(self.detail, at: .leading, to: self.title, at: .trailing, relation: .greaterThanOrEqual)
        case .value2:
            _ = constrain(self.title, at: .bottomMargin)
            _ = constrain(self.detail, at: .topMargin)
            _ = constrain(self.title, at: .width, ratio: 1.0/3.0)
            _ = constrain(self.detail, at: .leading, to: self.title, at: .trailing)
        }
        
        iconToTitleConstraint = constrain(self.title, at: .leading, to: self.icon, at: .trailing, diff: 17)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var tintColor: UIColor! {
        didSet {
            title.textColor = tintColor
            detail.textColor = tintColor
        }
    }
    
    fileprivate func setupIcon(image: UIImage?) {
        icon.image = image
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(icon)
        icon.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        icon.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        icon.layoutMargins = UIEdgeInsets.zero
    }

    fileprivate func setupImageView(_ imageView: UIImageView, image: UIImage?, at: NSLayoutAttribute) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        _ = addConstrainedSubview(imageView, constrain: .topMargin, .bottomMargin, at)
        imageView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        imageView.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        imageView.layoutMargins = UIEdgeInsets.zero
    }

    fileprivate func setupLabel(_ label: UILabel, font: UIFont?, title: String, at: NSLayoutAttribute) {
        label.text = title
        label.font = font
        label.textColor = tintColor
        _ = addConstrainedSubview(label, constrain: at)
        label.layoutMargins = UIEdgeInsets.zero
    }
}
