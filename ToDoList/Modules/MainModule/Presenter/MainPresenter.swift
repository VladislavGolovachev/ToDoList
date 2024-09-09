//
//  MainPresenter.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import Foundation

protocol MainViewProtocol: AnyObject {
    func reload()
}

protocol MainViewPresenterProtocol: AnyObject {
    init(view: MainViewProtocol, interactor: MainInteractorInputProtocol, router: RouterProtocol)
    func loadInitialReminders()
    
    func reminder(for index: Int, isCompleted: Bool?) -> String?
    func description(for index: Int, isCompleted: Bool?) -> String?
    func isCompleted(for index: Int, isCompleted: Bool?) -> Bool
    func date(for index: Int, isCompleted: Bool?) -> String?
    func time(for index: Int, isCompleted: Bool?) -> String?
    
    func remindersCount() -> Int
    func completedRemindersCount() -> Int
    func notCompletedRemindersCount() -> Int
    
    func currentDate() -> String
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

//MARK: MainViewPresenterProtocol
extension MainPresenter: MainViewPresenterProtocol {
    func loadInitialReminders() {
        interactor.loadInitialReminders()
    }
    
    func reminder(for index: Int, isCompleted: Bool?) -> String? {
        let reminder = interactor.todoProperty(for: index, 
                                               property: .reminder,
                                               isCompleted: isCompleted) as? String
        return reminder
    }
    
    func description(for index: Int, isCompleted: Bool?) -> String? {
        let notes = interactor.todoProperty(for: index, 
                                            property: .notes,
                                            isCompleted: isCompleted) as? String
        return notes
    }
    
    func isCompleted(for index: Int, isCompleted: Bool?) -> Bool {
        let isCompleted = interactor.todoProperty(for: index, 
                                                  property: .isCompleted,
                                                  isCompleted: isCompleted) as? Bool
        return isCompleted ?? false
    }
    
    func date(for index: Int, isCompleted: Bool?) -> String? {
        guard let date = interactor.todoProperty(for: index, 
                                                 property: .date,
                                                 isCompleted: isCompleted) as? Date else {return nil}
        
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
    
    func time(for index: Int, isCompleted: Bool?) -> String? {
        guard let date = interactor.todoProperty(for: index,
                                                 property: .date,
                                                 isCompleted: isCompleted) as? Date else {return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let timeString = dateFormatter.string(from: date)
        
        return timeString
    }
    
    func currentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM"
        
        let dateString = dateFormatter.string(from: Date.now)
        
        return dateString
    }
    
    func remindersCount() -> Int {
        let count = interactor.remindersCount(areForCompleted: nil)
        return count
    }
    
    func completedRemindersCount() -> Int {
        let count = interactor.remindersCount(areForCompleted: true)
        return count
    }
    
    func notCompletedRemindersCount() -> Int {
        let count = interactor.remindersCount(areForCompleted: false)
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
