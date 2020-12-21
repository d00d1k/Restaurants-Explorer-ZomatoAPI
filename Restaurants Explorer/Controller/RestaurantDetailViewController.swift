//
//  RestaurantDetailViewController.swift
//  Restaurants Explorer
//
//  Created by Nikita Kalyuzhnyy on 19.12.2020.
//

import Foundation
import UIKit
import Alamofire

class RestaurantDetailViewController: UIViewController {
    
    var restaurantId: String = ""
    var restaurantName: String = ""
    var restaurantImg: String = ""
    var restaurantAddress: String = ""
    var restaurantContact: String = ""
    var restaurantCity: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = restaurantName
        self.getRestaurantDetailsAPICall()
    }
    
    func getRestaurantDetailsAPICall() {
        
        let url = "https://developers.zomato.com/api/v2.1/restaurant"
        let params: [String: Any] = [
            "res_id": restaurantId
        ]
        
        let headers: HTTPHeaders = [
            "user-key": "60aff11bda397cdd548306f8c24437d4",
            "Accept": "application/json"
        ]
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            
            switch response.result {
            case .success(let JSON):
                
                if let dataDict = JSON as? [String: Any] {
                   
                    if let locationData: [String: Any] = dataDict["location"] as? [String: Any] {
                        
                        let addressValue: String = locationData["address"] as? String ??  "No Address Found"
                        self.restaurantAddress = addressValue
                        
                        let cityValue: String = locationData["city"] as? String ?? "No city found"
                        self.restaurantCity = cityValue
                    }
                    
                    let contactNumber:String = dataDict["phone_numbers"] as? String ??  "Not Found"
                    self.restaurantContact = contactNumber
                    
                }
                                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}

extension RestaurantDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantInformationCell", for: indexPath) as! RestaurantInformationCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none;
        
        cell.addressLabel.text = restaurantAddress
        cell.cityLabel.text = restaurantCity
        cell.contactNumberLabel.text = restaurantContact
        
        if self.restaurantImg != "" {
            DataManager.getData(from: self.restaurantImg as String) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async() {
                    cell.backGroundImage.image = UIImage(data: data)
                    cell.mainImage.image = UIImage(data: data)
                }
            }
        } else {
            cell.mainImage.image = UIImage(named: "1024px-No_image_available.svg")
        }
        
        return cell
    }
}
