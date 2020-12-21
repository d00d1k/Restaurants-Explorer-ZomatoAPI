//
//  RestaurantsListViewController.swift
//  Restaurants Explorer
//
//  Created by Nikita Kalyuzhnyy on 16.12.2020.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire

class RestaurantsListViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentControl: UISegmentedControl!
    
    var lattitudeValue = String()
    var longitudeValue = String()
    
    var restaurantNamesArray = [String]()
    var restaurantIdArray = [String]()
    var restaurantImgArray = [String]()
    var restaurantRaiting = [String]()
    var restaurantsSortFilter = String()
    
    let locationManager = CLLocationManager()
    
    @IBAction func segmentPressed(_ sender: UISegmentedControl) {
        sortSegmentPressed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        self.getRestaurantList()
    }
    
    func sortSegmentPressed() {
        switch sortSegmentControl.selectedSegmentIndex {
        case 0:
            restaurantsSortFilter = "cost"
            getRestaurantList()
        case 1:
            restaurantsSortFilter = "rating"
            getRestaurantList()
        case 2:
            restaurantsSortFilter = "real_distance"
            getRestaurantList()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            
            self.lattitudeValue = String(format: "%.2f", location.coordinate.latitude)
            self.longitudeValue = String(format: "%.2f", location.coordinate.longitude)
            print(lattitudeValue)
            print(longitudeValue)
        }
    }
    
    func getRestaurantList() {
        
        let url = "https://developers.zomato.com/api/v2.1/search"
        let parameters: [String: Any] = [
//            "lat": "37.33047789",//"\(self.lattitudeValue)",
//            "lon": "-122.02870208"//"\(self.longitudeValue)"
            "lat": "\(self.lattitudeValue)",
            "lon": "\(self.longitudeValue)",
            "sort": restaurantsSortFilter
        ]
        
        let headers: HTTPHeaders = [
            "user-key": "60aff11bda397cdd548306f8c24437d4",
            "Accept": "application/json"
        ]
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON {
            (response) in
            
            switch response.result {
            case .success(let JSON):
                
                if let dataDict = JSON as? [String: Any] {
                    debugPrint(JSON)
                    
                    if let nearbyRestaurants = dataDict["restaurants"] as? [[String: Any]] {
                        
                        self.restaurantNamesArray = []
                        self.restaurantIdArray = []
                        self.restaurantImgArray = []
                        
                        if nearbyRestaurants.count > 0 {
                            
                            for dictionaryData: Dictionary<String, Any> in nearbyRestaurants {
                                
                                if let restaurantsDictionary = dictionaryData["restaurant"] as? [String: Any] {
                                    
                                    let restaurantName: String = restaurantsDictionary["name"] as? String ?? "No Name"
                                    let restaurantId: String = restaurantsDictionary["id"] as? String ?? ""
                                    let restaurantFeatureImg: String = restaurantsDictionary["featured_image"] as? String ?? ""
                                    
                                    if let raiting = restaurantsDictionary["user_rating"] as? [String: Any] {
                                        let restaurantRaiting: String = raiting["rating_text"] as? String ?? "no raiting"
                                        self.restaurantRaiting.append(restaurantRaiting)
                                    }
                                    
                                    
                                    self.restaurantNamesArray.append(restaurantName)
                                    self.restaurantIdArray.append(restaurantId)
                                    self.restaurantImgArray.append(restaurantFeatureImg)
                                    print(self.restaurantNamesArray)
                                }
                            }
                        }
                    }
                }
                print("raiting \(self.restaurantRaiting)")
                print(self.restaurantNamesArray)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    
}

extension RestaurantsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurantNamesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.restaurantNameLabel.text = self.restaurantNamesArray[indexPath.row]
        
        if self.restaurantImgArray[indexPath.item] != "" {
            DataManager.getData(from: self.restaurantImgArray[indexPath.item] as String) {
                data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async {
                    cell.mainImage.image = UIImage(data: data)
                }
            }
        } else {
            DispatchQueue.main.async {
                cell.mainImage.image = UIImage(named: "1024px-No_image_available.svg")
            }
        }
        
        
        cell.raitingOfRestaurant.text = self.restaurantRaiting[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let restaurantDetailsViewController = self.storyboard!.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as? RestaurantDetailViewController
        
        restaurantDetailsViewController?.restaurantId = self.restaurantIdArray[indexPath.row]
        restaurantDetailsViewController?.restaurantName = self.restaurantNamesArray[indexPath.row]
        restaurantDetailsViewController?.restaurantImg = self.restaurantImgArray[indexPath.row]
        
        if (navigationController?.topViewController is RestaurantDetailViewController) {
            return
        } else {
            navigationController?.pushViewController(restaurantDetailsViewController!, animated: true)
        }
    }
}



