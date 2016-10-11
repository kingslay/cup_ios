//
//  ShareSheet.swift
//  Cup
//
//  Created by king on 16/8/13.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit
import MonkeyKing
import KSSwiftExtension
public class ShareSheet: UIView {
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var shareSrollView: UIScrollView!
    @IBOutlet weak var qqSpaceButton: UIButton!
    @IBOutlet weak var qqSessionButton: UIButton!
    @IBOutlet weak var weiboButton: UIButton!
    @IBOutlet weak var wxFriendButton: UIButton!
    @IBOutlet weak var wxTimeLineButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var backgroundView: UIView!
    var image: UIImage?

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView = UIView()
        self.backgroundView.frame = self.frame
        self.backgroundView.autoresizingMask = [.FlexibleHeight,.FlexibleWidth]
        self.backgroundView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.55)
        self.addSubview(self.backgroundView)
        self.sendSubviewToBack(self.backgroundView)
        shareSrollView.contentSize = CGSize(width: 320, height: 88)
    }
    public func showIn(view: UIView) {
        image = Swifty<UIImage>.imageFrom(view)
        self.frame = view.bounds
        if shareSrollView.ks.width > shareSrollView.contentSize.width {
            shareSrollView.ks.size(shareSrollView.contentSize)
            shareSrollView.ks.centerX(frame.width/2)
        }
        view .addSubview(self)
        self.backgroundView.alpha = 0
        self.containView.ks.top(self.ks.bottom)
        UIView.animateWithDuration(0.25) {
            self.backgroundView.alpha = 1
            self.containView.ks.top(self.ks.bottom - self.containView.ks.height)
        }
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(shareButtonTouchUpInside(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    @IBAction func shareButtonTouchUpInside(view: UIView?) {
        if let view = view where view !== self.cancelButton {
            let info: MonkeyKing.Info = (title: "MateCup",
                                         description: "MateCup一款真正温度定制智能水杯。",
                                         thumbnail: image,
                                         media: .Image(image!)
            )
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
        UIView.animateWithDuration(0.25, animations: {
            self.containView.ks.top(self.ks.bottom)
            self.backgroundView.alpha = 0

        }) { _ in
            self.removeFromSuperview()
        }
    }
}
