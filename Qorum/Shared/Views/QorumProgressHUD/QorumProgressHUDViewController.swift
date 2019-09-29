//
//  QorumProgressHUDViewController.swift
//  QorumProgressHUD
//
//  All rights reserved.
//

import UIKit
import VisualEffectView

class QorumProgressHUDViewController: UIViewController {
    
    var statusBarStyle = UIStatusBarStyle.default
    var statusBarHidden = false
    let loaderBlurView = UIView.loaderBlurOverlay()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let vc = UIApplication.shared.topMostViewController else { return statusBarStyle }
        if !vc.isKind(of: QorumProgressHUDViewController.self) {
            statusBarStyle = vc.preferredStatusBarStyle
        }
        return statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        guard let vc = UIApplication.shared.topMostViewController else { return statusBarHidden }
        if !vc.isKind(of: QorumProgressHUDViewController.self) {
            statusBarHidden = vc.prefersStatusBarHidden
        }
        return statusBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loaderBlurView)
    }
    
}
