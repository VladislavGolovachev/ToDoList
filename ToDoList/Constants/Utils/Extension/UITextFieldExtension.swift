//
//  UITextFieldExtension.swift
//  ToDoList
//
//  Created by Владислав Головачев on 10.09.2024.
//

import UIKit

extension UITextField {
    func setInputViewDatePicker(with pickerMode: UIDatePicker.Mode, with style: UIDatePickerStyle) {
        let datePicker = UIDatePicker()
        
        datePicker.preferredDatePickerStyle = style
        datePicker.datePickerMode = pickerMode
        datePicker.minimumDate = .now
        
        self.inputView = datePicker
    }
}

//size
//handling actions
