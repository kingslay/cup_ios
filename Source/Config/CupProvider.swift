//
//  CupProvider.swift
//  Cup
//
//  Created by kingslay on 15/11/2.
//  Copyright © 2015年 king. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import SwiftyJSON
import Alamofire

extension ObservableType where E: MoyaResponse {
    /// Maps data received from the signal into a JSON object. If the conversion fails, the signal errors.
    public func mapSwiftyJSON() -> Observable<JSON> {
        return flatMap { response -> Observable<JSON> in
            return just(JSON.init(data: response.data))
        }
    }
}
let CupProvider = RxMoyaProvider<CupMoya>(endpointClosure: { (let target) -> Endpoint<CupMoya> in
    let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
    switch target {
    case .Regist(_,_):
        return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: .JSON)
    default:
        return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        
    }
    
})

public enum CupMoya {
    case Login(String,String)
    case Regist(String,String)
}
let host = "http://localhost:8080/"
extension CupMoya : MoyaTarget {
    public var baseURL: NSURL { return NSURL(string: host)! }
    public var path: String {
        switch self {
        case .Login(_, _):
            return "/user/login"
        case .Regist(_,_):
            return "/user/regist"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .Regist(_,_):
            return .POST
        default:
            return .GET
        }
    }
    public var parameters: [String: AnyObject]? {
        switch self {
        case .Regist(let user,let password):
            return ["username":user,"password":password]
        case .Login(let user,let password):
            return ["username":user,"password":password]
        default:
            return nil
        }
    }
    
    public var sampleData: NSData {
        return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
    }
}

func uploadImage(imagePath:NSURL, headers: [String: String]? = nil){
    Alamofire.upload(.POST, host+"user/updateProfile.do",headers:headers,multipartFormData: {
        $0.appendBodyPart(fileURL: imagePath, name: "file")
        }, encodingCompletion: {
            switch $0 {
            case .Success(let upload,_,_):
                upload.responseJSON {
                    let json = JSON.init($0.result.value!)
                    staticAccount?.headImageURL = host + json["url"].stringValue
                    AccountModel.sharedAccount = staticAccount
                }
                break
            case .Failure(let _):
                break
            }
    })
}