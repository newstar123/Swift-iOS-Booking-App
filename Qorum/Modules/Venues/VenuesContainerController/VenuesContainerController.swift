//
//  VenuesContainerController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 9/29/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit

class VenueHolder: NSObject {
    
    var venues: [Venue] = []
    
    init(venues: [Venue]) {
        super.init()
        self.venues = venues
    }
    
    // Check venue for confitions to open tab
    func mayOpenTab(in venue: Venue) -> Bool {
        guard !venues.containsVenueWithOpenedTab else {
            return false
        }
        
        return venues.filter({ $0.isOpen &&  $0.isNearby}).contains(where: { $0.venue_id == venue.venue_id })
    }
}

protocol VenuesContainerDelegate: AnyObject {
    var pageController: UIPageViewController! { get }
    
    /// Handles scrollViewDidScroll
    ///
    /// - Parameter offset: current offset
    func scrollViewUpdatedOffset(offset: CGPoint)
    
    /// Sets current page
    func equalizePageOffsets()
    
    /// Opens Venue Details
    ///
    /// - Parameters:
    ///   - venue: venue to open
    ///   - cell: source cell
    ///   - controllerId: controller id presented from
    func showDetails(for venue: Venue, by cell: VenuesCollectionCell?, controllerId: Int)
    
    
    /// Checkins in Venue
    ///
    /// - Parameters:
    ///   - venue: venue
    ///   - cell: source cell
    ///   - controllerId: controller id presented from
    func openTab(for venue: Venue, by cell: VenuesCollectionCell?, controllerId: Int)
    
    /// Opens Tab for selected Venue
    ///
    /// - Parameters:
    ///   - venue: venue
    ///   - cell: source cell
    ///   - controllerId: controller id presented from
    func viewTab(for venue: Venue, by cell: VenuesCollectionCell?, controllerId: Int)
    
    /// Triggers when venues list will be updated
    ///
    /// - Parameter controller: controller updated with
    func finishedUpdatingVenues(in controller: VenuesContainerController)
}

class VenuesContainerController: UIViewController {
    
    let refreshHeader = RefreshHeaderView()
    var index = 0
    var containerSize: CGSize = CGSize.zero
    var offsetDiff = CGPoint.zero
    let scrollInset = CGFloat(0)
    weak var venuesController: VenuesViewController?
    var venues: [Venue] = [] {
        didSet {
            adapter.performUpdates(animated: false) { [weak delegate] finished in
                delegate?.finishedUpdatingVenues(in: self)
            }
        }
    }
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    weak var delegate: VenuesContainerDelegate?
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 4)
    }()
    
    init(index: Int) {
        super.init(nibName: nil, bundle: nil)
        self.index = index
        self.view.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let safeAreaInsets = UIApplication.shared.safeAreaInsets
        let height = view.frame.size.height - safeAreaInsets.top - safeAreaInsets.bottom
        containerSize = CGSize(width: view.frame.width, height: height)
        
        configureCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    // MARK: - Internal
    
    private func configureCollectionView() {
        collectionView.alwaysBounceVertical = true // to ensure we always can pull to refresh
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalTo(self.view)
        }
        collectionView.contentInset = UIEdgeInsetsMake(scrollInset, 0, 0, 0)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        adapter.collectionViewDelegate = self
        refreshHeader.viewToBlockOnRefresh = view
        collectionView.addSubview(refreshHeader)
    }
    
}

// MARK: - ListAdapterDataSource
extension VenuesContainerController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [VenueHolder(venues: venues)]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return VenuesSectionController(containerSize: containerSize, index: index)
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
}

// MARK: - UIScrollViewDelegate
extension VenuesContainerController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard (delegate?.pageController.viewControllers?.first as! VenuesContainerController).collectionView === self.collectionView else {
            return
        }
        delegate?.scrollViewUpdatedOffset(offset: CGPoint(x: offsetDiff.x, y: offsetDiff.y - scrollView.contentOffset.y))
        
        if let obj = adapter.visibleObjects().first, let parentVC = venuesController {
            adapter.visibleCells(for: obj).filter({ $0 is VenuesCollectionCell }).forEach({ ($0 as! VenuesCollectionCell).updateParallax(onView: parentVC.view) })
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(scrollViewDidEndScrollingAnimation(_:)), with: scrollView, afterDelay: 0.1)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        offsetDiff = scrollView.contentOffset
        if (delegate?.pageController.viewControllers?.first as! VenuesContainerController).collectionView === self.collectionView {
            delegate?.equalizePageOffsets()
        }
    }
    
}

// MARK: - UICollectionViewDelegate
extension VenuesContainerController: UICollectionViewDelegate {
    
}
