//
//  SelectTableViewController.swift
//  Transit
//
//  Created by Pat on 06/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit

class SelectTableViewController: UITableViewController {
    private let cellIdentifier = "SelectTable"
    private var interchanges = [Interchange]()
    weak var selectedListViewController: InterchangeTableViewController?
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dataClient = appDelegate.apigeeDataClient
        dataClient?.setLogging(true)
        if let collection = dataClient?.getCollection("transitstops") {
            var entity = collection.getNextEntity()
             while entity != nil {
                let name = entity?.getStringProperty("name")
                let coord = entity?.getObjectProperty("coord") as? NSDictionary
                let lat = coord?["lat"] as! Double
                let lng = coord?["lng"] as! Double
                let interchange = Interchange(name: name, latitude: lat, longitude: lng)
                interchanges.append(interchange)
                entity = collection.getNextEntity()
            }
            while collection.hasNextPage() {
                let response = collection.getNextPage()!
                if response.completedSuccessfully() {
                    var entity = collection.getNextEntity()
                    while entity != nil {
                        let name = entity?.getStringProperty("name")
                        let coord = entity?.getObjectProperty("coord") as? NSDictionary
                        let lat = coord?["lat"] as! Double
                        let lng = coord?["lng"] as! Double
                        let interchange = Interchange(name: name, latitude: lat, longitude: lng)
                        interchanges.append(interchange)
                        entity = collection.getNextEntity()
                    }
                }
            }
            interchanges.sort{$0.name < $1.name}
        }
        else {
            let alert = UIAlertController (title: "Error", message: "Fail to retrieve interchange list from the server. Refresh to try again.", preferredStyle: .alert)
            let action  = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        interchanges.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.interchanges.sort{ $0.name < $1.name}
        if let previousTable = selectedListViewController?.tableView {
            previousTable.reloadData()
        }
        
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return interchanges.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        // Configure the cell...
        let interchange = interchanges[indexPath.row]
        cell.textLabel?.text=interchange.name
        if isInterchangeInSelectedList(interchange: interchange) {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }

        return cell
    }
    private func isInterchangeInSelectedList(interchange: Interchange) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        for ic in appDelegate.interchanges {
            if ic.name == interchange.name {
                return true
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let interchangeList = appDelegate.interchanges
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                let name = cell.textLabel?.text
                var i = 0
                while i < interchangeList.count {
                    if interchangeList[i].name == name {
                        appDelegate.interchanges.remove(at: i)
                        return
                    }
                    i += 1
                }
            }
            else if cell.accessoryType  == .none {
                cell.accessoryType = .checkmark
                let ic = interchanges[indexPath.row]
                appDelegate.interchanges.append(Interchange(name: ic.name, latitude: ic.latitude, longitude: ic.longitude))
            }
        }
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
