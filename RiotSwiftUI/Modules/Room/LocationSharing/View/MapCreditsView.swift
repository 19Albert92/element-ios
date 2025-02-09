// 
// Copyright 2021 New Vector Ltd
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

import SwiftUI

@available(iOS 14.0, *)
struct MapCreditsView: View {
    
    // MARK: - Properties
    
    // MARK: Private
    
    @Environment(\.theme) private var theme: ThemeSwiftUI
    
    // MARK: Public
    
    var body: some View {
        HStack {
            Link("© MapTiler", destination: URL(string: "https://www.maptiler.com/copyright/")!)
            Link("© OpenStreetMap contributors", destination: URL(string: "https://www.openstreetmap.org/copyright")!)
        }
        .font(theme.fonts.caption1)
    }
}

@available(iOS 14.0, *)
struct MapCreditsView_Previews: PreviewProvider {
    static var previews: some View {
        MapCreditsView()
    }
}
