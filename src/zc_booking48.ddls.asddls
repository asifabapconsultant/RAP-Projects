@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'booking projection view'
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity zc_booking48
  as projection on zi_booking48
{
  key TravelId,
  key BookingId,
      BookingDate,
      @Search.defaultSearchElement: true
      CustomerId,
      CustomerName,
      @Search.defaultSearchElement: true
      CarrierId,
      CarrirerName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      _travel    : redirected to parent zc_travel48,
      _carrierid,
      _connection,
      _Booksuppl : redirected to composition child zc_booksuppl48
}
