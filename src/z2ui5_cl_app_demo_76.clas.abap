CLASS z2ui5_cl_app_demo_76 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_serializable_object .
    INTERFACES z2ui5_if_app .

    TYPES:
      BEGIN OF ts_tree_row_base,
        object TYPE string,
        col2   TYPE string,
        col3   TYPE string,
        col4   TYPE string,
      END OF ts_tree_row_base .
    TYPES:
      BEGIN OF ts_tree_level3.
        INCLUDE TYPE ts_tree_row_base.
  TYPES END OF ts_tree_level3 .
    TYPES:
      tt_tree_level3 TYPE STANDARD TABLE OF ts_tree_level3 WITH KEY object .
    TYPES:
      BEGIN OF ts_tree_level2.
        INCLUDE TYPE ts_tree_row_base.
    TYPES   categories TYPE tt_tree_level3.
    TYPES END OF ts_tree_level2 .
    TYPES:
      tt_tree_level2 TYPE STANDARD TABLE OF ts_tree_level2 WITH KEY object .
    TYPES:
      BEGIN OF ts_tree_level1.
        INCLUDE TYPE ts_tree_row_base.
    TYPES   categories TYPE tt_tree_level2.
    TYPES END OF ts_tree_level1 .
    TYPES:
      tt_tree_level1 TYPE STANDARD TABLE OF ts_tree_level1 WITH KEY object .
    TYPES:
      BEGIN OF ty_row,
        selkz TYPE abap_bool,
        title TYPE string,
        value TYPE string,
        descr TYPE string,
      END OF ty_row .

    DATA mt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.


    DATA mt_tree TYPE tt_tree_level1 .
    DATA check_initialized TYPE abap_bool .
    DATA mv_check_enabled_01 TYPE abap_bool VALUE abap_true ##NO_TEXT.
    DATA mv_check_enabled_02 TYPE abap_bool .

    DATA mv_selected_index TYPE abap_bool .
  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.

    METHODS view_display_master.
    METHODS view_display_detail.

  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_app_demo_76 IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method Z2UI5_CL_APP_DEMO_66_2->VIEW_DISPLAY_DETAIL
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD view_display_detail.

    DATA(lo_view_nested) = z2ui5_cl_xml_view=>factory( client ).

    DATA(page) = lo_view_nested->page( title = `Nested View` ).


    DATA(lr_table) = page->table(
                headertext = 'Table'
                mode = 'SingleSelectLeft'
                items = client->_bind_edit( mt_tab ) ).

    lr_table->header_toolbar(
                   )->overflow_toolbar(
                       )->button(
                           icon = 'sap-icon://pull-down'
                           text = 'copy selected entries'
                           press = client->_event( 'BUTTON_READ_SEL' ) ).

    lr_table->columns(
        )->column( )->text( 'Title' )->get_parent(
        )->column( )->text( 'Value' )->get_parent(
        )->column( )->text( 'Description' ).

    lr_table->items(
        )->column_list_item( selected = '{SELKZ}'
            )->cells(
                )->text( '{TITLE}'
                )->text( '{VALUE}'
                )->text( '{DESCR}' ).


    client->nest_view_display(
      val            = lo_view_nested->stringify( )
      id             = `test`
      method_insert  = 'addMidColumnPage'
      method_destroy = 'removeAllMidColumnPages'
    ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method Z2UI5_CL_APP_DEMO_66_2->VIEW_DISPLAY_MASTER
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD view_display_master.

*    DATA(lr_view) = z2ui5_cl_xml_view=>factory( client ).

    DATA(page) = z2ui5_cl_xml_view=>factory( client )->shell(
       )->page(
          title          = 'abap2UI5 - Games'
          navbuttonpress = client->_event( 'BACK' )
            shownavbutton = abap_true ).

    page->header_content(
             )->link( text = 'Demo'    target = '_blank'    href = `https://twitter.com/abap2UI5/status/1628701535222865922`
             )->link( text = 'Source_Code'  target = '_blank' href = page->hlp_get_source_code_url(  )
         )->get_parent( ).

    DATA(col_layout) =  page->flexible_column_layout( layout = 'TwoColumnsBeginExpanded' id ='test' ).

    DATA(lr_master) = col_layout->begin_column_pages( ).

    client->_bind( mt_tree ).
    DATA(tab) = lr_master->tree_table(
      rows = `{path:'/MT_TREE', parameters: {arrayNames:['CATEGORIES']}}`
      rowselectionchange = client->_event( 'EVT_TREE_SEL' )
      selectionbehavior = 'RowOnly'
      selectedindex = client->_bind_edit( me->mv_selected_index ) ).
    tab->tree_columns(
    )->tree_column( label = 'Object'
        )->tree_template(
        )->text( text = '{OBJECT}')->get_parent( )->get_parent(
        )->tree_column( label = 'Column2'
        )->tree_template(
        )->text( text = '{COL2}')->get_parent( )->get_parent(
        )->tree_column( label = 'Column3'
        )->tree_template(
        )->text( text = '{COL3}')->get_parent( )->get_parent(
        )->tree_column( label = 'Column4'
        )->tree_template(
        )->text( text = '{COL4}').

    client->view_display( page->stringify( ) ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method Z2UI5_CL_APP_DEMO_66_2->Z2UI5_IF_APP~MAIN
* +-------------------------------------------------------------------------------------------------+
* | [--->] CLIENT                         TYPE REF TO Z2UI5_IF_CLIENT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD z2ui5_if_app~main.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      mt_tree = VALUE #( ( object = '1' categories = VALUE #( ( object = '1.1' categories = VALUE #( ( object = '1.1.1')
                                                                                                     ( object = '1.1.2') ) )
                                                                               ( object = '1.2' ) ) )
                         ( object = '2' categories = VALUE #( ( object = '2.1' )
                                                              ( object = '2.2' ) ) )
                         ( object = '3' categories = VALUE #( ( object = '3.1' )
                                                              ( object = '3.2' ) ) ) ).



      view_display_master(  ).

    ENDIF.

    CASE client->get( )-event.

      WHEN 'BUTTON_READ_SEL'.
        IF NOT line_exists( mt_tab[ selkz = abap_true ] ).
          client->message_toast_display( text = 'No line selected' ).
        ELSE.
          client->message_toast_display( text = 'Line Selected' ).
        ENDIF.

      WHEN 'EVT_TREE_SEL'.

        mt_tab = VALUE #( descr = 'this is a description'
       (  title = 'title_01'  value = 'value_01' )
       (  title = 'title_02'  value = 'value_02' )
       (  title = 'title_03'  value = 'value_03' )
       (  title = 'title_04'  value = 'value_04' )
       (  title = 'title_05'  value = 'value_05' ) ).

        view_display_detail(  ).

      WHEN `UPDATE_DETAIL`.
        view_display_detail(  ).


      WHEN `NEST_TEST`.

        mv_check_enabled_01 = xsdbool( mv_check_enabled_01 = abap_false ).
        mv_check_enabled_02 = xsdbool( mv_check_enabled_01 = abap_false ).

        client->nest_view_model_update( ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.