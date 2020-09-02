//
//  LoginViewModel.swift
//  OPPU
//
//  Created by rigodev on 22.05.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import ReactorKit
import RxSwift

final class LoginViewModel: Reactor {
    let initialState: State
    
    struct State {
        var photoLibraryGranted = false
        var cameraGranted = false
        var loggedIn = false
        var loading = false
        var error: LoginError?
    }
    
    enum Action {
        case login(token: String)
        case getPhotoLibraryPermission
        case getCameraPermission
        case scannerDidScan(qrCode: String)
        case photoDidPick(image: UIImage)
        case photoLibraryDidShow
        case errorClosed
    }
    
    enum Mutation {
        case setInitialState
        case setLoading(Bool)
        case setLoggedIn(Bool)
        case setPhotoLibraryGranted(Bool)
        case setCameraGranted(Bool)
        case setError(LoginError?)
    }
    
    // MARK: - properties
    private let repository: AuthRepositoryProtocol
    private let storage: Storage
    private let permissionManager: PermissionManagerProtocol
    
    // MARK: - controller cycle
    init(repository: AuthRepositoryProtocol, storage: Storage, permissionManager: PermissionManagerProtocol) {
        self.repository = repository
        self.storage = storage
        self.permissionManager = permissionManager
        initialState = State()
    }
    
    // MARK: - methods
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .login(token):
            return login(with: token)
            
        case let .scannerDidScan(qrCode):
            return login(with: qrCode)
            
        case .getPhotoLibraryPermission:
            return permissionManager.requestPermission(for: .photoLibrary)
                .asObservable()
                .observeOn(MainScheduler.instance)
                .map({ result in
                    switch result {
                    case .success:
                        return .setPhotoLibraryGranted(true)
                    case let .failure(error):
                        return .setError(.photoLibraryDeny(error))
                    }
                })
            
        case let .photoDidPick(image):
            guard
                let ciImage = CIImage(image: image),
                let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                          context: nil,
                                          options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            else { return .empty() }
               
            let qrCodeObservable: Observable<String?> =
                Observable.create({ observer in
                    if let qrCode = detector.features(in: ciImage)
                        .compactMap({ ($0 as? CIQRCodeFeature)?.messageString })
                        .first {
                        observer.onNext(qrCode)
                    } else {
                        observer.onNext(nil)
                    }
                    return Disposables.create()
                })
            let processingSheduler = ConcurrentDispatchQueueScheduler(qos: .default)
            
            return .concat(
                .just(.setLoading(true)),
                qrCodeObservable
                    .subscribeOn(processingSheduler)
                    .observeOn(MainScheduler.instance)
                    .flatMap({ [unowned self] qrCode -> Observable<Mutation> in
                        if let qrCode = qrCode {
                            return self.login(with: qrCode)
                        } else {
                            return .of(.setLoading(false), .setError(.photoUnrecognized))
                        }
                    }),
                .just(.setLoading(false))
            )
            
        case .getCameraPermission:
            return permissionManager.requestPermission(for: .camera)
                .asObservable()
                .observeOn(MainScheduler.instance)
                .flatMap({ result -> Observable<Mutation> in
                    switch result {
                    case .success:
                        return .of(.setCameraGranted(true), .setCameraGranted(false))
                    case let .failure(error):
                        return .just(.setError(.cameraDeny(error)))
                    }
                })
            
        case .photoLibraryDidShow:
            return .just(.setPhotoLibraryGranted(false))
            
        case .errorClosed:
            return .just(.setError(nil))
        }
    }
    
    private func login(with token: String) -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            repository.login(token: token)
                .asObservable()
                .do(onNext: { [unowned self] response in
                    self.storage.saveUserInfo(with: token, response: response)
                })
                .flatMap({ _ -> Observable<Mutation> in
                    
                    return .of(.setLoggedIn(true))
                }),
            .just(.setLoading(false))
        ])
            .catchError({ error in
                print("login error: \(error)")
                return .of(.setLoading(false), .setError(.authorizationFailure))
            })
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setInitialState:
            newState = initialState
        case .setLoading(let loading):
            newState.loading = loading
        case .setLoggedIn(let loggedIn):
            newState.loggedIn = loggedIn
        case .setPhotoLibraryGranted(let isGranted):
            newState.photoLibraryGranted = isGranted
        case .setCameraGranted(let isGranted):
            newState.cameraGranted = isGranted
        case .setError(let error):
            newState.error = error
            print("error: \(error?.message ?? "")")
        }
        
        return newState
    }
    
}

extension LoginViewModel {
    
    enum LoginError: Equatable {
        case authorizationFailure
        case photoLibraryDeny(PermissionRequests.ErrorType)
        case cameraDeny(PermissionRequests.ErrorType)
        case photoUnrecognized
        
        var title: String {
            switch self {
            case .authorizationFailure:
                return "Неуспешная авторизация"
            case .photoLibraryDeny:
                return "Ошибка доступа к Альбому"
            case .cameraDeny:
                return "Ошибка доступа к Камере"
            case .photoUnrecognized:
                return "Обработка фотографии"
            }
        }
        
        var message: String {
            switch self {
            case .authorizationFailure:
                return "Не удалось авторизоваться по вашим данным."
            case .photoLibraryDeny(let error), .cameraDeny(let error):
                return error.description
            case .photoUnrecognized:
                return "Не удалось распознать QR-код."
            }
        }
    }
}
