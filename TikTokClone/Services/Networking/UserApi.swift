//
//  UserApi.swift
//  TikTokClone
//
//  Created by apple on 29.08.2023.
//


import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ProgressHUD

final class UserApi {
    func singIn(email: String, password: String, onSuccess: @escaping() -> Void, onError:
                @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authData, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    func signUp(withUsername username: String, email: String, password: String, image: UIImage?, onSuccess: @escaping() -> Void, onError:
                @escaping(_ errorMessage: String) -> Void) {
        guard let imageSelected = image else {
            ProgressHUD.showError("(Please enter a Profile Image")
            return
            
        }
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else { return }
        Auth.auth().createUser(withEmail: email, password: password){ authDataResult, error in
            if error != nil {
                print (error!.localizedDescription)
                return
            }
            if let authData = authDataResult {
                var dict: Dictionary<String, Any> = [
                    EMAIL : authData.user.email ?? "",
                    USERNAME : username,
                    STORAGE_PROFILE : "",
                    STATUS : "" ]
                
                let storageProfileRef = Ref().storageSpesificProfile (uid: authData.user.uid)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                storageProfileRef.putData(imageData,metadata: metadata){ storageMetaData, errorin in
                    if error != nil{
                        print (error!.localizedDescription)
                        return
                    }
                    StorageService.savePhoto(username: username, uid: authData.user.uid, data: imageData, metadata: metadata, storageProfileRef: storageProfileRef, dict: dict) {
                        onSuccess()
                    } onError: { errorMessage in
                        onError(errorMessage)
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
    }
}
