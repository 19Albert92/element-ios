// File created from FlowTemplate
// $ createRootCoordinator.sh Spaces/SpaceRoomList ExploreRoom ShowSpaceExploreRoom
/*
 Copyright 2021 New Vector Ltd
 
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

import UIKit

@objcMembers
final class ExploreRoomCoordinator: NSObject, ExploreRoomCoordinatorType {
    
    // MARK: - Properties
    
    // MARK: Private
    
    private let navigationRouter: NavigationRouterType
    private let session: MXSession
    private let spaceId: String
    // We need to stack the ID of visited space and subspaces so we know what is the current space ID when navigating to a room
    private var spaceIdStack: [String]
    private weak var roomDetailCoordinator: SpaceChildRoomDetailCoordinator?
    private weak var currentExploreRoomCoordinator: SpaceExploreRoomCoordinator?

    private lazy var slidingModalPresenter: SlidingModalPresenter = {
        return SlidingModalPresenter()
    }()

    // MARK: Public

    // Must be used only internally
    var childCoordinators: [Coordinator] = []
    
    weak var delegate: ExploreRoomCoordinatorDelegate?
    
    // MARK: - Setup
    
    init(session: MXSession, spaceId: String) {
        self.navigationRouter = NavigationRouter(navigationController: RiotNavigationController())
        self.session = session
        self.spaceId = spaceId
        self.spaceIdStack = [spaceId]
    }
    
    // MARK: - Public methods
    
    func start() {

        let rootCoordinator = self.createShowSpaceExploreRoomCoordinator(session: self.session, spaceId: self.spaceId, spaceName: self.session.spaceService.getSpace(withId: self.spaceId)?.summary?.displayname)

        rootCoordinator.start()

        self.add(childCoordinator: rootCoordinator)
        self.currentExploreRoomCoordinator = rootCoordinator

        self.navigationRouter.setRootModule(rootCoordinator)
    }
    
    func toPresentable() -> UIViewController {
        return self.navigationRouter.toPresentable()
    }
    
    // MARK: - Private methods
    
    private func pushSpace(with item: SpaceExploreRoomListItemViewData) {
        let coordinator = self.createShowSpaceExploreRoomCoordinator(session: self.session, spaceId: item.childInfo.childRoomId, spaceName: item.childInfo.name)
        coordinator.start()
        
        self.add(childCoordinator: coordinator)
        self.currentExploreRoomCoordinator = coordinator

        self.spaceIdStack.append(item.childInfo.childRoomId)
        
        self.navigationRouter.push(coordinator.toPresentable(), animated: true) {
            self.remove(childCoordinator: coordinator)
            self.spaceIdStack.removeLast()
        }
    }
    
    private func presentRoom(with item: SpaceExploreRoomListItemViewData, from sourceView: UIView?) {
        if let currentCoordinator = self.roomDetailCoordinator {
            self.remove(childCoordinator: currentCoordinator)
        }
        
        let summary = self.session.roomSummary(withRoomId: item.childInfo.childRoomId)
        let isJoined = summary?.isJoined ?? false

        if isJoined {
            self.navigateTo(roomWith: item.childInfo.childRoomId)
        } else {
            self.showRoomPreview(with: item, from: sourceView)
        }
    }

    private func showRoomPreview(with item: SpaceExploreRoomListItemViewData, from sourceView: UIView?) {
        let coordinator = self.createShowSpaceRoomDetailCoordinator(session: self.session, childInfo: item.childInfo)
        coordinator.start()
        self.add(childCoordinator: coordinator)
        self.roomDetailCoordinator = coordinator
        
        if UIDevice.current.isPhone {
            slidingModalPresenter.present(coordinator.toSlidingPresentable(), from: self.navigationRouter.toPresentable(), animated: true, completion: nil)
        } else {
            let viewController = coordinator.toPresentable()
            viewController.modalPresentationStyle = .popover
            if let sourceView = sourceView, let popoverPresentationController = viewController.popoverPresentationController {
                popoverPresentationController.sourceView = sourceView
                popoverPresentationController.sourceRect = sourceView.bounds
            }

            self.navigationRouter.present(viewController, animated: true)
        }
    }

    private func createShowSpaceExploreRoomCoordinator(session: MXSession, spaceId: String, spaceName: String?) -> SpaceExploreRoomCoordinator {
        let coordinator = SpaceExploreRoomCoordinator(parameters: SpaceExploreRoomCoordinatorParameters(session: session, spaceId: spaceId, spaceName: spaceName, showCancelMenuItem: self.navigationRouter.modules.isEmpty))
        coordinator.delegate = self
        return coordinator
    }
    
    private func createShowSpaceRoomDetailCoordinator(session: MXSession, childInfo: MXSpaceChildInfo) -> SpaceChildRoomDetailCoordinator {
        let coordinator = SpaceChildRoomDetailCoordinator(parameters: SpaceChildRoomDetailCoordinatorParameters(session: session, childInfo: childInfo))
        coordinator.delegate = self
        return coordinator
    }
    
    private func navigateTo(roomWith roomId: String) {
        let roomDataSourceManager = MXKRoomDataSourceManager.sharedManager(forMatrixSession: self.session)
        roomDataSourceManager?.roomDataSource(forRoom: roomId, create: true, onComplete: { [weak self] roomDataSource in
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let roomViewController = storyboard.instantiateViewController(withIdentifier: "RoomViewControllerStoryboardId") as? RoomViewController else {
                return
            }
            
            self?.navigationRouter.push(roomViewController, animated: true, popCompletion: nil)
            roomViewController.parentSpaceId = self?.spaceIdStack.last
            roomViewController.displayRoom(roomDataSource)
            roomViewController.navigationItem.leftItemsSupplementBackButton = true
            roomViewController.showMissedDiscussionsBadge = false
        })
    }
    
    private func presentRoomCreation() {
        let space = session.spaceService.getSpace(withId: spaceIdStack.last ?? "")
        let createRoomCoordinator = CreateRoomCoordinator(parameters: CreateRoomCoordinatorParameter(session: self.session, parentSpace: space))
        createRoomCoordinator.delegate = self
        let presentable = createRoomCoordinator.toPresentable()
        presentable.presentationController?.delegate = self
        toPresentable().present(presentable, animated: true, completion: nil)
        createRoomCoordinator.start()
        self.add(childCoordinator: createRoomCoordinator)
    }
}

// MARK: - ShowSpaceExploreRoomCoordinatorDelegate
extension ExploreRoomCoordinator: SpaceExploreRoomCoordinatorDelegate {
    func spaceExploreRoomCoordinator(_ coordinator: SpaceExploreRoomCoordinatorType, didSelect item: SpaceExploreRoomListItemViewData, from sourceView: UIView?) {
        if item.childInfo.roomType == .space {
            self.pushSpace(with: item)
        } else if item.childInfo.roomType == .room {
            self.presentRoom(with: item, from: sourceView)
        }
    }

    func spaceExploreRoomCoordinatorDidCancel(_ coordinator: SpaceExploreRoomCoordinatorType) {
        self.delegate?.exploreRoomCoordinatorDidComplete(self)
    }
    
    func spaceExploreRoomCoordinatorDidAddRoom(_ coordinator: SpaceExploreRoomCoordinatorType) {
        self.presentRoomCreation()
    }
}

// MARK: - ShowSpaceChildRoomDetailCoordinator
extension ExploreRoomCoordinator: SpaceChildRoomDetailCoordinatorDelegate {
    func spaceChildRoomDetailCoordinator(_ coordinator: SpaceChildRoomDetailCoordinatorType, didOpenRoomWith roomId: String) {
        self.navigationRouter.toPresentable().dismiss(animated: true) {
            if let lastCoordinator = self.roomDetailCoordinator {
                self.remove(childCoordinator: lastCoordinator)
            }
            self.navigateTo(roomWith: roomId)
        }
    }
    
    func spaceChildRoomDetailCoordinatorDidCancel(_ coordinator: SpaceChildRoomDetailCoordinatorType) {
        if UIDevice.current.isPhone {
            slidingModalPresenter.dismiss(animated: true) {
                if let roomDetailCoordinator = self.roomDetailCoordinator {
                    self.remove(childCoordinator: roomDetailCoordinator)
                }
            }
        } else {
            self.roomDetailCoordinator?.toPresentable().dismiss(animated: true, completion: {
                if let roomDetailCoordinator = self.roomDetailCoordinator {
                    self.remove(childCoordinator: roomDetailCoordinator)
                }
            })
        }
    }
}

// MARK: - CreateRoomCoordinatorDelegate
extension ExploreRoomCoordinator: CreateRoomCoordinatorDelegate {
    
    func createRoomCoordinator(_ coordinator: CreateRoomCoordinatorType, didCreateNewRoom room: MXRoom) {
        self.currentExploreRoomCoordinator?.reloadRooms()
        coordinator.toPresentable().dismiss(animated: true) {
            self.remove(childCoordinator: coordinator)
            self.navigateTo(roomWith: room.roomId)
        }
    }
    
    func createRoomCoordinator(_ coordinator: CreateRoomCoordinatorType, didAddRoomsWithIds roomIds: [String]) {
        self.currentExploreRoomCoordinator?.reloadRooms()
        coordinator.toPresentable().dismiss(animated: true) {
            self.remove(childCoordinator: coordinator)
        }
    }

    func createRoomCoordinatorDidCancel(_ coordinator: CreateRoomCoordinatorType) {
        coordinator.toPresentable().dismiss(animated: true) {
            self.remove(childCoordinator: coordinator)
        }
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension ExploreRoomCoordinator: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard let lastCoordinator = childCoordinators.last else {
            return
        }
        self.remove(childCoordinator: lastCoordinator)
    }
    
}
