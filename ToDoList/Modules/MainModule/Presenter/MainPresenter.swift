//
//  MainPresenter.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import Foundation

protocol MainViewProtocol: AnyObject {
    var selectedIndexOfSegmentedControl: Int {get}
    func reload()
}

protocol MainViewPresenterProtocol: AnyObject {
    init(view: MainViewProtocol, interactor: MainInteractorInputProtocol, router: RouterProtocol)
    func loadInitialReminders()
    
    func addNewReminder()
    func updateReminder(for index: Int, for item: TodoKeys, with value: Any)
    func deleteReminder(for index: Int)
    
    func currentDate() -> String
    func reminder(for index: Int) -> String?
    func description(for index: Int) -> String?
    func isCompleted(for index: Int) -> Bool
    func date(for index: Int) -> String?
    func time(for index: Int) -> String?
    
    func remindersCount() -> Int
    func completedRemindersCount() -> Int
    func notCompletedRemindersCount() -> Int
}

//MARK: MainPresenter
final class MainPresenter {
    let concurrentQueue = DispatchQueue(label: "concurrentqueue-presenter-vladislavgolovachev",
                                        qos: .userInitiated,
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
}

//MARK: MainViewPresenterProtocol
extension MainPresenter: MainViewPresenterProtocol {
    func loadInitialReminders() {
        interactor.loadInitialReminders()
    }
    
    func addNewReminder() {
        let creationDate = Date.now
        interactor.addNewReminder()
    }
    
    func updateReminder(for index: Int, for item: TodoKeys, with value: Any) {
        let state = reminderState()
        let keyedValues = [item: value]
        
        interactor.updateReminder(for: index, amongReminders: state, with: keyedValues)
    }
    
    func deleteReminder(for index: Int) {
        let state = reminderState()
        interactor.deleteReminder(for: index, amongReminders: state)
    }
    
    func currentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM"
        
        let dateString = dateFormatter.string(from: Date.now)
        
        return dateString
    }
    
    func reminder(for index: Int) -> String? {
        let state = reminderState()
        let reminder = interactor.todoProperty(for: index,
                                               amongReminders: state,
                                               property: .reminder) as? String
        return reminder
    }
    
    func description(for index: Int) -> String? {
        let state = reminderState()
        let notes = interactor.todoProperty(for: index,
                                            amongReminders: state,
                                            property: .notes) as? String
        return notes
    }
    
    func isCompleted(for index: Int) -> Bool {
        let state = reminderState()
        let isCompleted = interactor.todoProperty(for: index,
                                                  amongReminders: state,
                                                  property: .isCompleted) as? Bool
        return isCompleted ?? false
    }
    
    func date(for index: Int) -> String? {
        let state = reminderState()
        guard let date = interactor.todoProperty(for: index,
                                                 amongReminders: state,
                                                 property: .date) as? Date else {return nil}
        
        switch true {
        case Calendar.current.isDateInYesterday(date):
            return "Yesterday"
        case Calendar.current.isDateInToday(date):
            return "Today"
        case Calendar.current.isDateInTomorrow(date):
            return "Tomorrow"
            
        default: break
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd:MM:yy"
        
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func time(for index: Int) -> String? {
        let state = reminderState()
        guard let date = interactor.todoProperty(for: index,
                                                 amongReminders: state,
                                                 property: .date) as? Date else {return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let timeString = dateFormatter.string(from: date)
        
        return timeString
    }
    
    func remindersCount() -> Int {
        let count = interactor.remindersCount(ofReminders: .notSpecified)
        return count
    }
    
    func completedRemindersCount() -> Int {
        let count = interactor.remindersCount(ofReminders: .completed)
        return count
    }
    
    func notCompletedRemindersCount() -> Int {
        let count = interactor.remindersCount(ofReminders: .notCompleted)
        return count
    }
}

//MARK: MainInteractorOutputProtocol
extension MainPresenter: MainInteractorOutputProtocol {
    func errorCaused(message: String) {
        DispatchQueue.main.async {
            self.router.showAlert(message: message)
        }
    }
    
    func reloadView() {
        DispatchQueue.main.async {
            self.view?.reload()
        }
    }
}
