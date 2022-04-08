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
    
    @IBOutlet weak var SelectDatePicker: UITextField!
    //text view
    @IBOutlet weak var textDateText: UILabel!
    
    //button
    @IBOutlet weak var button_to_register: UIButton!
    @IBAction func button_action_to_register(_ sender: UIButton) {
        self.requestPostRegistration(
            name: NameEditText.text!,
            surname: SurNameEditText.text!,
            email: EmailEditText.text!,
            dateBirth: SelectDatePicker.text!,
            password: PasswordEditText.text!)
    }
    
    //date picker
    let dataPicker = UIDatePicker()
    
    //image
    @IBOutlet weak var Icon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button_to_register.isUserInteractionEnabled = false
        button_to_register.alpha = 0.7
        
        self.initialViewElements()
        self.initValidateTextField()
        self.createDataPicker()
        self.languageLocal()
    }
    
    func languageLocal() {
        //placeholders
        EmailEditText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("placeholder_to_field_text_email", comment: "placeholder_email"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 150/255.0, green: 157/255.0, blue: 169/255.0, alpha: 1)])
        
        PasswordEditText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("placeholder_to_field_text_login_password", comment: "placeholder_email"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 150/255.0, green: 157/255.0, blue: 169/255.0, alpha: 1)])
        
        NameEditText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("placeholder_to_field_text_name", comment: "placeholder_email"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 150/255.0, green: 157/255.0, blue: 169/255.0, alpha: 1)])
        
        SurNameEditText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("placeholder_to_field_text_surname", comment: "placeholder_email"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 150/255.0, green: 157/255.0, blue: 169/255.0, alpha: 1)])
        
        SelectDatePicker.attributedPlaceholder = NSAttributedString(string: self.formateDate(date: Date()),
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 150/255.0, green: 157/255.0, blue: 169/255.0, alpha: 1)])
        
        //text view
        textDateText.text = NSLocalizedString("text_name_section_date_birth", comment: "date_text")
        //button
        button_to_register.setTitle(NSLocalizedString("btn_go_to_login_in_register", comment: "button_register"), for: .normal)
    }
    
    func initValidateTextField() {
        //validation
        EmailEditText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        PasswordEditText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        NameEditText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        SurNameEditText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        SelectDatePicker.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .allEvents)
    }
    
    @objc func textFieldDidChange(_ textFields:UITextField) {
        if EmailEditText.text!.isEmpty || PasswordEditText.text!.isEmpty || NameEditText.text!.isEmpty || SurNameEditText.text!.isEmpty || SelectDatePicker.text!.isEmpty {
            button_to_register.isUserInteractionEnabled = false
            button_to_register.alpha = 0.7
        } else {
            button_to_register.isUserInteractionEnabled = true
            button_to_register.alpha = 1
        }
    }
    
    func initialViewElements() {
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
    }
    
    func createDataPicker(){
        dataPicker.datePickerMode = .date
        dataPicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        dataPicker.frame.size = CGSize(width: 0, height: 300)
        if #available(iOS 13.4, *) {
            dataPicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        dataPicker.maximumDate = Date()
        toolbarForInput()
        SelectDatePicker.inputView = dataPicker
        dataPicker.locale = Locale(identifier: localeDatePicker())
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        SelectDatePicker.text = formateDate(date: datePicker.date)
    }
    
    func formateDate(date: Date) -> String {
        let formater = DateFormatter()
        formater.dateFormat = "MM/dd/yyyy"
        formater.locale = Locale(identifier: localeDatePicker())
        return formater.string(from: date)
    }
    
    func toolbarForInput(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexSpace,doneBtn], animated: true)
        SelectDatePicker.inputAccessoryView = toolbar
    }
    
    @objc func doneAction(){
        view.endEditing(true)// закрытие datepicker по нажатию на кнопку
    }
    
    func localeDatePicker() -> String {
        let locale = Locale.preferredLanguages.first
        return locale!
    }
    
    func requestPostRegistration(name: String, surname: String, email: String, dateBirth: String, password: String) {
        
        var dateTime = self.getDateText(date: dateBirth).components(separatedBy: "/")

        let dayTime = dateTime[1]
        let monthTime = dateTime[0]
        let yearTime = dateTime[2]
        
        var isTrue: Bool = false

        let data : Data = "thisprojectid=\(11)&this_http_host=\("qaim.me")&lng=\(self.getLang())&email=\(email)&mailretry=\("")&password=\(password)&yourname=\(name)&surname=\(surname)&birthdateday=\(dayTime)&birthdatemonth=\(monthTime)&birthdateyear=\(yearTime)&checkID=\(1)&userUTC=\(1)&returnurl=\("")".data(using: .utf8)!

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
                    self.showAlertSuccess()
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
        let alert = UIAlertController(title: "", message: "Посмотрите на ваш почтовый адресс", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
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
