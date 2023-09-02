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
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
    }
    
    func observeUser(withId uid: String, completion: @escaping (User) -> Void) {
        Ref().databaseRoot.child("Users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    func observeProfileUser( completion: @escaping (User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Ref().databaseRoot.child("Users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    func observeUsers (completion: @escaping (User) -> Void) {
        Ref().databaseRoot.child("Users").observe(.childAdded) { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        }
    }
    func saveUserProfile(dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError:
                         @escaping(_ errorMessage: String) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Ref().databaseRoot.child("Users").child(uid).updateChildValues(dict) { error, dataRef in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
        
    }
    func deleteUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storage = Ref().storageRoot
        let ref = Ref().databaseRoot
        
        ref.child("Users").child(uid).removeValue { error, ref in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            
        }
        Auth.auth().currentUser?.delete { error in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
        }
        let profileRef = storage.child("profile").child(uid)
        profileRef.delete { error in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            } else {
                ProgressHUD.showSuccess()
            }
        }
    }
}
