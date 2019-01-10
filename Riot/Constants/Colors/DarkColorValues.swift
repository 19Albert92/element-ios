/*
 Copyright 2018 New Vector Ltd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import UIKit

/// Color constants for the dart theme
@objcMembers
final class DarkColorValues: NSObject, ColorValues {

    static let shared = DarkColorValues()

    let backgroundColor: UIColor = UIColor(rgb: 0x212224)

    let baseColor: UIColor = UIColor(rgb: 0x292E37)
    let baseTextPrimaryColor: UIColor = UIColor(rgb: 0xFFFFFF)
    let baseTextSecondaryColor: UIColor = UIColor(rgb: 0xFFFFFF)

    let searchBackgroundColor: UIColor = UIColor(rgb: 0x3E434B)
    let searchTextColor: UIColor = UIColor(rgb: 0xACB3C2)

    let headerBackgroundColor: UIColor = UIColor(rgb: 0x303540)
    let headerBorderColor: UIColor  = UIColor(rgb: 0x2E2F31)
    let headerTextPrimaryColor: UIColor = UIColor(rgb: 0x96A1B7)
    let headerTextSecondaryColor: UIColor = UIColor(rgb: 0xC8C8CD)

    let textPrimaryColor: UIColor = UIColor(rgb: 0xFFFFFF)
    let textSecondaryColor: UIColor = UIColor(rgb: 0xD8D8D8)

    let tintColor: UIColor = UIColor(rgb: 0x7AC9A1)
    let unreadRoomIndentColor: UIColor = UIColor(rgb: 0x2E3648)
    
    let notificationUnreadColor: UIColor = UIColor(rgb: 0x7AC9A1)
    let notificationMentionColor: UIColor = UIColor(rgb: 0x3F4147)

    let avatarColors: [UIColor] = [
        UIColor(rgb: 0x7AC9A1),
        UIColor(rgb: 0x1E7DDC),
        UIColor(rgb: 0x76DDD7)]
}
