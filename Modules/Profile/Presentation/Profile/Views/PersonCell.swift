//
//  PersonCell.swift
//  OPPU
//
//  Created by rigodev on 02.07.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import Kingfisher
import RxGesture
import RxSwift
import SnapKit
import UIKit

final class PersonCell: UITableViewCell {
    
    // MARK: - views
    private let horizontalContainer: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .top
        stack.spacing = 20
        return stack
    }()
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = Colors.lightGray
        view.kf.indicatorType = .activity
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let verticalContainer = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = Colors.tintColor
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = Colors.tintColor
        return label
    }()
    
    fileprivate let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Colors.darkGray
        button.layer.cornerRadius = 13
        button.setTitle("Выход", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        button.setTitleColor(Colors.lightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    // MARK: - life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - methods
    private func setup() {
        contentView.backgroundColor = Colors.lightGray
        
        contentView.addSubview(horizontalContainer)
        horizontalContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30)
            make.leading.trailing.equalToSuperview().inset(25)
            make.bottom.equalToSuperview()
        }
        
        horizontalContainer.addArrangedSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(84)
        }
        
        horizontalContainer.addArrangedSubview(verticalContainer)
        
        verticalContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
        
        verticalContainer.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
        }
        
        verticalContainer.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    func update(iconUrlString: String?, title: String?, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        if let encodingUrlString = iconUrlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let imageUrl = URL(string: encodingUrlString) {
            iconView.kf.setImage(with: imageUrl, options: [.cacheOriginalImage])
        }
    }
    
}

extension Reactive where Base == PersonCell {
    
    var tap: Observable<Void> {
        base.contentView.rx.tapGesture()
            .when(.recognized)
            .map { _ in () }
    }
    
    var logoutTap: Observable<Void> {
        base.logoutButton.rx.tapGesture()
            .when(.recognized)
            .map { _ in () }
    }
    
}
