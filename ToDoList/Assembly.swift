//
//  Assembly.swift
//  ToDoList
//
//  Created by Владислав Головачев on 09.09.2024.
//

import UIKit

protocol AssemblyProtocol {
    func createMainModule(router: RouterProtocol) -> UIViewController
}

struct Assembly: AssemblyProtocol {
    func createMainModule(router: RouterProtocol) -> UIViewController {
        let vc = MainViewController()
        let interactor = MainInteractor()
        let presenter = MainPresenter(view: vc, interactor: interactor, router: router)
        
        vc.presenter = presenter
        interactor.presenter = presenter
        
        return vc
    }
}
