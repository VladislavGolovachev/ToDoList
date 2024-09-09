//
//  MainPresenter.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import Foundation

protocol MainViewProtocol: AnyObject {
    
}

protocol MainViewPresenterProtocol: AnyObject {
    init(view: MainViewProtocol, interactor: MainInteractorInputProtocol, router: RouterProtocol)
    
}

final class MainPresenter: MainViewPresenterProtocol {
    let concurrentQueue = DispatchQueue(label: "concurrentqueue-presenter-vladislavgolovachev",
                                        qos: .userInitiated,
                                        attributes: .concurrent)
    
    weak var view: MainViewProtocol?
    let interactor: MainInteractorInputProtocol?
    let router: RouterProtocol?
    
    init(view: any MainViewProtocol, interactor: any MainInteractorInputProtocol, router: any RouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension MainPresenter: MainInteractorOutputProtocol {
    
}
