//
//  ShareSheet.swift
//  Cup
//
//  Created by king on 16/8/13.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit
import MonkeyKing

public class ShareSheet: UIView {
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var qqSpaceButton: UIButton!
    @IBOutlet weak var qqSessionButton: UIButton!
    @IBOutlet weak var weiboButton: UIButton!
    @IBOutlet weak var wxFriendButton: UIButton!
    @IBOutlet weak var wxTimeLineButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    let backgroundView: UIView
    var image: UIImage?
    required public init?(coder aDecoder: NSCoder) {
        self.backgroundView = UIView()
        super.init(coder: aDecoder)
        self.backgroundView.frame = self.frame
        self.backgroundView.autoresizingMask = [.FlexibleHeight,.FlexibleWidth]
        self.backgroundView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.55)
        self.addSubview(self.backgroundView)
        self.sendSubviewToBack(self.backgroundView)
    }
    public func showIn(view: UIView) {
        image = UIImage.ks_imageFrom(view)
        self.frame = view.bounds
        view .addSubview(self)
        self.backgroundView.alpha = 0
        self.containView.ks_top = self.ks_bottom
        UIView.animateWithDuration(0.25) { 
            self.backgroundView.alpha = 1
            self.containView.ks_top = self.ks_bottom - self.containView.ks_height
        }
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(shareButtonTouchUpInside(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    @IBAction func shareButtonTouchUpInside(view: UIView?) {
        if let view = view where view !== self.cancelButton {
            let info: MonkeyKing.Info = (title: "Session",
                description: "Hello Session",
                thumbnail: image,
                media: .URL(NSURL(string: "http://www.apple.com/cn")!))
            var message: MonkeyKing.Message?
            switch view {
            case self.weiboButton:
                message = MonkeyKing.Message.Weibo(.Default(info: info,accessToken:nil))
            case self.wxFriendButton:
                message = MonkeyKing.Message.WeChat(.Session(info:info))
            case self.wxTimeLineButton:
                message = MonkeyKing.Message.WeChat(.Timeline(info:info))
            case self.qqSessionButton:
                message = MonkeyKing.Message.QQ(.Friends(info:info))
            case self.qqSpaceButton:
                message = MonkeyKing.Message.QQ(.Zone(info:info))
            default: break
            }
            if let message = message {
                MonkeyKing.shareMessage(message) { success in
                    print("shareURLToWeChatSession success: \(success)")
                }
            }
        }
        UIView.animateWithDuration(0.25) {
            self.containView.ks_top = self.ks_bottom
            self.backgroundView.alpha = 0
        }
    }
}
