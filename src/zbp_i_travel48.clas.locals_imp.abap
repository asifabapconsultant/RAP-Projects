CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE Travel\_Booking.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    TRY.
        cl_numberrange_runtime=>number_get(
        EXPORTING
        nr_range_nr = '01'
        object = '/DMO/TRV_M'
        quantity = CONV #( lines( entities ) )
        IMPORTING
        number = DATA(lv_latest_number)
        returncode = DATA(returncode)
        returned_quantity = DATA(lv_qty)
         ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lv_error).

        LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entiy>).
          APPEND VALUE #(
          %cid = <ls_entiy>-%cid
          %key = <ls_entiy>-%key
           ) TO failed-travel.

          APPEND VALUE #(
        %cid = <ls_entiy>-%cid
        %key = <ls_entiy>-%key
        %msg = lv_error
         ) TO reported-travel.

        ENDLOOP.

    ENDTRY.

    ASSERT lv_qty =  lines( entities ).
    DATA(lv_num) = lv_latest_number - lv_qty.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      lv_num = lv_num + 1.
      APPEND VALUE #( %cid = <ls_entity>-%cid
                      travelid = lv_num
       ) TO mapped-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.
    DATA: lv_max_booking TYPE /dmo/booking_id.

    READ ENTITIES OF zi_travel48 IN LOCAL MODE
    ENTITY Travel BY \_Booking
    FROM CORRESPONDING #( entities )
    LINK DATA(lt_link).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>)
                                GROUP BY <ls_entity>-TravelId.
      lv_max_booking = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' )
        FOR ls_link IN lt_link USING KEY entity WHERE ( source-TravelId = <ls_entity>-TravelId )
        NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_link-target-BookingId
        THEN ls_link-target-BookingId
        ELSE lv_max ) ).

      lv_max_booking = REDUCE #( INIT lv_max = lv_max_booking
          FOR ls_entity IN entities USING KEY entity WHERE ( TravelId = <ls_entity>-TravelId )
          FOR ls_booking IN ls_entity-%target
          NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_booking-BookingId
          THEN ls_booking-BookingId
          ELSE lv_max ) ).


      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>) USING KEY entity WHERE TravelId = <ls_entity>-TravelId.
        LOOP AT <ls_entities>-%target ASSIGNING FIELD-SYMBOL(<ls_target>).
          APPEND CORRESPONDING #( <ls_target> ) TO mapped-booking ASSIGNING FIELD-SYMBOL(<ls_map_booking>).
          IF <ls_target>-BookingId IS INITIAL.
            lv_max_booking += 10.
            <ls_map_booking>-BookingId = lv_max_booking.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS earlynumbering_cba_Booksuppl FOR NUMBERING
      IMPORTING entities FOR CREATE Booking\_Booksuppl.
    METHODS AcceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~AcceptTravel RESULT result.

    METHODS copyTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~CopyTravel.

    METHODS RejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~RejectTravel RESULT result.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD earlynumbering_cba_Booksuppl.

    DATA: max_booking_supp_id TYPE /dmo/booking_supplement_id.

    READ ENTITIES OF zi_travel48 IN LOCAL MODE
    ENTITY Booking BY \_Booksuppl
    FROM CORRESPONDING #( entities )
    LINK DATA(booking_bookingsuppls).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>) GROUP BY <ls_entities>-%tky.

      max_booking_supp_id = REDUCE #( INIT max = CONV /dmo/supplement_id( '0' )
      FOR booking IN booking_bookingsuppls USING KEY entity
      WHERE ( source-TravelId = <ls_entities>-TravelId
          AND source-BookingId = <ls_entities>-BookingId
       )
       NEXT max = COND /dmo/booking_supplement_id( WHEN booking-target-bookingsupplementid > max
                                                   THEN booking-target-BookingId
                                                   ELSE max )
                                    ) .

      max_booking_supp_id = REDUCE #( INIT curnum = max_booking_supp_id
      FOR entity IN entities USING KEY entity
      WHERE ( TravelId = <ls_entities>-TravelId
          AND BookingId = <ls_entities>-BookingId )
      FOR target IN entity-%target
      NEXT curnum = COND /dmo/booking_supplement_id( WHEN target-BookingSupplementId > curnum
                                                     THEN target-BookingSupplementId
                                                     ELSE curnum )
                                    ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>) USING KEY entity WHERE TravelId = <ls_entities>-TravelId
                                                                              AND BookingId = <ls_entities>-BookingId.

        LOOP AT <ls_entity>-%target ASSIGNING FIELD-SYMBOL(<ls_target>).
          APPEND CORRESPONDING #( <ls_target> ) TO mapped-bookingsuppl ASSIGNING FIELD-SYMBOL(<mappped_booksuppl>).
          IF <ls_target>-BookingSupplementId IS INITIAL.
            max_booking_supp_id += 10.
            <mappped_booksuppl>-BookingSupplementId = max_booking_supp_id.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD AcceptTravel.
  ENDMETHOD.

  METHOD copyTravel.
    DATA: it_travel      TYPE TABLE FOR CREATE zi_travel48,
          it_booking_cba TYPE TABLE FOR CREATE zi_travel48\_Booking,
          it_booksup_cba TYPE TABLE FOR CREATE zi_booking48\_Booksuppl.
    READ ENTITIES OF zi_travel48 IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_travel_r)
    FAILED DATA(it_failed).
    READ ENTITIES OF zi_travel48 IN LOCAL MODE
    ENTITY Travel BY \_Booking
    ALL FIELDS WITH CORRESPONDING #( it_travel_r )
    RESULT DATA(it_booking_r).
    READ ENTITIES OF zi_travel48 IN LOCAL MODE
    ENTITY Booking BY \_Booksuppl
    ALL FIELDS WITH CORRESPONDING #( it_booking_r )
    RESULT DATA(it_bookingsup_r).

    LOOP AT it_travel_r ASSIGNING FIELD-SYMBOL(<ls_travel_r>).
      APPEND VALUE #( %cid = keys[ KEY entity TravelId = <ls_travel_r>-TravelId ]-%cid
                      %data = CORRESPONDING #( <ls_travel_r> EXCEPT travelid )
                       ) TO it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      <ls_travel>-BeginDate = cl_abap_context_info=>get_system_date(  ).
      <ls_travel>-EndDate = cl_abap_context_info=>get_system_date( ).
      <ls_travel>-Status = 'N'.
      APPEND VALUE #( %cid_ref = <ls_travel>-%cid
            ) TO it_booking_cba ASSIGNING FIELD-SYMBOL(<ls_booking_cba>).
      LOOP AT it_booking_r ASSIGNING FIELD-SYMBOL(<ls_booking_r>) USING KEY entity
                                                                  WHERE TravelId = <ls_travel_r>-TravelId.
        APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId
                        %Data = CORRESPONDING #( <ls_booking_r> EXCEPT travelid ) ) TO <ls_booking_cba>-%target
                                                                                    ASSIGNING FIELD-SYMBOL(<ls_booking_n>).

        APPEND VALUE #( %cid_ref = <ls_booking_n>-%cid ) TO it_booksup_cba ASSIGNING FIELD-SYMBOL(<ls_booksup_cba>).
        LOOP AT it_bookingsup_r ASSIGNING FIELD-SYMBOL(<ls_bookingsup_r>)
                                USING KEY entity
                                WHERE TravelId = <ls_travel_r>-TravelId
                                AND BookingId = <ls_booking_r>-BookingId.
          APPEND VALUE #( %cid = <ls_booking_n>-%cid && <ls_bookingsup_r>-BookingSupplementId
                          %data = CORRESPONDING #( <ls_bookingsup_r> ) ) TO <ls_booksup_cba>-%target
          ASSIGNING FIELD-SYMBOL(<ls_booksup_n>).

        ENDLOOP.


      ENDLOOP.
    ENDLOOP.
    MODIFY ENTITIES OF zi_travel48 IN LOCAL MODE
    ENTITY travel
    CREATE FIELDS ( AgencyId BeginDate BookingFee Createdat Createdby CurrencyCode CustomerId Description EndDate
                    Lastchangedat Lastchangedby Status TotalPrice )
    WITH it_travel
    ENTITY Travel
    CREATE BY \_Booking
    FIELDS ( BookingId BookingDate CarrierId ConnectionId CurrencyCode CustomerId FlightDate FlightPrice )
    WITH it_booking_cba
    ENTITY Booking
    CREATE BY \_Booksuppl
    FIELDS ( BookingId BookingSupplementId CurrencyCode Price SupplementId )
    WITH it_booksup_cba
    MAPPED DATA(it_mapped).

    mapped-travel = it_mapped-travel.
    mapped-booking = it_mapped-booking.
    mapped-bookingsuppl = it_mapped-bookingsuppl.

  ENDMETHOD.

  METHOD RejectTravel.
  ENDMETHOD.

ENDCLASS.
