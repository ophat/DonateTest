//
//  ViewController.swift
//  TempleteApp
//
//  Created by ophat on 8/21/20.
//  Copyright © 2020 Ophat. All rights reserved.
//

import UIKit
import ObjectMapper

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var mTableView: UITableView!
    
    var mChariteisList: NSMutableArray!
    var mRefresher:UIRefreshControl!
     
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAPI()
    }
    
    func setup(){
        mChariteisList  = NSMutableArray.init()

        mTableView.delegate     = self
        mTableView.dataSource   = self

        // Pull To Refresh
        mRefresher = UIRefreshControl()

        mRefresher.attributedTitle =  NSAttributedString(string:"Refreshing...")
        mRefresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        mTableView.refreshControl = mRefresher
        
        self.navigationItem.title = "Omise Charities"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    @objc func refresh(){
        
        DispatchQueue.main.async {
            self.mTableView.refreshControl?.endRefreshing()
            self.mRefresher.endRefreshing()
        }
        
        mChariteisList.removeAllObjects()
        mTableView.reloadData()
    
        
        
        getAPI()
        
    }
    
    //MARK: API
    func getAPI(){
        Loading.shareInstance().loading(view: self.view)
        
        APICaller.shareInstance().callAPI(path:SERVERPATH.charity.rawValue , cookie:"" , jsonObject:nil , delegate:self , sel:#selector(callBack))
    }
    
    @objc func callBack(apires:APIResponse){
       
        let statusCode = Int(apires.status!)
        let data   = apires.data!["data"] as! NSDictionary
         
        let charities = Mapper<APIRes_Charities>().map(JSONObject: data)
        
        if RESPONSE.SERVER_OK_START_RANGE.rawValue ... RESPONSE.SERVER_OK_END_RANGE.rawValue ~= statusCode! {
            
            let dataArray = Mapper<charitiesData>().mapArray(JSONObject: charities?.data)! as NSArray
            mChariteisList = NSMutableArray.init(array: dataArray )

            mTableView.reloadData()
 
        }else{
             self.perform(#selector(showErrorDialog(msg:)), with: apires.status!, afterDelay: 0.1)
        }
        
        Loading.shareInstance().unload()
    }
    
    // MARK: TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mChariteisList == nil {
            return 0
        }
        return mChariteisList.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
       let cellIdentifier = "charitiesDetail"
       
       guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? charitiesDetailCell  else {
           fatalError("The dequeued cell is not an instance of AgentDetail.")
       }
       
        let data = mChariteisList[indexPath.row] as! charitiesData

        cell.mTitle.text    = data.name
        let imageData = NSData(contentsOf: URL(string: data.logo_url)!)
        cell.mImage.image   = UIImage.init(data: imageData! as Data)
        cell.selectionStyle = .none

       return cell
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let data = mChariteisList[indexPath.row] as! charitiesData
        
        let page = self.storyboard!.instantiateViewController(withIdentifier: "donateview") as! DonateViewController
        page.donateid = data.id
        self.navigationController?.pushViewController(page, animated: true)
    
    }
    
    @objc func showErrorDialog(msg:String){
        let alert = UIAlertController(title:"Error" , message: msg, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

        }))

        self.present(alert, animated: true)
    }
}

class charitiesDetailCell:UITableViewCell{
    
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mTitle: UILabel!
    
}
