//
//  ProfileSectionModel.swift
//  OPPU
//
//  Created by rigodev on 05.07.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import RxDataSources

enum ProfileSectionModel: SectionModelType, Equatable {
    
    struct ProfileSection: Equatable {
        let header: Header?
        let footer: Footer?
        let items: [ProfileSectionItem]
        
        struct Header: Equatable {
            let title: String?
        }
        
        struct Footer: Equatable {
            let title: String
            let linkName: String?
            let urlString: String?
        }
    }
    
    case person(ProfileSection)
    case rating(ProfileSection)
    case statistics(ProfileSection)
    case menus(ProfileSection)
    
    var items: [ProfileSectionItem] {
        switch self {
        case .person(let profileSection),
             .rating(let profileSection),
             .statistics(let profileSection),
             .menus(let profileSection):
            return profileSection.items
        }
    }
    
    var header: ProfileSection.Header? {
        switch self {
        case .person(let profileSection),
             .rating(let profileSection),
             .statistics(let profileSection),
             .menus(let profileSection):
            return profileSection.header
        }
    }
    
    var footer: ProfileSection.Footer? {
        switch self {
        case .person(let profileSection),
             .rating(let profileSection),
             .statistics(let profileSection),
             .menus(let profileSection):
            return profileSection.footer
        }
    }
    
    init(original: Self, items: [ProfileSectionItem]) {
        switch original {
        case .person(let profileSection):
            self = .person(profileSection)
        case .rating(let profileSection):
            self = .rating(profileSection)
        case .statistics(let profileSection):
            self = .statistics(profileSection)
        case .menus(let profileSection):
            self = .menus(profileSection)
        }
    }
}
