//
//  ProfileDataSource.swift
//  OPPU
//
//  Created by rigodev on 01.07.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import RxDataSources
import RxSwift
import UIKit

extension ProfileViewController {
    
    func getDataSource() -> RxTableViewSectionedReloadDataSource<ProfileSectionModel> {
        return .init(configureCell: { [unowned self] (_, tableView, indexPath, item) -> UITableViewCell in
            
            switch item {
            case let .person(iconUrlString, name, roleName):
                let cell = tableView.dequeueReusableCell(PersonCell.self, for: indexPath)
                cell.update(iconUrlString: iconUrlString, title: name, subtitle: roleName)
                
                cell.rx.tap
                    .subscribe(onNext: { [unowned self] in
                        self.delegate?.showUser()
                    }).disposed(by: cell.rx.reuseBag)
                
                cell.rx.logoutTap
                    .map { Reactor.Action.logoutTap }
                    .bind(to: self.viewModel.action)
                    .disposed(by: cell.rx.reuseBag)
                return cell
                
            case let .rating(cellModel):
                let cell = tableView.dequeueReusableCell(RatingCell.self, for: indexPath)
                cell.configure(with: cellModel)
                if cellModel.hasArrow {
                    cell.rx.tap
                        .subscribe(onNext: {
                            switch cellModel.type {
                            case .region:
                                self.delegate?.showRegions()
                                    .map { Reactor.Action.selectRegion($0) }
                                    .bind(to: self.viewModel.action)
                                    .disposed(by: self.disposeBag)
                            case .section:
                                self.delegate?.showSections()
                                    .map { Reactor.Action.selectSection($0) }
                                    .bind(to: self.viewModel.action)
                                    .disposed(by: self.disposeBag)
                            case .standard:
                                break
                            }
                        })
                        .disposed(by: cell.rx.reuseBag)
                }
                return cell
                
            case let .statistic(parameter, model):
                let cell = tableView.dequeueReusableCell(TitleArrowCell.self, for: indexPath)
                cell.update(with: model.title, subtitle: model.subtitle, showArrow: model.interactionEnabled)
                if model.interactionEnabled {
                    cell.rx.tap
                        .subscribe(onNext: { [unowned self] in
                            self.delegate?.showStatisticParameters(for: parameter)
                        }).disposed(by: cell.rx.reuseBag)
                }
                return cell
                
            case let .menu(element, model):
                let cell = tableView.dequeueReusableCell(TitleArrowCell.self, for: indexPath)
                cell.update(with: model.title, subtitle: model.subtitle, showArrow: model.interactionEnabled)
                if model.interactionEnabled {
                    cell.rx.tap
                        .map { Reactor.Action.selectMenu(element) }
                        .bind(to: self.viewModel.action)
                        .disposed(by: cell.rx.reuseBag)
                }
                return cell
            }
        })
    }
}
