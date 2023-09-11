//
//  UserManager.swift
//  O2h-iOS-Assignment
//
//  Created by MD Faizan on 11/09/23.
//

import Foundation
import GoogleSignIn
import Firebase

class UserManager {
    
    static let shared = UserManager()
    
    
    func saveToken(token: String?) {
        UserDefaults.standard.set(token, forKey: Constants.uid)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: Constants.uid)
        UserDefaults.standard.removeObject(forKey: Constants.imagesStringArray)
    }
    
    func isUserLoggedIn() -> Bool {
       getToken()?.isEmpty == false
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: Constants.uid)
    }
}
