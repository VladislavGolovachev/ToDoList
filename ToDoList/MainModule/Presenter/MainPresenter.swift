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
    
}

final class MainPresenter: MainViewPresenterProtocol {
    let a = 2
}

extension MainPresenter: MainInteractorOutputProtocol {
    
}
