//
//  LoginResponse.swift
//  OPPU
//
//  Created by rigodev on 22.05.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

public struct LoginResponse: Decodable {
    public let role: Role
    public let user: User
    public let regions: [Region]?
    
    public struct Role: Decodable {
        public let code: Int
        public let roleName: String
    }
    
    public struct User: Decodable {
        public let firstname: String
        public let surname: String
        public let secondname: String?
        public let avatarUrl: String
        public let position: String
        public let organization: Organization
        
        private enum CodingKeys: String, CodingKey {
            case firstname = "first"
            case surname = "last"
            case secondname = "middle"
            case avatarUrl = "photo"
            case position
            case organization
        }
        
        public struct Organization: Decodable {
            public let id: String
            public let name: String
        }
    }
    
    public struct Region: Decodable {
        public let id: String
        public let code: String
        public let name: String
    }
    
}
