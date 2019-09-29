//
//  NoConnectionViewController.swift
//  Qorum
//
//  Created by Sergey Sivak on 2/2/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

class NoConnectionViewController: BaseViewController {
    
    override var backgroundStyle: BaseViewController.BackgroundAppearance {
        return .cityImage(qorumLogo: true)
    }
    
    override func reachabilityChanged(notification: Notification) {
        // do nothing here
    }
    
    /**
     * Presents Blocking screen if there is no Internet connection.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let noConnectionIcon = UIImageView(image: #imageLiteral(resourceName: "wifi-off"))
        view.addSubview(noConnectionIcon)
        
        let noConnectionLabel = UILabel()
        noConnectionLabel.font = UIFont.montserrat.regular(14)
        noConnectionLabel.numberOfLines = 4
        noConnectionLabel.textColor = #colorLiteral(red: 0.5098039216, green: 0.5254901961, blue: 0.568627451, alpha: 1)
        noConnectionLabel.textAlignment = .center
        noConnectionLabel.text = "Headsup: Your device is not connected to the\ninternet. Please check your cell phone\nsignal and/or wi-fi connection to\ncontinue using Qorum."
        view.addSubview(noConnectionLabel)

        noConnectionIcon.snp.makeConstraints { (make) in
            make.width.height.equalTo(44)
            make.centerY.equalTo(view.snp.centerY)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        noConnectionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(noConnectionIcon.snp.bottom).offset(24)
            make.centerX.equalTo(noConnectionIcon.snp.centerX)
        }
    }
    
}
