//
//  LoginViewController.swift
//  O2h-iOS-Assignment
//
//  Created by MD Faizan on 10/09/23.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase
import FirebaseCore

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.login
        checkIfLoggedInAndNavigate()
    }
    
    
    @IBAction func signInWithGoogleButtonTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signIn(with: GIDConfiguration.init(clientID: Constants.googleClientId), presenting: self) { googleUser, error in

            guard let googleUser = googleUser else {
                return
            }
            
            let token = googleUser.userID
            UserManager.shared.saveToken(token: token)

            //MARK: navigation code
            if let galleryViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.galleryViewController) as? GalleryViewController {
                self.navigationController?.pushViewController(galleryViewController, animated: true)
            }
        }
    }
    
    
    func checkIfLoggedInAndNavigate() {
        if UserManager.shared.isUserLoggedIn() {
            if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                GIDSignIn.sharedInstance.restorePreviousSignIn()
            }
            //navigation code
            if let galleryViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.galleryViewController) as? GalleryViewController {
                self.navigationController?.pushViewController(galleryViewController, animated: true)
            }
        }
    }
}


