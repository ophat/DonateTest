
//
//  APICaller.swift
//  APICaller
//
//  Created by ophat on 23/4/2562 BE.
//  Copyright © 2562 ophat. All rights reserved.
//

import UIKit
import Alamofire

enum APIError: Error {
    case noData
}

//// MARK: - BASEURL
enum BASESERVER:String {
    case BASE_URL       = "https://virtserver.swaggerhub.com/"
    case BASE           = "virtserver.swaggerhub.com"
}

enum SERVERPATH:String {
    case charity          = "chakritw/tamboon-api/1.0.0/charities"
    case donates          = "chakritw/tamboon-api/1.0.0/donations"
}

//// MARK: - Enum
enum RESPONSE:Int {
    case SERVER_OK_START_RANGE          = 200
    case SERVER_OK_END_RANGE            = 299
    
    case CLIENT_ERR_START_RANGE         = 400
    case CLIENT_ERR_END_RANGE           = 499
    
    case SERVER_ERR_START_RANGE         = 500
    case SERVER_ERR_END_RANGE           = 599
}

class APICaller: NSObject , URLSessionDelegate {

    static var mAPICaller:APICaller?
    
    override init() {
        super.init()
        APICaller.mAPICaller = self;
        APIRequest.init()
        APIResponse.init()
        
    }
    
    class func shareInstance() -> APICaller{
        return mAPICaller!
    }
    
    func callAPI(path:String , cookie:String , jsonObject:[String: AnyObject]? , delegate:Any? , sel:Selector){
            
        var method = HTTPMethod.get
        
        let parameters = jsonObject
        
        if parameters != nil{
            method = .post
        }
            
        APICaller.Manager.request( BASESERVER.BASE_URL.rawValue + path , method: method , parameters: parameters , encoding: JSONEncoding.default ).responseJSON { (responseData) -> Void in

                let return_api  = APIResponse.init()
                var dict = NSMutableDictionary.init()
            
                if responseData.result.value != nil {

                    return_api.status = String(format: "%d", responseData.response!.statusCode)

                    do{
                        let json = try JSONSerialization.jsonObject(with: responseData.data!, options: [])
                        dict.setObject(json, forKey: "data" as NSCopying)
                    }catch{}
                    
                }else{
                    return_api.status = String(format: "%d", 404)
                    dict.setObject(NSDictionary.init(), forKey: "data" as NSCopying)
                    
                }
            
                return_api.data = dict
            
                if let myClass = delegate as? NSObjectProtocol {
                    if myClass.responds(to: sel) {
                        myClass.perform(sel , with: return_api  )
                    }
                }

            
        }

    }
    
    private static var Manager : Alamofire.SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [BASESERVER.BASE.rawValue : .disableEvaluation]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate) {
            completionHandler(.rejectProtectionSpace, nil)
        }
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        }
    }
   
    func convertImgToBase64(img:UIImage)->String{
        let data:NSData = img.jpegData(compressionQuality: 0.5)! as NSData
        
        let imageString = data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        return imageString
    }
    
    func encodeURIComponent(string : String) -> String? {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-_.!~*'()")
        return string.addingPercentEncoding(withAllowedCharacters: characterSet)
    }
    
    public static func convertJSON(data : APIResponse) -> NSMutableDictionary{
    
        let dict = NSMutableDictionary.init()
        let statusCode = Int(data.status)
        
        if RESPONSE.SERVER_OK_START_RANGE.rawValue ... RESPONSE.SERVER_OK_END_RANGE.rawValue ~= statusCode! {
        
                   
            let datastr = String(format: "%@", data.data)
            let jdata = datastr.data(using: .utf8)
            do{
                if let returnValue = try JSONSerialization.jsonObject(with: jdata!, options : .allowFragments) as? Dictionary<String, Any> {
                    dict.setObject(data.status, forKey: "status" as NSCopying)
                   dict.setObject(returnValue, forKey: "data" as NSCopying)
                }
            } catch{}
         }
        else if RESPONSE.CLIENT_ERR_START_RANGE.rawValue ... RESPONSE.CLIENT_ERR_END_RANGE.rawValue ~= statusCode! {
        
             dict.setObject(data.status, forKey: "status" as NSCopying)
         }
         else if RESPONSE.SERVER_ERR_START_RANGE.rawValue ... RESPONSE.SERVER_ERR_END_RANGE.rawValue ~= statusCode! {
         
             dict.setObject(data.status, forKey: "status" as NSCopying)
         }
        
        return dict
    }
    
 
}
