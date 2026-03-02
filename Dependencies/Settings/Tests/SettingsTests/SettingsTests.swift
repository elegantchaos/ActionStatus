//
//  Test.swift
//  Settings
//
//  Created by Sam Deane on 02/03/2026.
//

import Foundation
import Testing
import Settings

extension AppSettingKey where Value == String {
  static let testString = AppSettingKey("testString", defaultValue: "Hello, World!")
  static let testInt = AppSettingKey<Int>("testInt", defaultValue: 123)
  static let testDouble = AppSettingKey("testDouble", defaultValue: 123.456)
  static let testBool = AppSettingKey("testBool", defaultValue: true)
}
struct SettingsTests {
  
    @Test func testRead() async throws {
      let settings = UserDefaults()
      settings.set("testValue", forKey: "testString")
      
      let value = settings.value(forKey: .testString)
      #expect(value == "testValue")
    }

  @Test func testWrite() async throws {
    let settings = UserDefaults()
    settings.set("testValue", forKey: .testString)
    
    let value = settings.string(forKey: "testString")
    #expect(value == "testValue")
  }

}
