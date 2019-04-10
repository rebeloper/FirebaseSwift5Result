//
//  RootViewController.swift
//  FirebaseSwift5Result
//
//  Created by Alex Nagy on 10/04/2019.
//  Copyright © 2019 Alex Nagy. All rights reserved.
//

import TinyConstraints
import FirebaseStorage

class RootViewController: UIViewController {
    
    struct FirebaseStorageFetchError {
        static let noUrl = CustomError(title: "Firebase Storage Fetch Error", description: "The url downloaded from Firebase Storage is nil", code: 0)
        static let noData = CustomError(title: "Firebase Storage Fetch Error", description: "The data downloaded from Firebase Storage is nil", code: 1)
        static let noImage = CustomError(title: "Firebase Storage Fetch Error", description: "Could not create UIImage from data downloaded from Firebase Storage", code: 2)
    }
    
    let referencePath = "Assets/Animals"
    let imageName = "Dog"
    let imageType = "png"
    
    let imageViewHeight: CGFloat = 100
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.startAnimating()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
        
        fetchFirebaseStorageAsset(from: referencePath, named: imageName, type: imageType) { (result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.imageView.backgroundColor = .clear
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let err):
                print("Failed to fetch image: \(err.localizedDescription)")
            }
        }
        
//        fetchFirebaseStorageAsset(from: referencePath, named: imageName, type: imageType) { (image, err) in
//            if let err = err {
//                print("Failed to fetch image: \(err.localizedDescription)")
//                return
//            }
//            guard let image = image else {
//                print("Failed to fetch image: no image available")
//                return
//            }
//
//            DispatchQueue.main.async {
//                self.imageView.image = image
//                self.imageView.backgroundColor = .clear
//                self.activityIndicator.stopAnimating()
//            }
//
//        }
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        imageView.addSubview(activityIndicator)
        
        imageView.topToSuperview(offset: 36, usingSafeArea: true)
        imageView.centerXToSuperview()
        imageView.width(imageViewHeight)
        imageView.height(imageViewHeight)
        
        activityIndicator.center(in: imageView)
    }
    
    fileprivate func fetchFirebaseStorageAsset(from referencePath: String, named: String, type: String = "jpeg", completion: @escaping (Result<UIImage, Error>) -> ()) {
        
        let reference = Storage.storage().reference().child("\(referencePath)/\(named).\(type)")
        
        reference.downloadURL { (url, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            guard let url = url else {
                completion(.failure(FirebaseStorageFetchError.noUrl))
                return
            }
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, err) in
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let data = data else {
                    completion(.failure(FirebaseStorageFetchError.noData))
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    completion(.failure(FirebaseStorageFetchError.noImage))
                    return
                }
                completion(.success(image))
                
            }).resume()
        }
        
    }
    
//    fileprivate func fetchFirebaseStorageAsset(from referencePath: String, named: String, type: String = "jpeg", completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
//
//        let reference = Storage.storage().reference().child("\(referencePath)/\(named).\(type)")
//
//        reference.downloadURL { (url, err) in
//            if let err = err {
//                completion(nil, err)
//                return
//            }
//            guard let url = url else {
//                completion(nil, nil)
//                return
//            }
//
//            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, err) in
//                if let err = err {
//                    completion(nil, err)
//                    return
//                }
//                guard let data = data else {
//                    completion(nil, nil)
//                    return
//                }
//
//                let image = UIImage(data: data)
//                completion(image, nil)
//
//            }).resume()
//        }
//
//    }

}

