//
//  Ref.swift
//  TikTokClone
//
//  Created by apple on 29.08.2023.
//
import Foundation
import FirebaseDatabase
import FirebaseStorage

let REF_USER = "Users"
let STORAGE_PROFILE = "profile"
let URL_STORAGE_ROOT = "gs://tiktokclon-22e88.appspot.com"
let EMAIL = "email"
let UID = "uid"
let USERNAME = "username"
let PROFILE_IMAGE_URL = "profileImageUrl"
let STATUS = "status"

let IDENTIFIER_TABBAR = "MainTabBar"
let IDENTIFIER_MAIN = "Auth"

class Ref {
    let databaseRoot = Database.database().reference()
    var databaseUsers: DatabaseReference {
        return databaseRoot.child(REF_USER)
    }
    func databaseSpesificUser (uid: String) -> DatabaseReference {
        return databaseUsers.child(uid)
    }
    func storageSpesificProfile(uid: String) -> StorageReference {
        return storageProfile.child(uid)
    }
    //Storage Ref
    let storageRoot = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
    var storageProfile: StorageReference {
        return storageRoot.child(STORAGE_PROFILE)
    }
}
