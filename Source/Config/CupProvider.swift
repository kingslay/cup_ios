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
      return just(JSON(data: response.data))
    }
  }
}
public enum CupMoya: TargetType  {
  case Login(String,String)
  case Regist(String,String)
  case PhoneLogin(String)
  case SaveMe
  case Clock(String)
  case Temperature(String,Int)
}
//let host = "http://121.199.75.79:8280"
let host = "https://localhost:8282"

extension CupMoya {
  public var baseURL: NSURL { return NSURL(string: host)! }
  public var path: String {
    switch self {
    case .Login(_, _):
      return "/user/login"
    case .Regist(_,_):
      return "/user/regist"
    case .PhoneLogin(_):
      return "/user/phonelogin"
    case .SaveMe:
      return "/user/saveme"
    case .Clock(_),.Temperature(_, _):
      return "/behaviour"
    }
  }
  public var method: Moya.Method {
    switch self {
    case .Login(_,_),.PhoneLogin(_):
      return .GET
    case .Clock(_),.Temperature(_, _):
      return .POST
    default:
      return .PUT
    }
  }
  public var parameters: [String: AnyObject]? {
    switch self {
    case .Regist(let user,let password):
      return ["username":user,"password":password]
    case .Login(let user,let password):
      return ["username":user,"password":password]
    case .PhoneLogin(let phone):
      return ["phone":phone]
    case .SaveMe:
      return staticAccount?.toDictionary()
    case .Clock(let clock):
      return ["clock":clock]
    case .Temperature(let explanation, let temperature):
      return ["explanation":explanation,"temperature":temperature]
    }
  }
  
  public var sampleData: NSData {
    return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
  }
}

let CupProvider = RxMoyaProvider<CupMoya>(endpointClosure: { (let target) -> Endpoint<CupMoya> in
  let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
  switch target {
  case .Login(_,_),.PhoneLogin(_):
    return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
  default:
    return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: .JSON)
    
  }
  }, plugins: [CredentialsPlugin {
    switch $0 {
    case CupMoya.Login(_, _),CupMoya.Regist(_,_),CupMoya.PhoneLogin(_):
            return nil
    default:
      return NSURLCredential(user: staticAccount!.phone!, password: "phone", persistence: .ForSession)
    }
    }])


func uploadImage(imagePath:NSURL, headers: [String: String]? = nil){
  var dict = [String : String]()
  if headers != nil {
    dict = headers!
  }
  dict["accountid"] = "\(staticAccount!.accountid)"
  Alamofire.upload(.POST, host+"/user/updateProfile.do",headers:dict,multipartFormData: {
    $0.appendBodyPart(fileURL: imagePath, name: "file")
    }, encodingCompletion: {
      switch $0 {
      case .Success(let upload,_,_):
        upload.authenticate(user: staticAccount!.phone!, password: "phone")
        upload.responseJSON {
          if let data = $0.result.value, let url = JSON(data)["url"].string {
            staticAccount?.avatar = url
          }
        }
        break
      case .Failure(_):
        break
      }
  })
}
