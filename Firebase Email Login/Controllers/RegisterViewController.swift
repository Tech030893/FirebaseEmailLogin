import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController
{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        profileImageView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(profileImageChange))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        profileImageView.addGestureRecognizer(gesture)
        
        registerButton.addTarget(self, action: #selector(registerButtonPress), for: .touchUpInside)
    }
    
    @objc private func profileImageChange()
    {
        presentActionSheet()
    }
    
    @objc private func registerButtonPress()
    {
        // TextField Validations
        
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 8 else {
            alertUserRegisterError()
            return
        }
        
        // Firebase Register Code
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            guard !exists else {
                // user already exists
                strongSelf.alertUserRegisterError(message: "Looks like a user account for that email address already exists!")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                
                guard authResult != nil, error == nil else {
                    print("Error creating user")
                    return
                }
                DatabaseManager.shared.insertUser(with: EmailUser(firstName: firstName, lastName: lastName, emailAddress: email))
                
                let vc = strongSelf.storyboard?.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
                vc.modalPresentationStyle = .fullScreen
                strongSelf.present(vc, animated: true, completion: nil)
            })
        })
    }
    
    func alertUserRegisterError(message: String = "Please enter all information correctly to register successfully")
    {
        let alert = UIAlertController(title: "ALERT", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginPress(_ sender: UIButton)
    {
        let vc = storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}

extension RegisterViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == firstNameTextField
        {
            lastNameTextField.becomeFirstResponder()
        }
        else if textField == lastNameTextField
        {
            emailTextField.becomeFirstResponder()
        }
        else if textField == emailTextField
        {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField
        {
            registerButtonPress()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func presentActionSheet()
    {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentCamera()
    {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    func presentPhotoPicker()
    {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.profileImageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}
