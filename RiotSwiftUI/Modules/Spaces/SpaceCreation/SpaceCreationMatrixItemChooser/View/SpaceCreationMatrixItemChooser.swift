// File created from SimpleUserProfileExample
// $ createScreen.sh Spaces/SpaceCreation/SpaceCreationMatrixItemChooser SpaceCreationMatrixItemChooser
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
struct SpaceCreationMatrixItemChooser: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: SpaceCreationMatrixItemChooserViewModel.Context
    @State var searchText: String = ""
    
    // MARK: Private
    
    @Environment(\.theme) private var theme: ThemeSwiftUI
    
    // MARK: Public
    
    @ViewBuilder
    var body: some View {
        VStack {
            ThemableNavigationBar(title: nil, showBackButton: true) {
                viewModel.send(viewAction: .back)
            } closeAction: {
                viewModel.send(viewAction: .cancel)
            }
            mainView
        }
        .background(theme.colors.background)
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private var mainView: some View {
        ZStack(alignment: .bottom) {
            listContent
            footerView
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        VStack {
            Text(viewModel.viewState.title)
                .font(theme.fonts.bodySB)
                .foregroundColor(theme.colors.primaryContent)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .accessibility(identifier: "titleText")
            Text(viewModel.viewState.message)
                .font(theme.fonts.callout)
                .foregroundColor(theme.colors.secondaryContent)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .accessibility(identifier: "messageText")
            Spacer().frame(height: 24)
            SearchBar(placeholder: VectorL10n.searchDefaultPlaceholder, text: $searchText)
                .onChange(of: searchText, perform: { value in
                    viewModel.send(viewAction: .searchTextChanged(searchText))
                })
        }
    }

    @ViewBuilder
    private var listContent: some View {
        ScrollView{
            headerView
            if viewModel.viewState.items.isEmpty {
                Text(viewModel.viewState.emptyListMessage)
                    .font(theme.fonts.body)
                    .foregroundColor(theme.colors.secondaryContent)
                    .accessibility(identifier: "emptyListMessage")
                Spacer()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.viewState.items) { item in
                        SpaceCreationMatrixItemChooserListRow(
                            avatar: item.avatar,
                            displayName: item.displayName,
                            detailText: item.detailText,
                            isSelected: viewModel.viewState.selectedItemIds.contains(item.id)
                        )
                        .onTapGesture {
                            viewModel.send(viewAction: .itemTapped(item.id))
                        }
                    }
                }
                .padding(.bottom, 76)
                .accessibility(identifier: "itemsList")
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
    
    @ViewBuilder
    private var footerView: some View {
        ThemableButton(icon: nil, title: viewModel.viewState.selectedItemIds.isEmpty ? VectorL10n.skip : VectorL10n.next) {
            viewModel.send(viewAction: .done)
        }
        .accessibility(identifier: "doneButton")
        .padding(.horizontal, 24)
        .padding(.bottom)
    }
}

// MARK: - Previews

@available(iOS 14.0, *)
struct SpaceCreationMatrixItemChooser_Previews: PreviewProvider {
    
    static let stateRenderer = MockSpaceCreationMatrixItemChooserScreenState.stateRenderer
    static var previews: some View {
        stateRenderer.screenGroup(addNavigation: true)
            .theme(.light).preferredColorScheme(.light)
        stateRenderer.screenGroup(addNavigation: true)
            .theme(.dark).preferredColorScheme(.dark)
    }
}
