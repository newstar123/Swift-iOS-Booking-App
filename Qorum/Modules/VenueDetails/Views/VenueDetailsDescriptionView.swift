//
//  VenueDetailsDescriptionView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 2/6/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import SnapKit

class VenueDetailsDescriptionView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var rows: [String] = []
    
    func fill(_ strings: [String]) {
        rows = strings
        pageControl.numberOfPages = rows.count
        
        for (ind, text) in rows.enumerated() {
            let textLabel = UILabel(font: UIFont.montserrat.regular(14))
            textLabel.textColor = .white
            textLabel.text = text
            textLabel.textAlignment = .left
            textLabel.numberOfLines = 0
            textLabel.baselineAdjustment = .none
            textLabel.isUserInteractionEnabled = false
            
            let container = UIView()
            container.backgroundColor = .clear
            container.addSubview(textLabel)
            container.isUserInteractionEnabled = false
            container.alpha = ind == 0 ? 1 : 0.5
            
            textLabel.snp.makeConstraints({ (make) in
                make.top.left.equalTo(container)
                make.right.equalTo(container.snp.right).offset(-32)
                make.bottom.greaterThanOrEqualTo(container)
            })
            
            scrollView.addSubview(container)
            let containerWidth = .deviceWidth - 60
            container.snp.makeConstraints({ (make) in
                make.width.equalTo(scrollView.snp.width).offset(-45)
                make.top.bottom.equalTo(scrollView)
                make.left.equalTo(scrollView.snp.left).offset(CGFloat(ind) * (containerWidth))
            })
            
            let lblHeight = textLabel.sizeThatFits(CGSize(width: containerWidth - 32, height: 1000)).height
            if scrollViewHeight.constant < lblHeight {
                scrollViewHeight.constant = lblHeight
            }
        }
    }
    
    func updateContentSize() {
        let contentWidth: CGFloat = 45.0 + CGFloat(rows.count) * (scrollView.width - 45.0)
        scrollView.contentSize = CGSize(width: contentWidth,
                                        height: scrollViewHeight.constant)
    }
    
    func animate(to page: Int) {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.scrollView.subviews.forEach({ $0.alpha = 0.5 })
            self.scrollView.subviews[page].alpha = 1
            let contentWidth: CGFloat = self.scrollView.width - 45
            self.scrollView.contentOffset = CGPoint(x: contentWidth * CGFloat(page), y: 0)
        }, completion: { (completed) in
            self.pageControl.currentPage = page
        })
    }

    //MARK: - Actions
    @IBAction func didSwipeLeft() {
        let page = pageControl.currentPage + 1
        if page < pageControl.numberOfPages && page >= 0 {
            animate(to: page)
        }
    }
    
    @IBAction func didSwipeRight() {
        let page = pageControl.currentPage - 1
        if page < pageControl.numberOfPages && page >= 0 {
            animate(to: page)
        }
    }
    
    @IBAction func pageControlDidChange() {
        let page = pageControl.currentPage
        if page < pageControl.numberOfPages && page >= 0 {
            animate(to: page)
        }
    }
}
