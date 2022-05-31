// 
// Copyright 2022 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

class RememberViewController: UIViewController {
    
    //image
    @IBOutlet weak var Icon: UIImageView!
    //edit text
    @IBOutlet weak var EmailEditText: UITextField!
    //action edit text
    @IBAction func EmailFieldTextAction(_ sender: UITextField) {
        let resultText = sender.text
        if(resultText == "") {
                button_to_rememberLog.alpha = 0.7
                button_to_rememberLog.isUserInteractionEnabled = false
            } else {
                button_to_rememberLog.alpha = 1
                button_to_rememberLog.isUserInteractionEnabled = true
            }
    }
    //button
    @IBOutlet weak var button_to_rememberLog: UIButton!
    //button action
    @IBAction func actionButtonToLogin(_ sender: UIButton) {
        self.requestPostRemember(emailRemember: EmailEditText.text!)
    }
    private var theme: Theme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set theme
        self.update(theme: ThemeService.shared().theme)
        
        self.hideKeyboardWhenTappedAround()
        
        button_to_rememberLog.isUserInteractionEnabled = false
        button_to_rememberLog.alpha = 0.7
        
        self.initialViewElements()
        self.initValidateTextField()
        self.languageLocal()
    }
    
    //MARK: - set language
    func languageLocal() {
        //placeholders
        EmailEditText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("placeholder_to_field_text_email", comment: "placeholder_email"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 150/255.0, green: 157/255.0, blue: 169/255.0, alpha: 1)])
        
        //button
        button_to_rememberLog.setTitle(NSLocalizedString(VectorL10n .bugReportSend, comment: "rememeberPassword"), for: .normal)
    }
    
    func initValidateTextField() {}
    
    // MARK: - Public
    //set theme
    private func update(theme: Theme) {
        self.theme = theme
        self.view.backgroundColor = theme.backgroundColor
        
        if let navigationBar = self.navigationController?.navigationBar {
            theme.applyStyle(onNavigationBar: navigationBar)
        }
        //text field text
        self.EmailEditText.textColor = theme.textPrimaryColor
    }
    
    //MARK: - initial view element
    func initialViewElements() {
        self.button_to_rememberLog.backgroundColor = UIColor(red: 12/255.0, green: 185/255.0, blue: 136/255.0, alpha: 1)
        self.button_to_rememberLog.tintColor = .white
        
        self.button_to_rememberLog.layer.cornerRadius = 10
        
        //edit text
        EmailEditText.setUnderLine()
        //image
        self.Icon.tintColor = UIColor(red: 12/255.0, green: 185/255.0, blue: 136/255.0, alpha: 1)
    }
    
    func requestPostRemember(emailRemember: String) {
        
        var responseText = "ok"
        
        let data : Data = "thisprojectid=\(11)&this_http_host=\("qaim.me")&rememberemail=\(emailRemember)&lng=\(self.getLang())&checkID=\(1)&userUTC=\(1)".data(using: .utf8)!
          
          // create the url with URL
        let url = URL(string: "https://qwertynetworks.com/register.php")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.addValue("Mozilla/4.0 (compatible; Universion/1.0; +https://qwertynetworks.com)", forHTTPHeaderField: "User-Agent")
        
        request.httpBody = data
        URLSession.shared.dataTask(with: request) { data, response, error in
           
            let responseText = String(data: data!, encoding: .utf8)!
            
            if responseText == "OK" && error == nil {
                DispatchQueue.main.sync {
                    self.showAlertSuccess()
                }
            } else if responseText != "OK" {
                DispatchQueue.main.async {
                    self.showAlertError(message: responseText)
                }
            }
        }.resume()
    }
    
    //MARK: - show alert error
    func showAlertError(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("done", comment: "empty_btn"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertSuccess() {
        let alert = UIAlertController(title: "", message: NSLocalizedString("success_request_to_register", comment: "success_message"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("done", comment: "empty_btn"), style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - get lang
    func getLang() -> String {
        var lang: String = ""
        if Locale.preferredLanguages[0].count > 2 {
            lang = Locale.preferredLanguages[0].components(separatedBy: "-")[0]
        } else {
            lang = Locale.preferredLanguages[0]
        }
        return lang
    }

}
