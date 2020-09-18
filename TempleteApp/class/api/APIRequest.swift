//
//  APIRequest.swift
//  SalesLove
//
//  Created by ophat on 11/12/19.
//  Copyright © 2019 Inception. All rights reserved.
//

import UIKit

class APIRequest: NSObject {

    static var mAPIRequest:APIRequest?
    
    override init() {
        super.init()
        APIRequest.mAPIRequest = self;
    }
    class func shareInstance() -> APIRequest{
        return mAPIRequest!
    }
    
    func requestDonations(name:String , amount:Int) -> [String: AnyObject] {
        let jsonObject  = ["name": name,
                           "token": "tokn_test_deadbeef",
                           "amount" : amount
                          ] as [String : Any]
        return jsonObject as [String : AnyObject]
            
    }
    
}
