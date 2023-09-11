//
//  ProfileViewController.swift
//  O2h-iOS-Assignment
//
//  Created by MD Faizan on 11/09/23.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

final class ProfileViewController: UIViewController {
    
    @IBOutlet weak private var userImageView: UIImageView!
    @IBOutlet weak private var userNameLabel: UILabel!
    @IBOutlet weak private var userEmailLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
        
        userNameLabel.text = GIDSignIn.sharedInstance.currentUser?.profile?.name
        userEmailLabel.text = GIDSignIn.sharedInstance.currentUser?.profile?.email
    }
    
    
    @IBAction func googleLogoutButtonTapped(_ sender: UIButton) {
        //signout with google
        GIDSignIn.sharedInstance.signOut()
        UserManager.shared.logout()
        if let _ = self.storyboard?.instantiateViewController(withIdentifier: Constants.loginViewController) as? LoginViewController {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
