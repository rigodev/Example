//
//  PermissionAlertItemView.swift
//  OPPU
//
//  Created by rigodev on 12.06.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import UIKit

public final class PermissionAlertItemView: UIView {
    
    private let imageView = UIImageView()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = Appearance.shared.titleFont
        label.textColor = Appearance.shared.titleColor
        return label
    }()
    
    public init(image: UIImage?, text: String) {
        super.init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        textLabel.text = text
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }
    
    private func setupUI() {
        addSubviews([imageView, textLabel])
        
        imageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(Appearance.shared.imageSize)
        }
        
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(Appearance.shared.interItemMargin)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(Appearance.shared.horizontalMargin)
        }
    }
}

extension PermissionAlertItemView {
    private struct Appearance {
        static let shared = Appearance()
        
        let interItemMargin: CGFloat = 10
        let horizontalMargin: CGFloat = 16
        let titleFont: UIFont = .systemFont(ofSize: 14)
        let titleColor: UIColor = .black
        let imageSize: CGFloat = 28.0
    }
}
