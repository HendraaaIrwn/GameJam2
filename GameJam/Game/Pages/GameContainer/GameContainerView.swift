import SpriteKit
import SwiftUI

struct GameContainerView: View {
    @Bindable var viewModel: GameFlowViewModel

    @State private var homeAudio = HomeAudioPlayer()
    @State private var gameplayAudio = GameplayAudioPlayer()

    var body: some View {
        Group {
            switch viewModel.screen {
            case .home:
                HomeView(startGame: viewModel.startGame)

            case .storyline:
                StorylineBoardView(onCompleted: viewModel.completeStorylineIntro)

            case .gameplay:
                ZStack(alignment: .top) {
                    if viewModel.activeLevel == .findManualKey {
                        FindManualKeyView(onComplete: viewModel.finishLevel)
                            .id(viewModel.levelID)
                            .ignoresSafeArea()
                    } else {
                        SpriteView(scene: viewModel.scene)
                            .id(viewModel.sceneID)
                            .ignoresSafeArea()
                    }

                    GameHUDView(
                        chapterNumber: viewModel.chapterNumber,
                        levelNumber: viewModel.levelNumber,
                        score: viewModel.score,
                        novaInstruction: viewModel.novaInstruction,
                        canRetry: viewModel.canRetry,
                        retry: viewModel.retry
                    )
                }
            case .chapterTransition:
                switch viewModel.activeTransition {
                case .chapter1ToChapter2:
                    ChapterTransitionView(onCompleted: viewModel.completeChapterTransition)
                case .chapter2ToChapter3:
                    Chapter02ToChapter03TransitionView(onCompleted: viewModel.completeChapterTransition)
                case .chapter3ToChapter4:
                    Chapter03ToChapter04TransitionView(onCompleted: viewModel.completeChapterTransition)
                }
            }
        }
        .onAppear {
            homeAudio.play()
        }
        .onChange(of: viewModel.screen) { _, screen in
            if screen == .home {
                homeAudio.play()
            } else {
                homeAudio.stop()
            }

            if screen == .gameplay {
                gameplayAudio.play()
            } else {
                gameplayAudio.stop()
            }
        }
    }
}
