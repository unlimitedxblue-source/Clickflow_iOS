import SwiftUI

struct HelpGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clickflowBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header Card
                        GlassCard {
                            VStack(spacing: 12) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(LinearGradient.clickflowAccent)

                                Text("Clickflow へようこそ")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)

                                Text("ポケット誤操作の完全防止と、音量ボタンによる超高速ショートカット起動を両立するスマートユーティリティです。")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.75))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }

                        // Feature 1: Pocket Guard
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Image(systemName: "shield.lefthalf.filled")
                                        .foregroundStyle(Color.clickflowNeonCyan)
                                        .font(.title3)
                                    Text("1. ポケットガード機能")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }

                                Text("• **自動ガード**: 端末をポケットに入れる（逆さま・下向きにする）と、自動的に画面が漆黒のOLED省電力ガード状態になり、タップ誤操作をブロックします。\n• **完全上向きで自動解除**: 端末を取り出して**画面を上に向けて構える**と、瞬時にガードが自動解除されます。\n• **手動解除**: 画面の任意の場所を長押しすることでも手動解除できます。")
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .lineSpacing(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Feature 2: Volume Command Trigger
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Image(systemName: "speaker.wave.3.fill")
                                        .foregroundStyle(Color.clickflowVividEmerald)
                                        .font(.title3)
                                    Text("2. 音量ボタントリガー")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }

                                Text("• **ブラインド操作**: ガード作動中や画面を見ない状態でも、iPhone 本体の「音量UP」または「音量DOWN」ボタンを押すだけで、設定した Apple ショートカットを即座に実行します。\n• **触覚フィードバック**: ボタン押下およびショートカット実行成功時に、心地よい Taptic Engine の振動で実行をお知らせします。")
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .lineSpacing(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Feature 3: How to Setup Shortcuts
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Image(systemName: "gearshape.2.fill")
                                        .foregroundStyle(Color.clickflowNeonCyan)
                                        .font(.title3)
                                    Text("3. ショートカットの設定方法")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }

                                Text("1. ホーム画面右上の「歯車（設定）」アイコンをタップ。\n2. 音量UP / DOWN ボタンに割り当てたい**ショートカット名**（例: `再生/停止`、`ボイスメモ` など）を入力して保存。\n3. iOS 標準の「ショートカット」アプリ内に同名のアクションを作成しておくだけで、ワンタップで連携が完了します。")
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .lineSpacing(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Feature 4: Privacy & On-Device
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Image(systemName: "lock.shield.fill")
                                        .foregroundStyle(Color.clickflowVividEmerald)
                                        .font(.title3)
                                    Text("4. プライバシー＆安全性")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }

                                Text("Clickflow は外部サーバーへのデータ通信やユーザー追跡を一切行いません。すべてのモーション判定とショートカット連携は iPhone 端末内（完全オンデバイス）で安全に処理されます。")
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .lineSpacing(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("使い方ガイド")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.clickflowNeonCyan)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    HelpGuideView()
}
