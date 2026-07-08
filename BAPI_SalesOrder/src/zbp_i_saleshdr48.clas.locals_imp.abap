CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_salesorder,
             cid                  TYPE abp_behv_cid,
             pid                  TYPE abp_behv_pid,
             order_header_in      TYPE bapisdhd1,
             ORDER_HEADER_INx     TYPE BAPISDHD1x,
             order_items_in       TYPE TABLE OF bapisditm WITH DEFAULT KEY,
             ORDER_ITEMS_INx      TYPE TABLE OF BAPISDITMx WITH DEFAULT KEY,
             order_partners       TYPE TABLE OF bapiparnr WITH DEFAULT KEY,
             order_schedules_in   TYPE TABLE OF bapischdl WITH DEFAULT KEY,
             order_schedules_inx  TYPE TABLE OF BAPISCHDLx WITH DEFAULT KEY,
             order_conditions_in  TYPE TABLE OF bapicond WITH DEFAULT KEY,
             order_conditions_inX TYPE TABLE OF bapicondx WITH DEFAULT KEY,
           END OF ty_salesorder.
    CLASS-DATA : lt_salesorder TYPE TABLE OF ty_salesorder,
                 ls_salesorder TYPE ty_salesorder,
                 salesdocument TYPE bapivbeln-vbeln,
                 return        TYPE TABLE OF bapiret2.
ENDCLASS.

CLASS lhc_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR header RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE header.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE header.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE header.

    METHODS read FOR READ
      IMPORTING keys FOR READ header RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK header.

    METHODS rba_Item FOR READ
      IMPORTING keys_rba FOR READ header\_Item FULL result_requested RESULT result LINK association_links.

    METHODS cba_Item FOR MODIFY
      IMPORTING entities_cba FOR CREATE header\_Item.


ENDCLASS.

CLASS lhc_header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    FIELD-SYMBOLS:
      <fs_header>  TYPE any,
      <fs_headerx> TYPE any.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      DATA: lv_pid TYPE abp_behv_pid.

      TRY.
          lv_pid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.

      APPEND VALUE #(
         %cid      = <ls_entity>-%cid
         %is_draft = <ls_entity>-%is_draft
         %pid      = lv_pid
       ) TO mapped-header.


      CLEAR lcl_buffer=>ls_salesorder.
      lcl_buffer=>ls_salesorder-cid = <ls_entity>-%cid.
      lcl_buffer=>ls_salesorder-pid = lv_pid.
      lcl_buffer=>ls_salesorder-order_header_in = VALUE #(
          doc_type   = <ls_entity>-auart
          sales_org  = <ls_entity>-vkorg
          distr_chan = <ls_entity>-vtweg
          division   = <ls_entity>-spart
      ).

      DATA(lo_hdrdesc) = CAST cl_abap_structdescr(
          cl_abap_typedescr=>describe_by_data( lcl_buffer=>ls_salesorder-order_header_in )
      ).

      LOOP AT lo_hdrdesc->components INTO DATA(ls_hdrcomp).
        ASSIGN COMPONENT ls_hdrcomp-name OF STRUCTURE lcl_buffer=>ls_salesorder-order_header_in TO <fs_header>.
        ASSIGN COMPONENT ls_hdrcomp-name OF STRUCTURE lcl_buffer=>ls_salesorder-order_header_inx TO <fs_headerx>.
        IF <fs_header> IS ASSIGNED AND <fs_headerx> IS ASSIGNED AND <fs_header> IS NOT INITIAL.
          <fs_headerx> = 'X'.
        ENDIF.
      ENDLOOP.
      lcl_buffer=>ls_salesorder-order_partners = VALUE #(
          ( partn_role = 'AG' partn_numb = <ls_entity>-kunnr )
          ( partn_role = 'WE' partn_numb = <ls_entity>-kunnr )
      ).

      APPEND lcl_buffer=>ls_salesorder TO lcl_buffer=>lt_salesorder.

    ENDLOOP.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Item.
  ENDMETHOD.

  METHOD cba_Item.
    FIELD-SYMBOLS:
      <fs_item>  TYPE any,
      <fs_itemx> TYPE any.

    DATA: lv_itemo TYPE posnr_va,
          ls_itemx TYPE bapisditmx.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<ls_cba>).

      READ TABLE lcl_buffer=>lt_salesorder ASSIGNING FIELD-SYMBOL(<ls_salesorder_buf>)
        WITH KEY cid = <ls_cba>-%cid_ref.

      IF sy-subrc <> 0.
        APPEND VALUE #( cid = <ls_cba>-%cid_ref ) TO lcl_buffer=>lt_salesorder ASSIGNING <ls_salesorder_buf>.
      ENDIF.

      lv_itemo = lines( <ls_salesorder_buf>-order_items_in ) * 10.

      LOOP AT <ls_cba>-%target ASSIGNING FIELD-SYMBOL(<ls_target>).
        IF <ls_target> IS NOT INITIAL.
          lv_itemo += 10.

          APPEND VALUE #(
            %cid      = <ls_target>-%cid
            %is_draft = <ls_target>-%is_draft
          ) TO mapped-item.

          APPEND VALUE #(
              itm_number = lv_itemo
              material   = <ls_target>-matnr
              target_qty = <ls_target>-zmeng
              target_qu  = <ls_target>-zieme
              plant      = <ls_target>-werks
          ) TO <ls_salesorder_buf>-order_items_in.

          CLEAR ls_itemx.
          ls_itemx-itm_number = lv_itemo.

          DATA(lo_itemxdesc) = CAST cl_abap_structdescr(
            cl_abap_typedescr=>describe_by_data( VALUE bapisditm( material = <ls_target>-matnr ) )
          ).

          LOOP AT lo_itemxdesc->components INTO DATA(ls_itemcomp).
            READ TABLE <ls_salesorder_buf>-order_items_in ASSIGNING FIELD-SYMBOL(<ls_current_item>)
            INDEX lines( <ls_salesorder_buf>-order_items_in ).
            ASSIGN COMPONENT ls_itemcomp-name OF STRUCTURE <ls_current_item> TO <fs_item>.
            ASSIGN COMPONENT ls_itemcomp-name OF STRUCTURE ls_itemx TO <fs_itemx>.

            IF <fs_item> IS ASSIGNED AND <fs_itemx> IS ASSIGNED AND <fs_item> IS NOT INITIAL.
              <fs_itemx> = 'X'.
            ENDIF.
          ENDLOOP.

          APPEND ls_itemx TO <ls_salesorder_buf>-order_items_inx.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE item.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE item.

    METHODS read FOR READ
      IMPORTING keys FOR READ item RESULT result.

    METHODS rba_Header FOR READ
      IMPORTING keys_rba FOR READ item\_Header FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Header.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_SALESHDR48 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_SALESHDR48 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: lcl_buffer=>lt_salesorder[].
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

  METHOD adjust_numbers.
    DATA: lv_msg TYPE string.
    IF lcl_buffer=>lt_salesorder IS NOT INITIAL.
      LOOP AT lcl_buffer=>lt_salesorder ASSIGNING FIELD-SYMBOL(<ls_salesorder>).
        CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
          EXPORTING
            order_header_in  = <ls_salesorder>-order_header_in
            order_header_inx = <ls_salesorder>-order_header_inx
          IMPORTING
            salesdocument    = lcl_buffer=>salesdocument
          TABLES
            return           = lcl_buffer=>return
            order_items_in   = <ls_salesorder>-order_items_in
            order_items_inx  = <ls_salesorder>-order_items_inx
            order_partners   = <ls_salesorder>-order_partners.

        IF lcl_buffer=>salesdocument IS NOT INITIAL.

          READ TABLE lcl_buffer=>return WITH KEY id = 'V1' number = '311' ASSIGNING FIELD-SYMBOL(<ls_return>)..
          APPEND VALUE #( %msg = new_message(
                                   id       = <ls_return>-id
                                   number   = <ls_return>-number
                                   severity = if_abap_behv_message=>severity-success
                                   v1       = <ls_return>-message
                                 ) ) TO reported-header.

          APPEND VALUE #(   %pid = <ls_salesorder>-pid
                            vbeln = lcl_buffer=>salesdocument
                            ) TO mapped-header.
          LOOP AT <ls_salesorder>-order_items_in ASSIGNING FIELD-SYMBOL(<ls_item>).
            APPEND VALUE #( %pid = <ls_salesorder>-pid
                            vbeln = lcl_buffer=>salesdocument
                            posnr = <ls_item>-itm_number
                             ) TO mapped-item.
          ENDLOOP.
        ELSE.
          LOOP AT lcl_buffer=>return ASSIGNING FIELD-SYMBOL(<ls_returne>).
            APPEND VALUE #( %msg = new_message(
                                     id       = <ls_returne>-id
                                     number   = <ls_returne>-number
                                     severity = if_abap_behv_message=>severity-information
                                     v1       = <ls_returne>-message
                                   ) ) TO reported-header.
          ENDLOOP.
          APPEND VALUE #(   %pid = <ls_salesorder>-pid
                            vbeln = lcl_buffer=>salesdocument
                            ) TO mapped-header.
          LOOP AT <ls_salesorder>-order_items_in ASSIGNING FIELD-SYMBOL(<ls_iteme>).
            APPEND VALUE #( %pid = <ls_salesorder>-pid
                            vbeln = lcl_buffer=>salesdocument
                            posnr = <ls_iteme>-itm_number
                             ) TO mapped-item.
          ENDLOOP.

        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
