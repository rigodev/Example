//
//  Storage+Ext.swift
//  OPPU
//
//  Created by rigodev on 06.07.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

extension Storage {
    
    func saveUserInfo(with token: String, response: LoginResponse) {
        saveToken(token)
        
        let roleResponse = response.role
        let user = User(role: .init(rawValue: roleResponse.code))
        saveUser(user)
        
        if userRegion == nil {
            let userRegion: UserRegion
            if let region = response.regions?.first {
                userRegion = UserRegion(id: region.id, name: region.name)
            } else {
                userRegion = .all
            }
            saveUserRegion(userRegion)
        }
        
        if userSection == nil {
            saveUserSection(UserSection.all)
        }
        
        if userStandard == nil {
            saveUserStandard(UserStandard.all)
        }
    }
    
}
