//
//  AuthRepositoryProtocol.swift
//  OPPU
//
//  Created by rigodev on 22.05.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import Moya
import RxSwift

public protocol AuthRepositoryProtocol {
    func login(token: String) -> Single<LoginResponse>
}
