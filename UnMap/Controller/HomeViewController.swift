//
//  ViewController.swift
//  UnMap
//
//  Created by 中西直人 on 2023/11/11.
//

import UIKit
import Supabase

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func logoutPressed(_ sender: UIButton) {
        let client = SupabaseClient(supabaseURL: URL(string: Environment.supabaseURL)!, supabaseKey: Environment.supabaseKey)
        Task {
            do {
                try await client.auth.signOut()
                DispatchQueue.main.async {
                    self.view.window?.rootViewController?.showLoginViewController()
                }
            } catch {
                print(error)
            }
        }
    }
}
