//
//  MainViewController.swift
//  GPUImageDemo
//
//  Created by pnam on 15/10/2022.
//

import UIKit

class MainViewController: UITabBarController {
    private lazy var homeViewController: HomeViewController = {
        let homeViewController = HomeViewController()
        return homeViewController
    }()
    
    private lazy var settingViewController: SettingViewController = {
        let settingViewController = SettingViewController()
        return settingViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        settingViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house"))
        
        let settingNavigationController = UINavigationController(rootViewController: settingViewController)
        settingViewController.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear"))
        
        let viewControllers = [
            homeNavigationController,
            settingNavigationController
        ]
        setViewControllers(viewControllers, animated: true)
        tabBar.backgroundColor = .white.withAlphaComponent(0.7)
        selectedIndex = 1
    }
}

extension MainViewController: UITabBarControllerDelegate {
    
}
