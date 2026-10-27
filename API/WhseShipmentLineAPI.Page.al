page 70138 "MJS Whse. Shipment Line API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Warehouse Shipment Line';
    EntitySetCaption = 'Warehouse Shipment Lines';
    EntityName = 'warehouseShipmentLine';
    EntitySetName = 'warehouseShipmentLines';
    SourceTable = "Warehouse Shipment Line";
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata "Warehouse Shipment Line" = R;

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
                field(shipmentNo; Rec."No.")
                {
                    Caption = 'Shipment No.';
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
                field(qtyToShip; Rec."Qty. to Ship")
                {
                    Caption = 'Qty. to Ship';
                }
                field(qtyShipped; Rec."Qty. Shipped")
                {
                    Caption = 'Qty. Shipped';
                }
                field(qtyPicked; Rec."Qty. Picked")
                {
                    Caption = 'Qty. Picked';
                }
                field(pickQty; Rec."Pick Qty.")
                {
                    Caption = 'Pick Qty.';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
            }
        }
    }
}
