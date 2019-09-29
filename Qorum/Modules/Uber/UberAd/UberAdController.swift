//
//  UberAdController.swift
//  Qorum
//
//  Created by administrator on 7/20/16.
//  Copyright © 2016 Qorum. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Mixpanel

class UberAdController: BaseViewController {
    
    var interactor: UberOrderBusinessLogic?
    var router: (NSObjectProtocol & UberOrderRoutingLogic & UberOrderDataPassing)?
    
    var uberData: UberRequestData?
    var checkin: Checkin?
    var venue: Venue?
    var uberRequestId: String = ""
    let progressView = UIView()
    var player: AVPlayer?
    var uberError: String?
    var uberErrorPayment: String?
    var uberErrorPaymentCode: String?
    var uberSurgeHref: String?
    var uberSurgeConfirmationId: String?
    var rideType: QorumRideType = .to
    var isOrdering = false
    var isLoading = false
    var isPlaying = false
    var isFinishedPlaying = false
    
    //MARK: - Setup
    deinit {
        print("UberAdDeinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override var backgroundStyle: BaseViewController.BackgroundAppearance {
        return .empty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let titleView = UILabel(font: UIFont.opensans.default(24), textColor: UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.8), text: "REQUESTING")
        titleView.frame = CGRect(x: 0, y: 30, width: .deviceWidth, height: 40)
        titleView.textAlignment = .center
        view.addSubview(titleView)
        
        progressView.frame = CGRect(x: 60, y: .deviceHeight - 25, width: .deviceWidth - 120, height: 6)
        progressView.backgroundColor = .white
        progressView.layer.cornerRadius = 3
        progressView.layer.masksToBounds = true
        view.addSubview(progressView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFinishedPlaying == false {
            setupPlayer()
            updateFareAndOrder()
        } else if UserDefaults.standard.string(forKey: UserDefaultsKeys.defaultUberPaymentKey.rawValue) != nil {
            showLoader("Ordering Uber")
            updateFareAndOrder()
        } else {
            navigateBackHierarchy()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func navigateBackHierarchy() {
        QorumNotification.needsFreeRideCheckinsUpdate.post()
        if let venueDetailsVC = navigationController?.find(VenueDetailsViewController.self) {
            navigationController?.popToViewController(venueDetailsVC, animated: true)
        } else if let venuesVC = navigationController?.find(VenuesViewController.self) {
            navigationController?.popToViewController(venuesVC, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func navigateBackRoot() {
        if let venuesVC = navigationController?.find(VenuesViewController.self) {
            QorumNotification.needsFreeRideCheckinsUpdate.post()
            navigationController?.popToViewController(venuesVC, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func navigateToUberPayments() {
        let vc = UberPaymentsController.fromStoryboard
        vc.freeRideAvailable = checkin?.ridesafeStatus?.isFreeRideAvailable == true
        vc.uberPaymentError = uberErrorPayment
        vc.uberPaymentErrorCode = uberErrorPaymentCode
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func applicationDidBecomeActive(_ notif: NSNotification) {
        player?.play()
    }
    
    func setupPlayer() {
        guard player == nil else { return }
        
        let borderView = UIView(frame: CGRect(x: 5, y: 80, width: .deviceWidth - 10, height: 1))
        borderView.backgroundColor = UIColor(red: 0, green: 174/255, blue: 196/255, alpha: 1.0)
        view.addSubview(borderView)
        
        var duration = 0
        let freeRide = checkin?.ridesafeStatus?.isFreeRideAvailable == true
        let adVideoURL = UserDefaults.standard.advertUberVideoURL(rideFromVenue: self.rideType == .from,
                                                                  freeRide: freeRide)
        guard let fileUrl = adVideoURL else { return }
        let asset = AVURLAsset(url: fileUrl)
        duration = Int(asset.duration.value / Int64(asset.duration.timescale))
        let video = AVPlayerItem(asset: asset)
        
        player = AVPlayer(playerItem: video)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            print("Something bad happened. Try catching specific errors to narrow things down\n\(error)")
        }
        
        player?.play()
        
        guard let track = asset.tracks(withMediaType: AVMediaType.video).first else { return }
        let videoSize = track.naturalSize.applying(track.preferredTransform)
        let videoY = borderView.bottom + 1
        let videoHt = (.deviceWidth / videoSize.width) * videoSize.height
        let ht = min(videoHt, .deviceHeight - videoY)
        playerLayer.frame = CGRect(x: 0, y: videoY, width: .deviceWidth, height: ht)
        Notification.Name.AVPlayerItemDidPlayToEndTime
            .add(observer: self, selector: #selector(playerDidFinishPlaying(_:)), object: player!.currentItem)
        Notification.Name.UIApplicationDidBecomeActive
            .add(observer: self, selector: #selector(applicationDidBecomeActive(_:)))
        view.layer.insertSublayer(playerLayer, below: progressView.layer)
        updateProgressView(0, duration: duration)
    }
    
    private func stopPlayer() {
        print("stopPlayer")
        self.player?.pause()
        self.player = nil
        self.isFinishedPlaying = true
        self.isPlaying = false
    }
    
    func updateProgressView(_ progress: CGFloat, duration: Int) {
        isPlaying = true
        for subview in progressView.subviews {
            subview.removeFromSuperview()
        }
        
        let howFarView = UIView()
        howFarView.backgroundColor = UIColor(red: 78/255, green: 153/255, blue: 233/255, alpha: 1.0)
        let wd = progressView.width * CGFloat(progress) / CGFloat(duration)
        howFarView.frame = CGRect(x: 0, y: 0, width: wd, height: progressView.height)
        progressView.addSubview(howFarView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard
                let uberAdVC = self,
                let time = uberAdVC.player?.currentTime() else { return }
            let currentProgress = CGFloat(CMTimeGetSeconds(time))
            if currentProgress.isLess(than: CGFloat(duration)) {
                uberAdVC.updateProgressView(currentProgress, duration: duration)
            }
        }
    }
    
    //MARK: - Updates
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        isPlaying = false
        playerFinished()
    }
    
    func playerFinished() {
        print("playerFinished")
        if let surgeHref = uberSurgeHref {
            let uberSurgeVC = UberSurgeController.fromStoryboard
            uberSurgeVC.href = surgeHref
            navigationController?.pushViewController(uberSurgeVC, animated: true)
        } else if uberError != nil {
            showUberError()
        } else {
            self.stopPlayer()
            self.openUber()
        }
    }
    
    func openUber() {
        print("openUber")
        guard uberRequestId != "", !isPlaying else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.openUber()
            }
            return
        }
        
        router?.openUberApp()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.stopPlayer()
            self?.navigateBackRoot()
        }
    }
    
    //MARK: - Order Uber
    func updateFareAndOrder() {
        print("updateFareAndOrder")
        interactor?.worker.uberTypeEstimate(uberData: uberData!) { [weak self] (result) in
            switch result {
            case let .value(result):
                self?.uberData?.type?.estimate = result
                if  self?.uberData?.dropoff != nil,
                    self?.uberData?.pickup != nil
                {
                    self?.isOrdering = true
                    self?.isLoading = true
                    self?.requestUber(data: self!.uberData!, afterSurge: false)
                }
            case let .error(error):
                self?.isOrdering = false
                self?.uberData?.type?.estimate = UberTypeEstimate(data: [:])
                self?.hideLoader()
                print("UberOrderWorker loadEstimate - uberTypeEstimate error:", error)
                self?.uberError = "We are sorry, but there was an error ordering your Uber. \(error.localizedDescription)"
                if self?.isPlaying == false {
                    self?.showUberError()
                }
            }
        }
    }
    
    func orderUberAfterSurge() {
        navigationController?.popToViewController(self, animated: true)
        showLoader("Ordering Uber")
        
        uberData?.surgeConfirmationId = self.uberSurgeConfirmationId
        
        if uberData?.dropoff != nil, uberData?.pickup != nil {
            requestUber(data: uberData!, afterSurge: true)
        } else {
            hideLoader()
        }
    }
    
    func requestUber(data: UberRequestData, afterSurge: Bool) {
        print("requestUber")
        interactor?.orderUber(uberData: data) { (success, uberRequestId, error) in
            if self.isFinishedPlaying != true {
                self.hideLoader()
            }
            print("UBER: %@", String(describing: uberRequestId))
            
            if let uberRequestId = uberRequestId, success {
                self.uberRequestId = uberRequestId
                
                if afterSurge == true {
                    self.uberSurgeHref = nil
                    self.uberError = nil
                } else {
                    let storedUser = User.stored
                    storedUser.settings.uberRequestId = uberRequestId
                    storedUser.save()
                    if  self.rideType == .from,
                        let checkin = self.checkin,
                        let checkoutDate = checkin.checkout_time
                    {
                        let minutes = Time(checkoutDate.timeIntervalSince(checkin.created), .seconds)[in: .minutes]
                        self.trackCloseTab(fromVenue: true, minutes: minutes)
                    } else if self.rideType == .from {
                        self.trackCloseTab(fromVenue: true, minutes: nil)
                    } else {
                        self.trackCloseTab(fromVenue: false, minutes: nil)
                    }
                }
                
                self.registerRide()
            } else if let href = uberRequestId {
                self.uberSurgeHref = href
            } else if let errorStr = error as? String {
                self.uberError = "We are sorry, but there was an error ordering your Uber. \(errorStr)"
            } else if let errorDict = error as? Dictionary<String, Any>,
                let errorTitle = errorDict["title"] {
                self.uberError = "We are sorry, but there was an error ordering your Uber. \(String(describing: errorTitle))"
                self.uberErrorPayment = String(describing: errorTitle)
                self.uberErrorPaymentCode = errorDict["code"] as? String
                if self.uberErrorPaymentCode == "invalid_payment_method" {
                    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.defaultUberPaymentKey.rawValue)
                }
            } else {
                self.uberError = "We are sorry, but there was an error ordering your Uber."
            }
            
            if self.isPlaying == false {
                self.showUberError()
            }
            
            if afterSurge {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.playerFinished()
                }
            }
        }
    }
    
    //MARK: - Apply promo
    func registerRide() {
        print("registerRide")
        guard uberRequestId.isNotEmpty, let uberData = uberData else { return }
        interactor?.registerRide(requestId: uberRequestId, uberData: uberData) { (result) in
            switch result {
            case let .value(rideId):
                self.applyPromo(rideId)
            case let .error(error):
                print("UberAdController registerRide error:", error)
                self.showFailedPromoAlert()
            }
        }
    }
    
    func applyPromo(_ rideId: String) {
        print("Start apliyng promo")
        guard let checkin = self.checkin,
            checkin.ridesafeStatus?.isFreeRideAvailable == true else
        {
            print("No free ride")
            isLoading = false
            openUber()
            return
        }
        
        print("Check ride promo")
        interactor?.checkRidePromo(checkinId: checkin.checkin_id) { (success) in
            guard success == true else {
                print("Check ride promo Failed")
                self.showFailedPromoAlert()
                return
            }
            
            print("Apply ride promo")
            self.interactor?.applyRidePromo(rideId: rideId, checkinId: checkin.checkin_id) { [weak self] response in
                guard let self = self else { return }
                switch response {
                case .success:
                    if self.isPlaying == true {
                        self.isLoading = false
                    } else {
                        self.openUber()
                    }
                case .alreadyApplied:
                    print("Promo code already applied")
                    self.showPromoAlreadyAppliedAlert()
                case .invalidPromo:
                    print("Can't apply invalid promo code")
                    self.showFailedPromoAlert()
                case .error(let error):
                    print("Applying ride promo failed: \n\(error)")
                    self.showFailedPromoAlert()
                }
            }
        }
    }
    
    func showPromoAlreadyAppliedAlert() {
        print("showPromoAlreadyAppliedAlert")
        isLoading = false
        let title = "Looks like your Uber account already has an existing promo code, which will be automatically applied to this ride."
        let message = "You can redeem your new Qorum promo code on your next ride by tapping the green Uber icon on the bottom right corner of the Venue list screen."
        UIAlertController.presentAsAlert(title: title, message: message, actions: [
            ("Got it!", .default, { [weak self] in
                guard let self = self else { return }
                if !self.isPlaying {
                    self.openUber()
                }
            })])
    }
    
    func showFailedPromoAlert() {
        print("showFailedPromoAlert")
        isLoading = false
        let title = "Ride promotion"
        let message = "Something went wrong loading your promotion, would you like to continue requesting your ride without a promo code?"
        UIAlertController.presentAsAlert(title: title, message: message, actions:
            [("Yes, continue", .default, { [weak self] in
                self?.openUber()
            }),
             ("No, cancel", .destructive, { [weak self] in
                self?.stopPlayer()
                if self?.uberRequestId.isNotEmpty == true {
                    self?.interactor?.cancelUber(requestId: self!.uberRequestId) { success in
                        DispatchQueue.main.async { [weak self] in self?.navigateBackRoot() }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in self?.navigateBackRoot() }
                }
             })])
    }
    
    func showUberError() {
        print("showUberError")
        hideLoader()
        if let errorString = uberError {
            stopPlayer()
            
            guard self.uberErrorPaymentCode == nil else {
                self.uberError = nil
                self.navigateToUberPayments()
                return
            }
            
            UIAlertController.presentAsAlert(title: errorString, actions:
                [("OK", .cancel, { [weak self] in
                    print("Player finished, error, okay pressed")
                    self?.navigateBackHierarchy()
                })])
        }
    }
    
    func trackCloseTab(fromVenue: Bool, minutes: Double?) {
        var properties = ["Relative to Tab": fromVenue ? "Request After Tab Close" : "Request Ride to the Venue",
                          "Venue": self.venue?.name ?? "",
                          "Market": self.venue?.market?.name ?? "",
                          "Neighborhood": self.venue?.neighborhood ?? ""]
        
        if minutes != nil {
            properties.updateValue(String(describing: minutes!), forKey: "Time at Venue")
        }
        
        AnalyticsService.shared.track(event: MixpanelEvents.uberRideRequestSuccess.rawValue,
                                      properties: properties)
    }
    
}
