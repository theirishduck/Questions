import Foundation

class Settings: NSObject, NSCoding {
	
	static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
	static let path = "\(Settings.documentsDirectory)/Settings.archive"
	var completedSets: [Int:[Bool]] = [:]
	var correctAnswers: Int = 0
	var incorrectAnswers: Int = 0
	var score: Int = 0
	var parallaxEnabled = true
	var musicEnabled = true
	var hapticFeedbackEnabled = true
	var darkThemeEnabled = false

	static var shared = Settings()
	fileprivate override init() { }

	func encode(with archiver: NSCoder) {
		archiver.encode(correctAnswers, forKey: "Correct answers")
		archiver.encode(incorrectAnswers, forKey: "Incorrect answers")
		archiver.encode(darkThemeEnabled, forKey: "DarkTheme")
		archiver.encode(parallaxEnabled, forKey: "Parallax")
		archiver.encode(musicEnabled, forKey: "Music")
		archiver.encode(completedSets, forKey: "Completed sets")
		archiver.encode(score, forKey: "Score")
	}

	required init (coder unarchiver: NSCoder) {
		super.init()
		correctAnswers = unarchiver.decodeInteger(forKey: "Correct answers")
		incorrectAnswers = unarchiver.decodeInteger(forKey: "Incorrect answers")
		darkThemeEnabled = unarchiver.decodeBool(forKey: "DarkTheme")
		parallaxEnabled = unarchiver.decodeBool(forKey: "Parallax")
		musicEnabled = unarchiver.decodeBool(forKey: "Music")
		score = unarchiver.decodeInteger(forKey: "Score")
		
		if let completedSets = unarchiver.decodeObject(forKey: "Completed sets") as? [Int:[Bool]] {
			self.completedSets = completedSets
		}
	}

	func save() -> Bool {
		return NSKeyedArchiver.archiveRootObject(self, toFile: Settings.path)
	}
}
