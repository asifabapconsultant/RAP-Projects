@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'booking projection view'
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity zc_booksuppl48
  as projection on zi_booksuppl48
{

  key TravelId,
  key BookingId,

  key BookingSupplementId,
      @Search.defaultSearchElement: true
      SupplementId,
      Supplimenttext,
      Price,
      CurrencyCode,
      _booking : redirected to parent zc_booking48,
      _travel  : redirected to zc_travel48,
      _supplementtext
}
