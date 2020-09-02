//
//  ScannerViewController.swift
//  OPPU
//
//  Created by rigodev on 06.06.2020.
//  Copyright © 2020 DevTeam. All rights reserved.
//

import AVFoundation
import SnapKit
import UIKit

protocol ScannerViewControllerDelegate: AnyObject {
    func scannerDidScan(code: String)
}

final class ScannerViewController: UIViewController {
    
    // MARK: - views
    private let cameraView = UIView()
    private let qrZoneView = UIView()
    
    private lazy var qrZoneBorderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let tooltipLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Поместите qr-код\nв центре камеры"
        return label
    }()
    
    private let topOverlay = OverlayView()
    private let middleLeftOverlay = OverlayView()
    private let middleRightOverlay = OverlayView()
    private let bottomOverlay = OverlayView()
    
    // MARK: - properties
    weak var delegate: ScannerViewControllerDelegate?
    private var isRunning: Bool { return captureSession.isRunning }
    private let borderWidth: CGFloat = 4
    
    private var flashIsOn: Bool? {
        didSet {
            guard let isOn = flashIsOn else { return }
            updateFlash(with: isOn)
            turnFlash(with: isOn)
        }
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
        configureScanner()
    }
    
    // MARK: - properties
    private let captureSession = AVCaptureSession()
    private var barTintColor: UIColor!
    
    // MARK: - methods
    private func setupView() {
        view.addSubviews([
            cameraView, qrZoneView, topOverlay, middleLeftOverlay, middleRightOverlay, bottomOverlay, qrZoneBorderView])
        
        cameraView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        topOverlay.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        topOverlay.addSubview(tooltipLabel)
        tooltipLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
        }
        
        qrZoneView.snp.makeConstraints { make in
            make.top.equalTo(topOverlay.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(qrZoneView.snp.width)
        }
        
        qrZoneBorderView.snp.makeConstraints { make in
            make.top.equalTo(qrZoneView).offset(-borderWidth)
            make.leading.equalTo(qrZoneView).offset(-borderWidth)
            make.trailing.equalTo(qrZoneView).offset(borderWidth)
            make.bottom.equalTo(qrZoneView).offset(borderWidth)
        }
        
        middleLeftOverlay.snp.makeConstraints { make in
            make.top.equalTo(topOverlay.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalTo(qrZoneView.snp.leading)
            make.bottom.equalTo(qrZoneView)
        }
        
        middleRightOverlay.snp.makeConstraints { make in
            make.top.equalTo(topOverlay.snp.bottom)
            make.leading.equalTo(qrZoneView.snp.trailing)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(qrZoneView)
        }
        
        bottomOverlay.snp.makeConstraints { make in
            make.top.equalTo(qrZoneView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
    }
    
    private func configureScanner() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            failure(with: .unsupportedDevice)
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                failure(with: .cannotAddInput)
                return
            }
        } catch let error {
            failure(with: .wrongMedia(error: error))
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failure(with: .cannotAddOutput)
            return
        }
        
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        cameraView.layer.insertSublayer(videoPreviewLayer, at: 0)
        startScanning()
        
        configureFlash(for: captureDevice)
    }
    
    private func configureFlash(for captureDevice: AVCaptureDevice) {
        if captureDevice.hasTorch {
            flashIsOn = false
        }
    }
    
    private func updateFlash(with isOn: Bool) {
        let imageName = isOn ? "flash_on" : "flash_off"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        let flashButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleFlash))
        navigationItem.rightBarButtonItem = flashButton
    }
    
    private func turnFlash(with isOn: Bool) {
        guard
            let device = AVCaptureDevice.default(for: .video),
            device.hasTorch
        else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = isOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
   
    @objc private func toggleFlash() {
        flashIsOn?.toggle()
    }
    
    private func startScanning() {
        if !isRunning {
            captureSession.startRunning()
        }
    }
    
    private func stopScanning() {
        if isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func foundQRCode(_ code: String) {
        navigationController?.popViewController(animated: true)
        delegate?.scannerDidScan(code: code)
    }
    
    private func failure(with error: ScannerError) {
        showAlert(with: error.title, message: error.message) { [unowned self] _ in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard
            let metadataObject = metadataObjects.first,
            metadataObject.type == .qr,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue
        else {
            failure(with: .incorrectQRCode)
            return
        }
        
        captureSession.stopRunning()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        foundQRCode(stringValue)
    }
    
}

extension ScannerViewController {
    
    enum ScannerError {
        case unsupportedDevice
        case cannotAddInput
        case cannotAddOutput
        case wrongMedia(error: Error)
        case incorrectQRCode
        
        var title: String {
            switch self {
            case .unsupportedDevice, .cannotAddInput, .cannotAddOutput, .wrongMedia:
                return "Ошибка настройки камеры"
            case .incorrectQRCode:
                return "Ошибка сканирования"
            }
        }
        
        var message: String {
            switch self {
            case .unsupportedDevice:
                return "Неподдерживаемое устройство: камера не найдена."
            case .cannotAddInput:
                return "Невозможно настроить входящий поток."
            case .cannotAddOutput:
                return "Невозможно настроить исходящий поток."
            case .wrongMedia(let error):
                return error.localizedDescription
            case .incorrectQRCode:
                return "Отсканирован некорретный QR-код."
            }
        }
    }
    
}
