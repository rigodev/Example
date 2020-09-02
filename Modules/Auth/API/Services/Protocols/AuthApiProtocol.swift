//
//  AuthApiProtocol.swift
//  OPPU
//
//  Created by rigodev on 22.05.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import Moya
import RxSwift

public protocol AuthApiProtocol {
    init(provider: NetworkProvider<AuthEndpoints>)
    
    func login(token: String) -> Single<Response>
}
