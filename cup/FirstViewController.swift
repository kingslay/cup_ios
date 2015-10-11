//
//  FirstViewController.swift
//  Cup
//
//  Created by king on 15/10/11.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import Moya

let CupProvider = RxMoyaProvider<Cup>(endpointClosure: { (let target) -> Endpoint<Cup> in
    let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
       switch target {
    case .Add(_,_):
        return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: .JSON)
    default:
        return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)

    }

})

public enum Cup {
    case Jsonfeed
    case Add(String,String)
    case TestError
}

extension Cup : MoyaTarget {
    public var baseURL: NSURL { return NSURL(string: "http://localhost:8080")! }
    public var path: String {
        switch self {
        case .Jsonfeed:
            return "/user/jsonfeed"
        case .Add(_,_):
            return "/user/add"
        case .TestError:
            return "/user/testError"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .Add(_,_):
            return .POST
        default:
            return .GET
        }
    }
    public var parameters: [String: AnyObject]? {
        switch self {
        case .Add(let user,let password):
            return ["username":user,"password":password]
        default:
            return nil
        }
    }
    
    public var sampleData: NSData {        return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
    }
}

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        CupProvider.request(.Jsonfeed).mapJSON().subscribeNext { (let json) -> Void in
            print(json)
        }
        CupProvider.request(.Add("wang","1")).mapString().subscribe { (event) -> Void in
            print(event)
        }
        CupProvider.request(.TestError).subscribe { (event) -> Void in
            print(event)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

