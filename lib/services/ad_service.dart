import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Singleton ad service. Fresh policy for أشكالي (no prior وقتي pattern to
/// match): interstitials only at chapter-end breakpoints (reviews + final),
/// one banner on the home screen, no rewarded ads shown to children.
class AdService {
  AdService._internal();
  static final AdService instance = AdService._internal();

  // TODO: replace with your real AdMob unit IDs before release.
  // These are Google's public test unit IDs - safe to ship in debug builds
  // but must be swapped before production.
  static const String interstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String bannerUnitId = 'ca-app-pub-3940256099942544/6300978111';

  /// Chapters after which an interstitial may show: the two review
  /// chapters and the final challenge. Core teaching chapters (1,2,3,5,6,7,
  /// 9,10,11,12) never interrupt with an ad.
  static const Set<int> _interstitialBreakpoints = {4, 8, 13};

  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;

  void preloadInterstitial() {
    if (_isLoadingInterstitial || _interstitialAd != null) return;
    _isLoadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoadingInterstitial = false;
        },
      ),
    );
  }

  bool shouldShowInterstitialAfterChapter(int chapterNumber) =>
      _interstitialBreakpoints.contains(chapterNumber);

  /// Shows the interstitial if one is loaded and this chapter is a
  /// breakpoint. Always preloads the next one after showing/dismissing.
  Future<void> maybeShowInterstitial(int chapterNumber) async {
    if (!shouldShowInterstitialAfterChapter(chapterNumber)) return;
    final ad = _interstitialAd;
    if (ad == null) {
      // Not ready this time - don't block the child's flow waiting on it.
      preloadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitial();
      },
    );
    _interstitialAd = null;
    await ad.show();
  }

  /// Banner for the home/chapter-map screen only - never inside an activity.
  BannerAd createHomeBannerAd({required void Function() onLoaded}) {
    final banner = BannerAd(
      adUnitId: bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    banner.load();
    return banner;
  }
}
