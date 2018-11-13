//
//  VerifyLoginViewController.swift
//  NumericCodeVerifier
//
//  Created by obex on 11/12/18.
//  Copyright © 2018 kevin.le. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VerifyLoginViewController: UIViewController {

    @IBOutlet weak var firstDigitTextField: UITextField!
    @IBOutlet weak var secondDigitTextField: UITextField!
    @IBOutlet weak var thirdDigitTextField: UITextField!
    @IBOutlet weak var fourthDigitTextField: UITextField!
    @IBOutlet weak var fifthDigitTextField: UITextField!
    @IBOutlet weak var sixthDigitTextField: UITextField!
    
    @IBOutlet weak var verifyButton: UIButton!
    
    var digitTextFields: [UITextField] = []
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        digitTextFields = [firstDigitTextField, secondDigitTextField, thirdDigitTextField, fourthDigitTextField, fifthDigitTextField, sixthDigitTextField]
        
        //Center text horizontally and vertically in each 'box'
        for digitTextField in digitTextFields {
            digitTextField.textAlignment = .center
            digitTextField.contentVerticalAlignment = .center
        }
        
        
        //After entering a digit, make cursor jumps to the next box
        let responders: [(digitTextField: UITextField, potentialNextResponder: UITextField?)] = [
            (firstDigitTextField, secondDigitTextField),
            (secondDigitTextField, thirdDigitTextField),
            (thirdDigitTextField, fourthDigitTextField),
            (fourthDigitTextField, fifthDigitTextField),
            (fifthDigitTextField, sixthDigitTextField),
            (sixthDigitTextField, nil)
        ]
        
        for (digitTextField, potentialNextResponder) in responders {
            if let nextResponder = potentialNextResponder {
                digitTextField.rx.controlEvent([.editingChanged])
                .asObservable()
                .subscribe(onNext: { nextResponder.becomeFirstResponder() })
                .disposed(by: disposeBag)
            } else {
                digitTextField.rx.controlEvent([.editingChanged])
                .asObservable()
                .subscribe(onNext: { digitTextField.resignFirstResponder() })
                .disposed(by: disposeBag)
            }
        }
        
        //Clear the digit if box is tapped on
        for digitTextField in digitTextFields {
            digitTextField.rx.controlEvent(.editingDidBegin)
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                digitTextField.text = ""
                self.enableButton(button: self.verifyButton, enabled: false)
            })
            .disposed(by: disposeBag)
        }
        
        //Anytime, there's an empty box, disable the Verify button
        let digitObservables = digitTextFields.map { $0.rx.text.map { $0 ?? "" } }
        
        Observable.combineLatest(digitObservables)
            .subscribe(onNext: { [unowned self] in
                var enabled = true
                
                for textField in $0 {
                    if textField.count < 1 {
                        enabled = false
                    }
                }
                
                self.enableButton(button: self.verifyButton, enabled: enabled)
            })
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func enableButton(button: UIButton, enabled:Bool) {
        button.isEnabled = enabled
        button.alpha = enabled ? 1.0 : 0.25
    }
}

