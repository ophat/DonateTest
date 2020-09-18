//
//  DonateViewController.swift
//  TempleteApp
//
//  Created by ophat on 9/18/20.
//  Copyright © 2020 Ophat. All rights reserved.
//

import UIKit
import ObjectMapper

class DonateViewController: UIViewController , UIAlertViewDelegate {

    var donateid:Int!
    
    @IBOutlet weak var mNameField: UITextField!
    @IBOutlet weak var mAmountField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func Donate(_ sender: Any) {
        
        if (mNameField.text!.count) > 0 && (mAmountField.text!.count) > 0  {
            Loading.shareInstance().loading(view: self.view)
            
            let callback = #selector(donate_callback(apires:))
            let request = APIRequest.shareInstance().requestDonations(name: mNameField.text!, amount: Int(mAmountField.text!)!)
                   
            APICaller.shareInstance().callAPI(path: SERVERPATH.donates.rawValue , cookie: "" , jsonObject: request , delegate: self , sel: callback )
        }
        
    }
    
    
    @objc func donate_callback(apires : APIResponse){
        
        let statusCode = Int(apires.status!)
        let data   = apires.data!["data"] as! NSDictionary

        let object = Mapper<APIRes_Donate>().map(JSONObject: data)
                   
        if RESPONSE.SERVER_OK_START_RANGE.rawValue ... RESPONSE.SERVER_OK_END_RANGE.rawValue ~= statusCode! {

            if (object!.success){
                
                let alert = UIAlertController(title:"Donate Success" , message: "", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                }))
                 

                self.present(alert, animated: true)
                
            }
            
        }else{
           //error
            
            let alert = UIAlertController(title:object?.error_code , message: object?.error_message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
            }))

            self.present(alert, animated: true)
        
        }
        Loading.shareInstance().unload()
    }
     
}
