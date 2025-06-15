import 'package:equatable/equatable.dart';
import '../../data/models/offer.dart';

abstract class OfferEvent extends Equatable {
  const OfferEvent();

  @override
  List<Object> get props => [];
}

class LoadOffers extends OfferEvent {}

class OffersUpdated extends OfferEvent {
  final List<Offer> offers;

  const OffersUpdated(this.offers);

  @override
  List<Object> get props => [offers];
}
