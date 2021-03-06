import AVFoundation
import UIKit

class MainViewController: UIViewController {
	
	// MARK: Properties
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var readQRCodeButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var backgroundImageView: UIImageView!
	
	static var parallaxEffect = UIMotionEffectGroup()
	static var backgroundView: UIView?

	// MARK: View life cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Add parallax effect to background image view
		MainViewController.backgroundView = backgroundImageView
		
		if Settings.shared.parallaxEnabled {
			MainViewController.addParallax(toView: MainViewController.backgroundView)
		}

		initializeSounds()
		initializeLables()
		
		// Loads the theme if user uses a home quick action
		NotificationCenter.default.addObserver(self, selector: #selector(loadTheme), name: .UIApplicationDidBecomeActive, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		// Load score
		let answersScore = Settings.shared.score
		scoreLabel.text = "🏆 \(answersScore)pts"
		
		if answersScore == 0 {
			scoreLabel.textColor = .darkGray
		} else if answersScore < 0 {
			scoreLabel.textColor = .darkRed
		} else {
			scoreLabel.textColor = .darkGreen
		}
		loadTheme()
	}
	
	@available(iOS, deprecated: 9.0)
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: UnwindSegue

	@IBAction func unwindToMainMenu(_ unwindSegue: UIStoryboardSegue) {
		Audio.setVolumeLevel(to: Audio.bgMusicVolume)
	}

	// MARK: Convenience
	
	private func initializeSounds() {
		
		Audio.bgMusic = AVAudioPlayer(file: "bensound-thelounge", type: "mp3")
		Audio.correct = AVAudioPlayer(file: "correct", type: "mp3")
		Audio.incorrect = AVAudioPlayer(file: "incorrect", type: "wav")
		
		Audio.bgMusic?.volume = Audio.bgMusicVolume
		Audio.correct?.volume = 0.10
		Audio.incorrect?.volume = 0.25
		
		if Settings.shared.musicEnabled {
			Audio.bgMusic?.play()
		}
		
		Audio.bgMusic?.numberOfLoops = -1
	}
	
	private func initializeLables() {
		startButton.setTitle("START GAME".localized, for: .normal)
		readQRCodeButton.setTitle("READ QR CODE".localized, for: .normal)
		settingsButton.setTitle("SETTINGS".localized, for: .normal)
		navigationItem.title = "Main menu".localized
	}
	
	@IBAction func loadTheme() {
		navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		backgroundImageView.dontInvert()
		startButton.dontInvert()
		readQRCodeButton.dontInvert()
		settingsButton.dontInvert()
		scoreLabel.dontInvert()
	}
	
	static func addParallax(toView view: UIView?) {
		
		let xAmount = 25
		let yAmount = 15
		
		let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
		horizontal.minimumRelativeValue = -xAmount
		horizontal.maximumRelativeValue = xAmount

		let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
		vertical.minimumRelativeValue = -yAmount
		vertical.maximumRelativeValue = yAmount
		
		MainViewController.parallaxEffect.motionEffects = [horizontal, vertical]
		view?.addMotionEffect(MainViewController.parallaxEffect)
	}
}

