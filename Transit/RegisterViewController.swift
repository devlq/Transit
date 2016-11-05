//
//  RegisterViewController.swift
//  Transit
//
//  Created by Pat on 05/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var fullnameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var password1Field: UITextField!
    @IBOutlet weak var password2Field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    private func loginNewUser () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dataClient = appDelegate.apigeeDataClient
        let user = appDelegate.appUser!
        if let response = dataClient?.log(inUser: user.userName, password: user.password!) {
            print(response.response)
            if response.completedSuccessfully() {
                let responseDict = response.response as! NSDictionary
                user.accessToken = responseDict["access_token"] as? String
                self.performSegue(withIdentifier: "registerToHomeViewSegue", sender: self)
            }
            else {
                let alert = UIAlertController (title: "Login Failed", message: response.response as! String?, preferredStyle: .alert)
                let action  = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func userRegister(sender: UIButton) {
        let passwordRegEx = "^(?=.*[A-Z].)(?=.*[!@#$&*0-9])(?=.*[a-z].).{8}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        
        var message = ""
        if  usernameField.text == "" || fullnameField.text == "" ||
            emailField.text == "" || password1Field.text == "" || password2Field.text == "" {
            message = "Incomplete information"
        }
        else if !isValidEmail(testStr: emailField.text!) {
            message = "Invalid email address"
        }
        else if password2Field.text != password1Field.text {
            message = "Passwords do not match"
        }
        else if !passwordTest.evaluate(with: password1Field.text) {
            message = "Password does not meet the requirements"
        }
        if message != "" {
            let alert = UIAlertController (title: "Error", message: message, preferredStyle: .alert)
            let action  = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        else {
            print("Input validated!")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let dataClient = appDelegate.apigeeDataClient
            if let response = dataClient?.addUser(usernameField.text, email: emailField.text,
                                                  name: fullnameField.text, password: password1Field.text) {
                print(response.response)
                if response.completedSuccessfully() {
                    let responseDict = response.response as! NSDictionary
                    let users = responseDict["entities"] as! [NSDictionary]
                    let user = users[0]
                    appDelegate.appUser=User(userName: user["username"] as! String, emailAddress: user["email"] as! String, fullName: user["name"] as! String, uuid: user["uuid"] as! String)
                    appDelegate.appUser?.password = password1Field.text
                    let alert = UIAlertController (title: "Registration Successful", message: "New account \(usernameField.text!) has been created successfully. Tap \"OK\" to login.", preferredStyle: .alert)
                    let action  = UIAlertAction(title: "OK", style: .default){
                        UIAlertAction in
                        self.loginNewUser()
                    }
                    alert.addAction(action)
                    present(alert, animated: true, completion: nil)
                }
                else {
                    let registerAlert = UIAlertController (title: "Registration Failed", message: response.response as! String?, preferredStyle: .alert)
                    let registerAction  = UIAlertAction(title: "OK", style: .default, handler: nil)
                    registerAlert.addAction(registerAction)
                    present(registerAlert, animated: true, completion: nil)
                }
            }
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
