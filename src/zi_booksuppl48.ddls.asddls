@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking interface view'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_booksuppl48
  as select from zbookingsup48
  association to parent zi_booking48 as _booking on  $projection.TravelId  = _booking.TravelId
                                                 and $projection.BookingId = _booking.BookingId
  association to zi_travel48 as _travel on $projection.TravelId = _travel.TravelId
  association[0..*] to /dmo/suppl_text as _supplementtext on $projection.SupplementId = _supplementtext.supplement_id


{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
  @ObjectModel.text.element: [ 'Supplimenttext' ]
      supplement_id         as SupplementId,
      @Semantics.text: true
      _supplementtext.description as Supplimenttext,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      _booking,
      _travel,
      _supplementtext
}
