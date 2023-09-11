//
//  GalleryViewController.swift
//  O2h-iOS-Assignment
//
//  Created by MD Faizan on 10/09/23.
//

import UIKit
import Kingfisher
import FirebaseAuth
import GoogleSignIn

final class GalleryViewController: UIViewController {
    
    //MARK:- IBOutlet
    @IBOutlet private weak var galleryCollectionView: UICollectionView!
    @IBOutlet private weak var collectionBottomConstraint: NSLayoutConstraint!
    
    private var loadingIndicator: UIActivityIndicatorView!
    var viewModel = GalleryViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.gallery
        addProfileButtonInNavBar()
        setupCollectionView()
        setupListener()
        setupLoadingIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the back button
        navigationItem.hidesBackButton = true
    }

    
    private func setupCollectionView() {
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        
        let nib = UINib(nibName: Constants.imageCollectionViewCell, bundle: nil)
        galleryCollectionView.register(nib, forCellWithReuseIdentifier: Constants.imageCell)
    }
    
    private func setupListener() {
        viewModel.updateCollectionView = { [weak self] in
            DispatchQueue.main.async {
                self?.galleryCollectionView.reloadData()
                self?.handleVisiblityOfLoadingIndicator(isLoading: false)
            }
        }
        
        viewModel.indexPathsToInsert = { [weak self] (indexPaths) in
            DispatchQueue.main.async {
                self?.galleryCollectionView.performBatchUpdates({
                    self?.galleryCollectionView.insertItems(at: indexPaths)
                }, completion: nil)
                self?.handleVisiblityOfLoadingIndicator(isLoading: false)
            }
        }
        
        viewModel.hideLoader = { [weak self] in
            DispatchQueue.main.async {
                self?.handleVisiblityOfLoadingIndicator(isLoading: false)
            }
        }
    }
    
    private func addProfileButtonInNavBar() {
        let profileButton = UIButton(type: .custom)
        profileButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        // Set the profile picture image
        let profileImage = UIImage(systemName: "person.fill") // Replace with your image name
        profileButton.setImage(profileImage, for: .normal)
        
        profileButton.backgroundColor = .orange
        
        // Make the button circular
        profileButton.layer.cornerRadius = 20 // Half of the button's height
        profileButton.clipsToBounds = true
        
        // Add an action to the button
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        let profileBarButtonItem = UIBarButtonItem(customView: profileButton)
        navigationItem.rightBarButtonItem = profileBarButtonItem
    }
    
    @objc func profileButtonTapped() {
        if let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.profileViewController) as? ProfileViewController {
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .gray
        loadingIndicator.hidesWhenStopped = true // Hide when not animating
        view.addSubview(loadingIndicator)

        // Position the loading indicator at the bottom
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }

   
    private func handleVisiblityOfLoadingIndicator(isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.collectionBottomConstraint.constant = isLoading ? 30 : 0
            self.view.layoutIfNeeded()
        }
    }

}

//MARK:- UICollectionViewDataSource, UICollectionViewDelegate
extension GalleryViewController: UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.datasourceImages.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.imageCell, for: indexPath) as? ImageCollectionViewCell
        
        
        let imageURL = viewModel.datasourceImages[indexPath.row]
        cell?.configureCell(with: imageURL)
 
        return cell ?? UICollectionViewCell()
    }
}

//MARK:- UICollectionViewDelegateFlowLayout
extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        let collectionwidth = galleryCollectionView.bounds.width
        return CGSize(width: collectionwidth/2 - 2, height: collectionwidth/2 - 2)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //Infinite scrolling and loading
        if indexPath.item == viewModel.datasourceImages.count - 1 && !viewModel.isFetching {
            handleVisiblityOfLoadingIndicator(isLoading: true)
            viewModel.fetchMoreImages()
        }
    }
}

