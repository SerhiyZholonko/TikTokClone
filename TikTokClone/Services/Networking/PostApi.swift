//
//  PostApi.swift
//  TikTokClone
//
//  Created by apple on 31.08.2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import ProgressHUD

final class PostApi {
    
    func sharePost(encodedVideoURL: URL?, selectedPhoto: UIImage?, textView: UITextView, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        let creadationDate = Date().timeIntervalSince1970
        guard let uid = Auth.auth().currentUser?.uid else {return}
        if let encodedVideoURLUnwrapped = encodedVideoURL {
            let videoldString = "\(NSUUID().uuidString).mp4"
            let storageRef = Ref().storageRoot.child("posts").child(videoldString)
            let metadata = StorageMetadata()
            storageRef.putFile(from: encodedVideoURLUnwrapped, metadata: metadata) { metadata, error in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                storageRef.downloadURL(completion: { [self] videoUrl, error in
                    if error != nil{
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    guard let videoUrlString = videoUrl?.absoluteString else {return}
                    uploadThumbnaiImageToStorage(selectedPhoto: selectedPhoto) { postImageUrl in
                        let values = ["creationDate": creadationDate,
                        "imageUrl": postImageUrl,
                        "videoUrl": videoUrlString,
                        "descrotton": textView.text ?? "",
                        "likes": 0,
                        "views": 0,
                        "comment Count": 0,
                        "uid": uid] as [String: Any]
                        let postId = Ref().databaseRoot.child("Posts").childByAutoId()
                        postId.updateChildValues (values, withCompletionBlock: { err, ref in
                            if error != nil{
                                onError(error!.localizedDescription)
                                return
                            }
                            guard let postKey = postId.key else {return}
                            Ref().databaseRoot.child("User-Posts").child(uid).updateChildValues([postKey: 1])
                            onSuccess()
                        })
                    }
                })
            }
        }
    }
    func uploadThumbnai1ImageToStorage() {
        
    }
    
    func uploadThumbnaiImageToStorage(selectedPhoto: UIImage?, completion: @escaping (String) -> ()) {
        if let thumbnailImage = selectedPhoto, let imageData = thumbnailImage.jpegData(compressionQuality:0.3){
            let photoldString = NSUUID().uuidString
            let storageRef = Ref().storageRoot.child("post_images").child(photoldString)
            storageRef.putData(imageData, completion: { metadata, error in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                storageRef.downloadURL(completion: { imageUrl, error in
                    if error != nil{
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    guard let postImageUrl = imageUrl?.absoluteString else {return}
                    completion(postImageUrl)
                })
            })
        }
    }
}
