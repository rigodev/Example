//
//  PermissionAlertView.swift
//  OPPU
//
//  Created by rigodev on 12.06.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import SnapKit
import UIKit

public final class PermissionAlertView: UIView {
    
    private let contentContainer = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Appearance.shared.titleFont
        label.textColor = Appearance.shared.titleColor
        label.text = "Разрешите ЦИФРОВОД доступ ко всему"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let itemContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    public init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("Not supported")
    }
    
    private func setupUI() {
        addSubview(contentContainer)
        contentContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(10)
        }
        
        contentContainer.addSubviews([titleLabel, itemContainer])
        titleLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
        
        itemContainer.addArrangedSubviews([
            PermissionAlertItemView(image: UIImage(named: "settings"), text: "Откройте Настройки"),
            PermissionAlertItemView(image: UIImage(named: "app"), text: "Выберите ЦИФРОВОД"),
            PermissionAlertItemView(image: UIImage(named: "checkmark"), text: "Включите разрешения")])
        itemContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
    }
}

extension PermissionAlertView {
    
    private struct Appearance {
        static let shared = Appearance()
        let titleFont = UIFont.boldSystemFont(ofSize: 17)
        let titleColor: UIColor = .black
    }
}
