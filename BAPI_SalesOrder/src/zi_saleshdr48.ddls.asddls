@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zi_saleshdr48
  as select from vbak
  composition [1..*] of zi_salesitem48 as _item
  association to tvakt                 as _doctype      on  _doctype.auart = $projection.auart
                                                        and _doctype.spras = $session.system_language
  association to tvkot                 as _Salesorgtext on  _Salesorgtext.vkorg = $projection.vkorg
                                                        and _Salesorgtext.spras = $session.system_language
  association to tvtwt                 as _dctext       on  _dctext.vtweg = $projection.vtweg
                                                        and _dctext.spras = $session.system_language
  association to tspat                 as _dtext        on  _dtext.spart = $projection.spart
                                                        and _dtext.spras = $session.system_language
  association to I_Customer            as _Customertext on  _Customertext.Customer = $projection.kunnr

{
  key vbeln,
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'Doctypetext' ]
      auart,
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'salesorgtext' ]
      vkorg,
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'dctext' ]
      vtweg,
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'dtext' ]
      spart,
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: [ 'Customername' ]
      kunnr,
      ernam,
      erdat,
      erzet,
      aedat,
      _doctype.bezei             as Doctypetext,
      _Salesorgtext.vtext        as salesorgtext,
      _dtext.vtext               as dtext,
      _dctext.vtext              as dctext,
      _Customertext.CustomerName as Customername,
      _item
}
