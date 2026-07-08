@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item'
@Metadata.allowExtensions: true
define view entity zc_salesitem48
  as projection on zi_salesitem48
{
  key vbeln,
  key posnr,
      matnr,
      @Semantics.quantity.unitOfMeasure: 'zieme'
      zmeng,
      zieme,
      werks,
      Materialname,
      UomName,
      PlantName,
      /* Associations */
      _header : redirected to parent zc_saleshdr48

}
