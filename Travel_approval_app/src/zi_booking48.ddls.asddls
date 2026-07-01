@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking suplement interface view'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_booking48
  as select from zbooking48
  composition [0..*] of zi_booksuppl48          as _Booksuppl
  association to parent zi_travel48    as _travel    on $projection.TravelId = _travel.TravelId
  association to /dmo/carrier          as _carrierid on $projection.CarrierId = _carrierid.carrier_id
  association[0..*] to /dmo/connection as _connection on $projection.ConnectionId = _connection.connection_id
{

  key travel_id            as TravelId,
  key booking_id           as BookingId,
      booking_date         as BookingDate,
      @ObjectModel.text.element: [ 'CustomerName' ]
      customer_id          as CustomerId,
      @Semantics.text: true
      _travel.CustomerName as CustomerName,
      @ObjectModel.text.element: [ 'CarrirerName' ]
      carrier_id           as CarrierId,
      @Semantics.text: true
      _carrierid.name      as CarrirerName,
      connection_id        as ConnectionId,
      flight_date          as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price         as FlightPrice,
      currency_code        as CurrencyCode,
      _travel,
      _carrierid,
      _Booksuppl,
      _connection
}
