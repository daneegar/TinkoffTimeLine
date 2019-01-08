//
//  errorsHandler.swift
//  TinkoffTimeLine
//
//  Created by Denis Garifyanov on 08/01/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation

import Foundation
import UIKit
enum errors: Error {
    case response
    case parser
    case connection
    case reading
    case saving
}
class PopUpError {
    static func showAnAllert(type: errors, sender: UIViewController){
        let alertButton = UIAlertAction(title: "OK", style: .default)
        switch type {
        case .response:
            let alertForNameanItem = UIAlertController(title: "Упс", message: "Что-то пошло не так, попробуйте перезапустить приложение", preferredStyle: .alert)
            alertForNameanItem.addAction(alertButton)
            sender.present(alertForNameanItem, animated: true)
        case .parser:
            let alertForNameanItem = UIAlertController(title: "Упс", message: "Сервис недоступен", preferredStyle: .alert)
            alertForNameanItem.addAction(alertButton)
            sender.present(alertForNameanItem, animated: true)
        case .connection:
            let alertForNameanItem = UIAlertController(title: "Упс", message: "Нет соединения с интернетом", preferredStyle: .alert)
            alertForNameanItem.addAction(alertButton)
            sender.present(alertForNameanItem, animated: true)
        case .reading:
            let alertForNameanItem = UIAlertController(title: "Упс", message: "Переустановите приложение", preferredStyle: .alert)
            alertForNameanItem.addAction(alertButton)
            sender.present(alertForNameanItem, animated: true)
        case .saving:
            let alertForNameanItem = UIAlertController(title: "Упс", message: "Проверьте наличие свободного места на телефоне", preferredStyle: .alert)
            alertForNameanItem.addAction(alertButton)
            sender.present(alertForNameanItem, animated: true)
        }
    }
}
