//
//  LoginViewController.swift
//  Transit
//
//  Created by Pat on 05/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func userlogin (sender: UIButton) {
        let userName = usernameField.text;
        let password = passwordField.text;
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dataClient = appDelegate.apigeeDataClient
        if let response = dataClient?.log(inUser: userName, password: password) {
            print("Response: \(response.response)")
            print("Error: \(response.error)")
            print("Error code: \(response.errorCode)")
            print("Error Message: \(response.errorDescription)")
        }
        
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
