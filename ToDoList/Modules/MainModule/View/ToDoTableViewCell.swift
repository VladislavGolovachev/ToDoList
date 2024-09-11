//
//  ToDoTableViewCell.swift
//  ToDoList
//
//  Created by Владислав Головачев on 04.09.2024.
//

import UIKit

protocol CellDelegateProtocol: AnyObject {
    func updateHeightOfRow(cell: UITableViewCell)
    
    func reminderChanged(of cell: ToDoTableViewCell, for reminder: String)
    func descriptionChanged(of cell: ToDoTableViewCell, for description: String)
    func dateNeedsUpdate(of cell: ToDoTableViewCell, for date: Date)
    func checkboxStateChanged(of cell: ToDoTableViewCell, forCheckedState: Bool)
}

final class ToDoTableViewCell: UITableViewCell {
    //MARK: Properties
    static let reuseIdentifier = "ToDoCell"
    
    weak var delegate: CellDelegateProtocol?
    
    private let backView = {
        let view = UIView()
        view.backgroundColor = ColorConstants.cell
        view.layer.cornerRadius = CellConstants.cornerRadius
        
        let padding = CellConstants.contentPadding
        view.layoutMargins = UIEdgeInsets(top: padding, left: padding,
                                          bottom: padding, right: padding)
        
        return view
    }()
    private let reminderTextView = {
        let textView = UITextView()
        textView.backgroundColor = ColorConstants.cell
        textView.isScrollEnabled = false
        
        textView.text = DefaultTextConstant.initialReminder
        textView.font = FontConstants.primary
        textView.textColor = ColorConstants.Text.primary
        
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.tag = TextViewTag.reminder
        
        return textView
    }()
    private let descriptionTextView = {
        let textView = UITextView()
        textView.backgroundColor = ColorConstants.cell
        textView.isScrollEnabled = false
        
        textView.text = DefaultTextConstant.description
        textView.font = FontConstants.secondary
        textView.textColor = ColorConstants.Text.secondary
        
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.tag = TextViewTag.description
        
        return textView
    }()
    private let separatorView = {
        let view = UIView()
        view.backgroundColor = ColorConstants.separator
        
        return view
    }()
    private lazy var dateTextField: UITextField = {
        let textField = UITextField()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontConstants.placeholder,
            .foregroundColor: ColorConstants.Text.placeholder
        ]
        let attributedPlaceholder = NSAttributedString(string: DefaultTextConstant.datePlaceholder,
                                                  attributes: attributes)
        
        textField.attributedPlaceholder = attributedPlaceholder
        
        return textField
    }()
    private let checkboxButton = {
        let button = ButtonWithExpandedHitbox(type: .custom)
        let name = CheckboxConstants.ImageName.unchecked
        let circleImage = UIImage(named: name)
        
        button.setImage(circleImage, for: .normal)
        button.tag = CheckboxState.unchecked.rawValue
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = MainViewConstants.Color.background
        
        reminderTextView.delegate = self
        descriptionTextView.delegate = self
        
        checkboxButton.addTarget(self, action: #selector(checkboxChanged(_:)), for: .touchUpInside)
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reminderTextView.text = DefaultTextConstant.reusableText
        descriptionTextView.text = DefaultTextConstant.description
        dateTextField.text = DefaultTextConstant.reusableText
        setReminderCheckedState(.unchecked)
    }
    
    override func layoutSubviews() {
        dateTextField.setInputViewDatePicker(withPickerMode: .dateAndTime,
                                             selector: #selector(dateChanged))
        
        dateTextField.inputView?.overrideUserInterfaceStyle = .light
        dateTextField.inputAccessoryView?.overrideUserInterfaceStyle = .light
    }
}

//MARK: Public Functions
extension ToDoTableViewCell {
    func setReminder(_ reminder: String) {
        reminderTextView.text = reminder
    }
    
    func setDescription(_ description: String) {
        descriptionTextView.text = description
    }
    
    func setIsCompleted(_ isCompleted: Bool) {
        if isCompleted {
            setReminderCheckedState(.checked)
            return
        }
        setReminderCheckedState(.unchecked)
    }
    
    func setDate(_ date: NSAttributedString) {
        dateTextField.attributedText = date
    }
}

//MARK: Actions
extension ToDoTableViewCell {
    @objc func dateChanged() {
        guard let datePicker = dateTextField.inputView as? UIDatePicker else {return}
        delegate?.dateNeedsUpdate(of: self, for: datePicker.date)
        
        dateTextField.resignFirstResponder()
    }
    
    @objc private func checkboxChanged(_ sender: UIButton) {
        guard let state = CheckboxState(rawValue: 1 - sender.tag) else {return}
        setReminderCheckedState(state)
    }
}

//MARK: Private Functions
extension ToDoTableViewCell {
    private func setReminderCheckedState(_ state: CheckboxState) {
        var name: String
        var flag = false
        if state == .checked {
            name = CheckboxConstants.ImageName.checked
            checkboxButton.tag = CheckboxState.checked.rawValue
            flag = true
        } else {
            name = CheckboxConstants.ImageName.unchecked
            checkboxButton.tag = CheckboxState.unchecked.rawValue
        }
        
        let image = UIImage(named: name)
        checkboxButton.setImage(image, for: .normal)
        
        delegate?.checkboxStateChanged(of: self, forCheckedState: flag)
    }
    
    private func addSubviews() {
        backView.addSubview(reminderTextView)
        backView.addSubview(descriptionTextView)
        backView.addSubview(separatorView)
        backView.addSubview(dateTextField)
        backView.addSubview(checkboxButton)
        
        contentView.addSubview(backView)
    }
    
    private func setupConstraints() {
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let halfMinimumLineSpacing = MainViewConstants.tableLineSpacing / 2.0
        let backViewMargins = backView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, 
                                                constant: halfMinimumLineSpacing),
            
            backView.topAnchor.constraint(equalTo: contentView.topAnchor, 
                                          constant: halfMinimumLineSpacing),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, 
                                              constant: MainViewConstants.padding),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, 
                                               constant: -MainViewConstants.padding),
            backView.bottomAnchor.constraint(equalTo: dateTextField.bottomAnchor, 
                                             constant: MainViewConstants.padding),
            
            reminderTextView.topAnchor.constraint(equalTo: backViewMargins.topAnchor),
            reminderTextView.leadingAnchor.constraint(equalTo: backViewMargins.leadingAnchor),
            reminderTextView.trailingAnchor.constraint(equalTo: checkboxButton.leadingAnchor,
                                                       constant: -CellConstants.HorizontalSpacing.checkbox),
            
            descriptionTextView.topAnchor.constraint(equalTo: reminderTextView.bottomAnchor, 
                                                     constant: CellConstants.VerticalSpacing.afterReminder),
            descriptionTextView.leadingAnchor.constraint(equalTo: backViewMargins.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: checkboxButton.leadingAnchor, 
                                                          constant: -CellConstants.HorizontalSpacing.checkbox),
            
            separatorView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor,
                                               constant: CellConstants.VerticalSpacing.common),
            separatorView.leadingAnchor.constraint(equalTo: backViewMargins.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: backViewMargins.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: CellConstants.separatorHeight),
            
            dateTextField.topAnchor.constraint(equalTo: separatorView.bottomAnchor,
                                           constant: CellConstants.VerticalSpacing.common),
            dateTextField.leadingAnchor.constraint(equalTo: backViewMargins.leadingAnchor),
            
            checkboxButton.trailingAnchor.constraint(equalTo: backViewMargins.trailingAnchor),
            checkboxButton.centerYAnchor.constraint(equalTo: backView.topAnchor,
                                            constant: CheckboxConstants.centerYOffset),
            checkboxButton.widthAnchor.constraint(equalToConstant: CheckboxConstants.width)
        ])
    }
}

//MARK: UITextViewDelegate
extension ToDoTableViewCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == TextViewTag.reminder {
            delegate?.reminderChanged(of: self, for: textView.text)
            return
        }
        delegate?.descriptionChanged(of: self, for: textView.text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.updateHeightOfRow(cell: self)
    }
}

//MARK: UITextFieldDelegate
extension ToDoTableViewCell: UITextFieldDelegate {
    
}

//MARK: Local Constants
extension ToDoTableViewCell {
    private enum CellConstants {
        static let contentPadding = 20.0
        static let cornerRadius = 10.0
        static let separatorHeight = 1.0
        
        enum VerticalSpacing {
            static let afterReminder = 5.0
            static let common = 15.0
        }
        enum HorizontalSpacing {
            static let checkbox = 5.0
        }
    }
    
    private enum ColorConstants {
        static let cell = UIColor.white
        static let separator = UIColor.separator.withAlphaComponent(0.1)
        
        enum Text {
            static let primary = UIColor.black
            static let secondary = UIColor.lightGray
            static let placeholder = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        }
    }
    
    private enum FontConstants {
        static let primary = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        static let secondary = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        static let placeholder = UIFont.systemFont(ofSize: 12.0, weight: .medium)
    }
    
    private enum CheckboxConstants {
        enum ImageName {
            static let checked = "CheckedCheckbox"
            static let unchecked = "UncheckedCheckbox"
        }
        static let width = 26.0
        static let centerYOffset = 40.0
    }
    
    private enum CheckboxState: Int {
        case unchecked
        case checked
    }
    
    private enum TextViewTag {
        static let reminder = 10
        static let description = 20
    }
    
    private enum DefaultTextConstant {
        static let initialReminder = "New reminder"
        static let reusableText = ""
        static let description = "Add note"
        static let datePlaceholder = "Set date"
    }
}
