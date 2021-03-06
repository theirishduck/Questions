import UIKit
import AVFoundation
	
class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	
	// MARK: Properties
	
	@IBOutlet weak var allowCameraButton: UIButton!
	@IBOutlet weak var helpButton: UIButton!
	
	var captureDevice: AVCaptureDevice?
	var captureSession = AVCaptureSession()
	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if #available(iOS 11.0, *) { self.navigationItem.largeTitleDisplayMode = .never }
		
		allowCameraButton.setTitle("Allow camera access".localized, for: .normal)
		
		captureDevice = AVCaptureDevice.default(for: .video)
		
		guard let captureDevice = captureDevice, let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
		
		captureSession.addInput(input)
		
		let captureMetadataOutput = AVCaptureMetadataOutput()
		captureSession.addOutput(captureMetadataOutput)
		
		captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
		captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
		
		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		loadPreview()
	}
	
	override func viewWillLayoutSubviews() {
		loadPreview()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadTheme), name: .UIApplicationDidBecomeActive, object: nil)
		loadTheme()
		
		guard self.captureDevice != nil else { return }
		
		DispatchQueue.main.async {
			
			if !self.captureSession.isRunning {
				self.captureSession.startRunning()
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		DispatchQueue.main.async {
			if self.captureSession.isRunning {
				self.captureSession.stopRunning()
			}
		}
	}
	
	@available(iOS, deprecated: 9.0)
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: AVCaptureMetadataOutputObjectsDelegate
	
	func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

		let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject
		
		guard let metadata = metadataObject else { return }
		
		if metadata.type == AVMetadataObject.ObjectType.qr {
			
			guard let data = metadata.stringValue?.data(using: .utf8) else { invalidQRCodeFormat(); return }
			
			var content: Question?
			
			do {
				content = try JSONDecoder().decode(Question.self, from: data)
			} catch { invalidQRCodeFormat(); }
			
			guard let validContent = validQuestions(from: content) else { invalidQRCodeFormat(); return }
			
			performSegue(withIdentifier: "unwindToQuestions", sender: validContent)
			captureSession.stopRunning()
		}
	}
	
	// MARK: UIStoryboardSegue Handling
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let content = sender as? Question, segue.identifier == "unwindToQuestions" {
			let controller = segue.destination as? QuestionsViewController
			controller?.isSetFromJSON = true
			controller?.set = content.quiz[0]
		}
	}
	
	@IBAction func unwindToQRScanner(_ segue: UIStoryboardSegue) { }
	
	// MARK: Alerts
	
	@IBAction func helpButtonAction() {
		
		if #available(iOS 10.0, *), Settings.shared.hapticFeedbackEnabled {
			let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
			feedbackGenerator.impactOccurred()
		}
		
		let alertViewController = UIAlertController.OKAlert(title: "Text to encode format", message: "READ_QR_FORMAT")
		present(alertViewController, animated: true)
	}
	
	@IBAction func allowCameraAction() {
		let alertViewController = UIAlertController(title: "Attention".localized,
		                                            message: "Camera access required for QR Scanning".localized,
		                                            preferredStyle: .alert)
		
		alertViewController.addAction(title: "Cancel".localized, style: .cancel)
		alertViewController.addAction(title: "Allow Camera".localized, style: .default) { action in
			if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
				UIApplication.shared.openURL(settingsURL)
			}
		}
		present(alertViewController, animated: true)
	}
	
	// MARK: Convenience
	
	private func validQuestions(from content: Question?) -> Question? {
		
		if let validQuiz = content?.quiz, !validQuiz.isEmpty {
			
			for fullQuestion in validQuiz[0] { // in case the content has multiple quizzes
				
				guard !fullQuestion.question.isEmpty, fullQuestion.answers.count == 4, fullQuestion.correct < 4, fullQuestion.correct >= 0 else { return nil }
				
				var isAnswersLenghtCorrect = true
				fullQuestion.answers.forEach { answer in
					if answer.isEmpty { isAnswersLenghtCorrect = false }
				}
			
				guard isAnswersLenghtCorrect else { return nil }
			}
		}
		
		return content
	}
	
	@objc func loadPreview() {
		
		switch UIApplication.shared.statusBarOrientation {
		case .landscapeLeft:
			videoPreviewLayer?.connection?.videoOrientation = .landscapeLeft
		case .landscapeRight:
			videoPreviewLayer?.connection?.videoOrientation = .landscapeRight
		default:
			videoPreviewLayer?.connection?.videoOrientation = .portrait
		}
		
		videoPreviewLayer?.frame = view.layer.bounds
		
		if let newLayer = videoPreviewLayer {
			view.layer.addSublayer(newLayer)
		}
		
		view.bringSubview(toFront: helpButton)
	}
	
	@objc func loadTheme() {
		
		navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		view.backgroundColor = .themeStyle(dark: .gray, light: .white)
		allowCameraButton.setTitleColor(dark: .warmYellow, light: .coolBlue, for: .normal)
		helpButton.setTitleColor(dark: .warmYellow, light: .coolBlue, for: .normal)
	}
	
	func invalidQRCodeFormat() {
		let alertViewController = UIAlertController.OKAlert(title: "Attention", message: "Invalid QR Code format")
		present(alertViewController, animated: true)
	}
}

