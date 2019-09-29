//
//  AddressSearchResultsContainer.swift
//  Qorum
//
//  Created by Vadym Riznychok on 5/22/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit
import GooglePlaces

class AddressSearchResultsContainer: UIView {
    
    @IBOutlet weak var addressController: UberAdressesView!
    @IBOutlet weak var resultsTable: UITableView!
    @IBOutlet weak var tableBottom: NSLayoutConstraint!
    var results: [GMSAutocompletePrediction] = []
    var searchString: String = ""
    var lastSelectedPlacePrediction: GMSAutocompletePrediction?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Notification.Name.UIKeyboardWillShow.add(observer: self, selector: #selector(keyboardWillShow))
        Notification.Name.UIKeyboardWillHide.add(observer: self, selector: #selector(keyboardWillHide))
        resultsTable.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func hide() {
        self.isHidden = true
        self.alpha = 0
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    func loadPlacesRequest(text: String) {
        guard text != "" else {
            self.results = []
            self.resultsTable.reloadData()
            return
        }
        searchString = text
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(loadPlaces), with: nil, afterDelay: 0.5)
    }
    
    @objc func loadPlaces() {
        self.lastSelectedPlacePrediction = nil
        GMSPlacesClient().autocompleteQuery(searchString, bounds: nil, filter: nil) { (predictions, error) in
            
            guard predictions != nil  else {
                self.results = []
                self.resultsTable.reloadData()
                return
            }
            
            self.results = predictions!
            self.resultsTable.reloadData()
        }
    }

    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.tableBottom.constant = keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.tableBottom.constant = 0
    }
    
}

extension AddressSearchResultsContainer: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.lastSelectedPlacePrediction = self.results[indexPath.row]
        self.addressController.deactivate()
    }
    
}

extension AddressSearchResultsContainer: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCellIdent", for: indexPath) as! AddressSuggestionCell
        
        cell.shortName.text = self.results[indexPath.row].attributedPrimaryText.string
        cell.address.text = self.results[indexPath.row].attributedFullText.string
        
        return cell
    }
}

class AddressSuggestionCell: UITableViewCell {
    
    @IBOutlet weak var shortName: UILabel!
    @IBOutlet weak var address: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
