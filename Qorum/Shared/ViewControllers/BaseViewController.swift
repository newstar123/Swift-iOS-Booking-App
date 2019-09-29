//
//  BaseViewController.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import Reachability
import PINRemoteImage

enum KRAlertType {
    case success
    case successWithMessage(String)
    case error
    case errorWithMessage(String)
    case none
}

class BaseViewController: UIViewController {
    
    /// Reachability Manager
    private let reachability = Reachability()!
    
    /// flag used to check connection state
    var isConnected: Bool {
        return reachability.connection != .none
    }
    
    /// a separate window to present blocker with alert for offline state
    private var noConnectionWindow: UIWindow?

    /// a separate window to present blocker with force update alert
    private var updateAvailableWindow: UIWindow?

    /// Returns embedding navigation controller, if present
    /// otherwise embeds in new one, then returns it
    var embeddedInNavigationController: BaseNavigationController {
        if let baseNC = navigationController as? BaseNavigationController {
            return baseNC
        }
        let newBaseNC = BaseNavigationController(rootViewController: self)
        newBaseNC.isNavigationBarHidden = true
        return newBaseNC
    }
    
    // MARK: - Subview tags
    
    fileprivate enum SubviewWithTag: Int {
        case cityBackground = 2488
        case cityBackgroundBlur = 2490
        case qorumLogo = 2491
        case qorumTitle = 2492
    }
    
    // MARK: - Object lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .baseViewBackgroundColor
        switch backgroundStyle {
        case .empty:
            break
        case .qorumLogo:
            addLogo()
        case .cityImage(let qorumLogo):
            addCityBackground(addingLogo: qorumLogo)
            QorumNotification.selectedCityChanged.add(observer: self,
                                                      selector: #selector(updateSelectedCityBackgroundSimple))
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Notification.Name.reachabilityChanged
            .add(observer: self, selector: #selector(reachabilityChanged(notification:)), object: reachability)
        QorumNotification.updateAvailable.add(observer: self,
                                                  selector: #selector(updateAvailable))

        try! reachability.startNotifier()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
        Notification.Name.reachabilityChanged
            .remove(observer: self, object: reachability)
        QorumNotification.updateAvailable.remove(observer: self, object: nil)
        hideLoader()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning: \(self)")
    }
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func viewWillUpdateCityBackground() {
        
    }
    
    func viewDidUpdateCityBackground() {
        
    }
    
    // MARK: - Private methods
    
    fileprivate func subView(_ subView: SubviewWithTag) -> UIView? {
        return view.viewWithTag(subView.rawValue)
    }
    
    /// Handles reachability status update
    ///
    /// - Parameter notification: reachability notification
    @objc internal func reachabilityChanged(notification: Notification) {
        guard parent == .none || !(parent is BaseViewController) else { return }
        var isConnectionChanged = false
        switch reachability.connection {
        case .wifi, .cellular:
            isConnectionChanged = noConnectionWindow != .none
            removeNoConnectionOverlay()
        case .none:
            isConnectionChanged = noConnectionWindow == .none
            addNoConnectionOverlay()
        }
        if isConnectionChanged {
            connectionChanged(isConnected: isConnected)
        }
    }
    
    /// Handles update availability notification
    @objc internal func updateAvailable() {
        guard parent == .none || !(parent is BaseViewController) else { return }
        addUpdateAvailableOverlay()
    }

    
    // MARK: - Public methods
    
    /// returns loader's visability flag
    var isLoaderVisible: Bool {
        return QorumProgressHUD.isVisible
    }
    
    /// Presents loader with custom message
    ///
    /// - Parameter message: message to present
    func showLoader(_ message: String?) {
        QorumProgressHUD.appearance().style = .black
        
        guard QorumProgressHUD.isVisible == false else {
            if message != nil {
                QorumProgressHUD.update(message: message!)
            }
            return
        }
        QorumProgressHUD.show(withMessage: message, completion: nil)
    }
    
    /// Hides loader
    ///
    /// - Parameter alertType: alert type
    func hideLoader(showing alertType: KRAlertType) {
        switch alertType {
        case .success: QorumProgressHUD.showSuccess()
        case .successWithMessage(let message): QorumProgressHUD.showSuccess(withMessage: message)
        case .error: QorumProgressHUD.showError()
        case .errorWithMessage(let message): QorumProgressHUD.showError(withMessage: message)
        case .none: QorumProgressHUD.dismiss()
        }
    }
    
    func showLoader() {
        showLoader(nil)
    }
    
    func hideLoader() {
        hideLoader(showing: .none)
    }
    
    func connectionChanged(isConnected: Bool) {
        
    }
    
    enum BackgroundAppearance {
        case empty
        case qorumLogo
        case cityImage(qorumLogo: Bool)
    }
    
    var backgroundStyle: BackgroundAppearance {
        return .cityImage(qorumLogo: false)
    }
    
}

// MARK: - City background displaying
extension BaseViewController {
    
    /// Inserts image and returs imageView
    ///
    /// - Parameters:
    ///   - image: image to insert
    ///   - tag: inserted view tag
    ///   - index: index order
    /// - Returns: resulting imageView
    @discardableResult
    fileprivate func insert(image: UIImage?, tag: Int, at index: Int) -> UIImageView {
        let imgView = UIImageView(image: image)
        imgView.contentMode = .scaleAspectFill
        imgView.layer.masksToBounds = true
        imgView.tag = tag
        view.insertSubview(imgView, at: index)
        view.backgroundColor = .baseViewBackgroundColor
        imgView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalTo(0)
        }
        return imgView
    }
    
    /// Removes subview from superview
    ///
    /// - Parameter subview: view to remove
    fileprivate func remove(subview: SubviewWithTag) {
        subView(subview)?.removeFromSuperview()
    }
    
    /// Rearranges subviews
    ///
    /// - Returns: city background imageView
    @discardableResult
    func getCityBackgroundInsertingIfAbsent() -> UIImageView {
        if let cityBackgroundView = subView(.cityBackground) {
            return cityBackgroundView as! UIImageView
        }
        return insert(image: nil, tag: SubviewWithTag.cityBackground.rawValue, at: 0)
    }
    
    /// Adds city thumbnail as a background
    ///
    /// - Parameter addingLogo: flag if logo should be added as well
    private func addCityBackground(addingLogo: Bool) {
        if addingLogo {
            addLogo()
        } else {
            removeLogo()
        }
        getCityBackgroundInsertingIfAbsent()
        getBackgroundImage { [weak self] result in
            switch result {
            case let .value(image, resultType):
                let cityBackground = self?.getCityBackgroundInsertingIfAbsent()
                cityBackground?.image = image
                self?.addCityBackgroundBlur()
                if !resultType.isImageCached {
                    cityBackground?.addFadingTransition(duration: AnimationDuration.Normal)
                }
            case let .error(error):
                print(error)
            }
        }
    }
    
    /// Updates background image with selected city thumbnail
    @objc func updateSelectedCityBackground() {
        updateBackground { [weak self] result in
            switch result {
            case let .value(cityBackground):
                cityBackground.addFadingTransition {
                    delayToMainThread(AnimationDuration.Long) { [weak self] in
                        self?.addCityBackgroundBlur(animated: true, duration: 1) { [weak self] in
                            self?.viewDidUpdateCityBackground()
                        }
                    }
                }
            case .error:
                self?.viewDidUpdateCityBackground()
            }
        }
    }
    
    /// Updates background without fading transition
    @objc func updateSelectedCityBackgroundSimple() {
        updateBackground { [weak self] result in
            switch result {
            case let .value(cityBackground):
                self?.addCityBackgroundBlur()
                cityBackground.addFadingTransition(duration: AnimationDuration.Normal) { [weak self] in
                    self?.viewDidUpdateCityBackground()
                }
            case .error:
                self?.viewDidUpdateCityBackground()
            }
        }
    }
    
    /// Updates background image
    ///
    /// - Parameter completion: completion handler
    private func updateBackground(completion: @escaping APIHandler<UIImageView>) {
        getCityBackgroundInsertingIfAbsent()
        getBackgroundImage { [weak self] result in
            switch result {
            case let .value(image, _):
                guard let self = self else { return }
                self.viewWillUpdateCityBackground()
                let cityBackground = self.getCityBackgroundInsertingIfAbsent()
                self.removeCityBackgroundBlur()
                cityBackground.image = image
                completion(.value(cityBackground))
            case let .error(error):
                print("updateBackground error:", error)
                completion(.error(error))
            }
        }
    }
    
    /// Fetches background image from server
    ///
    /// - Parameter handler: completion handler
    private func getBackgroundImage(handler: @escaping APIHandler<(UIImage, PINRemoteImageResultType)>) {
        guard let selectedCity = CityManager.shared.selectedCity else {
            handler(.error("\(type(of: self)) getBackgroundImage error: selectedVendorCity is missing"))
            return
        }
        let cityImageLink = selectedCity.imageLink
        guard let cityImageURL = URL(string: cityImageLink) else {
            handler(.error("\(type(of: self)) getBackgroundImage error: can't convert \"\(cityImageLink)\" to URL"))
            return
        }
        PINRemoteImageManager.shared().downloadImage(with: cityImageURL, options: []) { (result: PINRemoteImageManagerResult) in
            DispatchQueue.main.async {
                guard let image = result.image else {
                    handler(.error(result.error ?? "\(type(of: self)) getBackgroundImage unexpected error"))
                    return
                }
                handler(.value((image, result.resultType)))
            }
        }
    }
    
    /// Adds blur to background image
    ///
    /// - Parameters:
    ///   - animated: animated flag
    ///   - duration: animation duration
    ///   - completion: completion block
    func addCityBackgroundBlur(animated: Bool = false,
                               duration: TimeInterval = AnimationDuration.Normal,
                               completion: (() -> Void)? = nil) {
        removeCityBackgroundBlur()
        let blurView = UIView.blurredBackground()
        blurView.tag = SubviewWithTag.cityBackgroundBlur.rawValue
        let cityBackground = subView(.cityBackground)
        cityBackground?.insertSubview(blurView, at: 0)
        if animated {
            blurView.alpha = 0
            UIView.animate(withDuration: duration, animations: {
                blurView.alpha = 1
            }, completion: { (completed) in
                completion?()
            })
        } else {
            completion?()
        }
    }
    
    /// Removes blur from background image
    ///
    /// - Parameters:
    ///   - animated: animated flag
    ///   - duration: animation duration
    ///   - completion: completion block
    func removeCityBackgroundBlur(animated: Bool = false,
                                  duration: TimeInterval = AnimationDuration.Normal,
                                  completion: (() -> Void)? = nil) {
        guard let blurView = subView(.cityBackgroundBlur) else {
            completion?()
            return
        }
        guard animated else {
            blurView.removeFromSuperview()
            completion?()
            return
        }
        UIView.animate(withDuration: duration, animations: {
            blurView.alpha = 0
        }, completion: { _ in
            blurView.removeFromSuperview()
            completion?()
        })
    }
    
    /// Adds Qorum logo to the background
    ///
    /// - Parameter animated: Whether to use animated transition
    func addLogo(animated: Bool = false) {
        let cityBackground = getCityBackgroundInsertingIfAbsent()
        guard
            subView(.qorumLogo) == nil,
            subView(.qorumTitle) == nil else { return }
        let qorumLogoView = UIImageView(image: UIImage(named: "QorumLogo")!)
        qorumLogoView.tag = SubviewWithTag.qorumLogo.rawValue
        cityBackground.addSubview(qorumLogoView)
        qorumLogoView.snp.makeConstraints { (make) in
            make.width.equalTo(qorumLogoView.snp.height).multipliedBy(0.865)
            make.width.equalTo(view.snp.width).multipliedBy(0.2)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(CGFloat.deviceHeight*0.16)
        }
        let qorumTitleView = UIImageView(image: UIImage(named: "QorumTitle")!)
        qorumTitleView.tag = SubviewWithTag.qorumTitle.rawValue
        cityBackground.addSubview(qorumTitleView)
        qorumTitleView.snp.makeConstraints { (make) in
            make.width.equalTo(qorumTitleView.snp.height).multipliedBy(8)
            make.width.equalTo(view.snp.width).dividedBy(1.6)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(qorumLogoView.snp.bottom).offset(CGFloat.deviceHeight*0.03)
        }
        if animated {
            qorumLogoView.alpha = 0
            qorumTitleView.alpha = 0
            UIView.animate(withDuration: AnimationDuration.Short) {
                qorumLogoView.alpha = 1
                qorumTitleView.alpha = 1
            }
        }
    }
    
    /// Removes logo from background
    ///
    /// - Parameters:
    ///   - animated: Whether to use animated transition
    ///   - duration: Animation duration
    ///   - completion: Completion block
    func removeLogo(animated: Bool = false, duration: TimeInterval = AnimationDuration.Short, completion: (() -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: duration, animations: { [weak self] in
                self?.subView(.qorumLogo)?.alpha = 0
                self?.subView(.qorumTitle)?.alpha = 0
            }) { [weak self] _ in
                self?.remove(subview: .qorumLogo)
                self?.remove(subview: .qorumTitle)
                completion?()
            }
        } else {
            remove(subview: .qorumLogo)
            remove(subview: .qorumTitle)
            completion?()
        }
    }
    
}

extension PINRemoteImageResultType {
    
    var isImageCached: Bool {
        switch self {
        case .cache,
             .memoryCache: return true
        case .download,
             .none,
             .progress: return false
        }
    }
    
}

// MARK: - No Connection overlay displaying
extension BaseViewController {
    
    func addNoConnectionOverlay() {
        guard noConnectionWindow == .none else { return }
        let overlayWindow = UIWindow(frame: UIScreen.main.bounds)
        overlayWindow.rootViewController = NoConnectionViewController()
        overlayWindow.windowLevel = UIWindowLevelAlert + 2
        overlayWindow.makeKeyAndVisible()
        noConnectionWindow = overlayWindow
    }
    
    func removeNoConnectionOverlay() {
        guard noConnectionWindow != .none else { return }
        noConnectionWindow = nil
    }
    
}

// MARK: - Update Available overlay displaying
extension BaseViewController {
    
    func addUpdateAvailableOverlay() {
        guard updateAvailableWindow == .none else { return }
        let overlayWindow = UIWindow(frame: UIScreen.main.bounds)
        overlayWindow.rootViewController = UpdateAvailableViewController.fromStoryboard
        overlayWindow.windowLevel = UIWindowLevelAlert + 2
        overlayWindow.makeKeyAndVisible()
        updateAvailableWindow = overlayWindow
    }
}


