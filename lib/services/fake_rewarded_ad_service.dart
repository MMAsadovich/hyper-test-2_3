import 'rewarded_ad_service.dart';

class FakeRewardedAdService implements RewardedAdService {
  @override
  Future<bool> showRewarded() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return true;
  }
}
