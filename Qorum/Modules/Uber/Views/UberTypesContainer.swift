//
//  UberTypesContainer.swift
//  Qorum
//
//  Created by Vadym Riznychok on 4/18/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit

class UberTypesContainer: UIViewController {

    //MARK: - Properties
    var types: [UberType] = []
    var typeViews: [UberTypeView] = [UberTypeView]()
    var selectedType: UberType?
    weak var controller: UberTypesPageController?
    var discountValue: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        //@uber_pool_fix (search tag)
        let totalWidth: CGFloat = CGFloat(110 * types.filter({ !$0.name.lowercased().contains("pool1") }).count)
        var posX = CGFloat(.deviceWidth - totalWidth)/CGFloat(2)
        
        for type in types {
            //@uber_pool_fix (search tag)
            if type.name.lowercased().contains("pool1") { continue }
            
            let typeView = UberTypeView.fromNib() as UberTypeView
            typeView.discountAmount = discountValue
            typeView.container = self
            typeView.type = type
            typeView.frame = CGRect(x: posX, y: 0, width: 110, height: view.frame.size.height)
            typeView.backgroundColor = .clear
            typeView.deselectType()
            typeViews.append(typeView)
            self.view.addSubview(typeView)
            
            posX += 110
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareToShow() {
        typeViews.forEach({ $0.prepareToShow() })
    }
    
    func show() {
        typeViews.forEach({ $0.show()})
    }
    
    func hide() {
        typeViews.forEach({ $0.hide()})
    }
    
    func animateAppearance() {
        typeViews.forEach({ $0.animateAppearance()})
        if self.types.count > 0 {
            self.perform(#selector(didSelect(type:)), with: self.types.first, afterDelay: 0.8)
        }
    }
    
    func willAnimate(toLeft: Bool) {
        toLeft ? typeViews.forEach({ $0.prepareLeft()}) : typeViews.forEach({ $0.prepareRight()})
    }
    
    @objc func didSelect(type: UberType) {
        self.controller?.didSelectType(type: type)
        guard type != selectedType else { return }
        
        typeViews.forEach({
            if $0.type != type {
                $0.deselectType()
            } else {
                $0.selectType()
            }
        })
        selectedType = type
    }
    
    func deselectAll() {
        selectedType = nil
        typeViews.forEach({
            $0.deselectType()
        })
    }

}
