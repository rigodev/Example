//
//  ProfileSectionItem.swift
//  OPPU
//
//  Created by rigodev on 05.07.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

enum ProfileSectionItem: Equatable {
    
    case person(iconUrlString: String, name: String?, roleName: String?)
    case rating(RatingCellModel)
    case statistic(Statistic.StatisticParameter, ProfileCellModel)
    case menu(MenuItem, ProfileCellModel)
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.rating(model1), .rating(model2)):
            return model1 == model2
         case let (.statistic(lid, _), .statistic(rid, _)):
            return lid == rid
        case let (.menu(litem, _), .menu(ritem, _)):
            return litem == ritem
        default:
            return false
        }
    }
}
