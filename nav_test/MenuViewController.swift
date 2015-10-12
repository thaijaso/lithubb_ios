//
//  MenuController.swift
//  nav_test
//
//  Created by mac on 9/16/15.
//  Copyright © 2015 mac. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var menu = [Menu]()
    var menuFiltered = [Menu]()
    
    var didPressFilterButton: Bool = false
    var previousButtonTag: Int?
    
    var myMarker: GMSMarker?
    var dispensary: Dispensary?
    
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var dispensaryName: UINavigationItem!
    @IBOutlet weak var indicaButton: UIButton!
    @IBOutlet weak var hybridButton: UIButton!
    @IBOutlet weak var sativaButton: UIButton!
    @IBOutlet weak var edibleButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    
    
    
    @IBAction func filterButtonPressed(sender: UIButton) {
        if previousButtonTag == 1 {
            indicaButton.setBackgroundImage(UIImage(named: "IndicaDark"), forState: UIControlState.Normal)
        }
        if previousButtonTag == 2 {
            hybridButton.setBackgroundImage(UIImage(named: "HybridDark"), forState: UIControlState.Normal)
        }
        if previousButtonTag == 3 {
            sativaButton.setBackgroundImage(UIImage(named: "SativaDark"), forState: UIControlState.Normal)
        }
        if previousButtonTag == 4 {
            edibleButton.setBackgroundImage(UIImage(named: "EdibleDark"), forState: UIControlState.Normal)
        }
        if previousButtonTag == 5 {
            otherButton.setBackgroundImage(UIImage(named: "BluntDark"), forState: UIControlState.Normal)
        }
        didPressFilterButton = true
        menuFiltered = [Menu]()
        if sender.tag == 1 {
            //print(NSThread.isMainThread() ? "Main Thread" : "Not on Main Thread")
            indicaButton.setBackgroundImage(UIImage(named: "Indica"), forState: UIControlState.Normal)
            //indicaButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            //hybridButton.setBackgroundImage(UIImage(named: "HybridDark"), forState: UIControlState.Normal)
            filter("Indica")
            
        } else if sender.tag == 2 {
            hybridButton.setBackgroundImage(UIImage(named: "Hybrid"), forState: UIControlState.Normal)
            //sender.titleLabel?.textColor = UIColor.blackColor()
            filter("Hybrid")
        } else if sender.tag == 3 {
            sativaButton.setBackgroundImage(UIImage(named: "Sativa"), forState: UIControlState.Normal)
            filter("Sativa")
        } else if sender.tag == 4 {
            edibleButton.setBackgroundImage(UIImage(named: "Edible"), forState: UIControlState.Normal)
            filter("Edibles")
        } else if sender.tag == 5 {
            otherButton.setBackgroundImage(UIImage(named: "Blunt"), forState: UIControlState.Normal)
            filter("Other")
        }
        previousButtonTag = sender.tag
        //print(NSThread.isMainThread() ? "Main Thread" : "Not on Main Thread")
        productTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //product tableView source and delegate
        self.productTableView.dataSource = self
        self.productTableView.delegate = self
        getMenu()
        productTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if menuFiltered.count == 0 {
//            print("drawing the table, the count of menu is", menu.count)
//            return menu.count
//        } else {
//            return menuFiltered.count
//        }
        if didPressFilterButton == false {
            return menu.count
        } else {
            return menuFiltered.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = productTableView.dequeueReusableCellWithIdentifier("StrainCell") as? StrainCell
//        print("after cell\(cell)")
//        if menuFiltered.count != 0 {
//            cell!.nameLabel?.text = menuFiltered[indexPath.row].strainName as? String
//        } else {
//            cell!.nameLabel?.text = menu[indexPath.row].strainName as? String
//        }
//        return cell!
        let cell = productTableView.dequeueReusableCellWithIdentifier("StrainCell") as? StrainCell
        if didPressFilterButton == false {
            cell!.nameLabel?.text = menu[indexPath.row].strainName
        } else {
            cell!.nameLabel?.text = menuFiltered[indexPath.row].strainName
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowProduct", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let productViewController = segue.destinationViewController as! ProductViewController
        if let indexPath = productTableView.indexPathForCell(sender as! UITableViewCell) {
            productViewController.menuItem = menu[indexPath.row]
        }

        
    }
    
    func filter(filter: String) {
        print(filter)
        for product in menu {
            if product.category as! String == filter {
                menuFiltered.append(product)
            }
        }
    }
    
    func getMenu() {
        let dispensary: Dispensary?
        let dispensaryID: String?
        
        if myMarker?.userData != nil {
            dispensary = myMarker!.userData! as! Dispensary
            print(dispensary!)
            dispensaryID = String(dispensary!.id)
            print(dispensaryID)
        } else {
            //dispensaryID = String(dispensary!.id)
            dispensaryID = "1"
        }
        //print("this is the id", dispensaryID)
        
        
        //Alamo fire http request for the items disp carries
        let string = "http://lithubb.herokuapp.com/getMenu/\(dispensaryID!)"
        print(string)
        Alamofire.request(.GET, string)
            .responseJSON { request, response, result in switch result {
            //Runs if success
            case .Success(let data):
                print("Checked for disp items, success")
                let arrOfProducts = JSON(data)
                if arrOfProducts.count != 0 {
                    for var i = 0; i < arrOfProducts.count; ++i {
                        let dispensaryName = arrOfProducts[i]["name"].string
                        let strainID = arrOfProducts[i]["strain_id"].int
                        let strainName = arrOfProducts[i]["strain_name"].string
                        let vendorID = arrOfProducts[i]["vendor_id"].int
                        let priceGram = arrOfProducts[i]["price_gram"].double
                        let priceEigth = arrOfProducts[i]["price_eigth"].double
                        let priceQuarter = arrOfProducts[i]["price_quarter"].double
                        let priceHalf = arrOfProducts[i]["price_half"].double
                        let priceOz = arrOfProducts[i]["price_oz"].double
                        let category = arrOfProducts[i]["category"].string
                        let symbol = arrOfProducts[i]["symbol"].string
                        let description = arrOfProducts[i]["description"].string
                        let fullImage = arrOfProducts[i]["fullsize_img1"].string
                        let dispensaryMenu = Menu(dispensaryName: dispensaryName!, strainID: strainID!, vendorID: vendorID!, priceGram: priceGram!, priceEigth: priceEigth!, priceQuarter: priceQuarter!, priceHalf: priceHalf!, priceOz: priceOz!, strainName: strainName!, category: category!, description: description!)
                        dispensaryMenu.fullsize_img1 = fullImage
                        self.menu.append(dispensaryMenu)
                    }
                    self.dispensaryName.title = self.menu[0].dispensaryName
                    print("printing the menu count", self.menu.count)
                    self.productTableView.reloadData()
                } else {
                    print("there were no items")
                }

            //Failure case
            case .Failure(_, let error):
                print("There was an error getting your user information")
                }
        }
        //End alamofire
    }
    //end getMenu func
}
