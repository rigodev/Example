//
//  AlertController.swift
//  OPPU
//
//  Created by rigodev on 12.06.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import RxSwift
import UIKit

public final class AlertController: UIViewController {
    
    // MARK: - views
    private let customView: UIView
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.shared.alertBackgroundColor
        view.layer.cornerRadius = Appearance.shared.alertCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    private let okAction: AlertAction
    private let cancelAction: AlertAction
    
    private let okButton: UIButton = {
        let button = UIButton(type: .system)
        
        if let fontSize = button.titleLabel?.font.pointSize {
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        }
        
        button.layer.borderColor = Appearance.shared.buttonBorderColor.cgColor
        button.layer.borderWidth = Appearance.shared.buttonBorderWidth
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = Appearance.shared.buttonBorderColor.cgColor
        button.layer.borderWidth = Appearance.shared.buttonBorderWidth
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(customView: UIView, okAction: AlertAction, cancelAction: AlertAction) {
        self.customView = customView
        self.okAction = okAction
        self.cancelAction = cancelAction
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        view.backgroundColor = Appearance.shared.viewBackgroundColor
        
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Not supported")
    }
    
    private func setupUI() {
        okButton.setTitle(okAction.title, for: [])
        cancelButton.setTitle(cancelAction.title, for: [])
        
        okButton.rx.tap.bind {
            self.dismiss(animated: true, completion: nil)
            self.okAction.handler(self.okAction)
        }.disposed(by: disposeBag)
        
        cancelButton.rx.tap.bind {
            self.dismiss(animated: true, completion: nil)
            self.cancelAction.handler(self.cancelAction)
        }.disposed(by: disposeBag)
        
        view.addSubview(contentView)
        contentView.addSubviews([customView, okButton, cancelButton])

        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(Appearance.shared.alertWidth)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(-Appearance.shared.buttonBorderOffset)
            make.bottom.equalToSuperview().inset(-Appearance.shared.buttonBorderOffset)
            make.trailing.equalTo(okButton.snp.leading).offset(Appearance.shared.buttonBorderOffset)
            make.height.equalTo(Appearance.shared.buttonHeight)
        }
        
        okButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(-Appearance.shared.buttonBorderOffset)
            make.width.equalTo(cancelButton)
            make.height.equalTo(Appearance.shared.buttonHeight)
        }
        
        customView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(Appearance.shared.customViewBottomOffset)
        }
    }
}

extension AlertController {

    private struct Appearance {
        static let shared = Appearance()
        let buttonBorderOffset: CGFloat = 1
        let viewBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let alertBackgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        let buttonBorderColor = UIColor(red: 0.39, green: 0.39, blue: 0.39, alpha: 1).withAlphaComponent(0.29)
        let buttonHeight: CGFloat = 44.0
        let buttonBorderWidth: CGFloat = 1.0
        let alertWidth: CGFloat = 270.0
        let alertCornerRadius: CGFloat = 14.0
        let customViewBottomOffset: CGFloat = 64.0
    }
}

public class AlertAction {
    public let title: String
    fileprivate let handler: (AlertAction) -> Void
    
    public init(title: String, handler: @escaping (AlertAction) -> Void) {
        self.title = title
        self.handler = handler
    }
}
