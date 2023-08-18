CLASS z2ui5_cl_app_demo_88 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_serializable_object .
    INTERFACES z2ui5_if_app .


    DATA mv_selected_key TYPE string.


  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA check_initialized TYPE abap_bool.

    METHODS z2ui5_view_display.
    METHODS z2ui5_on_event.


  PRIVATE SECTION.
    DATA mv_page TYPE string.

ENDCLASS.



CLASS z2ui5_cl_app_demo_88 IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method Z2UI5_CL_APP_DEMO_89->Z2UI5_IF_APP~MAIN
* +-------------------------------------------------------------------------------------------------+
* | [--->] CLIENT                         TYPE REF TO Z2UI5_IF_CLIENT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD z2ui5_if_app~main.

    me->client     = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      mv_page = `page1`.
      z2ui5_view_display( ).
      RETURN.
    ENDIF.

    z2ui5_on_event( ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method Z2UI5_CL_APP_DEMO_89->Z2UI5_ON_EVENT
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'OnSelectIconTabBar' .
        client->message_toast_display( |Event SelectedTabBar Key {  mv_selected_key } | ).

        client->_event_client( val = 'NAV_TO' t_arg  = VALUE #( ( `NavCon` ) ( mv_selected_key ) ) ).
        z2ui5_view_display( ).

      WHEN OTHERS.
        mv_page = client->get( )-event.
        z2ui5_view_display( ).

    ENDCASE.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Protected Method Z2UI5_CL_APP_DEMO_89->Z2UI5_VIEW_DISPLAY
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD z2ui5_view_display.

    DATA(view) = z2ui5_cl_xml_view=>factory( client ).
    DATA(tool_page) = view->tool_page(
                          )->header( ns = `tnt`
                            )->tool_header(
                              )->image( src = `https://www.sap.com/dam/application/shared/logos/sap-logo-svg.svg`
                                        height = `1.5rem`
                                        class = `sapUiSmallMarginBegin`

                              )->title( level = `H1`
                                        text  = `Product Name`
                              )->title( level = `H3`
                                        text  = `Second Title`
                              )->toolbar_spacer(
                              )->overflow_toolbar_button( text = `Search`
                                                          tooltip = `Search`
                                                          icon = `sap-icon://search`
                                                          type = `Transparent`
                              )->overflow_toolbar_button( text = `Task`
                                                          tooltip = `Task`
                                                          icon = `sap-icon://circle-task`
                                                          type = `Transparent`
                              )->overflow_toolbar_button( text = `Notifications`
                                                          tooltip = `Notifications`
                                                          icon = `sap-icon://bell`
                                                          type = `Transparent`
                              )->avatar( src = ``
                                         displaysize = `XS`
                              )->overflow_toolbar_button( text = `Custom Action`
                                                          tooltip = `Custom Action`
                                                          icon = `sap-icon://grid`
                                                          type = `Transparent`
                              )->get_parent(
                            )->get_parent( )->subheader(
                            )->tool_header(
                              )->icon_tab_header( selectedkey = client->_bind_edit( mv_selected_key )
*                                                  select = client->_event( `OnSelectIconTabBar` )
*                                                  select = client->_event_client( action = 'NAV_TO' t_arg  = value #( ( `NavCon` ) ( `${$parameters}` ) ) )
                                                  select = client->_event_client( val = client->cs_event-nav_container_to t_arg  = value #( ( `NavCon` ) ( `${$parameters>/selectedKey}` ) ) )
                                                  mode = `Inline`
                                  )->items(
                                    )->icon_tab_filter( key = `page1` text = `Home` )->get_parent(
                                    )->icon_tab_filter( key = `page2` text = `Applications` )->get_parent(
                                    )->icon_tab_filter( key = `page3` text = `Users and Groups`
                                      )->items(
                                         )->icon_tab_filter( key = `page11` text = `User 1` )->get_parent(
                                         )->icon_tab_filter( key = `page32` text = `User 2` )->get_parent(
                                         )->icon_tab_filter( key = `page33` text = `User 3`
                                      )->get_parent( )->get_parent( )->get_parent( )->get_parent( )->get_parent( )->get_parent( )->get_parent(
                                )->main_contents(
*                                )->button( text = `page1` press = client->_event_client( action = 'NAV_TO' t_arg  = VALUE #( ( `NavCon` ) ( `page1` ) ) )
*                                )->button( text = `page2` press = client->_event_client( action = 'NAV_TO' t_arg  = VALUE #( ( `NavCon` ) ( `page2` ) ) )
*                                )->button( text = `page3` press = client->_event_client( action = 'NAV_TO' t_arg  = VALUE #( ( `NavCon` ) ( `page3` ) ) )
                                  )->nav_container( id = `NavCon` initialpage = `page1` defaulttransitionname = `flip`
                                     )->pages(
                                     )->page(
                                       title          = 'first page'
                                       id             = `page1`
                                    )->get_parent(
                                     )->page(
                                       title          = 'second page'
                                       id             = `page2`
                                    )->get_parent(
                                     )->page(
                                       title          = 'third page'
                                       id             = `page3`
                                ).


    client->view_display( tool_page->stringify( ) ).

  ENDMETHOD.
ENDCLASS.