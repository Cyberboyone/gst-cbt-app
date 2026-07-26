import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../config/constants.dart';
import 'dart:async';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  bool _initFailed = false;
  StreamSubscription? _connectivitySubscription;
  Timer? _bannerRetryTimer;

  bool _interstitialReady = false;
  bool _rewardedReady = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('[AdService] Initializing with gameId: ${AppConstants.unityAdsGameId}');
    await UnityAds.init(
      gameId: AppConstants.unityAdsGameId,
      testMode: kDebugMode,
      onComplete: () {
        debugPrint('[AdService] Unity Ads initialized successfully');
        _preloadAll();
      },
      onFailed: (error, message) {
        debugPrint('[AdService] Init failed: $error - $message');
        _initFailed = true;
      },
    );
    _listenConnectivity();
    _startPeriodicPreload();
  }

  void _preloadAll() {
    preloadInterstitial();
    preloadRewarded();
    preloadBanner();
  }

  void _listenConnectivity() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        debugPrint('[AdService] Network available - preloading ads');
        _preloadAll();
      }
    });
  }

  void _startPeriodicPreload() {
    _bannerRetryTimer?.cancel();
    _bannerRetryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_initFailed) {
        preloadBanner();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _bannerRetryTimer?.cancel();
  }

  void preload(String placementId) {
    if (_initFailed) {
      debugPrint('[AdService] Skipping preload - init failed');
      return;
    }
    debugPrint('[AdService] Preloading: $placementId');
    UnityAds.load(
      placementId: placementId,
      onComplete: (id) {
        debugPrint('[AdService] Loaded: $id');
        if (id == AppConstants.unityInterstitialPlacement) _interstitialReady = true;
        if (id == AppConstants.unityRewardedPlacement) _rewardedReady = true;
      },
      onFailed: (id, error, msg) {
        debugPrint('[AdService] Load failed: $id - $error - $msg');
        if (id == AppConstants.unityBannerPlacement) {
          Timer(const Duration(seconds: 5), () => preloadBanner());
        }
      },
    );
  }

  /// Show interstitial only if preloaded and ready, otherwise skip immediately
  void showInterstitial({VoidCallback? onComplete}) {
    final id = AppConstants.unityInterstitialPlacement;
    debugPrint('[AdService] showInterstitial called for $id (ready: $_interstitialReady)');

    bool callbackFired = false;
    void fireCallback() {
      if (!callbackFired) {
        callbackFired = true;
        onComplete?.call();
      }
    }

    // If not ready, skip immediately without showing
    if (!_interstitialReady) {
      debugPrint('[AdService] Interstitial not ready - skipping');
      Future.microtask(() => fireCallback());
      return;
    }

    // Safety timeout
    Timer(const Duration(seconds: 5), () {
      if (!callbackFired) {
        debugPrint('[AdService] Interstitial timeout - skipping');
        fireCallback();
      }
    });

    _interstitialReady = false;

    UnityAds.showVideoAd(
      placementId: id,
      onStart: (_) => debugPrint('[AdService] Interstitial started'),
      onSkipped: (_) {
        debugPrint('[AdService] Interstitial skipped');
        fireCallback();
      },
      onComplete: (_) {
        debugPrint('[AdService] Interstitial completed');
        preloadInterstitial();
        fireCallback();
      },
      onFailed: (_, e, m) {
        debugPrint('[AdService] Interstitial show failed: $e - $m');
        fireCallback();
      },
    );
  }

  /// Show rewarded only if preloaded and ready, otherwise fail immediately
  void showRewarded({VoidCallback? onRewarded, VoidCallback? onFailed}) {
    final id = AppConstants.unityRewardedPlacement;
    debugPrint('[AdService] showRewarded called for $id (ready: $_rewardedReady)');

    bool callbackFired = false;
    void fireReward() {
      if (!callbackFired) {
        callbackFired = true;
        onRewarded?.call();
      }
    }

    void fireFail() {
      if (!callbackFired) {
        callbackFired = true;
        onFailed?.call();
      }
    }

    // If not ready, fail immediately
    if (!_rewardedReady) {
      debugPrint('[AdService] Rewarded not ready - skipping');
      Future.microtask(() => fireFail());
      return;
    }

    // Safety timeout
    Timer(const Duration(seconds: 5), () {
      if (!callbackFired) {
        debugPrint('[AdService] Rewarded timeout - skipping');
        fireFail();
      }
    });

    _rewardedReady = false;

    UnityAds.showVideoAd(
      placementId: id,
      onStart: (_) => debugPrint('[AdService] Rewarded started'),
      onComplete: (_) {
        debugPrint('[AdService] Rewarded completed - granting reward');
        preloadRewarded();
        fireReward();
      },
      onSkipped: (_) {
        debugPrint('[AdService] Rewarded skipped');
        fireFail();
      },
      onFailed: (_, e, m) {
        debugPrint('[AdService] Rewarded show failed: $e - $m');
        fireFail();
      },
    );
  }

  void preloadInterstitial() => preload(AppConstants.unityInterstitialPlacement);

  void preloadRewarded() => preload(AppConstants.unityRewardedPlacement);

  void preloadBanner() => preload(AppConstants.unityBannerPlacement);
}
