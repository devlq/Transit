//
//  LoginViewController.swift
//  Transit
//
//  Created by Pat on 05/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit
//import FacebookLogin

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var fbButtonPlaceHolder: UILabel!
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginButton.delegate = self
        loginButton.center = fbButtonPlaceHolder.center
        
        view.addSubview(loginButton)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.fbLoginButton = loginButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("FB login completed")
        let email = ""
/*        let parameters = ["fields": "email"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start {
            (connection, result, error) -> Void in
            if error != nil {
                print(error as! String)
                email = ""
            }
            else if let resultDict = result as? NSDictionary {
                email = resultDict["email"] as? String
            }
            else {
                email = ""
            }
        }
*/        let token = FBSDKAccessToken.current()
        if let fb_token=token?.tokenString {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let dataClient = appDelegate.apigeeDataClient
            if let response = dataClient?.logInUser(withFacebook: fb_token) {
                print(response.response)
                if response.completedSuccessfully() {
                    let responseDict = response.response as! NSDictionary
                    let user = responseDict["user"] as! NSDictionary
                    appDelegate.appUser=User(userName: user["username"] as! String, emailAddress: email, fullName: user["name"] as! String, uuid: user["uuid"] as! String)
                    let token = responseDict["access_token"] as? String
                    appDelegate.appUser?.accessToken = token
                    dataClient?.addHTTPHeaderField("Authorization", withValue: "Bearer \(token!)")
                    /*                var error: NSErrorPointer=nil
                     dataClient?.storeOAuth2Tokens(inKeychain: "OAuth2Token", accessToken: appDelegate.appUser?.accessToken, refreshToken: nil, error: error)
                     if error != nil {
                     print("Store OAuth2 Tokens failed")
                     }
                     */
                    self.performSegue(withIdentifier: "showHomeViewSegue", sender: self)
                }
            }
        }
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("FB logout")
        loginButton.center = fbButtonPlaceHolder.center
        
        view.addSubview(loginButton)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.appUser=nil
        appDelegate.interchanges.removeAll()
        
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
                let token = responseDict["access_token"] as? String
                appDelegate.appUser?.accessToken = token
                dataClient?.addHTTPHeaderField("Authorization", withValue: "Bearer \(token!)")
/*                var error: NSErrorPointer=nil
                dataClient?.storeOAuth2Tokens(inKeychain: "OAuth2Token", accessToken: appDelegate.appUser?.accessToken, refreshToken: nil, error: error)
                if error != nil {
                    print("Store OAuth2 Tokens failed")
                }
*/
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
        appDelegate.interchanges.removeAll()
    }

    @IBAction func unWindToLogin(unwindSegue: UIStoryboardSegue) {
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination
        destinationVC.view.addSubview(loginButton)
        
    }
    

}
