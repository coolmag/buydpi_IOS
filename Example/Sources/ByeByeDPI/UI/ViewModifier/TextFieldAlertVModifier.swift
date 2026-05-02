//
//  TextFieldAlertVModifier.swift
//  SwByeDPI
//
//  Created by developer on 20.03.2026.
//

import SwiftUI
#if canImport(UIKit) && canImport(TextFieldAlert)
import TextFieldAlert
#endif

struct UniversalTextFieldAlert: ViewModifier {
    
    @Binding var isPresented: Bool
    @Binding var tfValue: String
    fileprivate let title: String
    fileprivate let placeholder: String?
    
    fileprivate let autocapitalizationType: AppTextAutocapitalizationType
    fileprivate let keyboardType: AppKeyboardType
    
    fileprivate let validator: ((String) -> Bool)?
    fileprivate let onCancel: () -> Void
    fileprivate let action: (String) -> Void

    func body(content: Content) -> some View {
#if canImport(TextFieldAlert) && (os(iOS) || os(tvOS))
        content.textFieldAlert(title: title, textFields: [
            TextFieldAlert.TextField(text: $tfValue, placeholder: placeholder, isSecureTextEntry: false, autocapitalizationType: autocapitalizationType.UIKitAdaptedValue, autocorrectionType: .default, keyboardType: keyboardType.UIKitAdaptedValue)
        ], actions: [
            TextFieldAlert.Action(title: R.string.localizable.generalCancel, style: .cancel, isEnabled: Binding(get: {
                return true
            }, set: { newVal in
                
            }), closure: { textFieldValues in
                onCancel()
                isPresented = false
            }),
            TextFieldAlert.Action(title: R.string.localizable.generalDone, style: .default, isEnabled: Binding(get: {
                if (tfValue.isEmpty) {
                    return false
                }
                if let safeValidator = validator, !safeValidator(tfValue) {
                    return false
                }
                return true
            }, set: { newVal in
                
            }), closure: { textFieldValues in
                if (textFieldValues.isEmpty) {
                    //Reset
                    onCancel()
                    isPresented = false
                    return
                }
                if let safeValidator = validator, !safeValidator(textFieldValues[0]) {
                    //Invalid input -> reset
                    onCancel()
                    isPresented = false
                    return
                }
                action(textFieldValues[0])
                isPresented = false
            })
        ], isPresented: $isPresented)
#else
        
        content.sheet(isPresented: $isPresented, onDismiss: {
            //Костыль - Проброс "отмены" при закрытии свайпом. Вызывается всегда (Кнопки Отмена или Готово, помимо свайпа), но не будет иметь эффекта при нажатии "Готово", так как первым будет отрабатывать изменение значения value на новым
            onCancel()
        }) {
            VStack(spacing: 20) {
                Text(title).font(.headline)
                
                TextField(placeholder ?? "", text: $tfValue)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Divider()
                
                HStack {
                    Button {
                        isPresented = false
                        onCancel()
                    } label: {
                        Text(R.string.localizable.generalCancel)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider().frame(height: 30)
                    
                    Button {
                        action(tfValue)
                        isPresented = false
                    } label: {
                        Text(R.string.localizable.generalDone)
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(tfValue.isEmpty || validator?(tfValue) == false)
                }
                .frame(height: Constants.buttonMinHeight)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding()
            //.presentationDetents([.height(220)]) // Компактный размер снизу
            //.presentationDragIndicator(.visible)
        }
#endif
    }
}

extension View {
    func textFieldAlert(
        isPresented: Binding<Bool>,
        text: Binding<String>,
        title: String,
        placeholder: String? = nil,
        autocapitalizationType: AppTextAutocapitalizationType = .none,
        keyboardType: AppKeyboardType = .defaultVal,
        validator: ((String) -> Bool)?,
        onCancel: @escaping () -> Void,
        action: @escaping (String) -> Void) -> some View {
        self.modifier(UniversalTextFieldAlert(
            isPresented: isPresented,
            tfValue: text,
            title: title,
            placeholder: placeholder,
            autocapitalizationType: autocapitalizationType,
            keyboardType: keyboardType,
            validator: validator,
            onCancel: onCancel,
            action: action
        ))
    }
}

enum AppTextAutocapitalizationType {
    case none
    case allCharacters
    case words
    case sentences
}

enum AppKeyboardType {
    case defaultVal
    case URL
    case alphabet
    case asciiCapable
    case asciiCapableNumberPad
    case decimalPad
    case emailAddress
    case namePhonePad
    case numberPad
    case numbersAndPunctuation
    case phonePad
    case twitter
    case webSearch
}

#if canImport(UIKit)
extension AppTextAutocapitalizationType {
    
    var UIKitAdaptedValue: UITextAutocapitalizationType {
        get {
            switch (self) {
            case .none: return .none
            case .allCharacters: return .allCharacters
            case .words: return .words
            case .sentences: return .sentences
            }
        }
    }
    
}

extension AppKeyboardType {
    
    var UIKitAdaptedValue: UIKeyboardType {
        get {
            switch (self) {
            case .defaultVal: return .default
            case .URL: return .URL
            case .alphabet: return .alphabet
            case .asciiCapable: return .asciiCapable
            case .asciiCapableNumberPad: return .asciiCapableNumberPad
            case .decimalPad: return .decimalPad
            case .emailAddress: return .emailAddress
            case .namePhonePad: return .namePhonePad
            case .numberPad: return .numberPad
            case .numbersAndPunctuation: return .numbersAndPunctuation
            case .phonePad: return .phonePad
            case .twitter: return .twitter
            case .webSearch: return .webSearch
            }
        }
    }
    
}
#endif
