//
//  UberTypesPageController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 4/18/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit

class UberTypesPageController: UIPageViewController {
    
    var uberClasses: [UberClass] = [] {
        didSet {
            setupControllers()
        }
    }
    var typeContainers: [UberTypesContainer] = []
    weak var uberController: UberOrderViewController?
    var selectedType: UberType?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupControllers() {
        typeContainers.removeAll()
        selectedType = nil
        
        for uberClass in uberClasses {
            let vc = UberTypesContainer()
            vc.discountValue = Double(uberController?.checkin?.uberDiscountValue ?? 0)
            vc.types = uberClass.types
            vc.controller = self
            typeContainers.append(vc)
        }
        
        if typeContainers.count > 0 {
            typeContainers.first!.willAnimate(toLeft: true)
            self.setViewControllers([typeContainers.first!], direction: .forward, animated: false, completion: { (completed) in
                self.typeContainers.first!.prepareToShow()
                self.typeContainers.first!.animateAppearance()
            })
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.2) { 
            self.typeContainers.first?.show()
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2) {
            self.typeContainers.forEach({ $0.hide() })
        }
    }
    
    func next() {
        if let index = typeContainers.index(of: viewControllers!.first as! UberTypesContainer), index < typeContainers.count - 1 {
            typeContainers[index + 1].willAnimate(toLeft: true)
            self.setViewControllers([typeContainers[index + 1]], direction: .forward, animated: true, completion: { (completed) in
                self.typeContainers[index + 1].animateAppearance()
            })
        }
    }
    
    func prev() {
        if let index = typeContainers.index(of: viewControllers!.first as! UberTypesContainer), index > 0 {
            typeContainers[index - 1].willAnimate(toLeft: false)
            self.setViewControllers([typeContainers[index - 1]], direction: .reverse, animated: true, completion: { (completed) in
                self.typeContainers[index - 1].animateAppearance()
            })
        }
    }
    
    func didSelectType(type: UberType) {
        guard selectedType != type else {
            uberController?.showTypeDetails(type: selectedType!)
            return
        }
        selectedType = type
        uberController?.selectUber(type: type)
        let containers: [UberTypesContainer] = typeContainers.filter({ $0 != viewControllers?.first })
        containers.forEach({ $0.deselectAll() })
    }
    
    func selectedView() -> UIImageView {
        let selectedContainer = viewControllers?.first as! UberTypesContainer
        let typeView = selectedContainer.typeViews.filter({ $0.type == selectedType })
        if typeView.count > 0 {
            return typeView.first?.image ?? UIImageView()
        }
        
        return UIImageView()
    }
    
}
