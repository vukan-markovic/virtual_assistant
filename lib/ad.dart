import 'package:firebase_admob/firebase_admob.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'credentials.dart';

class Ad {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    nonPersonalizedAds: true,
    childDirected: false,
  );

  Future<int> incrementCounter(String pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt(pref) ?? 0) + 1;
    await prefs.setInt(pref, counter);
    return counter;
  }

  void showAd() {
    FirebaseAdMob.instance.initialize(
      appId: Credentials.admob_app_id,
    );

    RewardedVideoAd.instance.load(
      adUnitId: Credentials.admob_ad_unit_id,
      targetingInfo: targetingInfo,
    );

    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      if (event == RewardedVideoAdEvent.loaded) RewardedVideoAd.instance.show();
    };
  }
}
