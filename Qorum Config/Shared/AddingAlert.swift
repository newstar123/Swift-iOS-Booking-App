//
//  AddingAlert.swift
//  Qorum Config
//
//  Created by Stanislav on 1/25/19.
//  Copyright © 2019 Bizico. All rights reserved.
//

import UIKit

/// The `UIAlertController` subclass designed for adding
/// `UserDefaultsStorable` entity to the storage i.e storing it.
class AddingAlert<Storable: UserDefaultsStorable>: UIAlertController, UITextFieldDelegate {
    
    /// The `UIAlertAction` for saving the entity.
    var saveAction: UIAlertAction?
    
    /// `UserDefaultsStorable` entity which we are going to save.
    var itemToSave: Storable?
    
    /// Sets up the alert to save given entity.
    ///
    /// - Parameters:
    ///   - item: `UserDefaultsStorable` entity which we are going to save.
    ///   - handler: Called on alert dismissal, regardless of action taken. Has `Bool` indicating successful item saving.
    convenience init(saving item: Storable,
                     handler: ((Bool)->())? = nil) {
        self.init(title: "Save New Item", message: "Enter title:", preferredStyle: .alert)
        self.itemToSave = item
        var title = item.title.value
        if !title.isTitleOk {
            title = ""
        }
        addTextField { textField in
            textField.placeholder = "Title"
            textField.text = title
            textField.autocapitalizationType = .sentences
            textField.enablesReturnKeyAutomatically = true
            textField.delegate = self
        }
        addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
            handler?(false)
        }))
        let saveActionTitle = self.saveActionTitle(for: title)
        saveAction = UIAlertAction(title: saveActionTitle, style: .default) { [weak self] _ in
            guard
                let newTitle = self?.textFields?.first?.text,
                newTitle.isTitleOk else
            {
                handler?(false)
                return
            }
            var profileToSave = item
            profileToSave.title = StorableTitle(value: newTitle)
            profileToSave.save()
            if !profileToSave.isCurrent {
                profileToSave.apply()
            }
            handler?(true)
        }
        addAction(saveAction!)
    }
    
    /// Evaluates the `saveAction`'s title for given item's title string
    ///
    /// - Parameter itemTitle: The title value of the item to save.
    /// - Returns: The title string for the `saveAction`.
    func saveActionTitle(for itemTitle: String) -> String {
        var actionTitle: String
        if Storable.willRewriteOnSave(title: itemTitle) {
            actionTitle = "Rewrite"
        } else {
            actionTitle = "Save"
        }
        let isCurrent = itemToSave?.isCurrent ?? true
        if !isCurrent {
            actionTitle.append(" and Apply")
        }
        return actionTitle
    }
    
    // MARK: - UITextFieldDelegate
    
    /// Updates the `saveAction`'s `title` and `isEnabled` as you input the title.
    ///
    /// - Parameters:
    ///   - textField: The text field containing the text.
    ///   - range: The range of characters to be replaced.
    ///   - string: The replacement string for the specified range. During typing, this parameter normally contains only the single new character that was typed, but it may contain more characters if the user is pasting text. When the user deletes one or more characters, the replacement string is empty.
    /// - Returns: Just `true`.
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let newString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        let actionTitle = saveActionTitle(for: newString)
        saveAction?.setValue(actionTitle, forKeyPath: "title")
        saveAction?.isEnabled = newString.isTitleOk
        return true
    }
    
    /// Returns `true` if textField contains text that fits `StorableTitle` requirements.
    ///
    /// - Parameter textField: The text field whose return button was pressed.
    /// - Returns: true if the text field should implement its default behavior for the return button; otherwise, false.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return (textField.text ?? "").isTitleOk
    }
    
}
