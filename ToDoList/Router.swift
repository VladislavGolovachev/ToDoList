//
//  Router.swift
//  ToDoList
//
//  Created by Владислав Головачев on 09.09.2024.
//

import UIKit

protocol RouterProtocol {
    func initiateRootViewController() -> UIViewController
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
}
