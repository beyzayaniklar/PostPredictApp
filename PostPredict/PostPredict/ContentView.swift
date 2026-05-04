import SwiftUI

/*
 PostPredict is an app that estimates the potential performance of a social media post.
*/

struct ContentView: View {
    @AppStorage("hasCompletedProfile") private var hasCompletedProfile = false

    var body: some View {
        NavigationStack {
            if hasCompletedProfile {
                PostInputView()
            } else {
                StartView()
            }
        }
    }
}

// MARK: - Models

enum SocialPlatform: String, CaseIterable, Identifiable {
    case instagram = "Instagram"
    case tiktok = "TikTok"
    case facebook = "Facebook"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .instagram: return "camera.filters"
        case .tiktok: return "music.note.tv"
        case .facebook: return "person.2.circle"
        }
    }
}

enum PostType: String, CaseIterable, Identifiable {
    case image = "Image"
    case reel = "Reel"
    case carousel = "Carousel"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .image: return "photo"
        case .reel: return "play.rectangle.fill"
        case .carousel: return "square.on.square"
        }
    }
}

enum PostingTime: String, CaseIterable, Identifiable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "moon.stars.fill"
        }
    }
}

enum PostingFrequency: String, CaseIterable, Identifiable {
    case low = "1–2 posts/week"
    case medium = "3–5 posts/week"
    case high = "6+ posts/week"

    var id: String { rawValue }
}

struct PredictionResult {
    let score: Int
    let estimatedLikes: Int
    let estimatedComments: Int
    let summary: String
    let suggestions: [String]
}

// MARK: - Start View

struct StartView: View {
    var body: some View {
        ZStack {
            BackgroundGradientView()

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 86))
                    .foregroundStyle(.white)

                VStack(spacing: 14) {
                    Text("PostPredict")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Predict how your social media post may perform.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.88))
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 14) {
                    FeatureRow(icon: "person.crop.circle.badge.checkmark", text: "Create your profile.")
                    FeatureRow(icon: "sparkles.rectangle.stack", text: "Get predictions.")
                }
                .padding()
                .background(.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .padding(.horizontal)

                NavigationLink {
                    ProfileSetupView()
                } label: {
                    Text("Create Profile")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical, 30)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)

            Text(text)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.92))

            Spacer()
        }
    }
}

// MARK: - Profile Setup

struct ProfileSetupView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("hasCompletedProfile") private var hasCompletedProfile = false
    @AppStorage("profileName") private var profileName = ""
    @AppStorage("profileFollowers") private var profileFollowers = 1000
    @AppStorage("profileNiche") private var profileNiche = "Lifestyle"
    @AppStorage("profileFrequency") private var profileFrequency = PostingFrequency.medium.rawValue
    @AppStorage("profilePrimaryPlatform") private var profilePrimaryPlatform = SocialPlatform.instagram.rawValue

    @State private var tempName = ""
    @State private var tempFollowers = ""
    @State private var tempNiche = "Lifestyle"
    @State private var tempFrequency = PostingFrequency.medium
    @State private var tempPrimaryPlatform = SocialPlatform.instagram

    private let niches = [
        "Lifestyle",
        "Fashion",
        "Fitness",
        "Food",
        "Travel",
        "Sports",
        "Music",
        "Education",
        "Business",
        "Tech"
    ]

    var body: some View {
        ZStack {
            BackgroundGradientView()

            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 10) {
                        Text("Create Your Profile")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Enter a few details so PostPredict can generate more realistic estimates.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.84))
                    }
                    .padding(.top, 24)

                    GlassCard {
                        VStack(spacing: 18) {
                            ProfileInputField(
                                title: "Name or Brand",
                                text: $tempName,
                                placeholder: "Enter your name or brand"
                            )

                            ProfileInputField(
                                title: "Follower Count",
                                text: $tempFollowers,
                                placeholder: "Example: 2500",
                                keyboardType: .numberPad
                            )

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Content Niche")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Picker("Content Niche", selection: $tempNiche) {
                                    ForEach(niches, id: \.self) { niche in
                                        Text(niche).tag(niche)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.white.opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Posting Frequency")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                SelectionRow(
                                    options: PostingFrequency.allCases,
                                    selection: $tempFrequency
                                ) { option in
                                    Text(option.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Primary Platform")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                SelectionRow(
                                    options: SocialPlatform.allCases,
                                    selection: $tempPrimaryPlatform
                                ) { platform in
                                    Text(platform.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                }
                            }
                        }
                    }

                    Button {
                        saveProfile()
                    } label: {
                        Text("Save Profile")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            tempName = profileName
            tempFollowers = profileFollowers > 0 ? "\(profileFollowers)" : ""
            tempNiche = profileNiche
            tempFrequency = PostingFrequency(rawValue: profileFrequency) ?? .medium
            tempPrimaryPlatform = SocialPlatform(rawValue: profilePrimaryPlatform) ?? .instagram
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveProfile() {
        let cleanedFollowers = Int(tempFollowers) ?? 1000
        profileName = tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Creator" : tempName
        profileFollowers = max(cleanedFollowers, 0)
        profileNiche = tempNiche
        profileFrequency = tempFrequency.rawValue
        profilePrimaryPlatform = tempPrimaryPlatform.rawValue
        hasCompletedProfile = true
        dismiss()
    }
}

struct ProfileInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .foregroundStyle(.white.opacity(0.45))
            )
            .keyboardType(keyboardType)
            .padding()
            .background(.white.opacity(0.10))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.14), lineWidth: 1)
            }
        }
    }
}

// MARK: - Main Input View

struct PostInputView: View {
    @AppStorage("profileName") private var profileName = "Creator"
    @AppStorage("profileFollowers") private var profileFollowers = 1000
    @AppStorage("profileNiche") private var profileNiche = "Lifestyle"
    @AppStorage("profileFrequency") private var profileFrequency = PostingFrequency.medium.rawValue
    @AppStorage("profilePrimaryPlatform") private var profilePrimaryPlatform = SocialPlatform.instagram.rawValue

    @State private var caption = ""
    @State private var selectedPlatform = SocialPlatform.instagram
    @State private var selectedPostType = PostType.reel
    @State private var selectedTime = PostingTime.evening
    @State private var result: PredictionResult?
    @State private var showResults = false

    var body: some View {
        ZStack {
            BackgroundGradientView()

            ScrollView {
                VStack(spacing: 22) {
                    headerSection
                    inputCard
                    actionButtons
                }
                .padding()
                .padding(.bottom, 24)
            }
        }
        .navigationDestination(isPresented: $showResults) {
            if let result {
                ResultsView(
                    result: result,
                    platform: selectedPlatform,
                    postType: selectedPostType,
                    postingTime: selectedTime,
                    caption: caption
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome, \(profileName)!")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var inputCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Caption")
                        .font(.headline)
                        .foregroundStyle(.white)

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.white.opacity(0.10))

                        TextEditor(text: $caption)
                            .scrollContentBackground(.hidden)
                            .background(.clear)
                            .frame(height: 130)
                            .foregroundStyle(.white)
                            .padding(10)

                        if caption.isEmpty {
                            Text("Write your caption here...")
                                .foregroundStyle(.white.opacity(0.45))
                                .padding(.top, 18)
                                .padding(.leading, 16)
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(0.14), lineWidth: 1)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Label("Platform", systemImage: selectedPlatform.icon)
                        .font(.headline)
                        .foregroundStyle(.white)

                    SelectionRow(options: SocialPlatform.allCases, selection: $selectedPlatform) { platform in
                        Text(platform.rawValue)
                            .font(.subheadline.weight(.semibold))
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Label("Post Type", systemImage: selectedPostType.icon)
                        .font(.headline)
                        .foregroundStyle(.white)

                    SelectionRow(options: PostType.allCases, selection: $selectedPostType) { type in
                        Text(type.rawValue)
                            .font(.subheadline.weight(.semibold))
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Label("Posting Time", systemImage: selectedTime.icon)
                        .font(.headline)
                        .foregroundStyle(.white)

                    SelectionRow(options: PostingTime.allCases, selection: $selectedTime) { time in
                        Text(time.rawValue)
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {
            Button {
                let finalResult = PredictionEngine.makePrediction(
                    caption: caption,
                    platform: selectedPlatform,
                    postType: selectedPostType,
                    postingTime: selectedTime,
                    followerCount: profileFollowers,
                    niche: profileNiche,
                    postingFrequency: PostingFrequency(rawValue: profileFrequency) ?? .medium,
                    primaryPlatform: SocialPlatform(rawValue: profilePrimaryPlatform) ?? .instagram
                )
                result = finalResult
                showResults = true
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Predict Performance")
                }
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            Button {
                caption = ""
                selectedPlatform = .instagram
                selectedPostType = .reel
                selectedTime = .evening
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            NavigationLink {
                ProfileSetupView()
            } label: {
                Text("Edit Profile")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .padding(.top, 2)
            }
        }
    }
}

// MARK: - Results View

struct ResultsView: View {
    let result: PredictionResult
    let platform: SocialPlatform
    let postType: PostType
    let postingTime: PostingTime
    let caption: String

    var body: some View {
        ZStack {
            BackgroundGradientView()

            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 10) {
                        Text("Prediction Results")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Here is your projected post performance based on your profile and content setup.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.84))
                    }
                    .padding(.top, 24)

                    scoreCard
                    statsRow
                    suggestionsCard
                    contentBreakdownCard
                }
                .padding()
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var scoreCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.12), lineWidth: 16)
                        .frame(width: 170, height: 170)

                    Circle()
                        .trim(from: 0, to: CGFloat(result.score) / 100)
                        .stroke(.white, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 170, height: 170)

                    Text("\(result.score)")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Text("Engagement Score")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.82))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            EqualMetricCard(icon: "heart.fill", title: "Estimated Likes", value: "\(result.estimatedLikes)")
            EqualMetricCard(icon: "bubble.left.and.bubble.right.fill", title: "Estimated Comments", value: "\(result.estimatedComments)")
        }
    }

    private var suggestionsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Label("Strategy Suggestions", systemImage: "lightbulb.max.fill")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                ForEach(Array(result.suggestions.prefix(3)).indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.subheadline.bold())
                            .foregroundStyle(.black)
                            .frame(width: 30, height: 30)
                            .background(.white)
                            .clipShape(Circle())

                        Text(result.suggestions[index])
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.92))
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    private var contentBreakdownCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Post Breakdown", systemImage: "square.grid.2x2.fill")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                DetailRow(title: "Platform", value: platform.rawValue)
                DetailRow(title: "Post Type", value: postType.rawValue)
                DetailRow(title: "Posting Time", value: postingTime.rawValue)
                DetailRow(title: "Caption Length", value: "\(caption.trimmingCharacters(in: .whitespacesAndNewlines).count) characters")
            }
        }
    }
}

// MARK: - Prediction Engine

struct PredictionEngine {
    static func makePrediction(
        caption: String,
        platform: SocialPlatform,
        postType: PostType,
        postingTime: PostingTime,
        followerCount: Int,
        niche: String,
        postingFrequency: PostingFrequency,
        primaryPlatform: SocialPlatform
    ) -> PredictionResult {

        let trimmedCaption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        let captionLength = trimmedCaption.count

        var score = 50

        switch platform {
        case .instagram: score += 8
        case .tiktok: score += 10
        case .facebook: score += 4
        }

        switch postType {
        case .image: score += 5
        case .carousel: score += 9
        case .reel: score += 13
        }

        switch postingTime {
        case .morning: score += 4
        case .afternoon: score += 7
        case .evening: score += 11
        }

        if captionLength == 0 {
            score -= 10
        } else if captionLength < 40 {
            score += 2
        } else if captionLength <= 120 {
            score += 8
        } else if captionLength <= 220 {
            score += 10
        } else {
            score += 5
        }

        if followerCount < 500 {
            score += 2
        } else if followerCount < 2000 {
            score += 5
        } else if followerCount < 10000 {
            score += 8
        } else {
            score += 10
        }

        switch postingFrequency {
        case .low: score += 2
        case .medium: score += 6
        case .high: score += 8
        }

        if platform == primaryPlatform {
            score += 4
        }

        if niche == "Sports" && postType == .reel { score += 3 }
        if niche == "Food" && platform == .instagram { score += 3 }
        if niche == "Tech" && platform == .facebook { score += 1 }
        if niche == "Fashion" && postType == .carousel { score += 2 }
        if niche == "Education" && captionLength > 80 { score += 2 }

        score = min(max(score, 0), 100)

        let engagementRate = Double(score) / 100.0

        let baseLikeMultiplier: Double
        switch platform {
        case .instagram: baseLikeMultiplier = 0.07
        case .tiktok: baseLikeMultiplier = 0.09
        case .facebook: baseLikeMultiplier = 0.05
        }

        let postTypeBoost: Double
        switch postType {
        case .image: postTypeBoost = 1.0
        case .carousel: postTypeBoost = 1.15
        case .reel: postTypeBoost = 1.3
        }

        let timeBoost: Double
        switch postingTime {
        case .morning: timeBoost = 0.95
        case .afternoon: timeBoost = 1.02
        case .evening: timeBoost = 1.12
        }

        let estimatedLikes = max(
            Int(Double(followerCount) * baseLikeMultiplier * engagementRate * postTypeBoost * timeBoost),
            5
        )

        let estimatedComments = max(Int(Double(estimatedLikes) * 0.08), 1)

        return PredictionResult(
            score: score,
            estimatedLikes: estimatedLikes,
            estimatedComments: estimatedComments,
            summary: "",
            suggestions: buildSuggestions(
                captionLength: captionLength,
                platform: platform,
                postType: postType,
                postingTime: postingTime,
                score: score
            )
        )
    }

    private static func buildSuggestions(
        captionLength: Int,
        platform: SocialPlatform,
        postType: PostType,
        postingTime: PostingTime,
        score: Int
    ) -> [String] {
        let firstSuggestion: String
        if captionLength < 40 {
            firstSuggestion = "Write a slightly longer caption so the post feels clearer, stronger, and more intentional overall."
        } else if captionLength > 220 {
            firstSuggestion = "Shorten the caption a little so the message feels cleaner, faster, and easier to follow."
        } else {
            firstSuggestion = "Keep this caption length, but strengthen the opening line to grab attention more quickly."
        }

        let secondSuggestion: String
        if platform == .instagram && postType != .reel {
            secondSuggestion = "Try this concept as a Reel too, since video usually performs better on Instagram."
        } else if platform == .tiktok {
            secondSuggestion = "Use a fast visual hook early, because TikTok content performs best with quick momentum."
        } else if platform == .facebook {
            secondSuggestion = "Keep the wording direct and relatable, because Facebook posts often reward clearer messaging."
        } else {
            secondSuggestion = "Match the format to the platform so the content feels more natural there."
        }

        let thirdSuggestion: String
        if postingTime != .evening {
            thirdSuggestion = "Test an evening posting time too and compare results to find your strongest window."
        } else if score < 60 {
            thirdSuggestion = "Keep the timing, but improve the hook and visuals to raise performance further."
        } else {
            thirdSuggestion = "Keep the timing strong and pair it with a sharper hook for better engagement."
        }

        return [firstSuggestion, secondSuggestion, thirdSuggestion]
    }
}

// MARK: - Reusable Views

struct BackgroundGradientView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.10, blue: 0.22),
                Color(red: 0.18, green: 0.12, blue: 0.32),
                Color(red: 0.10, green: 0.24, blue: 0.36)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack {
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
    }
}

struct EqualMetricCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 170, maxHeight: 170)
        .padding(20)
        .background(.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.72))
            Spacer()
            Text(value)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
        }
        .font(.body)
    }
}

struct SelectionRow<Option: Hashable & Identifiable, Content: View>: View {
    let options: [Option]
    @Binding var selection: Option
    let content: (Option) -> Content

    var body: some View {
        HStack(spacing: 10) {
            ForEach(options) { option in
                Button {
                    selection = option
                } label: {
                    content(option)
                        .foregroundStyle(selection == option ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .background(selection == option ? .white : .white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(.white.opacity(selection == option ? 0 : 0.10), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
