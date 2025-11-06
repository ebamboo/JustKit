//
//  KeychainTestViewController.swift
//  JustKit
//
//  Created by 姚旭 on 2025/11/6.
//

import UIKit

// App 特有的服务一般使用 boundle 作为服务标识
let service = "com.beizhu.appid"
// 跨 App 共享的服务一般根据多个 App 约定共享服务标识
//let sharedService = "com.beizhu.shared"

class KeychainTestViewController: UIViewController {
    
    // MARK: data
    
    class AccountModel {
        var account = ""
        var password = ""
        init(account: String = "", password: String = "") {
            self.account = account
            self.password = password
        }
    }
    
    var accountList: [AccountModel] = []
    
    // MARK: ui
    
    @IBOutlet weak var accountField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(
                UINib(nibName: "KeychainTestTableViewCell", bundle: nil),
                forCellReuseIdentifier: "KeychainTestTableViewCell"
            )
            tableView.tableHeaderView = UIView()
            tableView.sectionHeaderTopPadding = 0.1
        }
    }
    
    // MARK: action
    
    @IBAction func saveAction(_ sender: Any) {
        let account = accountField.text ?? ""
        let password = passwordField.text ?? ""
        if let _ = try? Keychain.saveData(password.data(using: .utf8)!, for: account, service: service) {
            print("save ========== success")
        } else {
            print("save ========== failure")
        }
    }
    
    @IBAction func searchForAllAccountsAction(_ sender: Any) {
        if let list = try? Keychain.readAccounts(service: service) {
            accountList = list.map { account in
                AccountModel(account: account)
            }
            tableView.reloadData()
            print("search all accounts ========== success \(list)")
        } else {
            print("search all accounts ========== failure")
        }
    }
    
    @IBAction func deleteAllAccountsAction(_ sender: Any) {
        if let _ = try? Keychain.clearData(for: nil, service: service) {
            accountList = []
            tableView.reloadData()
            print("clear all accounts ========== success")
        } else {
            print("clear all accounts ========== failure")
        }
    }
    
    func deleteAccount(_ account: String) {
        if let _ = try? Keychain.clearData(for: account, service: service) {
            accountList = accountList.filter { model in
                model.account != account
            }
            tableView.reloadData()
            print("clear account \(account) ========== success")
        } else {
            print("clear account \(account) ========== failure")
        }
    }
    
    func searchForAccount(_ account: String) {
        if let data = try? Keychain.readData(for: account, service: service) {
            let password = String(data: data, encoding: .utf8) ?? ""
            accountList.forEach { model in
                if model.account == account {
                    model.password = password
                }
            }
            tableView.reloadData()
            print("search account \(account) ========== success \(password)")
        } else {
            print("search account \(account) ========== failure")
        }
    }
    
}

extension KeychainTestViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        accountList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeychainTestTableViewCell") as! KeychainTestTableViewCell
        cell.accountInfo = accountList[indexPath.row]
        cell.onDelete = { [weak self] info in
            self?.deleteAccount(info.account)
        }
        cell.onSearch = { [weak self] info in
            self?.searchForAccount(info.account)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }
    
}
