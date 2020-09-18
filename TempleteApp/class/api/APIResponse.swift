//
//  APIResponse.swift
//  Love(Sale)
//
//  Created by ophat on 2/27/20.
//  Copyright © 2020 Inception. All rights reserved.
//

import UIKit
import ObjectMapper

/*
    {
      "total": 10,
      "data": [
        {
          "id": 7331,
          "name": "Habitat for Humanity",
          "logo_url": "http://www.adamandlianne.com/uploads/2/2/1/6/2216267/3231127.gif"
        }
      ]
    }
*/

/*
 {
   "success": true,
   "error_code": "insufficient_minerals",
   "error_message": "Card has insufficient balance."
 }
 
 */

//=========================== Main

class APIResponse: NSObject {
    var status:String!
    var data:NSMutableDictionary!
}
 
//=========================== Model

class APIRes_Charities : Mappable{

    var total:Int!
    var data:NSArray!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
         total <- map["total"]
         data <- map["data"]
    }
}

class charitiesData : Mappable{

    var id:Int!
    var name:String!
    var logo_url:String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
         id <- map["id"]
         name <- map["name"]
         logo_url <- map["logo_url"]
    }
}
 
class APIRes_Donate : Mappable{

    var success:Bool!
    var error_code:String!
    var error_message:String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
         success <- map["success"]
         error_code <- map["error_code"]
         error_message <- map["error_message"]
    }
}

