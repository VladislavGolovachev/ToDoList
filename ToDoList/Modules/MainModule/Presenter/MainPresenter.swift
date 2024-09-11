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
    func date(for index: Int) -> NSAttributedString?
    
    func remindersCount() -> Int
    func completedRemindersCount() -> Int
    func notCompletedRemindersCount() -> Int
    
    func stringDate(for: Date) -> NSAttributedString
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
}

//MARK: MainViewPresenterProtocol
extension MainPresenter: MainViewPresenterProtocol {
    func loadInitialReminders() {
        interactor.loadInitialReminders()
    }
    
    func addNewReminder() {
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
    
    func date(for index: Int) -> NSAttributedString? {
        let state = reminderState()
        guard let date = interactor.todoProperty(for: index,
                                                 amongReminders: state,
                                                 property: .date) as? Date else {return nil}
        
        return stringDate(for: date)
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
    
    func stringDate(for date: Date) -> NSAttributedString {
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
