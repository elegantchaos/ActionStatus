//
//  Test.swift
//  Settings
//
//  Created by Sam Deane on 02/03/2026.
//

import Foundation
import Settings
import Testing

extension AppSettingKey where Value == String {
  static let testString = AppSettingKey("testString", defaultValue: "Hello, World!")
}

extension AppSettingKey where Value == Int {
  static let testInt = AppSettingKey("testInt", defaultValue: 123)
}

extension AppSettingKey where Value == Double {
  static let testDouble = AppSettingKey("testDouble", defaultValue: 123.456)
}

extension AppSettingKey where Value == Bool {
  static let testBool = AppSettingKey("testBool", defaultValue: true)
}

extension AppSettingKey where Value == TestEnum {
  static let testEnum = AppSettingKey("testEnum", defaultValue: .a)
}

enum TestEnum: String {
  case a
  case b
}


struct SettingsTests {

  func testRead<T>(key: AppSettingKey<T>, value testValue: T) where T: Equatable, T: RawRepresentable {
    let settings = UserDefaults(suiteName: UUID().uuidString)!
    settings.set(testValue.rawValue, forKey: key.key)
    let value = settings.value(forKey: key)
    #expect(value == testValue)
  }

  func testRead<T>(key: AppSettingKey<T>, value testValue: T) where T: Equatable, T: SettingsCompatible {
    let settings = UserDefaults(suiteName: UUID().uuidString)!
    settings.set(testValue, forKey: key)

    let value = settings.value(forKey: key)
    #expect(value == testValue)
  }


  func testReadDefault<T: Equatable>(key: AppSettingKey<T>) {
    let settings = UserDefaults(suiteName: UUID().uuidString)!

    let value = settings.value(forKey: key)
    #expect(value == key.defaultValue)
  }

  func testWrite<T: Equatable>(key: AppSettingKey<T>, value testValue: T) where T: Equatable, T: RawRepresentable {
    let settings = UserDefaults(suiteName: UUID().uuidString)!
    settings.set(testValue, forKey: key)
    let raw = settings.object(forKey: key.key) as? T.RawValue
    let value = raw.flatMap { T(rawValue: $0) }
    #expect(value == testValue)
  }

  func testWrite<T: Equatable>(key: AppSettingKey<T>, value testValue: T) where T: Equatable, T: SettingsCompatible {
    let settings = UserDefaults(suiteName: UUID().uuidString)!
    settings.set(testValue, forKey: key)
    let value = settings.object(forKey: key.key) as? T
    #expect(value == testValue)
  }


  @Test func testRead() {
    testRead(key: .testString, value: "foo bar")
    testRead(key: .testInt, value: 987)
    testRead(key: .testDouble, value: 654.321)
    testRead(key: .testBool, value: true)
    testRead(key: .testEnum, value: .b)
  }

  @Test func testDefault() {
    testReadDefault(key: .testString)
    testReadDefault(key: .testInt)
    testReadDefault(key: .testDouble)
    testReadDefault(key: .testBool)
    testReadDefault(key: .testEnum)
  }

  @Test func testWrite() {
    testWrite(key: .testString, value: "foo bar")
    testWrite(key: .testInt, value: 987)
    testWrite(key: .testDouble, value: 654.321)
    testWrite(key: .testBool, value: true)
    testWrite(key: .testEnum, value: .b)
  }

}

#if canImport(SwiftUI)
import SwiftUI

struct SettingsAppStorageTests {
  @Test func testAppStorageString() {
    let settings = UserDefaults(suiteName: UUID().uuidString)!
    settings.set("foo bar", forKey: .testString)
    @AppStorage(.testString, store: settings) var testString
    #expect(testString == "foo bar")
    #expect(settings.string(forKey: "testString") == "foo bar")
  }
  
  @Test func testAppStorageEnum() {
    let settings = UserDefaults(suiteName: UUID().uuidString)!
    settings.set(TestEnum.b, forKey: .testEnum)
    @AppStorage(.testEnum, store: settings) var testEnum
    #expect(testEnum == .b)
    #expect(settings.string(forKey: "testEnum") == "b")
  }

  @Test func testAppStorageStringDefault() {
    let settings = UserDefaults(suiteName: UUID().uuidString)!
    @AppStorage(.testString, store: settings) var testString
    #expect(testString == AppSettingKey.testString.defaultValue)
    #expect(settings.object(forKey: "testString") == nil)
  }
  
  @Test func testAppStorageEnumDefault() {
    let settings = UserDefaults(suiteName: UUID().uuidString)!
    @AppStorage(.testEnum, store: settings) var testEnum
    #expect(testEnum == .a)
    #expect(settings.object(forKey: "testEnum") == nil)
  }

}
#endif
