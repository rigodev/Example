//
//  AuthEndpoints.swift
//  OPPU
//
//  Created by rigodev on 22.05.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import Moya
import Alamofire

public enum AuthEndpoints {
    case login(token: String)
}

extension AuthEndpoints: TargetType {
    
    public var baseURL: URL {
        switch self {
        case .login:
            return URL(string: RequestUrls.baseUrl)!
        }
    }
    
    public var path: String {
        switch self {
        case .login:
            return RequestUrls.Auth.login
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .login:
            return .get
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case let .login(token):
            let params = [RequestParams.token: token]
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        default:
            return nil
        }
    }
}
