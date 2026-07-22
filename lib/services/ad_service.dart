import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../config/constants.dart';
import 'dart:async';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  void init() {
    if (_initialized) return;
    _initialized = true;
    debugPrint('[AdService] Initializing with gameId: ${AppConstants.unityAdsGameId}');
    UnityAds.init(
      gameId: AppConstants.unityAdsGameId,
      testMode: kDebugMode,
      onComplete: () {
        debugPrint('[AdService] Unity Ads initialized successfully');
        preloadInterstitial();
        preloadRewarded();
      },
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

  void preload(String placementId) {
    debugPrint('[AdService] Preloading: $placementId');
    UnityAds.load(
      placementId: placementId,
      onComplete: (id) => debugPrint('[AdService] Loaded: $id'),
      onFailed: (id, error, msg) =>
          debugPrint('[AdService] Load failed: $id – $error – $msg'),
    );
  }

  void showInterstitial({VoidCallback? onComplete}) {
    final id = AppConstants.unityInterstitialPlacement;
    debugPrint('[AdService] showInterstitial called for $id');
    preloadInterstitial();
    _showInterstitialVideo(id, onComplete);
  }

  void _showInterstitialVideo(String id, VoidCallback? onComplete) {
    UnityAds.showVideoAd(
      placementId: id,
      onStart: (_) => debugPrint('[AdService] Interstitial started'),
      onSkipped: (_) {
        debugPrint('[AdService] Interstitial skipped');
        onComplete?.call();
      },
      onComplete: (_) {
        debugPrint('[AdService] Interstitial completed');
        preloadInterstitial();
        onComplete?.call();
      },
      onFailed: (_, e, m) {
        debugPrint('[AdService] Interstitial show failed: $e – $m');
        onComplete?.call();
      },
    );
  }

  void showRewarded({VoidCallback? onRewarded, VoidCallback? onFailed}) {
    final id = AppConstants.unityRewardedPlacement;
    debugPrint('[AdService] showRewarded called for $id');
    preloadRewarded();
    _showRewardedVideo(id, onRewarded, onFailed);
  }

  void _showRewardedVideo(String id, VoidCallback? onRewarded, VoidCallback? onFailed) {
    UnityAds.showVideoAd(
      placementId: id,
      onStart: (_) => debugPrint('[AdService] Rewarded started'),
      onComplete: (_) {
        debugPrint('[AdService] Rewarded completed – granting reward');
        preloadRewarded();
        onRewarded?.call();
      },
      onSkipped: (_) {
        debugPrint('[AdService] Rewarded skipped');
        onFailed?.call();
      },
      onFailed: (_, e, m) {
        debugPrint('[AdService] Rewarded show failed: $e – $m');
        onFailed?.call();
      },
    );
  }

  void preloadInterstitial() => preload(AppConstants.unityInterstitialPlacement);

  void preloadRewarded() => preload(AppConstants.unityRewardedPlacement);
}
