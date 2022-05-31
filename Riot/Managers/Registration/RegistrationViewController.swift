// 
// Copyright 2022 New Vector Ltd
// Copyright 2022 Qwerty Networks Lls
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
import MatrixSDK

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension String {
    func attributedStringWithColor(_ strings: String, color: UIColor, characterSpacing: UInt? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let range = (self as NSString).range(of: strings)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)

        guard let characterSpacing = characterSpacing else {return attributedString}

        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))

        return attributedString
    }
}

extension UITextField {

    func setUnderLine() {
        let border = CALayer()
        let width = CGFloat(1.0)
        if #available(iOS 13.0, *) {
            border.borderColor = CGColor(red: 221/255.0, green: 228/255.0, blue: 238/255.0, alpha: 1.0)
        } else {
            // Fallback on earlier versions
        }
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width - 10, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

class RegistrationViewController: UIViewController {
    
    
    //edit text
    @IBOutlet weak var EmailEditText: UITextField!
    @IBOutlet weak var PasswordEditText: UITextField!
    @IBOutlet weak var NameEditText: UITextField!
    @IBOutlet weak var SurNameEditText: UITextField!
    
    //text view
    @IBOutlet weak var text_permission: UILabel!
    
    //button
    @IBOutlet weak var button_to_register: UIButton!
    @IBAction func button_action_to_register(_ sender: UIButton) {
        self.requestPostRegistration(
            name: NameEditText.text!,
            surname: SurNameEditText.text!,
            email: EmailEditText.text!,
            password: PasswordEditText.text!)
    }
    
    //date picker
    let dataPicker = UIDatePicker()
    
    //image
    @IBOutlet weak var Icon: UIImageView!
    
    //switch
    @IBAction func action_switch_permission(_ sender: UISwitch) {
    }
    @IBOutlet weak var switch_permission: UISwitch!
    
    private var theme: Theme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        //set theme
        self.update(theme: ThemeService.shared().theme)
        //button
        button_to_register.isUserInteractionEnabled = false
        button_to_register.alpha = 0.7
        
        self.initialViewElements()
        self.initValidateTextField()
        self.languageLocal()
        
        //text view
        let attributedWithTextColor: NSAttributedString = text_permission.text!.attributedStringWithColor(NSLocalizedString("tearms", comment: "text permmission"), color: UIColor(red: 12/255.0, green: 185/255.0, blue: 136/255.0, alpha: 1))
        text_permission.attributedText = attributedWithTextColor
    }
    
    // MARK: - Public
    //set theme
    private func update(theme: Theme) {
        self.theme = theme
        self.view.backgroundColor = theme.backgroundColor
        
        if let navigationBar = self.navigationController?.navigationBar {
            theme.applyStyle(onNavigationBar: navigationBar)
        }
        //text view
        self.text_permission.textColor = theme.textPrimaryColor
        //field text
        self.EmailEditText.textColor = theme.textPrimaryColor
        self.PasswordEditText.textColor = theme.textPrimaryColor
        self.NameEditText.textColor = theme.textPrimaryColor
        self.SurNameEditText.textColor = theme.textPrimaryColor
    }
    
    // MARK: - language
    func languageLocal() {
        //placeholders to edit text
        EmailEditText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("placeholder_to_field_text_email", comment: "placeholder_email"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 150/255.0, green: 157/255.0, blue: 169/255.0, alpha: 1)])
        
        PasswordEditText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("placeholder_to_field_text_login_password", comment: "placeholder_email"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 150/255.0, green: 157/255.0, blue: 169/255.0, alpha: 1)])
        
        NameEditText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("placeholder_to_field_text_name", comment: "placeholder_email"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 150/255.0, green: 157/255.0, blue: 169/255.0, alpha: 1)])
        
        SurNameEditText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("placeholder_to_field_text_surname", comment: "placeholder_email"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 150/255.0, green: 157/255.0, blue: 169/255.0, alpha: 1)])
        
        //text view
        text_permission.text = NSLocalizedString("text_main_permission", comment: "text permission")
        //button
        button_to_register.setTitle(NSLocalizedString("btn_go_to_login_in_register", comment: "button_register"), for: .normal)
    }
    
    // MARK: - initial validation for text field
    func initValidateTextField() {
        //validation
        EmailEditText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        PasswordEditText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        NameEditText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        SurNameEditText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textFields:UITextField) {
        if EmailEditText.text!.isEmpty || PasswordEditText.text!.isEmpty || NameEditText.text!.isEmpty || SurNameEditText.text!.isEmpty {
            button_to_register.isUserInteractionEnabled = false
            button_to_register.alpha = 0.7
        } else {
            button_to_register.isUserInteractionEnabled = true
            button_to_register.alpha = 1
        }
    }
    
    // MARK: - initial view element
    func initialViewElements() {
        //button
        self.button_to_register.backgroundColor = UIColor(red: 12/255.0, green: 185/255.0, blue: 136/255.0, alpha: 1)
        self.button_to_register.tintColor = .white
        
        self.button_to_register.layer.cornerRadius = 10
        
        //edit text
        EmailEditText.setUnderLine()
        PasswordEditText.setUnderLine()
        NameEditText.setUnderLine()
        SurNameEditText.setUnderLine()
        //image
        self.Icon.tintColor = UIColor(red: 12/255.0, green: 185/255.0, blue: 136/255.0, alpha: 1)
        
        //text view
        text_permission.isUserInteractionEnabled = true
        let guestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickedToSiteQaim(_:)))
        text_permission.addGestureRecognizer(guestureRecognizer)
        
        //switch
        switch_permission.onTintColor = UIColor(red: 12/255.0, green: 185/255.0, blue: 136/255.0, alpha: 1)
    }
    
    @objc func clickedToSiteQaim(_ sender: Any) {
        var urls = String(format: "https://qaim.me/%@/agreement", getLang())
        guard let url = URL(string: urls) else { return }
        UIApplication.shared.open(url)
    }
    
    func formateDate(date: Date) -> String {
        let formater = DateFormatter()
        formater.dateFormat = "MM/dd/yyyy"
        formater.locale = Locale(identifier: localeDatePicker())
        return formater.string(from: date)
    }
    
    func localeDatePicker() -> String {
        let locale = Locale.preferredLanguages.first
        return locale!
    }
    
    func requestPostRegistration(name: String, surname: String, email: String, password: String) {
        
        var isTrue: Bool = false

        let data : Data = "thisprojectid=\(11)&this_http_host=\("qaim.me")&lng=\(self.getLang())&email=\(email)&mailretry=\("")&password=\(password)&yourname=\(name)&surname=\(surname)&birthdateday=\(01)&birthdatemonth=\(01)&birthdateyear=\(1970)&checkID=\(1)&userUTC=\(1)&returnurl=\("")".data(using: .utf8)!

        let url = URL(string: "https://qwertynetworks.com/register.php")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.addValue("Mozilla/4.0 (compatible; Universion/1.0; +https://qwertynetworks.com)", forHTTPHeaderField: "User-Agent")

        request.httpBody = data
        URLSession.shared.dataTask(with: request){ data, response, error in

            let responseText = String(data: data!, encoding: .utf8)!

            if responseText == "OK" && error == nil {
                DispatchQueue.main.sync {
                    if self.switch_permission.isOn {
                        self.showAlertSuccess()
                    } else {
                        self.showAlertSuccessNotSitchPermission()
                    }
                    
                }
            } else if responseText != "OK" {
                DispatchQueue.main.async {
                    self.showAlertError(message: responseText)
                }
            }
        }.resume()
    }
    
    func getDateText(date: String) -> String{
        var new_date = ""
        if date != "" {
            new_date = date
            return new_date
        } else {
            new_date = self.formateDate(date: Date())
            return new_date
        }
    }
    
    func showAlertError(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertSuccess() {
        let alert = UIAlertController(title: "", message: NSLocalizedString("success_request_to_register", comment: "success text"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)

        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertSuccessNotSitchPermission() {
        let alert = UIAlertController(title: "", message: NSLocalizedString("error_text_permission", comment: "error to switch text"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { _ in self.showAlertSuccess() }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { _ in }))
        self.present(alert, animated: true, completion: nil)
    }
    
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
