//
//  TwitterCell.swift
//  SearchTwitter
//
//  Created by kengo kato on 2021/05/23.
//

import UIKit

/// Tweet表示セル
class TwitterCell: UITableViewCell {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    func config(imageUrl: String?, name: String, message: String, date: String) {
        nameLabel.text = name
        messageLabel.text = message
        let date = Util.dateFromString(string: date, format: "EEE MMM dd HH:mm:ss Z yyyy")
        dateLabel.text = Util.stringFromDate(date: date, format: "yyyy年MM月dd日 HH時mm分ss秒")
    }
    
    func setIconImage(imageUrl: String?) {
        if let imageUrl = imageUrl {
            DispatchQueue.global(qos: .userInitiated).async {
                // キャッシュは今後検討
                let data = self.getImageData(url: imageUrl)
                DispatchQueue.main.async {
                    // noImageをセットしておく
                    self.iconImage.image = UIImage(named: "noImage")
                    if let data = data {
                        self.iconImage.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    private func getImageData(url: String) -> Data? {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            return data
        } catch let err {
            print("Error : \(err.localizedDescription)")
            return nil
        }
    }
}
