//
//  MainViewController.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import UIKit

class MainViewController: UIViewController {
    //MARK: Properties
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: .plain)
        tableView.register(ToDoTableViewCell.self,
                           forCellReuseIdentifier: ToDoTableViewCell.reuseIdentifier)
        
        tableView.backgroundColor = MainViewConstants.Color.background
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    //MARK: ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MainViewConstants.Color.background
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        setupConstraints()
    }
}

//MARK: Private Functions
extension MainViewController {
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
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
