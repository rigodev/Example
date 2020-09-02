//
//  AuthRepository.swift
//  OPPU
//
//  Created by rigodev on 22.05.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import RxSwift

public class AuthRepository: AuthRepositoryProtocol {
    private let api: AuthApiProtocol
    
    public init(api: AuthApiProtocol) {
        self.api = api
    }
    
    public func login(token: String) -> Single<LoginResponse> {
        api.login(token: token)
            .map(LoginResponse.self)
    }
}
