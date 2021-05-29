//
//  Util.swift
//  SearchTwitter
//
//  Created by kengo kato on 2021/05/29.
//

import UIKit

/// キーボード閉じるが付いたSearchBar
class DoneSearchBar: UISearchBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let tools = UIToolbar()
        tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.closeButtonTapped))
        tools.items = [spacer, closeButton]
        self.inputAccessoryView = tools
    }
    
    @objc func closeButtonTapped() {
        self.endEditing(true)
        self.resignFirstResponder()
    }
}

class Util {
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    class func showAlert(title: String?, message:String?,
                         positiveButton: String,
                         negativeButton: String? = nil,
                         positiveAction: (() -> ())?  = nil,
                         negativeAction: (() -> ())?  = nil) {
        
        if let vc = Util.getTopViewController() {
            let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: positiveButton, style: .default, handler: { (action) in
                if let positiveAction = positiveAction {
                    positiveAction()
                }
            }))
            
            if let negativeButton = negativeButton {
                dialog.addAction(UIAlertAction(title: negativeButton, style: .cancel, handler: { (action) in
                    if let negativeeAction = negativeAction {
                        negativeeAction()
                    }
                }))
            }
            vc.present(dialog, animated: true, completion: nil)
        }
    }
    
    class func getTopViewController() -> UIViewController? {
        var vc = UIApplication.shared.windows.first?.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        return vc
    }
}

extension String {
    func localize(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}
