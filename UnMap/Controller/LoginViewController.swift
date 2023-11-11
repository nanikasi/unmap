//
//  LoginViewController.swift
//  UnMap
//
//  Created by 中西直人 on 2023/11/11.
//

import UIKit
import AuthenticationServices
import Supabase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginProviderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProviderLoginView()
    }
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginProviderView.addSubview(authorizationButton)
        
        authorizationButton.centerXAnchor.constraint(equalTo: loginProviderView.centerXAnchor).isActive = true
        authorizationButton.centerYAnchor.constraint(equalTo: loginProviderView.centerYAnchor).isActive = true
        authorizationButton.widthAnchor.constraint(equalTo: loginProviderView.widthAnchor, multiplier: 0.9).isActive = true
        authorizationButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
    }
    
    func performExistingAccountSetupFlows() {
        let requests = [ASAuthorizationAppleIDProvider().createRequest()]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let idToken = appleIDCredential.identityToken.flatMap({ String(data: $0, encoding: .utf8) })
            else {
              return
            }
            
            self.saveUserInCloud(idToken: idToken)
        default:
            break
        }
    }
    
    private func saveUserInCloud(idToken: String) {
        let client = SupabaseClient(supabaseURL: URL(string: Environment.supabaseURL)!, supabaseKey: Environment.supabaseKey)
        Task {
            do {
                try await client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: idToken
                    )
                )
                showHomeViewController()
            } catch {
                print(error)
            }
        }
    }
    
    private func showHomeViewController() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension UIViewController {
    func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController") as? LoginViewController {
            loginViewController.modalPresentationStyle = .formSheet
            loginViewController.isModalInPresentation = true
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
}
