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
    UnityAds.init(
      gameId: AppConstants.unityAdsGameId,
      testMode: kDebugMode,
      onComplete: () {
        print('[AdService] Unity Ads initialized successfully');
        preloadInterstitial();
        preloadRewarded();
      },
      onFailed: (error, message) =>
          print('[AdService] Init failed: $error – $message'),
    );
    _listenConnectivity();
  }

  void _listenConnectivity() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        print('[AdService] Network available – preloading ads');
        preloadInterstitial();
        preloadRewarded();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  void preload(String placementId) {
    print('[AdService] Preloading: $placementId');
    UnityAds.load(
      placementId: placementId,
      onComplete: (id) => print('[AdService] Loaded: $id'),
      onFailed: (id, error, msg) =>
          print('[AdService] Load failed: $id – $error – $msg'),
    );
  }

  void showInterstitial({VoidCallback? onComplete}) {
    final id = AppConstants.unityInterstitialPlacement;
    print('[AdService] showInterstitial called for $id');
    _showInterstitialVideo(id, onComplete);
  }

  void _showInterstitialVideo(String id, VoidCallback? onComplete) {
    UnityAds.showVideoAd(
      placementId: id,
      onStart: (_) => print('[AdService] Interstitial started'),
      onSkipped: (_) {
        print('[AdService] Interstitial skipped');
        onComplete?.call();
      },
      onComplete: (_) {
        print('[AdService] Interstitial completed');
        preloadInterstitial();
        onComplete?.call();
      },
      onFailed: (_, e, m) {
        print('[AdService] Interstitial show failed: $e – $m');
        onComplete?.call();
      },
    );
  }

  void showRewarded({VoidCallback? onRewarded, VoidCallback? onFailed}) {
    final id = AppConstants.unityRewardedPlacement;
    print('[AdService] showRewarded called for $id');
    _showRewardedVideo(id, onRewarded, onFailed);
  }

  void _showRewardedVideo(String id, VoidCallback? onRewarded, VoidCallback? onFailed) {
    UnityAds.showVideoAd(
      placementId: id,
      onStart: (_) => print('[AdService] Rewarded started'),
      onComplete: (_) {
        print('[AdService] Rewarded completed – granting reward');
        preloadRewarded();
        onRewarded?.call();
      },
      onSkipped: (_) {
        print('[AdService] Rewarded skipped');
        onFailed?.call();
      },
      onFailed: (_, e, m) {
        print('[AdService] Rewarded show failed: $e – $m');
        onFailed?.call();
      },
    );
  }

  void preloadInterstitial() => preload(AppConstants.unityInterstitialPlacement);

  void preloadRewarded() => preload(AppConstants.unityRewardedPlacement);
}
