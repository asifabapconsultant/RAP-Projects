CLASS zlcl_buffer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: gt_entities TYPE TABLE FOR CREATE zi_saleshdr48,
           gt_mapping  TYPE RESPONSE FOR MAPPED EARLY zi_saleshdr48,
           gt_failed   TYPE RESPONSE FOR FAILED EARLY zi_saleshdr48,
           gt_reported TYPE RESPONSE FOR REPORTED EARLY zi_saleshdr48,
           gt_mapped   TYPE RESPONSE FOR MAPPED EARLY zi_saleshdr48.

    TYPES: BEGIN OF ty_so,
             order_header_in      TYPE bapisdhd1,
             order_header_inx     TYPE bapisdhd1x,
             order_item_in        TYPE STANDARD TABLE OF bapisditm WITH DEFAULT KEY,
             order_item_inx       TYPE STANDARD TABLE OF bapisditmx WITH DEFAULT KEY,
             order_partners       TYPE STANDARD TABLE OF bapiparnr WITH DEFAULT KEY,
             orders_schedules_in  TYPE STANDARD TABLE OF bapischdl WITH DEFAULT KEY,
             orders_schedules_inx TYPE STANDARD TABLE OF bapischdlx WITH DEFAULT KEY,
           END OF ty_so.


    CLASS-METHODS: createheader
      IMPORTING
        entities TYPE gt_entities
      EXPORTING
        failed   TYPE gt_failed
        reported TYPE gt_reported
      CHANGING
        mapped   TYPE gt_mapped.
    CLASS-DATA: gt_so TYPE TABLE OF ty_so.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zlcl_buffer IMPLEMENTATION.
  METHOD createheader.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      IF gt_so IS  INITIAL.
        APPEND INITIAL LINE TO gt_so ASSIGNING FIELD-SYMBOL(<ls_so>).
        <ls_so>-order_header_in = CORRESPONDING #( <ls_entity> ).
        <ls_so>-order_partners = VALUE #( ( partn_role = 'SH' partn_numb = <ls_entity>-kunnr )
                                          ( partn_role = 'SP' partn_numb = <ls_entity>-kunnr ) ).
        <ls_so>-order_header_inx-doc_type  = abap_true.
        <ls_so>-order_header_inx-sales_org  = abap_true.
        <ls_so>-order_header_inx-distr_chan  = abap_true.
        <ls_so>-order_header_inx-division  = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
