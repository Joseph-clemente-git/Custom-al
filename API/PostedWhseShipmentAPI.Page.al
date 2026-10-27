page 70147 "MJS Posted Whse. Shpt. API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Posted Warehouse Shipment';
    EntitySetCaption = 'Posted Warehouse Shipments';
    EntityName = 'postedWarehouseShipment';
    EntitySetName = 'postedWarehouseShipments';
    SourceTable = "Posted Whse. Shipment Header";
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata "Posted Whse. Shipment Header" = R,
                  tabledata "Posted Whse. Shipment Line" = R;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(whseShipmentNo; Rec."Whse. Shipment No.")
                {
                    Caption = 'Whse. Shipment No.';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(assignedUserId; Rec."Assigned User ID")
                {
                    Caption = 'Assigned User ID';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(shipmentDate; Rec."Shipment Date")
                {
                    Caption = 'Shipment Date';
                }
                field(assignmentDate; Rec."Assignment Date")
                {
                    Caption = 'Assignment Date';
                }
                field(assignmentTime; Rec."Assignment Time")
                {
                    Caption = 'Assignment Time';
                }
                field(binCode; Rec."Bin Code")
                {
                    Caption = 'Bin Code';
                }
                field(zoneCode; Rec."Zone Code")
                {
                    Caption = 'Zone Code';
                }
                field(shippingAgentCode; Rec."Shipping Agent Code")
                {
                    Caption = 'Shipping Agent Code';
                }
                field(shipmentMethodCode; Rec."Shipment Method Code")
                {
                    Caption = 'Shipment Method Code';
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                }
                field(sourceDocument; SourceDocument)
                {
                    Caption = 'Source Document';
                }
            }
        }
    }

    var
        SourceDocument: Enum "Warehouse Activity Source Document";

    trigger OnAfterGetRecord()
    var
        PostedWhseShptLine: Record "Posted Whse. Shipment Line";
    begin
        // The header has no Source Document; take its lines' one, blank when
        // they mix sources — the web app splits Sales Order / Transfer Order history by it.
        Clear(SourceDocument);
        PostedWhseShptLine.SetLoadFields("Source Document");
        PostedWhseShptLine.SetRange("No.", Rec."No.");
        if not PostedWhseShptLine.FindFirst() then
            exit;
        PostedWhseShptLine.SetFilter("Source Document", '<>%1', PostedWhseShptLine."Source Document");
        if PostedWhseShptLine.IsEmpty() then
            SourceDocument := PostedWhseShptLine."Source Document";
    end;
}
