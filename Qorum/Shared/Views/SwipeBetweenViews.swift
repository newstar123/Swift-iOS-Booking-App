//
//  SwipeBetweenViews.swift
//  Qorum
//
//  Created by Michael Wilson on 9/14/15.
//  Copyright © 2015 Qorum. All rights reserved.
//
//  Based on pod 'RKSwipeBetweenViewControllers'
//

import UIKit

class SwipeBetweenViews: UIView, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate {

    let selectionBar = UIView()
    var viewControllerArray:[UIViewController] = []
    var buttonTextArray:[String] = []
    var currentPage = 0
    var pageViewController:UIPageViewController!
    var isScrolling = false
    var viewControllersLoaded = false
    var scrollview:UIScrollView!
    var isAsset = false
    
    override init(frame: CGRect) { //Frame should be approx. screen_width x 100
        super.init(frame: frame)

        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func adjustWithPageViewController() {
        for (i, controller) in viewControllerArray.enumerated() {
            controller.view.clipsToBounds = false
            let button = UIButton(frame: CGRect(x: CGFloat(i)*self.width/CGFloat(viewControllerArray.count), y: 0, width: self.width/CGFloat(viewControllerArray.count), height: 18))
            button.tag = i
            button.backgroundColor = .clear
            button.titleLabel?.font = UIFont.montserrat.medium(14)

            button.addTarget(self, action: #selector(tappedButton(_:)), for: .touchUpInside)

            button.setTitle(buttonTextArray[i], for: UIControlState())
            button.setTitleColor(.white, for: .selected)
            button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: UIControlState())
            if i == 0 {
                button.isSelected = true
                button.setTitleColor(UIColor(white: 1, alpha: 1), for: .highlighted)
            }
            else {
                button.isSelected = false
                button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .highlighted)
            }
            self.addSubview(button)
        }
        
        selectionBar.frame = CGRect(x: 0, y: 19, width: self.width/CGFloat(viewControllerArray.count), height: 9)
        selectionBar.backgroundColor = .clear

        if isAsset {
            let imgView = UIImageView(image: UIImage(named: "menu_underscore"))
            imgView.frame = CGRect(x: 0, y: 0, width: selectionBar.width, height: 9)
            imgView.contentMode = .scaleAspectFill
            imgView.clipsToBounds = true
            selectionBar.addSubview(imgView)
        } else {
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: selectionBar.width, height: 1))
            backgroundView.backgroundColor = UIColor.barSelectorColor
            let triangle = TriangleUpView(frame: CGRect(x: (selectionBar.width - 12)/2.0, y: -5, width: 12, height: 6))

            selectionBar.addSubview(backgroundView)
            selectionBar.addSubview(triangle)
        }
        self.addSubview(selectionBar)

        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers([viewControllerArray[0]],
                                              direction: .forward,
                                              animated: true)
        let pageScrollView = pageViewController.view.subviews.find(UIScrollView.self)
        scrollview = pageScrollView
        scrollview.delegate = self
    }

    @objc func tappedButton(_ button: UIButton) {
        switchPage(button.tag)
        if let pageViewController = pageViewController as? TipFeaturesHoursController {
            pageViewController.adjustOffsets(button.tag, animated: true)
        }
    }
    
    func switchPage(_ pageNumber: Int) {
        if !isScrolling {
            let index = currentPage
            if pageNumber > index {
                for i in index+1 ... pageNumber {
                    let animateTo = i
                    pageViewController.setViewControllers([viewControllerArray[i]], direction: .forward, animated: true, completion: {(finished:Bool) -> Void in
                        if finished {
                            self.updateCurrentPage(animateTo)
                        }
                    })
                }
            }
            else if pageNumber < index {
                for i in (pageNumber ... index-1).reversed() {
                    let animateTo = i
                    pageViewController.setViewControllers([viewControllerArray[i]], direction: .reverse, animated: true, completion: {(finished:Bool) -> Void in
                        if finished {
                            self.updateCurrentPage(animateTo)
                        }
                    })
                }
            }
        }
    }

    func updateCurrentPage(_ index: Int) {
        currentPage = index
        for subview in self.subviews {
            if subview.isKind(of: UIButton.self) {
                let button = subview as! UIButton
                if button.tag == currentPage {
                    button.isSelected = true
                    button.setTitleColor(UIColor(white: 1, alpha: 1), for: .highlighted)
                }
                else {
                    button.isSelected = false
                    button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .highlighted)
                }
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centerOffset = self.width - scrollView.contentOffset.x
        let xOffset = selectionBar.width*CGFloat(currentPage)
        selectionBar.x = xOffset-centerOffset/CGFloat(viewControllerArray.count)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = viewControllerArray.index(of: viewController)
        if index == NSNotFound || index == 0 {
            return nil
        }
        return viewControllerArray[index!-1]
    }


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = viewControllerArray.index(of: viewController)
        if index == NSNotFound {
            return nil
        }
        else if index!+1 == viewControllerArray.count {
            return nil
        }
        return viewControllerArray[index!+1]
    }
    

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

        if let controller = pendingViewControllers.first, let next = viewControllerArray.index(of: controller) {
            // adjust offsets for pending
            let tipFeatures = pageViewController as? TipFeaturesHoursController
            tipFeatures?.adjustOffsets(next, animated: true)
        }
        if let next = viewControllerArray.index(of: pendingViewControllers.first!) {
            if let pageViewController = pageViewController as? TipFeaturesHoursController {
                pageViewController.adjustOffsets(next, animated: true)
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let last = pageViewController.viewControllers?.last {
                if let index = viewControllerArray.index(of: last) {
                    self.updateCurrentPage(index)
                }
            }
        } else {
            // adjusted offsets for pending useless, rollback them
            if let controller = previousViewControllers.first, let current = viewControllerArray.index(of: controller) {
                let tipFeatures = pageViewController as? TipFeaturesHoursController
                tipFeatures?.adjustOffsets(current, animated: true)
            }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }
}
