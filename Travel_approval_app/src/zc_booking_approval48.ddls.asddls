@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'travel booking approval'
@Metadata.allowExtensions: true
define view entity zc_booking_approval48 as projection on zi_booking48
{
    key TravelId,
    key BookingId,
    BookingDate,
    CustomerId,
    CustomerName,
    CarrierId,
    CarrirerName,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    /* Associations */
    _Booksuppl,
    _carrierid,
    _connection,
    _travel : redirected to parent zc_travel_approval48
}
