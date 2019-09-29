//
//  RefreshHeaderView.swift
//  Qorum
//
//  Created by Stanislav on 17.11.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

class RefreshHeaderView: UIControl {
    
    enum PullState: Int {
        case pulling, normal, loading
    }
    /// pull area dimensions
    let pullTriggerHeight: CGFloat = 86
    let pullAreaHeight: CGFloat = 72
    let pullAreaMinHeight: CGFloat = 26
    
    /// animating view
    let loadingView = QorumLoadingView(frame: .zero,
                                       lineWidth: 1,
                                       firstColor: .loaderGreenColor,
                                       secondColor: .loaderBlueColor,
                                       thirdColor: .loaderGreenColor,
                                       duration: 3)
    
    /// Indicates that user pulled the refresh control enough to trigger
    /// the refreshing request by giving a user the impact feedback
    let feedbackGenerator = UIImpactFeedbackGenerator()
    
    /// scroll view controlled by refresh view
    var scrollView: UIScrollView? {
        return superview as? UIScrollView
    }
    
    /// custom view that will be blocked on refresh
    weak var viewToBlockOnRefresh: UIView?
    
    /// observes scrollview's content offset changes
    private var contentOffsetObserver: NSKeyValueObservation?
    
    /// refresh state
    var pullState: PullState = .normal {
        didSet {
            switch pullState {
            case .pulling:
                loadingView.alpha = 1
            case .normal:
                loadingView.progress = 0
                loadingView.stopAnimating()
            case .loading:
                loadingView.progress = 1.0
                loadingView.startAnimating()
            }
        }
    }
    
    /// Indicating whether the loading view is fading while refreshing
    /// Used to ignore scrolling offset to calculate the loading view transparency while the loading view is fading
    var isFading = false
    
    // MARK: - Object lifecycle
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        invalidateObservers()
    }
    
    /// Removes observers
    func invalidateObservers() {
        if let observer = contentOffsetObserver {
            observer.invalidate()
            scrollView?.removeObserver(observer, forKeyPath: "contentOffset")
            contentOffsetObserver = nil
        }
    }
    
    /// Setups view
    private func setup() {
        loadingView.progress = 0
        loadingView.startEmpty = false
        addSubview(loadingView)
    }
    
    /// Adds refresh view to scrollview
    ///
    /// - Parameters:
    ///   - scrollView: scrollview to add at
    ///   - target: target for refreshing event
    ///   - action: action for refreshing event
    ///   - blocksOnRefresh: view that will be blocked upon refresh, can be nil
    func add(to scrollView: UIScrollView,
             addingTarget target: Any,
             action: Selector,
             blocksOnRefresh: UIView? = nil) {
        viewToBlockOnRefresh = blocksOnRefresh
        scrollView.addSubview(self)
        addTarget(target, action: action, for: .valueChanged)
    }
    
    // MARK: - View lifecycle
    
    override func willMove(toSuperview newSuperview: UIView?) {
        invalidateObservers()
        super.willMove(toSuperview: newSuperview)
        if let scrollView = newSuperview as? UIScrollView {
            contentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] _, _ in
                self?.didScroll()
            }
        }
        autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let circleSize: CGFloat = 40
        let width = superview?.bounds.width ?? bounds.width
        loadingView.frame = CGRect(x: (width - circleSize) / 2,
                                   y: 0,
                                   width: circleSize,
                                   height: circleSize)
    }
    
    // MARK: - Refreshing
    
    /// Starts refreshing animation
    @objc func startAnimating() {
        guard pullState != .loading else { return }
        let needsAppear = pullState == .normal
        pullState = .loading
        viewToBlockOnRefresh?.isUserInteractionEnabled = false
        let areaHeight = pullAreaHeight
        let initialOffset = scrollView?.contentOffset.y
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scrollView?.contentInset.top = areaHeight
            if  let initialOffset = initialOffset,
                let scrollView = self?.scrollView,
                scrollView.contentOffset.y == initialOffset,
                initialOffset <= areaHeight
            {
                scrollView.contentOffset.y = -areaHeight
            }
        }
        if needsAppear {
            isFading = true
            loadingView.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseIn, animations: { [weak self] in
                self?.loadingView.alpha = 1
            }) { [weak self] _ in
                self?.isFading = false
            }
        }
    }
    
    /// Stops animation
    func stopAnimating() {
        guard pullState == .loading else { return }
        viewToBlockOnRefresh?.isUserInteractionEnabled = true
        isFading = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak loadingView] in
            loadingView?.alpha = 0
        }) { [weak loadingView] _ in
            loadingView?.stopAnimating()
        }
        UIView.animate(withDuration: 0.3, delay: 0.1, options: [], animations: { [weak self] in
            self?.scrollView?.contentInset.top = 0
        }) { [weak self] _ in
            self?.pullState = .normal
            self?.isFading = false
        }
    }
    
    /// Handles scroll action
    private func didScroll() {
        guard let scrollView = scrollView else { return }
        let contentOffset = scrollView.contentOffset.y
        switch pullState {
        case .normal:
            if scrollView.isDragging, contentOffset <= -pullAreaMinHeight {
                pullState = .pulling
            }
        case .pulling:
            let pullDistance = min(max(pullAreaMinHeight, -contentOffset), pullTriggerHeight)
            loadingView.y = (pullAreaHeight - loadingView.height)/2 - pullDistance
            let oldProgress = loadingView.progress
            loadingView.progress = (pullDistance - pullAreaMinHeight) / (pullTriggerHeight - pullAreaMinHeight)
            if contentOffset > -pullAreaMinHeight {
                pullState = .normal
            } else if !scrollView.isDragging, oldProgress >= 0.99 {
                startAnimating()
                sendActions(for: .valueChanged)
                feedbackGenerator.impactOccurred()
            }
        case .loading:
            loadingView.y = (contentOffset - loadingView.height)/2
            if !isFading {
                let loadingHeight = loadingView.height
                loadingView.alpha = min(max(0, (-contentOffset - loadingHeight) / (pullAreaHeight - loadingHeight)), 1)
            }
        }
    }
    
}


