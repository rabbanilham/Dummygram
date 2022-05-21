//
//  String+Extension.swift
//  Dummygram
//
//  Created by Bagas Ilham on 14/05/22.
//

import Foundation

extension String {

    
    enum ValidityType {
        case email
        case password
    }
    
    func isValid(_ validityType: ValidityType,_ text: String) -> Bool {
        
        switch validityType {
        case .email:
            if text.contains("@") {
                return true
            } else {
                return false
            }
         
        case .password:
            if text.count >= 8 {
                return true
            } else {
                return false
            }
        }
    }
}

extension String {
   var isValidEmail: Bool {
      let regularExpressionForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let testEmail = NSPredicate(format:"SELF MATCHES %@", regularExpressionForEmail)
      return testEmail.evaluate(with: self)
   }
   var isValidPhone: Bool {
      let regularExpressionForPhone = "^\\d{3}-\\d{3}-\\d{4}$"
      let testPhone = NSPredicate(format:"SELF MATCHES %@", regularExpressionForPhone)
      return testPhone.evaluate(with: self)
   }
}
