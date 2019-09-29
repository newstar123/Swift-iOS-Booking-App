//
//  InnerQorumProgressHUD.swift
//  QorumProgressHUD
//
//  All rights reserved.
//

import UIKit

/// fade animation duration
private let fadeTime = Double(0.2)

/// HUD dimensions
private let hudViewMargin = CGFloat(50)
private let hudViewPadding = CGFloat(15)
private let iconViewSize = CGSize(width: 50, height: 50)
private let messageLabelTopMargin = CGFloat(10)
private let messageLabelMinWidth = CGFloat(120)

// MARK: - Internal actions --------------------------

extension QorumProgressHUD {
    
    /// Configures HUD
    func configureProgressHUDView() {
        window.windowLevel = UIWindowLevelNormal
        hudViewController.view.translatesAutoresizingMaskIntoConstraints = false

        hudView.backgroundColor = .white
        hudView.layer.cornerRadius = 10
        hudView.translatesAutoresizingMaskIntoConstraints = false

        iconView.backgroundColor = .clear
        iconView.isHidden = false
        iconView.translatesAutoresizingMaskIntoConstraints = false

        activityIndicatorView.frame.size = iconViewSize
        activityIndicatorView.firstColor = .loaderGreenColor
        activityIndicatorView.secondColor = .loaderBlueColor
        activityIndicatorView.thirdColor = .loaderGreenColor
        activityIndicatorView.duration = 3
        activityIndicatorView.lineWidth = 3
        
        iconDrawingView.frame.size = iconViewSize
        iconDrawingView.backgroundColor = .clear
        iconDrawingView.isHidden = true

        iconDrawingLayer.frame.size = iconViewSize
        iconDrawingLayer.lineWidth = 0
        iconDrawingLayer.fillColor = nil

        imageView.frame.size = iconViewSize
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true

        messageLabel.backgroundColor = .clear
        messageLabel.textAlignment = .center
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.5
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        iconDrawingView.layer.addSublayer(iconDrawingLayer)
        iconView.addSubview(imageView)
        iconView.addSubview(iconDrawingView)
        iconView.addSubview(activityIndicatorView)
        hudView.addSubview(iconView)
        hudView.addSubview(messageLabel)
        hudViewController.view.addSubview(hudView)
        window.rootViewController = hudViewController

        setUpConstraints()
        applyStyles()
    }

    /// Shows HUD with custom message
    ///
    /// - Parameters:
    ///   - message: message to show
    ///   - iconType: icon type
    ///   - image: image to present
    ///   - imageSize: image size
    ///   - isOnlyText: alert without image
    ///   - isLoading: blocks disappearing
    ///   - completion: completion block
    func show(withMessage message: String?,
              iconType: QorumProgressHUDIconType? = nil,
              image: UIImage? = nil,
              imageSize: CGSize? = nil,
              isOnlyText: Bool = false,
              isLoading: Bool = false,
              completion: CompletionHandler? = nil ) {
        DispatchQueue.main.async {
            self.applyStyles()
            self.updateLayouts(message: message, iconType: iconType, image: image, imageSize: imageSize, isOnlyText: isOnlyText)

            let deadline = self.cancelCurrentDismissHandler() ? 0 : fadeTime
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + deadline) {
                self.fadeInView(completion: completion)
                if isLoading { return }
                self.registerDismissHandler()
            }
        }
    }

    /// Dismisses HUD
    ///
    /// - Parameter completion: completion block
    func dismiss(completion: CompletionHandler?) {
        DispatchQueue.main.async {
            self.fadeOutView(completion: completion)
        }
    }
}

// MARK: - Private actions --------------------------

extension QorumProgressHUD {
    
    /// Setups UI
    func setUpConstraints() {
        hudViewCenterYConstraint = NSLayoutConstraint(item: hudView, attribute: .centerY, toItem: hudViewController.view, constant: viewOffset ?? viewAppearance.viewOffset)
        hudViewSideMarginConstraints.append(contentsOf: [
            NSLayoutConstraint(item: hudView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: hudViewController.view, constant: hudViewMargin),
            NSLayoutConstraint(item: hudView, attribute: .right, relatedBy: .lessThanOrEqual, toItem: hudViewController.view, constant: -hudViewMargin)
        ])

        iconViewConstraints.append(contentsOf: [
            NSLayoutConstraint(item: iconView, attribute: .top, toItem: hudView, constant: hudViewPadding),
            NSLayoutConstraint(item: iconView, attribute: .centerX, toItem: hudView),
            NSLayoutConstraint(item: iconView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: hudView, constant: hudViewPadding),
            NSLayoutConstraint(item: iconView, attribute: .right, relatedBy: .lessThanOrEqual, toItem: hudView, constant: -hudViewPadding),
            NSLayoutConstraint(item: iconView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: hudView, constant: -hudViewPadding)
        ])

        messageLabelMinWidthConstraint = NSLayoutConstraint(item: messageLabel, attribute: .width, relatedBy: .greaterThanOrEqual, constant: messageLabelMinWidth)
        messageLabelConstraints.append(contentsOf: [
            messageLabelMinWidthConstraint,
            NSLayoutConstraint(item: messageLabel, attribute: .top, toItem: iconView, attribute: .bottom, constant: messageLabelTopMargin),
            NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: hudView, constant: hudViewPadding),
            NSLayoutConstraint(item: messageLabel, attribute: .left, toItem: hudView, constant: hudViewPadding),
            NSLayoutConstraint(item: messageLabel, attribute: .right, toItem: hudView, constant: -hudViewPadding),
            NSLayoutConstraint(item: messageLabel, attribute: .bottom, toItem: hudView, constant: -hudViewPadding)
        ])

        hudViewController.view.addConstraints([
            NSLayoutConstraint(item: hudView, attribute: .centerX, toItem: hudViewController.view),
            hudViewCenterYConstraint
        ] + hudViewSideMarginConstraints)
        hudView.addConstraints(iconViewConstraints + messageLabelConstraints)
        iconView.addConstraints([
            NSLayoutConstraint(item: iconView, attribute: .width, constant: iconViewSize.width),
            NSLayoutConstraint(item: iconView, attribute: .height, constant: iconViewSize.height)
        ])
    }

    /// Marks added completion handler as cancelled
    ///
    /// - Returns: true if cancelled
    func cancelCurrentDismissHandler() -> Bool {
        guard let handler = dismissHandler else { return true }
        defer { dismissHandler = nil }
        handler.cancel()
        return handler.isCancelled
    }

    /// Adds completion handler to global queue
    func registerDismissHandler() {
        dismissHandler = DispatchWorkItem {
            QorumProgressHUD.dismiss()
            _ = self.cancelCurrentDismissHandler()
        }
        let deadline = DispatchTime.now() + (deadlineTime ?? viewAppearance.deadlineTime)
        DispatchQueue.global().asyncAfter(deadline: deadline, execute: dismissHandler!)
    }
    
    /// Animates view with fade in animation
    ///
    /// - Parameter completion: completion block
    func fadeInView(completion: CompletionHandler?) {
        if QorumProgressHUD.isVisible {
            hudView.alpha = 0
        } else {
            hudViewController.view.alpha = 0
            if let presentingVC = presentingViewController {
                presentingVC.view.addSubview(hudViewController.view)
            } else {
                appWindow = UIApplication.shared.keyWindow
                window.makeKeyAndVisible()
            }
        }

        QorumProgressHUD.isVisible = true
        UIView.animate(withDuration: fadeTime, animations: {
            self.hudView.alpha = 1
            self.hudViewController.view.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }

    /// Animates view with fade out animation
    ///
    /// - Parameter completion: completion block
    func fadeOutView(completion: CompletionHandler?) {
        UIView.animate(withDuration: fadeTime, animations: {
            self.hudViewController.view.alpha = 0
        }, completion: { _ in
            self.appWindow?.makeKeyAndVisible()
            self.appWindow = nil
            self.window.isHidden = true
            self.hudViewController.view.removeFromSuperview()
            self.presentingViewController = nil
            self.activityIndicatorView.stopAnimating()
            QorumProgressHUD.isVisible = false
            completion?()
        })
    }

    /// Configures UI
    func applyStyles() {
        hudView.backgroundColor = style?.backgroundColor ?? viewAppearance.style.backgroundColor
        messageLabel.textColor = style?.textColor ?? viewAppearance.style.textColor
        iconDrawingLayer.fillColor = style?.iconColor?.cgColor ?? viewAppearance.style.iconColor?.cgColor
        hudViewController.view.backgroundColor = maskType?.maskColor ?? viewAppearance.maskType.maskColor
        messageLabel.font = font ?? viewAppearance.font
    }

    /// Resets UI
    func resetLayouts() {
        iconView.isHidden = false
        activityIndicatorView.stopAnimating()
        iconDrawingView.isHidden = true
        iconDrawingLayer.path = nil
        imageView.image = nil
        imageView.isHidden = true
        messageLabel.isHidden = false
        hudViewCenterYConstraint.constant = viewOffset ?? viewAppearance.viewOffset
        hudViewSideMarginConstraints.forEach { $0.isActive = true }
        iconViewConstraints.forEach { $0.isActive = true }
        messageLabelConstraints.forEach { $0.isActive = true }
    }

    /// Updates HUD UI
    ///
    /// - Parameters:
    ///   - message: message to present
    ///   - iconType: icon type
    ///   - image: image to show
    ///   - imageSize: size of image
    ///   - isOnlyText: single text will be shown
    func updateLayouts(message: String?, iconType: QorumProgressHUDIconType?, image: UIImage?, imageSize: CGSize?, isOnlyText: Bool) {
        resetLayouts()
        messageLabel.text = message

        if isOnlyText {
            iconView.isHidden = true
            iconViewConstraints.forEach { $0.isActive = false }
            messageLabelMinWidthConstraint.isActive = false
            return
        }

        if message == nil {
            messageLabel.isHidden = true
            messageLabelConstraints.forEach { $0.isActive = false }
            hudViewSideMarginConstraints.forEach { $0.isActive = false }
        }

        switch (iconType, image) {
        case (nil, nil):
            activityIndicatorView.startAnimating()

        case (nil, let image):
            imageView.isHidden = false
            let size = imageSize ?? image!.size
            imageView.contentMode = size.width < imageView.bounds.width && size.height < imageView.bounds.height ? .center : .scaleAspectFit
            imageView.image = image

        case (let iconType, _):
            iconDrawingView.isHidden = false
            iconDrawingLayer.path = iconType!.getPath()
            iconDrawingLayer.fillColor = iconDrawingLayer.fillColor ?? iconType!.getColor()
        }
    }
}
