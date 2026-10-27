page 70126 "MJS Whse. Pick Line API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Warehouse Pick Line';
    EntitySetCaption = 'Warehouse Pick Lines';
    EntityName = 'warehousePickLine';
    EntitySetName = 'warehousePickLines';
    SourceTable = "Warehouse Activity Line";
    SourceTableView = where("Activity Type" = const(Pick));
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;

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
                field(pickNo; Rec."No.")
                {
                    Caption = 'Pick No.';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(actionType; Rec."Action Type")
                {
                    Caption = 'Action Type';
                }
                field(whseDocumentType; Rec."Whse. Document Type")
                {
                    Caption = 'Whse. Document Type';
                }
                field(whseDocumentNo; Rec."Whse. Document No.")
                {
                    Caption = 'Whse. Document No.';
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Source No.';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
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
                field(qtyToHandle; Rec."Qty. to Handle")
                {
                    Caption = 'Qty. to Handle';
                }
                field(qtyHandled; Rec."Qty. Handled")
                {
                    Caption = 'Qty. Handled';
                }
                field(qtyOutstanding; Rec."Qty. Outstanding")
                {
                    Caption = 'Qty. Outstanding';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field(lotNo; Rec."Lot No.")
                {
                    Caption = 'Lot No.';
                }
                field(expirationDate; Rec."Expiration Date")
                {
                    Caption = 'Expiration Date';
                }
                field(lotRequired; LotRequired)
                {
                    Caption = 'Lot Required';
                    Editable = false;
                }
            }
        }
    }

    var
        LotRequired: Boolean;

    // Whether Register Pick will demand a Lot No. on this line: the item's
    // Item Tracking Code has Lot Warehouse Tracking — the same setup check
    // Whse.-Activity-Register runs (CheckWhseItemTrkgLine).
    trigger OnAfterGetRecord()
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        LotRequired := false;
        if ItemTrackingMgt.GetWhseItemTrkgSetup(Rec."Item No.", WhseItemTrackingSetup) then
            LotRequired := WhseItemTrackingSetup."Lot No. Required";
    end;
}
