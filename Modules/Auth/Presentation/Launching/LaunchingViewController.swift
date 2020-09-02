//
//  LaunchingViewController.swift
//  OPPU
//
//  Created by rigodev on 05.06.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import ReactorKit
import RxSwift
import SnapKit
import UIKit

protocol LaunchingViewControllerDelegate: AnyObject {
    func didComplete(success: Bool)
}

final class LaunchingViewController: UIViewController, View {
    typealias Reactor = LaunchingViewModel
    
    // MARK: - views
    private let logoIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "logo")
        return view
    }()
    
    private let emptyView = UIView()
    
    private let companyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textColor = Colors.tintColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "РФ"
        return label
    }()
    
    private let companyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textColor = Colors.tintColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Монитор внедрения цифровых решений"
        return label
    }()
    
    
    // MARK: - properties
    weak var delegate: LaunchingViewControllerDelegate?
    private let viewModel: LaunchingViewModel
    var disposeBag = DisposeBag()

    // MARK: - life cycle
    init(viewModel: LaunchingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        makeConstraints()
        reactor = viewModel
        
        viewModel.action.onNext(.signIn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - methods
    func bind(reactor: Reactor) {
        reactor.state.map { $0.loading }
            .distinctUntilChanged()
            .bind(to: rx.isActivityIndicatorRunning)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.error }
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [unowned self] error in
                self.showAlert(
                    with: error.title,
                    message: error.message, handler: { [weak self] _ in
                        self?.viewModel.action.onNext(.errorClosed)
                    }
                )
            }).disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.completed }
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] completed in
                self.delegate?.didComplete(success: completed)
            }).disposed(by: disposeBag)
    }
    
    private func prepareView() {
        view.backgroundColor = .white
        
        view.addSubviews([logoIcon, companyTitleLabel, emptyView, companyDescriptionLabel])
    }
    
    private func makeConstraints() {
        let sideOffset: CGFloat = 60
        
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(70)
        }
        
        companyDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(sideOffset)
        }
        
        companyTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(sideOffset)
            make.bottom.equalTo(emptyView.snp.top).inset(-40)
        }
        
        logoIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(110)
            make.bottom.equalTo(companyTitleLabel.snp.top).offset(-30)
        }
    }
    
}
