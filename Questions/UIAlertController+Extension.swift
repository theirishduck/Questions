import UIKit

extension UIAlertController {
	
	func addAction(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?) {
		let alertAction = UIAlertAction(title: title, style: style, handler: handler)
		self.addAction(alertAction)
	}
	
	static func OKAlert(title: String?, message: String?) -> UIAlertController {
		let alertViewController = self.init(title: title?.localized, message: message?.localized, preferredStyle: .alert)
		alertViewController.addAction(title: "OK".localized, style: .default, handler: nil)
		
		return alertViewController
	}
}