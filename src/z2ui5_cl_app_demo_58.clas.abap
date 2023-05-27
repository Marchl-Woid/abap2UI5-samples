CLASS z2ui5_cl_app_demo_58 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_S_filter_pop,
        option TYPE string,
        low    TYPE string,
        high   TYPE string,
        key    TYPE string,
      END OF ty_S_filter_pop.
    DATA mt_filter TYPE STANDARD TABLE OF ty_S_filter_pop WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_token,
        key      TYPE string,
        text     TYPE string,
        visible  TYPE abap_bool,
        selkz    TYPE abap_bool,
        editable TYPE abap_bool,
      END OF ty_S_token.

    DATA mv_value TYPE string.
    DATA mt_token            TYPE STANDARD TABLE OF ty_S_token WITH EMPTY KEY.
    DATA mt_token_popup            TYPE STANDARD TABLE OF ty_S_token WITH EMPTY KEY.
    DATA mt_token_sugg       TYPE STANDARD TABLE OF ty_S_token WITH EMPTY KEY.

    DATA mt_mapping TYPE z2ui5_if_client=>ty_t_name_value.

    TYPES:
      BEGIN OF ty_s_tab,
        selkz            TYPE abap_bool,
        product          TYPE string,
        create_date      TYPE string,
        create_by        TYPE string,
        storage_location TYPE string,
        quantity         TYPE i,
      END OF ty_s_tab.
    TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_tab WITH EMPTY KEY.

    DATA mt_table TYPE ty_t_table.

    TYPES:
      BEGIN OF ty_S_filter,
        product TYPE RANGE OF string,
      END OF ty_S_filter.

    CLASS-METHODS hlp_get_uuid
      RETURNING
        VALUE(result) TYPE string.

    DATA ms_filter TYPE ty_s_filter.


  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF app,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        get               TYPE z2ui5_if_client=>ty_s_get,
        next              TYPE z2ui5_if_client=>ty_s_next,
      END OF app.


    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render.
    METHODS z2ui5_on_render_main.
    METHODS z2ui5_on_render_pop_filter.

    METHODS z2ui5_set_data.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_58 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    me->client     = client.
    app-get        = client->get( ).
    app-view_popup = ``.
    app-next-title = `Filter`.


    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render( ).

    client->set_next( app-next ).
    CLEAR app-get.
    CLEAR app-next.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-get-event.

      WHEN `BUTTON_START`.
        z2ui5_set_data( ).

      WHEN `FILTER_UPDATE`.

        app-next-s_cursor-id = `FILTER`.
        app-next-s_cursor-cursorpos = `999`.
        app-next-s_cursor-selectionend = `999`.
        app-next-s_cursor-selectionstart  = `999`.

        IF mv_value IS NOT INITIAL.
          DATA ls_range LIKE LINE OF ms_filter-product.
          DATA(lv_length) = strlen( mv_value ) - 1.
          CASE mv_value(1).

            WHEN `=`.
              ls_range = VALUE #(  option = `EQ` low = mv_value+1 ).

            WHEN `<`.
              IF mv_value+1(1) = `=`.
                ls_range = VALUE #(  option = `LE` low = mv_value+2 ).
              ELSE.
                ls_range = VALUE #(  option = `LT` low = mv_value+1 ).
              ENDIF.
            WHEN `>`.
              IF mv_value+1(1) = `=`.
                ls_range = VALUE #(  option = `GE` low = mv_value+2 ).
              ELSE.
                ls_range = VALUE #(  option = `GT` low = mv_value+1 ).
              ENDIF.

            WHEN `*`.
              IF mv_value+lv_length(1) = `*`.
                SHIFT mv_value RIGHT DELETING TRAILING `*`.
                SHIFT mv_value LEFT DELETING LEADING `*`.
                ls_range = VALUE #(  option = `CP` low = mv_value ).
              ENDIF.



            WHEN OTHERS.

              IF mv_value CP `...`.
                SPLIT mv_value AT `...` INTO ls_range-low ls_range-high.
                ls_range-option = `BT`.
              ELSE.
                ls_range = VALUE #( option = `EQ` low = mv_value ).
              ENDIF.

          ENDCASE.

          INSERT ls_range INTO TABLE ms_filter-product.

        ENDIF.


      WHEN `POPUP_ADD`.
        INSERT VALUE #( key = hlp_get_uuid( ) ) INTO TABLE mt_filter.
        app-view_popup = `VALUE_HELP`.

      WHEN `POPUP_DELETE`.
        DELETE mt_filter WHERE key = app-get-event_data.
        app-view_popup = `VALUE_HELP`.

      WHEN `FILTER_VALUE_HELP`.
        app-next-s_cursor-id = `FILTER`.
        app-next-s_cursor-cursorpos = `999`.
        app-next-s_cursor-selectionend = `999`.
        app-next-s_cursor-selectionstart  = `999`.
        app-view_popup = `VALUE_HELP`.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).

    ENDCASE.



  ENDMETHOD.


  METHOD z2ui5_on_init.

    app-view_main = `MAIN`.

    mt_mapping = VALUE #(
    (  name = `EQ` value = `={LOW}`    )
    (   name = `LT` value = `<{LOW}`   )
    (   name = `LE` value = `<={LOW}`  )
    (   name = `GT` value = `>{LOW}`   )
    (   name = `GE` value = `>={LOW}`  )
    (   name = `CP` value = `*{LOW}*`  )

    (   name = `BT` value = `{LOW}...{HIGH}` )
    (   name = `NE` value = `!(={LOW})`    )
    (   name = `NE` value = `!(<leer>)`    )
    ( name = `<leer>` value = `<leer>`    )

   ).

    mt_filter = VALUE #(
      ( option = `EQ` low = `test` key = `01` )
      ( option = `EQ` low = `test` key = `02` )
       ).


  ENDMETHOD.


  METHOD z2ui5_on_render.

    CLEAR mv_value.
    CLEAR mt_token.
    LOOP AT ms_filter-product REFERENCE INTO DATA(lr_row).

      DATA(lv_value) = mt_mapping[ name = lr_row->option ]-value.

      REPLACE `{LOW}` IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.

      INSERT VALUE #( key = lv_value text = lv_value visible = abap_true editable = abap_false ) INTO TABLE mt_token.
    ENDLOOP.

    CASE app-view_popup.
      WHEN `VALUE_HELP`.
        z2ui5_on_render_pop_filter( ).
    ENDCASE.

    CASE app-view_main.
      WHEN 'MAIN'.
        z2ui5_on_render_main( ).
    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_render_main.

    DATA(view) = z2ui5_cl_xml_view=>factory(
        )->page( id = `page_main`
                title          = 'abap2UI5 - List Report Features'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton  = abap_true
            )->header_content(
                )->link(
                    text = 'Demo' target = '_blank'
                    href = 'https://twitter.com/OblomovDev/status/1637163852264624139'
                )->link(
                    text = 'Source_Code' target = '_blank' href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
           )->get_parent( ).

    DATA(page) = view->dynamic_page(
            headerexpanded = abap_true
            headerpinned   = abap_true
            ).

    DATA(header_title) = page->title( ns = 'f'
            )->get( )->dynamic_page_title( ).

    header_title->heading( ns = 'f' )->hbox(
        )->title( `Filter` ).

    header_title->expanded_content( 'f' ).

    header_title->snapped_content( ns = 'f' ).

    DATA(lo_box) = page->header( )->dynamic_page_header( pinnable = abap_true
         )->flex_box( alignitems = `Start` justifycontent = `SpaceBetween` )->flex_box( alignItems = `Start` ).

    lo_box->vbox(
        )->text(  `Product:`
        )->multi_input(
                    tokens          = client->_bind( mt_token )
                    showclearicon   = abap_true
                    value           = client->_bind( mv_value )
*                    tokenUpdate     = client->_event( val = 'FILTER_UPDATE1' data = `$event` )
                    tokenUpdate     = client->_event( val = 'FILTER_UPDATE1' data = `JSON.parse( ${$parameters>/removedTokens} )` )
                    submit          = client->_event( 'FILTER_UPDATE' )
                    id              = `FILTER`
                    valueHelpRequest  = client->_event( 'FILTER_VALUE_HELP' )
*                    enabled = abap_false
                )->item(
                        key = `{KEY}`
                        text = `{TEXT}`
                )->tokens(
                    )->token(
                        key = `{KEY}`
                        text = `{TEXT}`
                        visible = `{VISIBLE}`
                        selected = `{SELKZ}`
                        editable = `{EDITABLE}`
        ).

    lo_box->get_parent( )->hbox( justifycontent = `End` )->button(
        text = `Go` press = client->_event( `BUTTON_START` ) type = `Emphasized`
        ).

    DATA(cont) = page->content( ns = 'f' ).

    DATA(tab) = cont->table( items = client->_bind( val = mt_table ) ).

    DATA(lo_columns) = tab->columns( ).
    lo_columns->column( )->text( text = `Product` ).
    lo_columns->column( )->text( text = `Date` ).
    lo_columns->column( )->text( text = `Name` ).
    lo_columns->column( )->text( text = `Location` ).
    lo_columns->column( )->text( text = `Quantity` ).

    DATA(lo_cells) = tab->items( )->column_list_item( ).
    lo_cells->text( `{PRODUCT}` ).
    lo_cells->text( `{CREATE_DATE}` ).
    lo_cells->text( `{CREATE_BY}` ).
    lo_cells->text( `{STORAGE_LOCATION}` ).
    lo_cells->text( `{QUANTITY}` ).

    app-next-xml_main = page->get_root( )->xml_get( ).

  ENDMETHOD.



  METHOD z2ui5_on_render_pop_filter.


    CLEAR mt_token_popup.
    LOOP AT mt_filter REFERENCE INTO DATA(lr_row).

      DATA(lv_value) = mt_mapping[ name = lr_row->option ]-value.

      REPLACE `{LOW}` IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.

      INSERT VALUE #( key = lv_value text = lv_value visible = abap_true editable = abap_false ) INTO TABLE mt_token_popup.
    ENDLOOP.


    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog(
    contentheight = `50%`
    contentwidth = `50%`
        title = 'Define Conditons - Product' ).

*

*if mt_filter is not INITIAL.

    DATA(vbox) = lo_popup->vbox( height = `100%` justifyContent = 'SpaceBetween' ).

    DATA(pan)  = vbox->panel(
*      EXPORTING
         expandable = abap_false
         expanded   = abap_true
         headertext = `Product`
*      RECEIVING
*        result     =
     ). "->grid( ).
    DATA(item) = pan->list(
           "   headertext = `Product`
              noData = `no conditions defined`
             items           = client->_bind( mt_filter )
             selectionchange = client->_event( 'SELCHANGE' )
                )->custom_list_item( ).

    DATA(grid) = item->grid( ).

    grid->combobox(
                 selectedkey = `{OPTION}`
                 items       = client->_bind_one( mt_mapping )
*                                    ( key = 'BLUE'  text = 'green' )
*                                    ( key = 'GREEN' text = 'blue' )
*                                    ( key = 'BLACK' text = 'red' )
*                                    ( key = 'GRAY'  text = 'gray' ) ) )
             )->item(
                     key = '{NAME}'
                     text = '{NAME}'
             )->get_parent(
             )->input( value = `{LOW}`
             )->input( value = `{HIGH}`  visible = `{= ${OPTION} === 'BT' }`
             )->button( icon = 'sap-icon://decline' type = `Transparent` press = client->_event( val = `POPUP_DELETE` data = `${KEY}` )
             ).

*endif.

    DATA(panel) = vbox->vbox(

      )->hbox( justifycontent = `End` )->button( text = `Add` icon = `sap-icon://add` press = client->_event( val = `POPUP_ADD` ) )->get_parent(
      )->panel(
*      EXPORTING
          expandable = abap_false
          expanded   = abap_true
          headertext = `Selected Elements and Conditions`
*      RECEIVING
*        result     =
      )->grid( ).

    panel->multi_input(
                    tokens          = client->_bind( mt_token_popup )
                    showclearicon   = abap_true
*                    value           = client->_bind( mv_value )
*                    tokenUpdate     = client->_event( val = 'FILTER_UPDATE1' data = `$event` )
                    tokenUpdate     = client->_event( val = 'FILTER_UPDATE1' data = `JSON.parse( ${$parameters>/removedTokens} )` )
                    submit          = client->_event( 'FILTER_UPDATE' )
                    id              = `FILTER`
                    valueHelpRequest  = client->_event( 'FILTER_VALUE_HELP' )
                    enabled = abap_false
                )->item(
                        key = `{KEY}`
                        text = `{TEXT}`
                )->tokens(
                    )->token(
                        key = `{KEY}`
                        text = `{TEXT}`
                        visible = `{VISIBLE}`
                        selected = `{SELKZ}`
                        editable = `{EDITABLE}`
               ).

    panel->button( icon = 'sap-icon://decline' type = `Transparent` press = client->_event( val = `POPUP_DELETE_ALL` )
       ).

*data(hbox) = lo_popup->vbox(
*    )->text( `Selected Elements and Conditions`
*    )->hbox( ).
*
*       hbox->
*
*
*  hbox->button( icon = 'sap-icon://decline' type = `Transparent` press = client->_event( val = `POPUP_DELETE_ALL` )
*        ).


*    grid->combobox(
*            selectedkey = client->_bind( screen-combo_key )
*            items       = client->_bind_one( VALUE ty_t_combo(
*                    ( key = 'BLUE'  text = 'green' )
*                    ( key = 'GREEN' text = 'blue' )
*                    ( key = 'BLACK' text = 'red' )
*                    ( key = 'GRAY'  text = 'gray' ) ) )
*                )->item(
*                    key = '{KEY}'
*                    text = '{TEXT}'
*        )->get_parent( )->get_parent( ).
*
*         grid->text( `Product` ).
*         grid->text( `Product` ).
*         grid->text( `Product` ).
*         grid->text( `Product` ).
*         grid->text( `Product` ).
*         grid->text( `Product` ).
*         grid->text( `Product` ).
*         grid->text( `Product` ).



*        )->vbox( class = `sapUiMediumMargin` ).
*
*
*        vbox->flex_box(
*                )->combobox(
*
*                )->get_parent(
*                )->input(
*                )->button( ).
*
*        vbox->text( `Selected Elements and Conditions (` && `5` &&  `)` ).

*        )->table(
*            mode = 'MultiSelect'
*            items = client->_bind( ms_layout-t_filter_show )
*            )->columns(
*                )->column( )->text( 'Title' )->get_parent(
*                )->column( )->text( 'Color' )->get_parent(
*                )->column( )->text( 'Info' )->get_parent(
*                )->column( )->text( 'Description' )->get_parent(
*            )->get_parent(
*            )->items( )->column_list_item( selected = '{SELKZ}'
*                )->cells(
*             "       )->checkbox( '{SELKZ}'
*                    )->text( '{NAME}'
*                    )->text( '{VALUE}'
*             "       )->text( '{DESCR}'
*        )->get_parent( )->get_parent( )->get_parent( )->get_parent(

    lo_popup->footer( )->overflow_toolbar(
        )->toolbar_spacer(
        )->button(
            text  = 'OK'
            press = client->_event( 'FILTER_VALUE_HELP_OK' )
            type  = 'Emphasized'
       )->button(
            text  = 'Cancel'
            press = client->_event( 'FILTER_VALUE_HELP_CANCEL' )
       ).

    app-next-xml_popup = lo_popup->get_root( )->xml_get( ).

  ENDMETHOD.

  METHOD z2ui5_set_data.

    mt_table = VALUE #(
        ( product = 'table'    create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'chair'    create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'sofa'     create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'computer' create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'oven'     create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'table2'   create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
    ).

  ENDMETHOD.


  METHOD hlp_get_uuid.

    DATA uuid TYPE sysuuid_c32.

    TRY.
        CALL METHOD ('CL_SYSTEM_UUID')=>create_uuid_c32_static
          RECEIVING
            uuid = uuid.
      CATCH cx_sy_dyn_call_illegal_class.
        DATA lv_fm TYPE string.
        lv_fm = 'GUID_CREATE'.
        CALL FUNCTION lv_fm
          IMPORTING
            ev_guid_32 = uuid.
    ENDTRY.

    result = uuid.

  ENDMETHOD.

ENDCLASS.