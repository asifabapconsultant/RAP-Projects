@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel approval'
@Metadata.allowExtensions: true
define root view entity zc_travel_approval48
  provider contract transactional_query
  as projection on zi_travel48
{
  key TravelId,
      AgencyId,
      Agencyname,
      CustomerId,
      CustomerName,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      CurrencyName,
      Description,
      Status,
      Statustext,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _agency,
      _Booking : redirected to composition child zc_booking_approval48,
      _currencytext,
      _customer,
      _statustext
}
