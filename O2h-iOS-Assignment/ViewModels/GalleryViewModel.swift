//
//  GalleryViewModel.swift
//  O2h-iOS-Assignment
//
//  Created by MD Faizan on 10/09/23.
//

import Foundation


final class GalleryViewModel {
    var datasourceImages: [String] = []
    private var currentPage = 1
    private var imagesPerPage = 10
    var isFetching = false
    var updateCollectionView: (() -> Void)?
    var hideLoader: (() -> Void)?
    var indexPathsToInsert: (([IndexPath]) -> Void)?
    private var retryCount = 0
    
    
    init() {
        self.fetchMoreImages()
    }
    
    func fetchMoreImages() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            guard let `self` = self else { return }
            if !self.isFetching {
                self.isFetching = true
                self._fetchMoreImages()
            }
        }
    }
    
    private func _fetchMoreImages() {
        ImageService.shared.fetchImages(page: currentPage, perPage: imagesPerPage) { [weak self] (images, error) in
            guard let `self` = self else { return }
            
            if let error = error {
                print("Error fetching images: \(error)")
                if self.retryCount < 3 {
                    self.datasourceImages = self.getImageUrls()
                    self.updateCollectionView?()
                    self.isFetching = false
                    self.retryCount += 1
                }
                self.hideLoader?()
                return
            }
            let images = images?.map { $0.download_url } ?? []
            if self.currentPage == 1 {
                self.datasourceImages = images
            } else {
                self.appendData(newData: images)
            }
            
            
            self.storeImageUrls(self.datasourceImages)
            
            DispatchQueue.main.async {
                if self.currentPage == 1 {
                    self.updateCollectionView?()
                    self.isFetching = false
                }
                self.currentPage += 1  // Increment the page number for the next request
                self.retryCount = 0
            }
        }
    }
    
    
    //MARK:- APPEND DATASOURCE
    private func appendData(newData: [String]) {
        datasourceImages.append(contentsOf: newData)
        updateCollectionView(with: newData)
    }
    
    // Function to update the collection view with new data
    private func updateCollectionView(with newData: [String]) {
        let startIndex = datasourceImages.count - newData.count
        let endIndex = datasourceImages.count - 1
        
        let indexPaths = (startIndex...endIndex).map { IndexPath(item: $0, section: 0) }
        
        DispatchQueue.main.async {
            self.indexPathsToInsert?(indexPaths)
            self.isFetching = false
        }
    }
    
    
    //MARK:-  Storing an array of strings
    func storeImageUrls(_ urls: [String]) {
        UserDefaults.standard.set(urls, forKey: Constants.imagesStringArray)
    }
    
    func getImageUrls() -> [String] {
        let data = (UserDefaults.standard.array(forKey: Constants.imagesStringArray) as? [String]) ?? []
        return data
    }
}
