//
//  MainViewController.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import UIKit

final class MainViewController: UIViewController {
    //MARK: Properties
    var presenter: MainViewPresenterProtocol?
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
        label.font = FontConstants.date
        label.textColor = ColorConstants.Text.date
        
        return label
    }()
    let segmentedControl = CustomSegmentedControl()
    let newTaskButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor =  ColorConstants.buttonBackground
        button.layer.cornerRadius = ButtonConstants.cornerRadius
        
        button.setImage(UIImage(named: ButtonConstants.imageName), for: .normal)
        
        var config = UIButton.Configuration.plain()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontConstants.buttonTitle,
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
        presenter?.loadInitialReminders()
        
        view.backgroundColor = MainViewConstants.backgroundColor
        
        if let dateString = presenter?.currentDate() {
            dateLabel.text = dateString
        }
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlAction(_:)), for: .valueChanged)
        newTaskButton.addTarget(self, action: #selector(newTaskButtonAction(_:)), for: .touchUpInside)
        newTaskButton.addTarget(self, action: #selector(newTaskButtonAnimation(_:)), for: .touchDown)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addSubviews()
        setupConstraints()
    }
}

//MARK: Actions
extension MainViewController {
    @objc private func segmentedControlAction(_ control: CustomSegmentedControl) {
        reloadTableAccordingToSegmentedControl()
    }
    
    @objc private func newTaskButtonAction(_ button: UIButton) {
        if segmentedControl.selectedSegmentIndex == 2 {
            segmentedControl.selectedSegmentIndex = 0
            reloadTableAccordingToSegmentedControl()
        }
        
        presenter?.addNewReminder()

        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        reloadSegmentedControl()
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .top)
        tableView.endUpdates()
    }
    
    @objc private func newTaskButtonAnimation(_ button: UIButton) {
        UIView.animate(withDuration: 0.1) {
            button.backgroundColor = ColorConstants.buttonBackground.withAlphaComponent(0.3)
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                button.backgroundColor = ColorConstants.buttonBackground
                button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
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
            segmentedControl.heightAnchor.constraint(equalToConstant: 20),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, 
                                           constant: ViewConstants.Spacing.common),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func customizeCell(_ cell: ToDoTableViewCell, at row: Int) {
        if let reminder = presenter?.reminder(for: row) {
            cell.setReminder(reminder)
        }
        if let isCompleted = presenter?.isCompleted(for: row) {
            cell.setIsCompleted(isCompleted)
        }
        if let date = presenter?.date(for: row) {
            cell.setDate(date)
        }
        if let time = presenter?.time(for: row) {
            cell.setTime(time)
        }
    }
    
    private func reloadTableAccordingToSegmentedControl() {
        let indexPath = IndexPath(row: 0, section: 0)
        
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        tableView.reloadData()
    }
    
    private func reloadSegmentedControl() {
        if let count = presenter?.remindersCount() {
            segmentedControl.setRemindersAmount(String(count), forSegment: 0)
        }
        if let count = presenter?.notCompletedRemindersCount() {
            segmentedControl.setRemindersAmount(String(count), forSegment: 1)
        }
        if let count = presenter?.completedRemindersCount() {
            segmentedControl.setRemindersAmount(String(count), forSegment: 2)
        }
    }
}

//MARK: UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            count = presenter?.remindersCount()
        case 1:
            count = presenter?.notCompletedRemindersCount()
        case 2:
            count = presenter?.completedRemindersCount()
        default:
            break
        }
        
        return count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = ToDoTableViewCell.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath)
        as? ToDoTableViewCell ?? ToDoTableViewCell()
        
        cell.cellDelegate = self
        customizeCell(cell, at: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, 
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        presenter?.deleteReminder(for: indexPath.row)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .right)
        tableView.endUpdates()
        
        reloadSegmentedControl()
    }
}

//MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
}

//MARK: MainViewProtocol
extension MainViewController: MainViewProtocol {
    var selectedIndexOfSegmentedControl: Int {
        return segmentedControl.selectedSegmentIndex
    }
    
    func reload() {
        reloadSegmentedControl()
        tableView.reloadData()
    }
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
        static let buttonBackground = UIColor.systemBlue.withAlphaComponent(0.1)
        
        enum Text {
            static let title = UIColor.black
            static let date = UIColor.lightGray
        }
    }
    
    private enum FontConstants {
        static let title = UIFont.systemFont(ofSize: 28.0, weight: .bold)
        static let date = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        static let buttonTitle = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    }
    
    private enum ButtonConstants {
        static let cornerRadius = 12.0
        static let imageName = "Plus"
        static let imagePadding = 5.0
        static let width = 130.0
        static let height = 40.0
    }
}
