import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/offer_repository.dart';
import 'offer_event.dart';
import 'offer_state.dart';

class OfferBloc extends Bloc<OfferEvent, OfferState> {
  final OfferRepository _offerRepository;
  StreamSubscription? _offerSubscription;

  OfferBloc({required OfferRepository offerRepository})
      : _offerRepository = offerRepository,
        super(OfferInitial()) {
    on<LoadOffers>(_onLoadOffers);
    on<OffersUpdated>(_onOffersUpdated);
  }

  void _onLoadOffers(LoadOffers event, Emitter<OfferState> emit) {
    _offerSubscription?.cancel();
    _offerSubscription = _offerRepository.getOffers().listen(
      (offers) {
        add(OffersUpdated(offers));
      },
    );
  }

  void _onOffersUpdated(OffersUpdated event, Emitter<OfferState> emit) {
    emit(OfferLoaded(offers: event.offers));
  }

  @override
  Future<void> close() {
    _offerSubscription?.cancel();
    return super.close();
  }
}
