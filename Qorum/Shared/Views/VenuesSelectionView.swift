//
//  VenuesSelectionView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 9/29/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

protocol VenuesSelectionViewDelegate {
    func selectControllerAtIndex(index: Int, completion:@escaping () -> Void)
}

class VenuesSelectionView: UIView {
    
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var buttonUnderlineX: NSLayoutConstraint!
    
    var delegate: VenuesSelectionViewDelegate?
    
    /// width of button
    var buttonWidth: CGFloat = 0.0
    
    /// defines buttonUnderline view padding
    let pagging: CGFloat = 15
    
    /// currently selected index
    var selectedIndex = 0 {
        didSet {
            buttonUnderlineX.constant = (CGFloat(selectedIndex) * (buttonWidth) + pagging)
            (self.buttonsStack.arrangedSubviews as! [UIButton]).forEach({
                if self.buttonsStack.arrangedSubviews.index(of: $0) == selectedIndex {
                    $0.setTitleColor(UIColor(white: 1, alpha: 1), for: UIControlState())
                } else {
                    $0.setTitleColor(UIColor(white: 1, alpha: 0.5), for: UIControlState())
                }
            })
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buttonWidth = (buttonsStack.frame.size.width / CGFloat(buttonsStack.arrangedSubviews.count))
    }
    
    /// Setups view with titles and delegate
    ///
    /// - Parameters:
    ///   - titles: titles for buttons
    ///   - delegate: delegate to receive callback
    func configureWithTitles(titles: [String], delegate: VenuesSelectionViewDelegate) {
        self.delegate = delegate
        self.buttonsStack.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        for title in titles {
            let button = UIButton(type: .custom)
            button.setTitle(title.uppercased(), for: .normal)
            button.backgroundColor = .clear
            button.titleLabel?.font = UIFont.montserrat.medium(14)
            button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: UIControlState())
            if titles.index(of: title) == 0 {
                button.setTitleColor(UIColor(white: 1, alpha: 1), for: UIControlState())
            }
            button.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
            self.buttonsStack.addArrangedSubview(button)
        }
        
        buttonWidth = (buttonsStack.frame.size.width / CGFloat(buttonsStack.arrangedSubviews.count))
        buttonUnderlineX.constant = pagging
    }
    
    @IBAction func didTapButton(sender: UIButton) {
        let ind = buttonsStack.arrangedSubviews.index(of: sender)!
        guard ind != self.selectedIndex else {
            return
        }
        
        enableButtons(enable: false)
        
        self.delegate?.selectControllerAtIndex(index: ind, completion: {
            self.enableButtons(enable: true)
        })
        self.selectedIndex = ind
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    /// Enables/disables buttons
    ///
    /// - Parameter enable: enable state
    func enableButtons(enable: Bool) {
        guard (self.buttonsStack.arrangedSubviews.first as? UIButton)?.isEnabled != enable else {
            return
        }
        
        (self.buttonsStack.arrangedSubviews as! [UIButton]).forEach({ $0.isEnabled = enable })
    }

}

// MARK: - UIScrollViewDelegate
extension VenuesSelectionView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.frame.size.width - scrollView.contentOffset.x
        let scrollViewWidthMultiplier = (scrollView.frame.size.width - 30) / scrollView.frame.size.width
        buttonUnderlineX.constant = (CGFloat(selectedIndex) * buttonWidth) + ((offsetY * -1 * (scrollViewWidthMultiplier)) / CGFloat(buttonsStack.arrangedSubviews.count)) + pagging
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        enableButtons(enable: false)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            enableButtons(enable: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        enableButtons(enable: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        enableButtons(enable: true)
    }
    
}
