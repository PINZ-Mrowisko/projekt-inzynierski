import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/user/market_repo.dart';
import 'package:the_basics/features/auth/models/market_model.dart';

class MarketController extends GetxController {
  static MarketController get instance => Get.find();

  // create an observable employee model
  // this will allow us to save the current emp data and not pull it from FB each time
  Rx<MarketModel> market = MarketModel.empty().obs;
  final marketRepo = Get.put(MarketRepo());

  @override
  void onInit() {
    super.onInit();
    fetchCurrentMarket();
  }

  Future<void> fetchCurrentMarket() async {
    try {
      //final market = await marketRepo.fetchCurrentMarketDetails();
      // assign the curr user to the observable var
      //this.market(market);
    } catch (e) {
      market(MarketModel.empty());
    }
  }

}