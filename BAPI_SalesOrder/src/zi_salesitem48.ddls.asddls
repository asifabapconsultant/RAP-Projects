@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_salesitem48
  as select from vbap
  association to parent zi_saleshdr48 as _header            on  $projection.vbeln = _header.vbeln
  association to I_MaterialText       as _materialtext      on  _materialtext.Material = $projection.matnr
                                                            and _materialtext.Language = $session.system_language
  association to I_UnitOfMeasureText  as _UnitOfMeasureText on  _UnitOfMeasureText.UnitOfMeasure = $projection.zieme
                                                            and _UnitOfMeasureText.Language      = $session.system_language
  association to I_Plant              as _Plant             on  _Plant.Plant    = $projection.werks
                                                            and _Plant.Language = $session.system_language
{
  key vbeln,
  key posnr,
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'Materialname' ]
      matnr,
      @Semantics.quantity.unitOfMeasure: 'zieme'
      zmeng,
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'UomName' ]
      zieme,
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'PlantName' ]
      werks,
      _materialtext.MaterialName                    as Materialname,
      _UnitOfMeasureText.UnitOfMeasureName as UomName,
      _Plant.PlantName                              as PlantName,
      _header

}
