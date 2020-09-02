//
//  LaunchingViewModel.swift
//  OPPU
//
//  Created by rigodev on 05.06.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import ReactorKit
import RxSwift

final class LaunchingViewModel: Reactor {
    let initialState: State
    private let delayInterval = RxTimeInterval.milliseconds(1500)
    
    struct State {
        var completed: Bool?
        var loading = false
        var error: LaunchingError?
    }
    
    enum Action {
        case signIn
        case errorClosed
    }
    
    enum Mutation {
        case setCompleted(success: Bool?)
        case setLoading(Bool)
        case setError(LaunchingError?)
    }
    
    // MARK: - properties
    private let repository: AuthRepositoryProtocol
    private let storage: Storage
    
    // MARK: - controller cycle
    init(repository: AuthRepositoryProtocol, storage: Storage) {
        self.repository = repository
        self.storage = storage
        initialState = State()
    }
    
    // MARK: - methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .signIn:
            guard let savedToken = storage.token else {
                let delaySheduler = ConcurrentDispatchQueueScheduler(qos: .default)
                return Observable.concat([
                    .just(.setLoading(true)),
                    Observable<Mutation>
                        .just(.setLoading(false))
                        .delay(delayInterval, scheduler: delaySheduler)
                        .observeOn(MainScheduler.instance),
                    .just(.setCompleted(success: false))
                ])
            }
            return login(with: savedToken)
            
        case .errorClosed:
            return .of(.setError(nil), .setCompleted(success: false))
        }
    }
    
    private func login(with token: String) -> Observable<Mutation> {
        let delaySheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        return Observable.concat([
            .just(.setLoading(true)),
            repository.login(token: token)
                .asObservable()
                .delay(delayInterval, scheduler: delaySheduler)
                .do(onNext: { [unowned self] response in
                    self.storage.saveUserInfo(with: token, response: response)
                })
                .observeOn(MainScheduler.instance)
                .flatMap({ _ -> Observable<Mutation> in
                    return .of(.setCompleted(success: true))
                }),
            .just(.setLoading(false))
        ])
            .catchError({ error in
                return .of(.setLoading(false), .setError(.authorizationFailure(error)))
            })
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let loading):
            newState.loading = loading
        case .setCompleted(let completed):
            newState.completed = completed
        case .setError(let error):
            newState.error = error
            print("error: \(error?.message ?? "")")
        }
        
        return newState
    }
    
}

extension LaunchingViewModel {
    
    enum LaunchingError: Equatable {
        case authorizationFailure(Error)
        
        var title: String {
            switch self {
            case .authorizationFailure:
                return "Неуспешная авторизация"
            }
        }
        
        var message: String {
            switch self {
            case .authorizationFailure:
                return "Не удалось авторизоваться по вашим данным."
            }
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (authorizationFailure(error1), authorizationFailure(error2)):
                return error1.localizedDescription == error2.localizedDescription
            }
        }
    }
}

