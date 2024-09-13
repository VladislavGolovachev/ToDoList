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
    var currentTodos = [Todo]()
    var todoCounts = [0, 0, 0]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: .plain)
        tableView.register(ToDoTableViewCell.self,
                           forCellReuseIdentifier: ToDoTableViewCell.reuseIdentifier)
        
        tableView.backgroundColor = MainViewConstants.Color.background
        tableView.separatorStyle = .none
        
        tableView.showsVerticalScrollIndicator = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    let titleLabel = {
        let label = UILabel()
        label.text = "Tasks"
        label.font = FontConstants.title
        label.textColor = ColorConstants.Text.title
        
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        
        label.text = presenter?.currentDate()
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
        view.isUserInteractionEnabled = false
        presenter?.initialLoading()
        
        view.backgroundColor = MainViewConstants.Color.background
        
        setActions()
        addSubviews()
        setupConstraints()
    }
}

//MARK: Actions
extension MainViewController {
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func segmentedControlAction(_ control: CustomSegmentedControl) {
        presenter?.fetchTodoList(completion: nil)
    }
    
    @objc private func newTaskButtonAction(_ button: UIButton) {
        if segmentedControl.selectedSegmentIndex == 2 {
            segmentedControl.selectedSegmentIndex = 0
            
            presenter?.fetchTodoList { [weak self] in
                self?.presenter?.addNewReminder()
            }
            return
        }
        
        presenter?.addNewReminder()
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

//MARK: Private Functions and Computed Properties
extension MainViewController {
    private var indexPathZero: IndexPath {
        IndexPath(row: 0, section: 0)
    }
    
    private func setActions() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlAction(_:)), for: .valueChanged)
        newTaskButton.addTarget(self, action: #selector(newTaskButtonAction(_:)), for: .touchUpInside)
        newTaskButton.addTarget(self, action: #selector(newTaskButtonAnimation(_:)), for: .touchDown)
    }
    
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
    
    private func scrollToTop() {
        if tableView.numberOfRows(inSection: 0) == 0 {
            return
        }
        tableView.scrollToRow(at: indexPathZero, at: .top, animated: false)
    }
    
    private func customizeCell(_ cell: ToDoTableViewCell, at indexPath: IndexPath) {
        let todo = currentTodos[indexPath.row]
        
        cell.setReminder(todo.reminder)
        if let notes = todo.notes {
            cell.setDescription(notes)
        }
        cell.setIsCompleted(todo.isCompleted)
        guard let date = todo.date,
              let dateString = presenter?.attributedString(from: date) else {return}
        cell.setDate(dateString)
    }
}

//MARK: UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTodos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = ToDoTableViewCell.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath)
        as? ToDoTableViewCell ?? ToDoTableViewCell()
        
        cell.delegate = self
        customizeCell(cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, 
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        presenter?.deleteReminder(for: indexPath.row)
    }
}

//MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, 
                   didEndDisplaying cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ToDoTableViewCell else {return}
        cell.delegate = nil
    }
}

//MARK: MainViewProtocol
extension MainViewController: MainViewProtocol {
    var selectedIndexOfSegmentedControl: Int {
        return segmentedControl.selectedSegmentIndex
    }
    var currentReminders: [Todo] {
        get {
            currentTodos
        }
        set {
            currentTodos = newValue
        }
    }
    var reminderCounts: [Int] {
        get {
            todoCounts
        }
        set {
            todoCounts = newValue
        }
    }
    
    func reload() {
        tableView.reloadData()
        scrollToTop()
        view.isUserInteractionEnabled = true
    }
    
    func reloadSegmentedControl() {
        for i in 0...2 {
            segmentedControl.setRemindersAmount(String(todoCounts[i]), forSegment: i)
        }
    }
    
    func animateCellAdding() {
        scrollToTop()

        tableView.beginUpdates()
        tableView.insertRows(at: [indexPathZero], with: .top)
        tableView.endUpdates()
    }
    
    func animateCheckboxHit(at indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            tableView.deleteRows(at: [indexPath], with: .right)
        case 2:
            tableView.deleteRows(at: [indexPath], with: .left)
        default:
            return
        }
    }
    
    func animateCellDeleting(at indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .left)
        tableView.endUpdates()
    }
}

//MARK: CellDelegateProtocol
extension MainViewController: CellDelegateProtocol {
    func reminderChanged(of cell: ToDoTableViewCell, for reminder: String) {
        guard let index = tableView.indexPath(for: cell)?.row else {return}
        presenter?.updateReminder(for: index, for: .reminder, with: reminder)
    }
    
    func descriptionChanged(of cell: ToDoTableViewCell, for description: String) {
        guard let index = tableView.indexPath(for: cell)?.row else {return}
        presenter?.updateReminder(for: index, for: .notes, with: description)
    }
    
    func dateNeedsUpdate(of cell: ToDoTableViewCell, for date: Date) {
        guard let index = tableView.indexPath(for: cell)?.row,
              let presenter else {return}
        
        let dateString = presenter.attributedString(from: date)
        cell.setDate(dateString)
        
        presenter.updateReminder(for: index, for: .date, with: date)
    }
    
    func checkboxStateChanged(of cell: ToDoTableViewCell, 
                              forCheckedState checkboxState: Bool) {
        guard let index = tableView.indexPath(for: cell)?.row else {return}
        presenter?.updateReminder(for: index, for: .isCompleted, with: checkboxState)
    }
    
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
