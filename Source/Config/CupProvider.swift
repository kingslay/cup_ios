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

extension ObservableType where E: Moya.Response {
    /// Maps data received from the signal into a JSON object. If the conversion fails, the signal errors.
    public func mapSwiftyJSON() -> Observable<JSON> {
        return flatMap { response -> Observable<JSON> in
            return Observable.just(JSON(data: response.data))
        }
    }
}
public enum CupMoya: TargetType  {
    case login(String,String)
    case regist(String,String)
    case phoneLogin(String)
    case saveMe
    case clock(String)
    case temperature(String,Int)
    case uploadImage([String: String]?,[Moya.MultipartFormData])
}

extension CupMoya {
    //let host = "http://localhost:8280"
    public var baseURL: URL { return URL(string: "https://114.55.91.36:8282")! }
    public var task: Task {
        switch self {
        case .uploadImage(_,let multipart):
            return .upload(.multipart(multipart))
        default:
            return .request
        }
    }
    public var path: String {
        switch self {
        case .login(_, _):
            return "/user/login"
        case .regist(_,_):
            return "/user/regist"
        case .phoneLogin(_):
            return "/user/phonelogin"
        case .saveMe:
            return "/user/saveme"
        case .clock(_),.temperature(_, _):
            return "/behaviour"
        case .uploadImage(_, _):
            return "/user/updateProfile.do"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .login(_,_),.phoneLogin(_):
            return .GET
        case .clock(_),.temperature(_, _),.uploadImage(_,_):
            return .POST
        default:
            return .PUT
        }
    }
    public var parameters: [String: Any]? {
        switch self {
        case .regist(let user,let password):
            return ["username":user,"password":password]
        case .login(let user,let password):
            return ["username":user,"password":password]
        case .phoneLogin(let phone):
            return ["phone":phone]
        case .saveMe:
            return staticAccount?.dictionary
        case .clock(let clock):
            return ["clock":clock]
        case .temperature(let explanation, let temperature):
            return ["explanation":explanation,"temperature":temperature]
        case .uploadImage(let dic,_):
            return dic
        }
    }
    public var sampleData: Data {
        return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
    }
}
extension CupMoya {
    ///因为AlamofireImage不是马上执行的，所以不能用单例
    public static func sharedManager() -> Manager {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            // 不验证证书链，总是让 TLS 握手成功
            "121.199.75.79": .disableEvaluation,
            "114.55.91.36": .disableEvaluation
        ]
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        return Manager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }
    public static func DefaultEndpointMapping(_ target: CupMoya) -> Endpoint<CupMoya> {
        let url = target.baseURL.appendingPathComponent(target.path).absoluteString
        switch target {
        case .login(_,_),.phoneLogin(_):
            return Endpoint(URL: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        case .uploadImage(_,_):
            return Endpoint(URL: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters:nil , parameterEncoding: JSONEncoding(),httpHeaderFields: target.parameters as? [String : String])
        default:
            return Endpoint(URL: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: JSONEncoding())
            
        }
    }
    public static let credentialsPlugin = CredentialsPlugin {
        switch $0 {
        case CupMoya.login(_, _),CupMoya.regist(_,_),CupMoya.phoneLogin(_):
            return nil
        default:
            return URLCredential(user: staticAccount!.phone!, password: "phone", persistence: .forSession)
        }
    }

    public static func upload(imagePath:URL, headers: [String: String]? = nil) {
        var dict = [String : String]()
        if headers != nil {
            dict = headers!
        }
        dict["accountid"] = "\(staticAccount!.accountid)"
        _ = CupProvider.request(.uploadImage(dict,[Moya.MultipartFormData(provider: .file(imagePath), name: "file")])).mapJSON().subscribe(onNext: { (data) -> Void in
            if let json = data as? [String:Any],let url = json["url"] as? String {
                staticAccount?.avatar = url
            }
        })
    }
}
let CupProvider = RxMoyaProvider<CupMoya>(endpointClosure:CupMoya.DefaultEndpointMapping ,manager:CupMoya.sharedManager(), plugins: [CupMoya.credentialsPlugin])


extension Notification.Name {
    static let synchronizeClock = Notification.Name("synchronizeClock")
}
