import Foundation

extension String {
	
	var localized: String {
		return NSLocalizedString(self, comment: "")
	}
	
	func attributedStringWith(_ attributes: [NSAttributedStringKey : Any]? = nil) -> NSAttributedString {
		return NSAttributedString(string: self, attributes: attributes)
	}
}

extension NSAttributedString {
	
	static func +(left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
		let result = NSMutableAttributedString()
		result.append(left)
		result.append(right)
		return result
	}
}
