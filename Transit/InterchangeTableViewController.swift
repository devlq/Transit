//
//  InterchangeTableViewController.swift
//  Transit
//
//  Created by Pat on 06/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit

class InterchangeTableViewController: UITableViewController {
    private let cellIdentifier = "InterchangeTable"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.interchanges.count+1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if indexPath.row == appDelegate.interchanges.count {
            cell.textLabel?.textColor=UIColor.gray
            cell.textLabel?.text = "Add New Interchanges"
            cell.detailTextLabel?.textColor=UIColor.gray
            cell.detailTextLabel?.text = "You will be reminded near these interchanges"
            let image = UIImage(named: "plus.png")
            cell.imageView?.image = image
        }
        else {
            cell.textLabel?.textColor=UIColor.black
            cell.textLabel?.text = appDelegate.interchanges[indexPath.row].name
            cell.textLabel?.textAlignment = .left
            cell.detailTextLabel?.textColor=UIColor.black
            cell.detailTextLabel?.text = "\(appDelegate.interchanges[indexPath.row].latitude!), \(appDelegate.interchanges[indexPath.row].longitude!)"
            cell.detailTextLabel?.textAlignment = .left
            cell.imageView?.image=nil
        }
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if indexPath.row == appDelegate.interchanges.count {
            performSegue(withIdentifier: "selectInterchangeSegue", sender: self)
        }
    }
    
    @IBAction func listUpdated (sender: UIButton) {
        tableView.reloadData()
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination
        if destinationVC.isKind(of: SelectTableViewController.self) {
            let table = destinationVC as! SelectTableViewController
            table.selectedListViewController = self
        }
    }
    

}
