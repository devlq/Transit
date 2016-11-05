//
//  User.swift
//  Transit
//
//  Created by Pat on 05/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import Foundation

class User {
    var userName: String!
    var password: String?
    var emailAddress: String!
    var fullName: String!
    var accessToken: String?
    var uuid: String!
    
    init(userName:String,  emailAddress:String,  fullName:String,  uuid:String)  {
        self.userName = userName
        self.emailAddress = emailAddress
        self.fullName = fullName
        self.uuid = uuid
    }
    
}
