//
//  ImageService.swift
//  O2h-iOS-Assignment
//
//  Created by MD Faizan on 10/09/23.
//

import Foundation

class ImageService {
    
    // Define a completion handler closure to send data to ImageModel
    typealias ImageCompletionHandler = ([ImageModel]?, Error?) -> Void
    
    // Create a shared singleton instance
    static let shared = ImageService()
    
    // Make the initializer private to ensure it's a singleton
    private init() {}
    
    // Function to fetch images from an API
    func fetchImages(page: Int, perPage: Int, completion: @escaping ImageCompletionHandler) {
        guard let url = URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=\(perPage)") else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let images = try decoder.decode([ImageModel].self, from: data)
                    completion(images, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}
