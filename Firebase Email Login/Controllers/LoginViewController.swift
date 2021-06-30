import UIKit
import FirebaseAuth

class LoginViewController: UIViewController
{
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.addTarget(self, action: #selector(loginButtonPress), for: .touchUpInside)
    }
    
    @objc private func loginButtonPress()
    {
        // TextField Validations
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty, password.count >= 8 else {
            alertUserLoginError()
            return
        }
        
        // Firebase Login Code
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else {
                print("Failed to login user with email: \(email)")
                return
            }
            let user = result.user
            print("User logged in successfully: \(user)")
            let vc = strongSelf.storyboard?.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
            vc.modalPresentationStyle = .fullScreen
            strongSelf.present(vc, animated: true, completion: nil)
        })
    }
    
    func alertUserLoginError()
    {
        let alert = UIAlertController(title: "ALERT", message: "Please enter all information correctly to login", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func registerPress(_ sender: UIButton)
    {
        let vc = storyboard?.instantiateViewController(identifier: "RegisterViewController") as! RegisterViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == emailTextField
        {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField
        {
            loginButtonPress()
        }
        return true
    }
}
