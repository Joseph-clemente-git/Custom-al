page 70148 "MJS Posted Whse. Shpt Line API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Posted Warehouse Shipment Line';
    EntitySetCaption = 'Posted Warehouse Shipment Lines';
    EntityName = 'postedWarehouseShipmentLine';
    EntitySetName = 'postedWarehouseShipmentLines';
    SourceTable = "Posted Whse. Shipment Line";
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata "Posted Whse. Shipment Line" = R;

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
                field(postedShipmentNo; Rec."No.")
                {
                    Caption = 'Posted Shipment No.';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(sourceDocument; Rec."Source Document")
                {
                    Caption = 'Source Document';
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Source No.';
                }
                field(destinationNo; Rec."Destination No.")
                {
                    Caption = 'Destination No.';
                }
                // The document the post itself created (e.g. the Posted Sales
                // Shipment) — the link from a warehouse post to its sales-side
                // history document.
                field(postedSourceDocument; Rec."Posted Source Document")
                {
                    Caption = 'Posted Source Document';
                }
                field(postedSourceNo; Rec."Posted Source No.")
                {
                    Caption = 'Posted Source No.';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(binCode; Rec."Bin Code")
                {
                    Caption = 'Bin Code';
                }
                field(zoneCode; Rec."Zone Code")
                {
                    Caption = 'Zone Code';
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(quantityBase; Rec."Qty. (Base)")
                {
                    Caption = 'Quantity (Base)';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(shipmentDate; Rec."Shipment Date")
                {
                    Caption = 'Shipment Date';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field(whseShipmentNo; Rec."Whse. Shipment No.")
                {
                    Caption = 'Whse. Shipment No.';
                }
            }
        }
    }
}
