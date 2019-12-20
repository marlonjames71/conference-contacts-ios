//
//  CameraViewController.swift
//  swaap
//
//  Created by Marlon Raskin on 12/19/19.
//  Copyright © 2019 swaap. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

	@IBOutlet private weak var cameraView: UIView!
	@IBOutlet private weak var profileImageView: UIImageView!
	@IBOutlet private weak var nameOfReceiver: UILabel!

	var session: AVCaptureSession!
	var previewLayer: AVCaptureVideoPreviewLayer!

	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		session = AVCaptureSession()

		setupVideoCaptureAndSession()

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.insertSublayer(previewLayer, at: 0)

        session.startRunning()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if session.isRunning == false {
			session.startRunning()
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		if session.isRunning == true {
			session.stopRunning()
		}
	}

	private func setupUI() {
		profileImageView.clipsToBounds = true
		profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
	}

	// MARK: - IBActions
	@IBAction func cancelTapped(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}

	// MARK: - Alerts
    func failed() {
		let alertVC = UIAlertController(title: "Scanning not supported",
								   message: "Your device does not support scanning a code from an item. Please use a device with a camera.",
								   preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true)
        session = nil
    }

	// MARK: - Delegate & Helper Methods
	private func setupVideoCaptureAndSession() {
		guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
		let videoInput: AVCaptureDeviceInput

		do {
			videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
		} catch {
			return
		}

		if session.canAddInput(videoInput) {
			session.addInput(videoInput)
		} else {
			failed()
		}

		let metaDataOutput = AVCaptureMetadataOutput()

		if session.canAddOutput(metaDataOutput) {
			session.addOutput(metaDataOutput)

			metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			metaDataOutput.metadataObjectTypes = [.qr]
		} else {
			failed()
		}
	}

	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		if let metaDataObject = metadataObjects.first {
			guard let readableObject = metaDataObject as? AVMetadataMachineReadableCodeObject else { return }
			guard let stringValue = readableObject.stringValue else { return }
			HapticFeedback.produceHeavyFeedback()
			title = "Found"
			found(code: stringValue)
		}
	}

	private func found(code: String) {
		// Do something with metaData stringValue here
	}

	// MARK: - System Overrides
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}
}