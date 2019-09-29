//
//  OnboardingContainerViewController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 9/26/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import SnapKit

class OnboardingContainerViewController: UIViewController {
    
    let data: Onboarding.Data.ViewModel.DisplayData?
    
    lazy var titleLbl: UILabel = {
        let view = UILabel()
        view.font = UIFont.montserrat.semibold(26)
        view.numberOfLines = 1
        view.minimumScaleFactor = 0.1
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = .center
        view.textColor = .white
        self.view.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.top.equalTo(55)
            make.height.equalTo(40)
        })
        return view
    }()
    
    lazy var subtitleLbl: UILabel = {
        let view = UILabel()
        view.font = UIFont.montserrat.light(16)
        view.numberOfLines = 2
        view.minimumScaleFactor = 0.1
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = .center
        view.textColor = .white
        self.view.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.top.equalTo(titleLbl.snp.bottom)
            make.height.equalTo(80)
        })
        view.sizeToFit()
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        self.view.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.top.equalTo(self.subtitleLbl.snp.bottom)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.bottom.equalTo(-90)
        })
        return view
    }()
    
    init(data: Onboarding.Data.ViewModel.DisplayData) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
        self.titleLbl.text = data.title
        self.subtitleLbl.text = data.subTitle
        self.imageView.image = data.image
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.data = nil
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .baseViewBackgroundColor
    }
}
