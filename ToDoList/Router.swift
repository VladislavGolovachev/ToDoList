//
//  Router.swift
//  ToDoList
//
//  Created by Владислав Головачев on 09.09.2024.
//

import UIKit

protocol RouterProtocol {
    func initiateRootViewController() -> UIViewController
    func showAlert(message: String)
}

final class Router: RouterProtocol {
    private let assembly: AssemblyProtocol
    private var rootViewController: UIViewController?
    
    init(assembly: AssemblyProtocol) {
        self.assembly = assembly
    }
    
    func initiateRootViewController() -> UIViewController {
        let vc = assembly.createMainModule(router: self)
        rootViewController = vc
        
        return vc
    }
    
    func showAlert(message: String) {
        func showAlert(message: String) {
            let alert = UIAlertController(title: "An error caused",
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default))
            
            rootViewController?.present(alert, animated: true)
        }
    }
}
