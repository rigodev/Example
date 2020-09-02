//
//  AuthAssembly.swift
//  OPPU
//
//  Created by rigodev on 22.05.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import Swinject

struct AuthAssembly: BaseAssembly {
    
    func registerApi(container: Container) {
        container.register(AuthApiProtocol.self) { resolver in
            let loggerPlugin = resolver.resolve(CoreNetworkLoggerPluginProtocol.self)!.logger
            let sessionManager = resolver.resolve(NetworkSessionProtocol.self)!
            let provider = NetworkProvider<AuthEndpoints>(
                session: sessionManager.networkSession,
                plugins: [loggerPlugin],
                errorsToCheck: [])
            return AuthApi(provider: provider)
        }
    }
    
    func registerRepositories(container: Container) {
        container.register(AuthRepositoryProtocol.self) { resolver in
            let api = resolver.resolve(AuthApiProtocol.self)!
            return AuthRepository(api: api)
        }
    }
    
    func registerViewModels(container: Container) {
        container.register(LaunchingViewModel.self) { resolver in
            let storage = container.resolve(Storage.self)!
            let repository = container.resolve(AuthRepositoryProtocol.self)!
            return LaunchingViewModel(repository: repository, storage: storage)
        }
        
        container.register(LoginViewModel.self) { resolver in
            let repository = resolver.resolve(AuthRepositoryProtocol.self)!
            let storage = resolver.resolve(Storage.self)!
            let permissionManager = resolver.resolve(PermissionManagerProtocol.self)!
            return LoginViewModel(repository: repository, storage: storage, permissionManager: permissionManager)
        }
    }
    
    func registerViewControllers(container: Container) {
        container.register(LaunchingViewController.self) { resolver in
            let viewModel = resolver.resolve(LaunchingViewModel.self)!
            return LaunchingViewController(viewModel: viewModel)
        }
        
        container.register(LoginViewController.self) { resolver in
            let viewModel = resolver.resolve(LoginViewModel.self)!
            return LoginViewController(viewModel: viewModel)
        }
    }
}
