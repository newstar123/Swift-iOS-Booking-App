//
//  MenuController.swift
//  Qorum
//
//  Created by Will Parks on 06.10.2016.
//  Copyright © 2016 Qorum. All rights reserved.
//

import UIKit

/// The screen to diplay menu group items.
class MenuController: BaseViewController, SBInstantiable {
    
    static let storyboardName = StoryboardName.venueDetails
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var itemName: UILabel!
    
    /// The group containing menu items.
    var menu: Menu? = nil
    
    var venue: Venue? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        
        itemName.text = menu!.name
        venueName.text = venue!.name
        
        tableView.layoutMargins = UIEdgeInsets.zero
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITableViewDataSource
extension MenuController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu!.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell") as? MenuItemCell else {
            return UITableViewCell()
        }
        
        let item = menu!.items[indexPath.row]
        cell.name.text =  item.name
        cell.price.text = "$\(item.price.monetaryValue)"
        
        return cell
    }
    
}
