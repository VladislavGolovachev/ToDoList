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
    func reloadRow(at: IndexPath, isAnimationNeeded: Bool)
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
                              qos: .utility,
                              attributes: .concurrent)
    
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
        queue.async {
            self.interactor.loadInitialReminders() { [weak self] in
                self?.interactor.fetchInitialCounts()
                self?.interactor.fetchTodos(amongReminders: .notSpecified, completion: nil)
            }
        }
    }
    
    func fetchTodoList(completion: (() -> Void)?) {
        let state = reminderState()
        queue.async {
            self.interactor.fetchTodos(amongReminders: state, completion: completion)
        }
    }
    
    func addNewReminder() {
        queue.async() {
            self.prepareViewForAddingCell()
            
            DispatchQueue.main.async {
                self.view?.reloadSegmentedControl()
                self.view?.animateCellAdding()
            }
            
            self.interactor.addNewReminder()
        }
    }
    
    func updateReminder(for index: Int, for item: TodoKeys, with value: Any) {
        let state = reminderState()
        
        queue.async {
            self.prepareViewForUpdatingCell(forRow: index, key: item, value: value)
            
            let keyedValues = [item: self.validValue(of: value, forKey: item)]
            if item != .isCompleted {
                self.interactor.updateReminder(for: index,
                                               amongReminders: state,
                                               with: keyedValues,
                                               completion: nil)
                return
            }
            
            DispatchQueue.main.async {
                self.view?.reloadSegmentedControl()
            }
            
            if state == .notSpecified {
                self.interactor.updateReminder(for: index,
                                               amongReminders: state,
                                               with: keyedValues) { [weak self] in
                    self?.interactor.fetchTodos(amongReminders: state, completion: nil)
                }
                return
            }
            
            self.view?.currentReminders.remove(at: index)
            
            DispatchQueue.main.async {
                self.view?.animateCheckboxHit(at: IndexPath(row: index, section: 0))
            }
            
            self.interactor.updateReminder(for: index,
                                           amongReminders: state,
                                           with: keyedValues,
                                           completion: nil)
        }
    }
    
    func deleteReminder(for index: Int) {
        let state = reminderState()
        queue.async {
            self.prepareViewForDeletingCell(forRow: index)
            
            let indexPath = IndexPath(row: index, section: 0)
            DispatchQueue.main.async {
                self.view?.reloadSegmentedControl()
                self.view?.animateCellDeleting(at: indexPath)
            }
            
            self.interactor.deleteReminder(for: index, amongReminders: state)
        }
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
    func reloadView(with todos: [Todo], completion: (() -> Void)?) {
        DispatchQueue.main.async {
            print(todos.count, "fetched from the interactor")
            self.view?.currentReminders = todos
            self.view?.reload()
            
            self.queue.async {
                completion?()
            }
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
            let text = modifiedText(string)
            view?.currentReminders[index].reminder = text
            
            if text.count == string.count {
                return
            }
            DispatchQueue.main.async {
                self.view?.reloadRow(at: IndexPath(row: index, section: 0), isAnimationNeeded: false)
            }
            return
            
        case .notes:
            guard let string = value as? String else {return}
            let text = modifiedText(string)
            view?.currentReminders[index].notes = text
            
            if text.count == string.count {
                return
            }
            DispatchQueue.main.async {
                self.view?.reloadRow(at: IndexPath(row: index, section: 0), isAnimationNeeded: true)
            }
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
    
    private func modifiedText(_ rawText: String) -> String {
        var modifiedText = rawText
        
        for char in rawText.reversed() {
            switch char {
            case " ", "\n":
                modifiedText.removeLast()
                
            default:
                return modifiedText
            }
        }
        
        return modifiedText
    }
    
    private func validValue(of value: Any, forKey key: TodoKeys) -> Any {
        switch key {
        case .reminder, .notes:
            guard let rawText = value as? String else {
                return ""
            }
            return modifiedText(rawText)
            
        default:
            return value
        }
    }
}
