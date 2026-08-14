CLASS lhc_position DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS detposition FOR DETERMINE ON MODIFY
      IMPORTING keys FOR position~detposition.

    METHODS val_position FOR VALIDATE ON SAVE
      IMPORTING keys FOR position~val_position.

ENDCLASS.

CLASS lhc_position IMPLEMENTATION.

  METHOD detposition.

    DATA lv_pos(6) TYPE n.

    READ ENTITIES OF ZI_addah2 IN LOCAL MODE
     ENTITY position
       FIELDS ( tempitemno OrderNo ) WITH CORRESPONDING #( keys )
     RESULT  DATA(lt_position)
     REPORTED DATA(lt_reported)
     FAILED DATA(lt_failed).

    LOOP AT lt_position ASSIGNING FIELD-SYMBOL(<lfs_position>)
                         WHERE tempItemNo IS INITIAL .

      SELECT a~tempitemno FROM zaddap2dr AS a
       WHERE tempitemno IS NOT INITIAL
          AND    orderno = @<lfs_position>-OrderNo
          INTO TABLE @DATA(tpos1) .


      SORT tpos1 BY tempitemno DESCENDING.
      IF lines( tpos1 ) > 0.
        lv_pos = tpos1[ 1 ]-tempitemno .
      ENDIF.
      lv_pos = lv_pos + 10.

      MODIFY ENTITIES OF ZI_addah2 IN LOCAL MODE
      ENTITY position
       UPDATE FIELDS ( tempitemno )
        WITH VALUE #( ( %tky = <lfs_position>-%tky tempitemno =  lv_pos ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD val_position.

    DATA lv_max TYPE i.
    DATA lv_pos(6) TYPE n.

*
*    READ ENTITIES OF zi_addah2 IN LOCAL MODE
*     ENTITY position by \_Header
*       all FIELDS  WITH CORRESPONDING #( keys )
*     RESULT  DATA(lt_header).



    READ ENTITIES OF zi_addah2 IN LOCAL MODE
     ENTITY position
       FIELDS ( OrderNo tempitemno ItemNo  ) WITH CORRESPONDING #( keys )
     RESULT  DATA(lt_position)
     REPORTED DATA(lt_reported)
     FAILED DATA(lt_failed).

    LOOP AT lt_position ASSIGNING FIELD-SYMBOL(<lfs_position>) .


      IF <lfs_position>-%pid IS NOT INITIAL .

        IF  <lfs_position>-OrderNo IS INITIAL.

          SELECT SINGLE parentdraftuuid FROM zaddap2dr
                    WHERE draftuuid = @<lfs_position>-%pid
                     INTO @DATA(lv_parentid).


          SELECT  OrderNo, tempitemno, ItemNo , draftuuid  FROM zaddap2dr
              WHERE parentdraftuuid EQ @lv_parentid
               INTO TABLE @DATA(tpos1).

        ELSE.


          SELECT  OrderNo, tempitemno, ItemNo , draftuuid  FROM zaddap2dr
           WHERE orderno EQ @<lfs_position>-OrderNo
            INTO TABLE @tpos1.

        ENDIF.

        DELETE   tpos1 WHERE draftuuid = <lfs_position>-%pid.
        READ TABLE tpos1 ASSIGNING FIELD-SYMBOL(<pos1>)
                                     WITH KEY TempitemNo = <lfs_position>-TempitemNo.
        IF sy-subrc = 0.
          failed-position = VALUE #( ( %tky = <lfs_position>-%tky  ) ).
          reported-position = VALUE #(
                                             ( %tky = <lfs_position>-%tky
*                                               %state_area = 'VALIDATE1'
                                               %msg = me->new_message(
                                                        id       = 'ZADDAMESS'
                                                        number   =  '004'
                                                        severity = if_abap_behv_message=>severity-error
                                                          v1  = <lfs_position>-tempitemno
                                                     )     ) ).


        ENDIF.
      ENDIF.

*     ---------------------------------------------------------------------

      IF <lfs_position>-%pid  IS INITIAL. "update

        IF <lfs_position>-TempitemNo <> <lfs_position>-itemno.

          failed-position = VALUE #( ( %tky = <lfs_position>-%tky  ) ).
          reported-position = VALUE #(
                                             ( %tky = <lfs_position>-%tky
                                               %msg = me->new_message(
                                                        id       = 'ZADDAMESS'
                                                        number   =  '005'
                                                        severity = if_abap_behv_message=>severity-error
                                                          v1  = <lfs_position>-tempitemno
                                                           )     ) ).

          CONTINUE.
        ENDIF.

      ENDIF.



    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR header RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK header.

    METHODS Edit FOR MODIFY
      IMPORTING keys FOR ACTION header~Edit.

ENDCLASS.

CLASS lhc_header IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD Edit.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_ADDAH2 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_ADDAH2 IMPLEMENTATION.

  METHOD adjust_numbers.
    DATA : lt_header TYPE STANDARD TABLE OF zaddah1,
           lt_item1  TYPE STANDARD TABLE OF zaddap1,
           lt_item   TYPE STANDARD TABLE OF zaddap1.
    DATA ls_item     TYPE zaddap1.
    DATA lv_pos TYPE numc4.

    IF  mapped-header IS NOT INITIAL.
      READ ENTITIES OF zi_addah2 IN LOCAL MODE
      ENTITY header
      ALL FIELDS WITH CORRESPONDING #( mapped-header )
      RESULT  DATA(lt_head).



      IF lines( lt_head ) > 0.

        SELECT MAX( order_no )  FROM zaddah1 INTO @DATA(lv_order).
        lv_order = lv_order + 1.

        lt_header = CORRESPONDING #( lt_head  MAPPING FROM ENTITY  ).

        GET TIME STAMP FIELD DATA(ts).
        LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) WHERE Order_No IS INITIAL.
          <fs_header>-Order_No = lv_order.
          <fs_header>-created_datetime = ts.
          <fs_header>-create_by = sy-uname.
        ENDLOOP.

        INSERT zaddah1 FROM TABLE @lt_header.

        LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<fs_head>) WHERE OrderNo IS INITIAL.
          APPEND INITIAL LINE TO mapped-header
                  ASSIGNING FIELD-SYMBOL(<fs_mapped>).
          <fs_mapped>-%pid = <fs_head>-%pid.
          <fs_mapped>-OrderNo = lv_order.
        ENDLOOP.
      ENDIF.



      IF mapped-position IS NOT INITIAL.
*
        READ ENTITIES OF zi_addah2 IN LOCAL MODE
             ENTITY header
             ALL FIELDS WITH CORRESPONDING #( mapped-header )
             RESULT  lt_head.
*
        READ ENTITIES OF zi_addah2 IN LOCAL MODE
            ENTITY zi_addah2 BY \_position
            ALL FIELDS WITH CORRESPONDING #( mapped-header )
            RESULT  DATA(lt_itm).



        LOOP AT lt_itm ASSIGNING FIELD-SYMBOL(<fs_itm>).
          <fs_itm>-orderno = lv_order.
          <fs_itm>-ItemNo = <fs_itm>-TempitemNo.
          ls_item = CORRESPONDING #( <fs_itm>  MAPPING FROM ENTITY  ).
          APPEND ls_item TO lt_item.

        ENDLOOP.


        lt_item1 = CORRESPONDING #( lt_itm  MAPPING FROM ENTITY  ). " no need
        GET TIME STAMP FIELD DATA(ts1).

        LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
          <fs_item>-order_no = lv_order.
          <fs_item>-item_no = <fs_item>-tempitem_no.

          <fs_item>-created_datetime = ts1.
          <fs_item>-create_by = sy-uname.

        ENDLOOP.

        INSERT zaddap1 FROM TABLE @lt_item.

        LOOP AT lt_itm  INTO DATA(ls_itm) WHERE %pid IS NOT INITIAL.

          LOOP AT mapped-position ASSIGNING FIELD-SYMBOL(<fs_pos>)
          WHERE %pid = ls_itm-%pid.

            <fs_pos>-ItemNo = ls_itm-ItemNo.
            <fs_pos>-OrderNo = ls_itm-OrderNo.
            <fs_pos>-%pid     =  ls_itm-%pid .

          ENDLOOP.
        ENDLOOP.

      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD save_modified.

    DATA : lt_head      TYPE STANDARD TABLE OF zaddah1,
           lt_headerupd TYPE STANDARD TABLE OF zaddah1,
           lt_header1   TYPE STANDARD TABLE OF zaddah1,
           lt_itemupd1  TYPE STANDARD TABLE OF zaddap1,
           lt_itemupd   TYPE STANDARD TABLE OF zaddap1,
           lt_headerins TYPE STANDARD TABLE OF zaddah1,
           lt_itemins   TYPE STANDARD TABLE OF zaddap1,
           ls_itemsins  type zaddap1,
           lt_headerdel TYPE STANDARD TABLE OF zaddah1,
           lt_itemdel   TYPE STANDARD TABLE OF zaddap1.
    DATA lv_pos TYPE numc4.
    DATA lv_order(6) TYPE n.

    IF update-header IS NOT INITIAL.
      lt_headerupd = CORRESPONDING #( update-header MAPPING FROM ENTITY  ).
*
*              READ ENTITIES OF zi_addah2 IN LOCAL MODE
*              ENTITY header by \_position
*              ALL FIELDS WITH VALUE #( (   OrderNo = lt_headerupd[ 1 ]-order_no
*                                             %is_draft = '01'   ) )
*              RESULT  DATA(lt_pos).


      UPDATE zaddah1 FROM TABLE @lt_headerupd.
    ENDIF.


    IF create-position IS NOT INITIAL.
*      lt_itemins = CORRESPONDING #( create-position MAPPING FROM ENTITY  ).

      READ TABLE  update-header ASSIGNING FIELD-SYMBOL(<fs_header>)
                                      INDEX 1.
      IF sy-subrc = 0.
*
        READ ENTITIES OF zi_addah2 IN LOCAL MODE
              ENTITY header
              ALL FIELDS WITH VALUE #( (   OrderNo = <fs_header>-OrderNo
                                            %is_draft = '01' ) )
              RESULT  DATA(lt_headc).


         READ ENTITIES OF zi_addah2 IN LOCAL MODE
            ENTITY zi_addah2 BY \_position
            ALL FIELDS WITH CORRESPONDING #( lt_headc )
            RESULT  DATA(lt_itm1).

            loop at lt_itm1 ASSIGNING FIELD-SYMBOL(<fs_item1>).
             if <fs_item1>-%pid is initial.
             delete lt_itm1 index sy-tabix.
             else.
             ls_itemsins = CORRESPONDING #( <fs_item1> MAPPING FROM ENTITY  ).
*              ls_itemsins-order_no
             ls_itemsins-item_no = ls_itemsins-tempitem_no.
             append ls_itemsins to lt_itemins.
             endif.
            endloop.

        INSERT zaddap1 FROM TABLE @lt_itemins.
      ENDIF.
    ENDIF.


    IF update-position IS NOT INITIAL.
      lt_itemupd = CORRESPONDING #( update-position MAPPING FROM ENTITY  ).
      LOOP AT lt_itemupd ASSIGNING FIELD-SYMBOL(<fs_item>).
        <fs_item>-item_no = <fs_item>-tempitem_no.
        lv_order = <fs_item>-order_no.
      ENDLOOP.

*  No need
*      READ ENTITIES OF zi_addah2 IN LOCAL MODE
*         ENTITY header
*         ALL FIELDS WITH VALUE #( (   OrderNo = lv_order ) )
*         RESULT  DATA(lt_head1).
*      lt_header1 = CORRESPONDING #( lt_head1 MAPPING FROM ENTITY  ).
*
*      READ ENTITIES OF zi_addah2 IN LOCAL MODE
*            ENTITY zi_addah2 BY \_position
*            ALL FIELDS WITH CORRESPONDING #( lt_head1 )
*            RESULT  DATA(lt_itm1).
*      lt_itemupd1  = CORRESPONDING #( lt_itm1 MAPPING FROM ENTITY  ).
* No need


      UPDATE zaddap1 FROM TABLE @lt_itemupd.


    ENDIF.



    IF delete-header IS NOT INITIAL.
      lt_headerdel = CORRESPONDING #( delete-header MAPPING FROM ENTITY  ).
      DELETE zaddah1 FROM TABLE @lt_headerdel.
      DELETE zaddap1 FROM TABLE @lt_headerdel.
    ENDIF.

    IF delete-position IS NOT INITIAL.
      lt_itemdel = CORRESPONDING #( delete-position MAPPING FROM ENTITY  ).
      DELETE zaddap1 FROM TABLE @lt_itemdel.
    ENDIF.



  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
