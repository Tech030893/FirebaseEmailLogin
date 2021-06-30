import UIKit
import FirebaseAuth

class HomeViewController: UIViewController
{
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    private func validateAuth()
    {
        if FirebaseAuth.Auth.auth().currentUser == nil
        {
            let vc = storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false, completion: nil)
        }
    }
    
    @IBAction func logoutPress(_ sender: UIButton)
    {
        let actionSheet = UIAlertController(title: "Alert", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { [weak self] _ in
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let vc = self?.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true, completion: nil)
            }
            catch {
                print("Failed to logout")
            }
        }))
        present(actionSheet, animated: true, completion: nil)
    }
}
