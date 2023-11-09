//
//  Singleton.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 30.08.2023.
//

import Foundation

// final class Singleton {
//
//    private init() {}//чтобы класс был в 1ом экземпляре: т.к. private, то нельзя создать экземпляр класса Session извне, используя инициализатор. Тут лучше класс, тк нет копирования как в структуре
//
//    static let sharedInstance = Singleton() //чтобы получить доступность извне. Когда AРР запускается, то происходит обход статичных полей и присваивание им значений - так ему ставится 1 значение и мы можем всегда им пользоваться
//
//    var token: String? = "8adf47e8d901e2a6f5b58897510f9cdb"
// }

enum Use {
    static let token = "8adf47e8d901e2a6f5b58897510f9cdb" // меньше кодовая база - меньше ошибок, легче
}
