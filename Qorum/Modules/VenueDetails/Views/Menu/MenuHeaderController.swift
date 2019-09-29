//
//  MenuHeaderController.swift
//  Qorum
//
//  Created by Will Parks on 06.10.2016.
//  Copyright © 2016 Qorum. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Menu {
    var name: String
    var items: [MenuItem]
}

// MARK: - JSONAbleType
extension Menu: JSONAbleType {
    
    static func from(json: JSON) throws -> Menu {
        let name = json["name"].stringValue
        let items: [MenuItem] = (try? MenuItem.arrayFrom(json: json["items"])) ?? []
        return Menu(name: name, items: items)
    }
    
}

struct MenuItem {
    var id: String
    var name: String
    var price: Money
}

// MARK: - JSONAbleType
extension MenuItem: JSONAbleType {
    
    static func from(json: JSON) throws -> MenuItem {
        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let cents = json["price"].intValue
        let price = Money(Double(cents), .cents)
        return MenuItem(id: id,
                        name: name,
                        price: price)
    }
    
}

// MARK: -

/// The screen for displaying different menu groups.
class MenuHeaderController: BaseViewController, SBInstantiable {
    
    static let storyboardName = StoryboardName.venueDetails
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var venueName: UILabel!
    
    var venue: Venue? = nil
    
    /// The menu groups.
    var menus: [Menu] = []
    
    let refreshHeader = RefreshHeaderView()
    let interactor = VenueDetailsInteractor()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        
        guard let venue = self.venue else { return }
        
        venueName.text = venue.name
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = .clear
        tableView.layoutMargins = UIEdgeInsets.zero
        
        configureRefreshControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if menus.isEmpty {
            loadTable()
        }
    }
    
    private func configureRefreshControl() {
        refreshHeader.add(to: tableView,
                          addingTarget: self,
                          action: #selector(loadTable),
                          blocksOnRefresh: tableView)
    }
    
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func loadTable() {
        if let venue = venue {
            refreshHeader.startAnimating()
            loadMenu(venueId: venue.venue_id)
        }
    }
    
    // MARK: - Menu
    
    private func loadMenu(venueId: Int) {
        fetchMenu(venueId: venueId) { [weak self] result in
            switch result {
            case let .value(items):
                self?.menus = items
                self?.tableView.reloadData()
            case let .error(error):
                print("Menu loading error:", error)
                UIAlertController.presentAsAlert(title: "Cannot load menu")
            }
            self?.refreshHeader.stopAnimating()
        }
    }
    
    private func fetchMenu(venueId: Int,
                           completion: @escaping APIHandler<[Menu]>) {
        let request = VenuesRequest(target: .fetchMenu(venueId: venueId))
        request.performArrayDecoding(for: "menu", completion: completion)
    }
    
}

// MARK: - UITableViewDataSource
extension MenuHeaderController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuHeadersCell") as? MenuHeadersCell else {
            return UITableViewCell()
        }
        cell.name.text = menus[indexPath.row].name
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension MenuHeaderController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = menus[indexPath.row]
        let menuController = MenuController.fromStoryboard
        menuController.menu = menu
        menuController.venue = venue
        navigationController?.pushViewController(menuController, animated: true)
    }
    
}
