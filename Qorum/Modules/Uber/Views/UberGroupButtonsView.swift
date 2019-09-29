//
//  UberGroupButtonsView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 5/4/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit

class UberGroupButtonsView: UIScrollView {
    
    var selectedButtonTitle: String?
    var titlesList: [String] = []
    weak var pageController: UberTypesPageController?
    var uberClasses: [UberClass] = [] {
        didSet {
            addButtons(titles: uberClasses)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isScrollEnabled = false
        self.alpha = 0
    }

    func show() {
        UIView.animate(withDuration: 0.2) { 
            self.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
            self.contentOffset = CGPoint.zero
        }
    }
    
    func addButtons(titles: [UberClass]) {
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        titlesList = titles.map({ $0.name.rawValue.uppercased() })
        selectedButtonTitle = titlesList.first
        
        let buttonWidth = .deviceWidth/2
        var posX = (.deviceWidth/4)
        for title in titlesList {
            let butt = UIButton(frame: CGRect(x: posX, y: 0, width: buttonWidth, height: 26))
            butt.titleLabel?.font = UIFont.montserrat.medium(16)
            butt.setTitle(title, for: .normal)
            butt.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
            let isSelected = title == selectedButtonTitle
            butt.setTitleColor(isSelected ? .white : .gray, for: .normal)
            butt.titleLabel?.font = butt.titleLabel?.font.withSize( isSelected ? 16 : 14)
            self.addSubview(butt)
            
            posX += buttonWidth
        }
        
        self.contentSize = CGSize(width: posX + .deviceWidth/4, height: 26)
    }
    
    @IBAction func didTapButton(sender: UIButton) {
        guard sender.titleLabel?.text != selectedButtonTitle, uberClasses.count > 0 else { return }
        
        var isIncreasing = false
        let filtered = titlesList.filter({ $0 == sender.titleLabel?.text })
        if filtered.count > 0 {
            isIncreasing = (titlesList.index(of: selectedButtonTitle!))! < (titlesList.index(of: filtered.first!))!
            selectedButtonTitle = filtered.first!
        }
        
        let buttons: [UIButton] = subviews.filter({ $0 is UIButton }) as! [UIButton]
        if buttons.count > 0 {
            for button in buttons {
                let isSelected = button.titleLabel?.text == selectedButtonTitle
                button.setTitleColor(isSelected ? .white : .gray, for: .normal)
                button.titleLabel?.font = button.titleLabel?.font.withSize( isSelected ? 16 : 14)
            }
        }
        
        isIncreasing ? pageController?.next() : pageController?.prev()
        
        let duration = TimeInterval(UINavigationControllerHideShowBarDuration) + 0.6
        
        UIView.animate(withDuration: duration, animations: {
            let posX = (.deviceWidth/2) * CGFloat(self.titlesList.index(of: self.selectedButtonTitle!)!)
            self.contentOffset = CGPoint(x: posX, y: 0)
        }, completion: nil)
    }
    
    @IBAction func didSwipe(recognizer: UISwipeGestureRecognizer) {
        guard recognizer.state == .ended, (recognizer.direction == .left || recognizer.direction == .right), uberClasses.count > 0 else {
            return
        }
        
        if let currentInd = titlesList.index(of: selectedButtonTitle!), (currentInd > 0 && recognizer.direction == .right) || (currentInd < (titlesList.count - 1) && recognizer.direction == .left) {
            let butt = UIButton()
            butt.setTitle(titlesList[recognizer.direction == .left ? currentInd + 1 : currentInd - 1], for: .normal)
            self.didTapButton(sender: butt)
        }
        
    }
}
