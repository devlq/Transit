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
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    @IBAction func userlogin (sender: UIButton) {
        let userName = usernameField.text;
        let password = passwordField.text;
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dataClient = appDelegate.apigeeDataClient
        if let response = dataClient?.log(inUser: userName, password: password) {
            print(response.response)
            if response.completedSuccessfully() {
                let responseDict = response.response as! NSDictionary
                let user = responseDict["user"] as! NSDictionary
                appDelegate.appUser=User(userName: user["username"] as! String, emailAddress: user["email"] as! String, fullName: user["name"] as! String, uuid: user["uuid"] as! String)
                appDelegate.appUser?.accessToken = responseDict["access_token"] as? String
                
                self.performSegue(withIdentifier: "showHomeViewSegue", sender: self)
            }
            else {
                let alert = UIAlertController (title: "Login Failed", message: response.response as! String?, preferredStyle: .alert)
                let action  = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func logOut (unwindSegue: UIStoryboardSegue) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dataClient = appDelegate.apigeeDataClient
        dataClient?.logOut(appDelegate.appUser?.userName)
        appDelegate.appUser=nil
    }

    @IBAction func unWindToLogin(unwindSegue: UIStoryboardSegue) {
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
