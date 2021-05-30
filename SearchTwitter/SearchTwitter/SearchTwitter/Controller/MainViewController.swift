//
//  ViewController.swift
//  SearchTwitter
//
//  Created by kengo kato on 2021/05/23.
//

import UIKit
import Swifter

// Main画面
class MainViewController: UIViewController {
    @IBOutlet weak var searchBar: DoneSearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var cellHeightList: [IndexPath: CGFloat] = [:]
    private var twitters: [TwitterInfo] = []
    private var refreshCtl: UIRefreshControl!
    
    private var searchWord = ""
    private var isLoading = false
    
    // 任意に変えること
    private let TWITTERCONSUMERKEY = ""
    private let TWITTERCONSUMERSECRET = ""
    private var swifter: Swifter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    /// 初期設定
    private func config() {
        tableView.register(UINib(nibName: "TwitterCell", bundle: nil), forCellReuseIdentifier: "TwitterCell")
        refreshCtl = UIRefreshControl()
        refreshCtl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        tableView.refreshControl = refreshCtl
        tableView.estimatedRowHeight = 5
        tableView.rowHeight = UITableView.automaticDimension
        
        /// 認証処理
        swifter = Swifter(consumerKey: TWITTERCONSUMERKEY, consumerSecret: TWITTERCONSUMERSECRET, appOnly: true)
        swifter.authorizeAppOnly { token, response in
            
        } failure: { err in
            print("Error : \(err.localizedDescription)")
            Util.showAlert(title: "error".localize(), message: "authLoginError".localize(), positiveButton: "ok".localize(),
             positiveAction: {
                // アプリを使用できないので、終了する
                exit(0)
            },
            negativeAction:  {})

        }
    }
    
    /// 検索処理
    /// - Parameters:
    ///   - text: 検索文字
    ///   - isFirst: 初回検索かどうか
    ///   - sinceID: 一番新しいTweetID
    ///   - maxID: 一番古いTweetID
    ///   - complete:
    private func search(text: String, isFirst: Bool = true, sinceID: String? = nil, maxID: String? = nil, complete: ((Bool) -> ())? = nil) {
        // 検索文字がない場合、読み込み中の場合は無視
        if text.count <= 0 || isLoading {
            if let complete = complete {
                complete(false)
            }
            return
        }
        isLoading = true
        swifter.searchTweet(using: text,
                            sinceID: sinceID,
                            maxID: maxID) {[weak self] json, metadata in
            
            guard let strongSelf = self else {
                self?.isLoading = false
                if let complete = complete {
                    complete(false)
                }
                return
            }

            // 結合tweet
            var joinTweet: [TwitterInfo] = []
            // 取得したtweet
            var newTweets: [TwitterInfo] = []
            // 既存tweet
            let tweets = strongSelf.twitters
            if let array = json.array {
                for tweet in array {
                    // 既存の中に同じtweetがないか検索をかけて、存在していなければAdd
                    if !tweets.contains(where: { return $0.id == tweet["id_str"].string ?? "" }) {
                        let info = TwitterInfo(
                            id: tweet["id_str"].string ?? "",
                            name: tweet["user"]["name"].string ?? "",
                            imageUrl: tweet["user"]["profile_image_url"].string ?? "",
                            text: tweet["text"].string ?? "",
                            date: tweet["created_at"].string ?? "")
                        newTweets.append(info)
                    }
                }
            }
            strongSelf.isLoading = false
            
            // 最新のTweetは先頭に結合、過去のTweetは末尾に結合
            if sinceID != nil {
                joinTweet = newTweets + tweets
            } else {
                joinTweet = tweets + newTweets
            }
            strongSelf.twitters = joinTweet
            if let complete = complete {
                complete(true)
            }
        } failure: { e in
            self.isLoading = false
            if let complete = complete {
                complete(false)
            }
        }
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        if let twitterInfo = twitters.first {
            self.search(text: searchWord, sinceID: twitterInfo.id) { success in
                self.refreshCtl.endRefreshing()
                self.tableView.reloadData()
            }
        } else {
            refreshCtl.endRefreshing()
        }
    }
    
}

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.count > 0 {
            // 現在検索している文字列と違う場合は、検索結果を初期化しておく
            if searchWord != text {
                twitters = []
            }
            searchWord = text
            search(text: text, isFirst: twitters.count == 0) { success in
                if success {
                    self.tableView.reloadData()
                }
            }
        }
        searchBar.resignFirstResponder()
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twitters.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択ハイライトを消す　そもそもいらないかな？　今後詳細を製造時に必要か？
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterCell", for: indexPath) as! TwitterCell
        let info = twitters[indexPath.row]
        cell.config(imageUrl: info.imageUrl, name: info.name, message: info.text, date: info.date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 画像だけ表示直前で行うようにする
        if let cell = cell as? TwitterCell {
            let info = twitters[indexPath.row]
            cell.setIconImage(imageUrl: info.imageUrl)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 再読み込み処理 scrollViewの判定処理は増えたら必要
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        if currentOffsetY >= maximumOffset && tableView.isDragging {
            if let twitterInfo = twitters.last {
                self.search(text: searchWord, maxID: twitterInfo.id) { success in
                    if success {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}
