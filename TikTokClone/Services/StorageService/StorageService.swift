//
//  File.swift
//  TikTokClone
//
//  Created by apple on 29.08.2023.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD

final class StorageService {
    static func savePhoto(username: String, uid: String, data: Data, metadata: StorageMetadata, storageProfileRef: StorageReference, dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        storageProfileRef.downloadURL{ url, error in
            if error != nil {
                onError (error!.localizedDescription)
                return
            }
           
            if let metaImageUrl = url?.absoluteString {
                if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                    changeRequest.photoURL = url
                    changeRequest.displayName = username
                    changeRequest.commitChanges { error in
                        if let error = error {
                            ProgressHUD.showError(error.localizedDescription)
                        }
                    }
                }
                var dictTemp = dict
                dictTemp["profileImageUrl"] = metaImageUrl
                Ref().databaseSpesificUser(uid: uid).updateChildValues(dictTemp){ error, ref in
                    if error == nil {
                        onSuccess()
                    } else {
                        onError(error!.localizedDescription)
                    }
                       }
            }
        }
    }
}


