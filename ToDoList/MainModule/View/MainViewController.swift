//
//  MainViewController.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import UIKit

class MainViewController: UIViewController {
    //MARK: Properties
    let lbl1 = {
        let label = UILabel()
        label.backgroundColor = ColorConstants.interactiveTheme
        label.text = "25"
        label.textColor = .white
        label.font = label.font.withSize(12)
        label.layer.cornerRadius = 15
        
        return label
    }()
    let lbl2 = {
        let label = UILabel()
        label.backgroundColor = ColorConstants.interactiveTheme
        label.text = "13"
        label.textColor = .white
        label.font = label.font.withSize(12)
        label.layer.cornerRadius = 15
        
        return label
    }()
    let lbl3 = {
        let label = UILabel()
        label.backgroundColor = ColorConstants.interactiveTheme
        label.text = "12"
        label.textColor = .white
        label.font = label.font.withSize(12)
        label.layer.cornerRadius = 15
        
        return label
    }()
    
    let tableView = {
        let tableView = UITableView(frame: CGRectZero, style: .plain)
        tableView.register(ToDoTableViewCell.self,
                           forCellReuseIdentifier: ToDoTableViewCell.reuseIdentifier)
        
        tableView.backgroundColor = MainViewConstants.backgroundColor
        tableView.separatorStyle = .none
        
        return tableView
    }()
    let titleLabel = {
        let label = UILabel()
        label.text = "Tasks"
        label.font = FontConstants.title
        label.textColor = ColorConstants.Text.title
        
        return label
    }()
    let dateLabel = {
        let label = UILabel()
        label.text = "Wednesday, 11 May"
        label.font = FontConstants.date
        label.textColor = ColorConstants.Text.date
        
        return label
    }()
    let segmentedControl = {
        let control = UISegmentedControl()
        control.backgroundColor = MainViewConstants.backgroundColor
        
        let string = "All"
        let titles = [string, "Opened", "Closed"]
        for (index, title) in titles.enumerated() {
            control.insertSegment(withTitle: title, at: index, animated: false)
            control.setWidth(100, forSegmentAt: index)
        }
        let segmentWidth = 60.0
        control.setWidth(segmentWidth, forSegmentAt: 0)
        let titleWidth = string.size(withAttributes: control.titleTextAttributes(for: .normal)).width
        let offset = -CGFloat(Int((segmentWidth - titleWidth) / 2)) + 5
        
        control.setContentPositionAdjustment(UIOffset(horizontal: offset, vertical: 0), forSegmentType: .left, barMetrics: .default)
        
        control.setTitleTextAttributes([.foregroundColor: ColorConstants.interactiveTheme],
                                       for: .selected)
        control.setTitleTextAttributes([.foregroundColor: ColorConstants.Text.date],
                                       for: .normal)
        
        
        let size = CGSize(width: 1, height: 20)
        let rect = CGRect(origin: CGPointZero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        MainViewConstants.backgroundColor.setFill()
        UIRectFill(rect)
        let blankImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let sizet = CGSize(width: 3, height: 20)
        let rectt = CGRect(origin: CGPointZero, size: sizet)
        UIGraphicsBeginImageContextWithOptions(sizet, false, 0.0)
        ColorConstants.Text.date.withAlphaComponent(0.4).setFill()
        UIRectFill(rectt)
        let separatorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        control.setBackgroundImage(blankImage, for: .normal, barMetrics: .default)
        control.setDividerImage(blankImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        control.setDividerImage(separatorImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        control.setDividerImage(separatorImage, forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
        control.setDividerImage(separatorImage, forLeftSegmentState: .selected, rightSegmentState: .highlighted, barMetrics: .default)
        control.setDividerImage(separatorImage, forLeftSegmentState: .highlighted, rightSegmentState: .selected, barMetrics: .default)
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = MainViewConstants.backgroundColor
        
        return control
    }()
    let newTaskButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor =  ColorConstants.button
        button.layer.cornerRadius = ButtonConstants.cornerRadius
        
        button.setImage(UIImage(named: ButtonConstants.imageName), for: .normal)
        
        var config = UIButton.Configuration.plain()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontConstants.button,
            .foregroundColor: ColorConstants.interactiveTheme
        ]
        config.attributedTitle = AttributedString("New Task", attributes: AttributeContainer(attributes))
        config.imagePadding = ButtonConstants.imagePadding
        button.configuration = config
        
        return button
    }()
    
    //MARK: ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MainViewConstants.backgroundColor
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addSubviews()
        setupConstraints()
        
        
//        segmentedControl.addSubview(lbl1)
//        segmentedControl.addSubview(lbl2)
//        segmentedControl.addSubview(lbl3)
//        
//        lbl1.translatesAutoresizingMaskIntoConstraints = false
//        lbl2.translatesAutoresizingMaskIntoConstraints = false
//        lbl3.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            lbl1.centerXAnchor.constraint(equalTo: segmentedControl.leadingAnchor, constant: 60),
//            lbl1.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor),
//            
//            lbl2.centerXAnchor.constraint(equalTo: segmentedControl.centerXAnchor, constant: 25),
//            lbl2.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor),
//            
//            lbl3.centerXAnchor.constraint(equalTo: segmentedControl.trailingAnchor, constant: -13),
//            lbl3.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor),
//        ])
    }
}

//MARK: Private Functions
extension MainViewController {
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(dateLabel)
        view.addSubview(segmentedControl)
        view.addSubview(newTaskButton)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        view.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let safeArea = view.safeAreaLayoutGuide
        let padding = MainViewConstants.padding
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, 
                                            constant: ViewConstants.upperPadding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: newTaskButton.leadingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, 
                                           constant: ViewConstants.Spacing.afterTitle),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            dateLabel.trailingAnchor.constraint(equalTo: newTaskButton.leadingAnchor),
            
            newTaskButton.topAnchor.constraint(equalTo: safeArea.topAnchor, 
                                               constant: ViewConstants.upperPadding),
            newTaskButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            newTaskButton.widthAnchor.constraint(equalToConstant: ButtonConstants.width),
            newTaskButton.heightAnchor.constraint(equalToConstant: ButtonConstants.height),
            
            segmentedControl.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, 
                                                  constant: ViewConstants.Spacing.common),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
//            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 30),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, 
                                           constant: ViewConstants.Spacing.common),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//MARK: UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = ToDoTableViewCell.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath)
        as? ToDoTableViewCell ?? ToDoTableViewCell()
        
        cell.cellDelegate = self
        
        return cell
    }
}

//MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
}

//MARK: MainViewProtocol
extension MainViewController: MainViewProtocol {
    
}

//MARK: CellDelegateProtocol
extension MainViewController: CellDelegateProtocol {
    func updateHeightOfRow(cell: UITableViewCell) {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}

//MARK: Local Constants
extension MainViewController {
    
    private enum ViewConstants {
        static let upperPadding = 10.0
        enum Spacing {
            static let common = 20.0
            static let afterTitle = 2.0
        }
    }
    
    private enum ColorConstants {
        static let interactiveTheme = UIColor.systemBlue
        static let button = UIColor.systemBlue.withAlphaComponent(0.1)
        
        enum Text {
            static let title = UIColor.black
            static let date = UIColor.lightGray
        }
    }
    
    private enum FontConstants {
        static let title = UIFont.systemFont(ofSize: 28.0, weight: .bold)
        static let date = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        static let button = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    }
    
    private enum ButtonConstants {
        static let cornerRadius = 12.0
        static let imageName = "Plus"
        static let imagePadding = 5.0
        static let width = 130.0
        static let height = 40.0
    }
}
