//
//  FootpathTableViewController.swift
//  Transit
//
//  Created by Pat on 08/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit

class FootpathTableViewController: UITableViewController {
    private let cellIdentifier = "FootpathTable"
    private var footpaths = [[String:Any]]()
    private var collection:ApigeeCollection!
    private var loading = false
    @IBOutlet weak var loadingIndcator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dataClient = appDelegate.apigeeDataClient
        dataClient?.setLogging(true)
        loading = true
        navigationController?.navigationBar.addSubview(loadingIndcator)
        loadingIndcator.center.x=(navigationController?.navigationBar.center.x)!-60
        loadingIndcator.center.y=(navigationController?.navigationBar.center.y)!-20
        DispatchQueue.main.async(execute: {
            self.loadingIndcator.startAnimating()
        })
        collection = dataClient?.getCollection("footpaths") { resp in
            var entity = self.collection.getNextEntity()
            while entity != nil {
                let name = entity?.getStringProperty("name")
                let start_address = entity?.getStringProperty("start_address")
                let end_address = entity?.getStringProperty("end_address")
                let polyline = entity?.getStringProperty("overview_polyline")
                let start_location = entity?.getObjectProperty("start_location") as? NSDictionary
                let end_location = entity?.getObjectProperty("end_location") as? NSDictionary
                let footpath = ["name" : name,
                                "start_address" : start_address,
                                "end_address" : end_address,
                                "polyline" : polyline,
                                "start_lat" : start_location?["lat"],
                                "start_lng" : start_location?["lng"],
                                "end_lat" : end_location?["lat"],
                                "end_lng" : end_location?["lng"]]
                self.footpaths.append(footpath )
                entity = self.collection.getNextEntity()
            }
            while self.collection.hasNextPage () {
                self.collection.getNextPage()
                let response = self.collection.getNextPage()!
                if response.completedSuccessfully() {
                    var entity = self.collection.getNextEntity()
                    while entity != nil {
                        let name = entity?.getStringProperty("name")
                        let start_address = entity?.getStringProperty("start_address")
                        let end_address = entity?.getStringProperty("end_address")
                        let polyline = entity?.getStringProperty("overview_polyline")
                        let start_location = entity?.getObjectProperty("start_location") as? NSDictionary
                        let end_location = entity?.getObjectProperty("end_location") as? NSDictionary
                        let footpath = ["name" : name,
                                        "start_address" : start_address,
                                        "end_address" : end_address,
                                        "polyline" : polyline,
                                        "start_lat" : start_location?["lat"],
                                        "start_lng" : start_location?["lng"],
                                        "end_lat" : end_location?["lat"],
                                        "end_lng" : end_location?["lng"]]
                        self.footpaths.append(footpath)
                        entity = self.collection.getNextEntity()
                    }
                }
            }
            self.footpaths.sort{($0["name"] as! String) < ($1["name"] as! String)}
            self.loading = false
            DispatchQueue.main.async(execute: {
                self.loadingIndcator.stopAnimating()
            })
            self.tableView.reloadData()
         }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if loading  {
            return 0
        }
        else {
            return footpaths.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text=footpaths[indexPath.row]["name"] as? String
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
