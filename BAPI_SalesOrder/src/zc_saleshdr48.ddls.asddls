@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header'
@Metadata.allowExtensions: true
define root view entity zc_saleshdr48
  provider contract transactional_query
  as projection on zi_saleshdr48

{
  key vbeln,
      auart,
      vkorg,
      vtweg,
      spart,
      kunnr,
      ernam,
      erdat,
      erzet,
      aedat,
      Doctypetext,
      salesorgtext,
      dctext,
      dtext,
      Customername,
      /* Associations */
      _item : redirected to composition child zc_salesitem48
}
