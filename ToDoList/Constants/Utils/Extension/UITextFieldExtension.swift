//
//  UITextFieldExtension.swift
//  ToDoList
//
//  Created by Владислав Головачев on 10.09.2024.
//

import UIKit

extension UITextField {
    func setInputViewDatePicker(withPickerMode pickerMode: UIDatePicker.Mode,
                                selector: Selector?) {
        guard let screenWidth = window?.screen.bounds.width else {return}
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = pickerMode
        datePicker.locale = Locale(identifier: "en")
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0,
                                              width: screenWidth,
                                              height: Constants.toolBarHeight))
        
        let flexibleSpace = UIBarButtonItem(systemItem: .flexibleSpace)
        let barButton = UIBarButtonItem(title: "Done", style: .done,
                                        target: nil, action: selector)
        toolBar.setItems([flexibleSpace, barButton], animated: false)
        
        inputView = datePicker
        inputAccessoryView = toolBar
    }
}

fileprivate enum Constants {
    static let toolBarHeight: Double = 50
}
