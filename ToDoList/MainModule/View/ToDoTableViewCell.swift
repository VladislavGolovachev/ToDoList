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
    static let reuseIdentifier = "ToDoCell"
    
    weak var cellDelegate: CellDelegateProtocol?
    
    let backView = {
        let view = UIView()
        view.backgroundColor = MainViewConstants.Color.cell
        view.layer.cornerRadius = MainViewConstants.Cell.cornerRadius
        
        let padding = MainViewConstants.Cell.contentPadding
        view.layoutMargins = UIEdgeInsets(top: padding, left: padding,
                                          bottom: padding, right: padding)
        
        return view
    }()
    
    let reminderTextView = {
        let textView = UITextView()
        textView.backgroundColor = MainViewConstants.Color.cell
        textView.isScrollEnabled = false
        
        textView.text = "Client Review & Feedback"
        textView.font = MainViewConstants.Font.primary
        textView.textColor = MainViewConstants.Color.Text.primary
        
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }()
    let descriptionTextView = {
        let textView = UITextView()
        textView.backgroundColor = MainViewConstants.Color.cell
        textView.isScrollEnabled = false
        
        textView.text = "Crypto Wallet"
        textView.font = MainViewConstants.Font.secondary
        textView.textColor = MainViewConstants.Color.Text.secondary
        
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }()
    
    let separatorView = {
        let view = UIView()
        view.backgroundColor = MainViewConstants.Color.separator
        
        return view
    }()
    
    let dateLabel = {
        let label = UILabel()
        label.text = "Today"
        
        label.font = MainViewConstants.Font.secondary
        label.textColor = MainViewConstants.Color.Text.secondary
        
        return label
    }()
    let timeLabel = {
        let label = UILabel()
        label.text = "10:00PM-11:45PM"
        
        label.font = MainViewConstants.Font.time
        label.textColor = MainViewConstants.Color.Text.time
        
        return label
    }()
    
    let checkboxButton = {
        let button = ButtonWithExpandedHitbox(type: .custom)
        let name = MainViewConstants.Checkbox.Name.unchecked
        let circleImage = UIImage(named: name)
        
        button.setImage(circleImage, for: .normal)
        button.tag = 0
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = MainViewConstants.Color.background
        
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
        descriptionTextView.text = " "
    }
}

//MARK: Actions
extension ToDoTableViewCell {
    @objc private func action(_ sender: UIButton) {
        var name: String
        if checkboxButton.tag == 0 {
            name = MainViewConstants.Checkbox.Name.checked
        } else {
            name = MainViewConstants.Checkbox.Name.unchecked
        }
        checkboxButton.tag = 1 - checkboxButton.tag
        
        let image = UIImage(named: name)
        sender.setImage(image, for: .normal)
    }
}

//MARK: Private Functions
extension ToDoTableViewCell {
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
        
        let halfMinimumLineSpacing = MainViewConstants.CollectionView.minimumLineSpacing / 2.0
        let backViewMargins = backView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, 
                                                constant: halfMinimumLineSpacing),
            
            backView.topAnchor.constraint(equalTo: contentView.topAnchor, 
                                          constant: halfMinimumLineSpacing),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, 
                                              constant: MainViewConstants.Cell.padding),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, 
                                               constant: -MainViewConstants.Cell.padding),
            backView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor, 
                                             constant: MainViewConstants.Cell.padding),
            
            reminderTextView.topAnchor.constraint(equalTo: backViewMargins.topAnchor),
            reminderTextView.leadingAnchor.constraint(equalTo: backViewMargins.leadingAnchor),
            reminderTextView.trailingAnchor.constraint(equalTo: checkboxButton.leadingAnchor,
                                                       constant: -MainViewConstants.Cell.HorizontalSpacing.checkbox),
            
            descriptionTextView.topAnchor.constraint(equalTo: reminderTextView.bottomAnchor, 
                                                     constant: MainViewConstants.Cell.VerticalSpacing.afterReminder),
            descriptionTextView.leadingAnchor.constraint(equalTo: backViewMargins.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: checkboxButton.leadingAnchor, 
                                                          constant: -MainViewConstants.Cell.HorizontalSpacing.checkbox),
            
            separatorView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor,
                                               constant: MainViewConstants.Cell.VerticalSpacing.common),
            separatorView.leadingAnchor.constraint(equalTo: backViewMargins.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: backViewMargins.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: MainViewConstants.Cell.separatorHeight),
            
            dateLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor,
                                           constant: MainViewConstants.Cell.VerticalSpacing.common),
            dateLabel.leadingAnchor.constraint(equalTo: backViewMargins.leadingAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor,
                                           constant: MainViewConstants.Cell.VerticalSpacing.common),
            timeLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor,
                                               constant: MainViewConstants.Cell.HorizontalSpacing.timeLabel),
            
            checkboxButton.trailingAnchor.constraint(equalTo: backViewMargins.trailingAnchor),
            checkboxButton.centerYAnchor.constraint(equalTo: backView.topAnchor,
                                            constant: MainViewConstants.Checkbox.centerYOffset),
            checkboxButton.widthAnchor.constraint(equalToConstant: MainViewConstants.Checkbox.width),
        ])
    }
}

extension ToDoTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        cellDelegate?.updateHeightOfRow(cell: self)
    }
}
