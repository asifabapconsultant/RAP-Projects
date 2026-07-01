@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zi_travel48
  as select from ztravel48
  composition [1..*] of zi_booking48            as _Booking
  association        to /dmo/agency                    as _agency   on  $projection.AgencyId = _agency.agency_id
  association        to /dmo/customer                  as _customer on  $projection.CustomerId = _customer.customer_id
  association to /DMO/I_Travel_Status_VH as _statustext      on  $projection.Status = _statustext.TravelStatus
  association to I_CurrencyText          as _currencytext    on  $projection.CurrencyCode = _currencytext.Currency
                                                                    and _currencytext.Language   = $session.system_language
{
  key travel_id                  as TravelId,
      @ObjectModel.text.element: [ 'Agencyname' ]
      agency_id                  as AgencyId,
      @Semantics.text: true
      _agency.name               as Agencyname,
      @ObjectModel.text.element: [ 'CustomerName' ]
      customer_id                as CustomerId,
      @Semantics.text: true
      _customer.last_name        as CustomerName,
      begin_date                 as BeginDate,
      end_date                   as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee                as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price                as TotalPrice,
      @ObjectModel.text.element: [ 'CurrencyName' ]
      currency_code              as CurrencyCode,
      _currencytext.CurrencyName as CurrencyName,
      description                as Description,
      @ObjectModel.text.element: [ 'Statustext' ]
      status                     as Status,
      @Semantics.text: true
      _statustext._Text.Text as Statustext,
      createdby                  as Createdby,
      createdat                  as Createdat,
      lastchangedby              as Lastchangedby,
      lastchangedat              as Lastchangedat,
      _Booking,
      _agency,
      _customer,
      _statustext,
      _currencytext
}
