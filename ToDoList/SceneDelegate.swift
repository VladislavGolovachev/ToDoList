//
//  SceneDelegate.swift
//  ToDoList
//
//  Created by Владислав Головачев on 03.09.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        let assembly = Assembly()
        let router = Router(assembly: assembly)
        let vc = router.initiateRootViewController()
        
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}
