//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    func downloadJSon(_ url: String, _ completion: @escaping (String?) -> Void) {
        DispatchQueue.global().async {
            let url = URL(string: url)!
            let data = try! Data(contentsOf: url)
            let json = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                completion(json)
            }
        }
    }
    
    // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
    func downloadJson(_ url: String) -> Observable<String?> {
        return Observable.create { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, err) in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                
                if let dat = data, let json = String(data: dat, encoding: .utf8) {
                    emitter.onNext(json)
                }
                
                emitter.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
            
        }
        
        //        return Observable.create { f in
        //            DispatchQueue.global().async {
        //                let url = URL(string: url)!
        //                let data = try! Data(contentsOf: url)
        //                let json = String(data: data, encoding: .utf8)
        //
        //                DispatchQueue.main.async {
        //                    f.onNext(json)
        //                }
        //            }
        //            return Disposables.create()
        //        }
    }
    
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        self.setVisibleWithAnimation(self.activityIndicator, true)
        
        // 2. Obervable로 오는 데이터를 사용하는 방법
        downloadJson(MEMBER_LIST_URL)
            .subscribe { event in
                switch event {
                case .next(let json):
                    DispatchQueue.main.async {
                        self.editView.text = json
                        self.setVisibleWithAnimation(self.activityIndicator, false)
                    }
                case .completed:
                    break
                case .error(_):
                    break
                }
            }
        
        //        let observable = downloadJson(MEMBER_LIST_URL)
        //        let disposable = observable.subscribe { event in
        //            switch event {
        //            case .next(let json):
        //                DispatchQueue.main.async {
        //                    self.editView.text = json
        //                    self.setVisibleWithAnimation(self.activityIndicator, false)
        //                }
        //            case .completed:
        //                break
        //            case .error(_):
        //                break
        //            }
        //        }
        
    }
}

