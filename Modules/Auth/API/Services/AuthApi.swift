//
//  AuthApi.swift
//  OPPU
//
//  Created by rigodev on 22.05.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import Moya
import RxSwift

public final class AuthApi: AuthApiProtocol {
    
    //MARK: - Privates
    private let provider: NetworkProvider<AuthEndpoints>
    
    //MARK: - Publics
    public init(provider: NetworkProvider<AuthEndpoints>) {
        self.provider = provider
    }
    
    public func login(token: String) -> Single<Response> {
        return provider.request(.login(token: token))
    }
}
