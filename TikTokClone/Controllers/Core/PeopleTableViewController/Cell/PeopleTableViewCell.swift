//
//  PeopleTableViewCell.swift
//  TikTokClone
//
//  Created by apple on 02.09.2023.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            loadDate()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        setupView()
    }
    private func setupView() {
        avatar.layer.cornerRadius = 25
    }
    private func loadDate() {
        usernameLabel.text = user?.username
        guard let profileImageUrl = user?.profileImageUrl else { return }
        avatar.loadImage(profileImageUrl)
    }
}
