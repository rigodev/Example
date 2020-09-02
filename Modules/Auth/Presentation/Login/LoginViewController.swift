//
//  LoginViewController.swift
//  OPPU
//
//  Created by rigodev on 22.05.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import ReactorKit
import RxSwift
import SnapKit
import UIKit

protocol LoginViewControllerDelegate: AnyObject {
    func loggedIn()
    func openLink(_ url: URL)
}

final class LoginViewController: UIViewController, View {
    typealias Reactor = LoginViewModel
    
    // MARK: - views
    lazy private var loginView = LoginView()
    
    // MARK: - properties
    weak var delegate: LoginViewControllerDelegate?
    
    private let viewModel: LoginViewModel
    
    var disposeBag = DisposeBag()
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()

    // MARK: - life cycle
    init(viewModel: LoginViewModel) {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
        if let presented = self.presentedViewController  { presented.dismiss(animated: true) }
    }
    
    // MARK: - methods
    func bind(reactor: Reactor) {
        reactor.state.map { $0.loading }
            .distinctUntilChanged()
            .bind(to: rx.isActivityIndicatorRunning)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.loading }
            .distinctUntilChanged()
            .map { !$0 }
            .bind(to: loginView.rx.isGalleyButtonEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.loading }
            .distinctUntilChanged()
            .map { !$0 }
            .bind(to: loginView.rx.isScanButtonEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.loading }
            .distinctUntilChanged()
            .map { !$0 }
            .bind(to: loginView.rx.isEulaEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.error }
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [unowned self] error in
                switch error {
                case .cameraDeny, .photoLibraryDeny:
                    self.showPermissionAlert()
                case .authorizationFailure, .photoUnrecognized:
                    self.showAlert(
                        with: error.title,
                        message: error.message, handler: { [weak self] _ in
                            self?.viewModel.action.onNext(.errorClosed)
                        }
                    )
                }
            }).disposed(by: disposeBag)
        
        reactor.state.map { $0.loggedIn }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [unowned self] _ in
                self.presentedViewController?.dismiss(animated: true)
                self.delegate?.loggedIn()
            }).disposed(by: disposeBag)
        
        reactor.state.map { $0.photoLibraryGranted }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [unowned self] _ in
                self.showPhotoLibrary()
            }).disposed(by: disposeBag)
        
        reactor.state.map { $0.cameraGranted }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [unowned self] _ in
                self.showScanner()
            }).disposed(by: disposeBag)
        
        loginView.rx.scanTap
            .map { Reactor.Action.getCameraPermission }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        loginView.rx.galleryTap
            .map { Reactor.Action.getPhotoLibraryPermission }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        loginView.rx.eulaTap
            .subscribe(onNext: { [unowned self] in
                guard let url = URL(string: Links.eula.urlString) else { return }
                self.delegate?.openLink(url)
            }).disposed(by: disposeBag)
        
    }
    
    private func prepareView() {
        view.backgroundColor = .white
        view.addSubview(loginView)
    }
    
    private func makeConstraints() {
        loginView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(70)
            make.centerY.equalToSuperview()
        }
    }
    
    private func showPhotoLibrary() {
        present(imagePicker, animated: true) { [unowned self] in
            self.viewModel.action.onNext(.photoLibraryDidShow)
        }
    }
    
    private func showScanner() {
        let controller = ScannerViewController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func showPermissionAlert() {
        let okAction = AlertAction(
            title: "Настройки",
            handler: { [unowned self] _ in
                self.viewModel.action.onNext(.errorClosed)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
        })
        
        let cancelAction = AlertAction(
            title: "Закрыть",
            handler: { [unowned self] _ in
                self.viewModel.action.onNext(.errorClosed)
            }
        )
        
        let alert = AlertController(customView: PermissionAlertView(), okAction: okAction, cancelAction: cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else { return }        
        viewModel.action.onNext(.photoDidPick(image: image))
    }
    
}

extension LoginViewController: ScannerViewControllerDelegate {
    func scannerDidScan(code: String) {
        viewModel.action.onNext(.scannerDidScan(qrCode: code))
    }
}
