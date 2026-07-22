import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../config/constants.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  Stream<ConnectivityResult>? _connectivitySubscription;

  void init() {
    if (_initialized) return;
    _initialized = true;
    UnityAds.init(
      gameId: AppConstants.unityAdsGameId,
      testMode: kDebugMode,
      onComplete: () => debugPrint('[AdService] Unity Ads ready'),
      onFailed: (error, message) =>
          debugPrint('[AdService] Init failed: $error – $message'),
    );
    _listenConnectivity();
  }

  void _listenConnectivity() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        debugPrint('[AdService] Network available – preloading ads');
        preloadInterstitial();
        preloadRewarded();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Pre-load an interstitial or rewarded ad.
  void preload(String placementId) {
    UnityAds.load(
      placementId: placementId,
      onComplete: (id) => debugPrint('[AdService] Loaded: $id'),
      onFailed: (id, error, msg) =>
          debugPrint('[AdService] Load failed: $id – $error – $msg'),
    );
  }

  /// Show an interstitial ad (fire-and-forget).
  void showInterstitial({VoidCallback? onComplete}) {
    UnityAds.showVideoAd(
      placementId: AppConstants.unityInterstitialPlacement,
      onStart: (_) {},
      onSkipped: (_) => onComplete?.call(),
      onComplete: (_) => onComplete?.call(),
      onFailed: (_, e, m) {
        debugPrint('[AdService] Interstitial failed: $e – $m');
        onComplete?.call();
      },
    );
  }

  /// Show a rewarded ad. [onRewarded] fires only when the user watched fully.
  void showRewarded({VoidCallback? onRewarded, VoidCallback? onFailed}) {
    UnityAds.showVideoAd(
      placementId: AppConstants.unityRewardedPlacement,
      onStart: (_) {},
      onComplete: (_) {
        debugPrint('[AdService] Rewarded completed – granting reward');
        onRewarded?.call();
      },
      onSkipped: (_) {
        debugPrint('[AdService] Rewarded skipped');
        onFailed?.call();
      },
      onFailed: (_, e, m) {
        debugPrint('[AdService] Rewarded failed: $e – $m');
        onFailed?.call();
      },
    );
  }

  /// Pre-load the next interstitial (call after app startup / after showing one).
  void preloadInterstitial() => preload(AppConstants.unityInterstitialPlacement);

  /// Pre-load the next rewarded (call after app startup / after showing one).
  void preloadRewarded() => preload(AppConstants.unityRewardedPlacement);
}
