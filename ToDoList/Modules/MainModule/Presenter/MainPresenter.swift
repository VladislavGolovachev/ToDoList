//
//  MainPresenter.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import Foundation

protocol MainViewProtocol: AnyObject {
    var reminderCounts: [Int] {get set}
    var currentReminders: [Todo] {get set}
    var selectedIndexOfSegmentedControl: Int {get}
    
    func reload()
    func reloadSegmentedControl()
    
    func animateCellAdding()
    func animateCheckboxHit(at: IndexPath)
    func animateCellDeleting(at: IndexPath)
}

protocol MainViewPresenterProtocol: AnyObject {
    init(view: MainViewProtocol, interactor: MainInteractorInputProtocol, router: RouterProtocol)
    func initialLoading()
    func fetchTodoList(completion: (() -> Void)?)
    
    func addNewReminder()
    func updateReminder(for index: Int, for item: TodoKeys, with value: Any)
    func deleteReminder(for index: Int)
    
    func currentDate() -> String
    func attributedString(from date: Date) -> NSAttributedString
}

//MARK: MainPresenter
final class MainPresenter {
    let queue = DispatchQueue(label: "serialqueue-presenter-vladislavgolovachev",
                                        qos: .utility)
    
    weak var view: MainViewProtocol?
    let interactor: MainInteractorInputProtocol
    let router: RouterProtocol
    
    init(view: MainViewProtocol, interactor: MainInteractorInputProtocol, router: RouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

//MARK: MainViewPresenterProtocol
extension MainPresenter: MainViewPresenterProtocol {
    func initialLoading() {
        interactor.loadInitialReminders() { [weak self] in
            self?.interactor.fetchInitialCounts()
            self?.interactor.fetchTodos(amongReminders: .notSpecified)
        }
    }
    
    func fetchTodoList(completion: (() -> Void)?) {
        let workItem = DispatchWorkItem {
            let state = self.reminderState()
            self.interactor.fetchTodos(amongReminders: state)
        }
        DispatchQueue.main.async(execute: workItem)
        
        workItem.notify(queue: .main) {
            completion?()
        }
    }
    
    func addNewReminder() {
        prepareViewForAddingCell()
        
        view?.reloadSegmentedControl()
        view?.animateCellAdding()
        
        interactor.addNewReminder()
    }
    
    func updateReminder(for index: Int, for item: TodoKeys, with value: Any) {
        prepareViewForUpdatingCell(forRow: index, key: item, value: value)
        
        let state = reminderState()
        let keyedValues = [item: value]

        if item != .isCompleted {
            interactor.updateReminder(for: index,
                                      amongReminders: state,
                                      with: keyedValues,
                                      completion: nil)
            return
        }
        
        if state == .notSpecified {
            interactor.updateReminder(for: index,
                                      amongReminders: state,
                                      with: keyedValues) { [weak self] in
                self?.interactor.fetchTodos(amongReminders: state)
            }
            
            return
        }
        
        view?.reloadSegmentedControl()
        view?.animateCheckboxHit(at: IndexPath(row: index, section: 0))
    }
    
    func deleteReminder(for index: Int) {
        prepareViewForDeletingCell(forRow: index)
        
        let indexPath = IndexPath(row: index, section: 0)
        view?.reloadSegmentedControl()
        view?.animateCellDeleting(at: indexPath)
        
        let state = reminderState()
        interactor.deleteReminder(for: index, amongReminders: state)
    }
    
    func currentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM"
        
        let dateString = dateFormatter.string(from: Date.now)
        
        return dateString
    }
    
    func attributedString(from date: Date) -> NSAttributedString {
        let dateString = dateAttributedString(from: date)
        let timeString = timeAttributedString(from: date)
        
        let mutableString = NSMutableAttributedString()
        mutableString.append(dateString)
        mutableString.append(timeString)
        
        return mutableString
    }
}

//MARK: MainInteractorOutputProtocol
extension MainPresenter: MainInteractorOutputProtocol {
    func reloadView(with todos: [Todo]) {
        DispatchQueue.main.async {
            self.view?.currentReminders = todos
            self.view?.reload()
        }
    }
    
    func reloadTabs(with counts: [Int]) {
        DispatchQueue.main.async {
            self.view?.reminderCounts = counts
            self.view?.reloadSegmentedControl()
        }
    }
    
    func errorCaused(message: String) {
        DispatchQueue.main.async {
            self.router.showAlert(message: message)
        }
    }
    
}

//MARK: Private Functions
extension MainPresenter {
    private func reminderState() -> ReminderState {
        guard let index = view?.selectedIndexOfSegmentedControl else {
            return .notSpecified
        }
        
        switch index {
        case 1:
            return .notCompleted
        case 2:
            return .completed
        default:
            return .notSpecified
        }
    }
    
    private func dateAttributedString(from date: Date) -> NSAttributedString {
        var dateString: String
        switch true {
        case Calendar.current.isDateInYesterday(date):
            dateString = "Yesterday"
        case Calendar.current.isDateInToday(date):
            dateString = "Today"
        case Calendar.current.isDateInTomorrow(date):
            dateString = "Tomorrow"
            
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy"
            dateString = dateFormatter.string(from: date)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: MainViewConstants.Font.date,
            .foregroundColor: MainViewConstants.Color.date
        ]
        let attributedString = NSAttributedString(string: dateString + "   ", attributes: attributes)
        
        return attributedString
    }
    
    private func timeAttributedString(from date: Date) -> NSAttributedString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma"
        let timeString = dateFormatter.string(from: date)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: MainViewConstants.Font.time,
            .foregroundColor: MainViewConstants.Color.time
        ]
        let attributedString = NSAttributedString(string: timeString, attributes: attributes)
        
        return attributedString
    }
    
    private func prepareViewForUpdatingCell(forRow index: Int, key: TodoKeys, value: Any) {
        switch key {
        case .reminder:
            guard let string = value as? String else {return}
            view?.currentReminders[index].reminder = string
            return
            
        case .notes:
            view?.currentReminders[index].notes = value as? String
            return
            
        case .date:
            view?.currentReminders[index].date = value as? Date
            return
            
        default: break
        }
        
        guard let isCompleted = value as? Bool else {return}
        if isCompleted {
            view?.reminderCounts[1] -= 1
            view?.reminderCounts[2] += 1
        } else {
            view?.reminderCounts[1] += 1
            view?.reminderCounts[2] -= 1
        }
        view?.currentReminders.remove(at: index)
    }
    
    private func prepareViewForAddingCell() {
        view?.reminderCounts[0] += 1
        view?.reminderCounts[1] += 1
        
        let todo = Todo(reminder: MainViewConstants.initialReminderText,
                        isCompleted: false)
        view?.currentReminders.insert(todo, at: 0)
    }
    
    private func prepareViewForDeletingCell(forRow index: Int) {
        guard let object = view?.currentReminders[index] else {return}
        
        if object.isCompleted {
            view?.reminderCounts[2] -= 1
        } else {
            view?.reminderCounts[1] -= 1
        }
        view?.reminderCounts[0] -= 1
        
        view?.currentReminders.remove(at: index)
    }
}
