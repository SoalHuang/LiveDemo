//
//  AppDelegate.swift
//  LiveDemo
//
//  Created by soal on 2021/1/26.
//  Copyright © 2021 soso. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        
        let menuVC = MenuViewController(nibName: "MenuViewController", bundle: .main)
        
        window?.rootViewController = UINavigationController(rootViewController: menuVC)
        
        window?.makeKeyAndVisible()
        
        return true
    }
}

