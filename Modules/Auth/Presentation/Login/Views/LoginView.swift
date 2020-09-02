//
//  LoginView.swift
//  OPPU
//
//  Created by rigodev on 22.05.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class LoginView: UIView {
    // MARK: - views
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 19, weight: .medium)
        label.textAlignment = .center
        label.textColor = Colors.tintColor
        label.text = "Сканируйте QR-код \nдля авторизации"
        return label
    }()
    
    fileprivate let scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.borderColor = Colors.tintColor.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.tintColor = Colors.tintColor
        button.setTitleColor(Colors.tintColor, for: .normal)
        button.setTitle("Сканировать\nкамерой", for: .normal)
        button.setImage(UIImage(named: "scan"), for: .normal)
        return button
    }()
    
    fileprivate let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.borderColor = Colors.tintColor.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.tintColor = Colors.tintColor
        button.setTitleColor(Colors.tintColor, for: .normal)
        button.setTitle("Загрузить\nиз галереи", for: .normal)
        button.setImage(UIImage(named: "gallery"), for: .normal)
        return button
    }()
    
    fileprivate lazy var infoView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.linkTextAttributes = [.underlineStyle: true]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributedString = NSMutableAttributedString(
            string: "Авторизация означает согласие с политикой конфиденциальности, правилами пользования и обработкой личных данных",
            attributes: [.font: UIFont.systemFont(ofSize: 12), .paragraphStyle: paragraphStyle])
        if let url = URL(string: "eula") {
            let range = attributedString.mutableString.range(of: "политикой конфиденциальности, правилами")
            attributedString.addAttribute(.link, value: url, range: range)
        }
        textView.attributedText = attributedString
        
        return textView
    }()
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - properties
    fileprivate let eulaLinkTapped = PublishSubject<Void>()
    
    // MARK: - methods
    private func configureView() {
        let buttonHeight: CGFloat = 90
        let iconSide: CGFloat = 60
        let iconSideInset: CGFloat = 16
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        addSubview(scanButton)
        scanButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(44)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(buttonHeight)
        }
        scanButton.imageView?.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(iconSideInset)
            make.width.height.equalTo(iconSide)
        }
        
        addSubview(galleryButton)
        galleryButton.snp.makeConstraints { make in
            make.top.equalTo(scanButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(buttonHeight)
        }
        galleryButton.imageView?.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(iconSideInset)
            make.width.height.equalTo(iconSide)
        }
        
        addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.top.equalTo(galleryButton.snp.bottom).offset(100)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension LoginView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        eulaLinkTapped.onNext(())
        return false
    }
}

extension Reactive where Base == LoginView {
    var scanTap: Observable<Void> {
        base.scanButton.rx.tap.asObservable()
    }
    
    var galleryTap: Observable<Void> {
        base.galleryButton.rx.tap.asObservable()
    }
    
    var eulaTap: Observable<Void> {
        base.eulaLinkTapped.asObservable()
    }
    
    var isScanButtonEnabled: Binder<Bool> {
        base.scanButton.rx.isEnabled
    }
    
    var isGalleyButtonEnabled: Binder<Bool> {
        base.galleryButton.rx.isEnabled
    }
    
    var isEulaEnabled: Binder<Bool> {
        base.infoView.rx.isUserInteractionEnabled
    }

}
