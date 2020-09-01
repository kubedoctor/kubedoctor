//
// Created by 翟怀楼 on 2020/7/23.
// Copyright (c) 2020 翟怀楼. All rights reserved.
//

import Foundation

func date2String(_ date:Date, dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale.init(identifier: "zh_CN")
    formatter.dateFormat = dateFormat
    let date = formatter.string(from: date)
    return date
}