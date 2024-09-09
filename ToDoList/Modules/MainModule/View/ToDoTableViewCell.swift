//
//  ToDoTableViewCell.swift
//  ToDoList
//
//  Created by Владислав Головачев on 04.09.2024.
//

import UIKit

protocol CellDelegateProtocol: AnyObject {
    func updateHeightOfRow(cell: UITableViewCell)
}

final class ToDoTableViewCell: UITableViewCell {
    //MARK: Properties
    static let reuseIdentifier = "ToDoCell"
    
    weak var cellDelegate: CellDelegateProtocol?
    
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
        
        textView.text = "New reminder"
        textView.font = FontConstants.primary
        textView.textColor = ColorConstants.Text.primary
        
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }()
    private let descriptionTextView = {
        let textView = UITextView()
        textView.backgroundColor = ColorConstants.cell
        textView.isScrollEnabled = false
        
        textView.text = "Notes"
        textView.font = FontConstants.secondary
        textView.textColor = ColorConstants.Text.secondary
        
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }()
    private let separatorView = {
        let view = UIView()
        view.backgroundColor = ColorConstants.separator
        
        return view
    }()
    private let dateLabel = {
        let label = UILabel()
        label.text = "No date was set"
        
        label.font = FontConstants.secondary
        label.textColor = ColorConstants.Text.secondary
        
        return label
    }()
    private let timeLabel = {
        let label = UILabel()
        label.text = "No time was set"
        
        label.font = FontConstants.time
        label.textColor = ColorConstants.Text.time
        
        return label
    }()
    private let checkboxButton = {
        let button = ButtonWithExpandedHitbox(type: .custom)
        let name = CheckboxConstants.ImageName.unchecked
        let circleImage = UIImage(named: name)
        
        button.setImage(circleImage, for: .normal)
        button.tag = 0
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = MainViewConstants.backgroundColor
        
        reminderTextView.delegate = self
        descriptionTextView.delegate = self
        
        checkboxButton.addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reminderTextView.text = " "
        descriptionTextView.text = "Notes"
        dateLabel.text = "No date was set"
        timeLabel.text = "No time was set"
        setReminderCheckedState(.notCompleted)
    }
}

//MARK: Actions
extension ToDoTableViewCell {
    @objc private func action(_ sender: UIButton) {
        if sender.tag == 0 {
            setReminderCheckedState(.completed)
            return
        }
        setReminderCheckedState(.notCompleted)
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
            setReminderCheckedState(.completed)
            return
        }
        setReminderCheckedState(.notCompleted)
    }
    
    func setDate(_ date: String) {
        dateLabel.text = date
    }
    
    func setTime(_ time: String) {
        timeLabel.text = time
    }
}

//MARK: Private Functions
extension ToDoTableViewCell {
    private func setReminderCheckedState(_ state: CheckboxState) {
        var name: String
        if state == .completed {
            name = CheckboxConstants.ImageName.checked
            checkboxButton.tag = 1
        } else {
            name = CheckboxConstants.ImageName.unchecked
            checkboxButton.tag = 0
        }
        
        let image = UIImage(named: name)
        checkboxButton.setImage(image, for: .normal)
    }
    
    private func addSubviews() {
        backView.addSubview(reminderTextView)
        backView.addSubview(descriptionTextView)
        backView.addSubview(separatorView)
        backView.addSubview(dateLabel)
        backView.addSubview(timeLabel)
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
            backView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor, 
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
            
            dateLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor,
                                           constant: CellConstants.VerticalSpacing.common),
            dateLabel.leadingAnchor.constraint(equalTo: backViewMargins.leadingAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor,
                                           constant: CellConstants.VerticalSpacing.common),
            timeLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor,
                                               constant: CellConstants.HorizontalSpacing.timeLabel),
            
            checkboxButton.trailingAnchor.constraint(equalTo: backViewMargins.trailingAnchor),
            checkboxButton.centerYAnchor.constraint(equalTo: backView.topAnchor,
                                            constant: CheckboxConstants.centerYOffset),
            checkboxButton.widthAnchor.constraint(equalToConstant: CheckboxConstants.width),
        ])
    }
}

//MARK: UITextViewDelegate
extension ToDoTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        cellDelegate?.updateHeightOfRow(cell: self)
    }
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
            static let timeLabel = 5.0
        }
    }
    
    private enum ColorConstants {
        static let cell = UIColor.white
        static let separator = UIColor.separator.withAlphaComponent(0.1)
        
        enum Text {
            static let primary = UIColor.black
            static let secondary = UIColor.lightGray
            static let time = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        }
    }
    
    private enum FontConstants {
        static let primary = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        static let secondary = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        static let time = UIFont.systemFont(ofSize: 12.0, weight: .medium)
    }
    
    private enum CheckboxConstants {
        enum ImageName {
            static let checked = "CheckedCheckbox"
            static let unchecked = "UncheckedCheckbox"
        }
        static let width = 26.0
        static let centerYOffset = 40.0
    }
    
    private enum CheckboxState {
        case completed
        case notCompleted
    }
}
