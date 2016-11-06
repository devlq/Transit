//
//  HomeViewController.swift
//  Transit
//
//  Created by Pat on 05/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var greeting: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let name = appDelegate.appUser?.fullName
        greeting.text="Welcome \(name!)"
        
        if let fbLogoutButton = appDelegate.fbLoginButton {
            let token = FBSDKAccessToken.current()
            if token != nil {
                fbLogoutButton.center = logoutButton.center
                logoutButton.isHidden = true
            }
            else {
                logoutButton.isHidden = false
            }
        }
        else {
            logoutButton.isHidden = false 
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool)    {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
