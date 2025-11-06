//
//  KeychainTestTableViewCell.swift
//  JustKit
//
//  Created by 姚旭 on 2025/11/6.
//

import UIKit

class KeychainTestTableViewCell: UITableViewCell {
    
    var accountInfo: KeychainTestViewController.AccountModel! {
        didSet {
            accountLabel.text = accountInfo.account
            passwordLabel.text = accountInfo.password
        }
    }
    
    var onDelete: ((KeychainTestViewController.AccountModel) -> Void)?
    var onSearch: ((KeychainTestViewController.AccountModel) -> Void)?
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBAction func deleteAccountAction(_ sender: Any) {
        onDelete?(accountInfo)
    }
    @IBAction func searchForPasswordAction(_ sender: Any) {
        onSearch?(accountInfo)
    }
    
}
