//
//  AuthCoordinator.swift
//  OPPU
//
//  Created by rigodev on 22.05.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import Swinject

protocol AuthCoordinatorDelegate: AnyObject {
    func loggedIn()
}

final class AuthCoordinator: BaseCoordinator {
    weak var delegate: AuthCoordinatorDelegate?
    
    private let navigation: Navigatable
    private let container: Container
    private let storage: Storage
    
    init(container: Container, navigation: Navigatable) {
        self.container = container
        self.navigation = navigation
        storage = container.resolve(Storage.self)!
    }
    
    func start() {
        showLaunchingViewController()
    }
    
    func resume() {
        showLoginViewController(pushing: false)
    }
    
    private func showLaunchingViewController() {
        let controller = container.resolve(LaunchingViewController.self)!
        controller.delegate = self
        navigation.push(controller, animated: true)
    }
    
    private func showLoginViewController(pushing: Bool) {
        let controller = container.resolve(LoginViewController.self)!
        controller.delegate = self
        
        if pushing {
            navigation.push(controller, animated: true)
        } else {
            navigation.navigationController.viewControllers.insert(controller, at: 0)
            navigation.popToRoot(animated: true)
        }
    }
    
    private func openInSafari(url: URL) {
        navigation.openInSafari(url: url)
    }
    
}

extension AuthCoordinator: LaunchingViewControllerDelegate {
    func didComplete(success: Bool) {
        if success {
            delegate?.loggedIn()
        } else {
            showLoginViewController(pushing: true)
        }
    }
}

extension AuthCoordinator: LoginViewControllerDelegate {
    func loggedIn() {
        delegate?.loggedIn()
    }
    
    func openLink(_ url: URL) {
        openInSafari(url: url)
    }
}
