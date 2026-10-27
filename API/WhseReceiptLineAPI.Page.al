page 70130 "MJS Whse. Receipt Line API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Warehouse Receipt Line';
    EntitySetCaption = 'Warehouse Receipt Lines';
    EntityName = 'warehouseReceiptLine';
    EntitySetName = 'warehouseReceiptLines';
    SourceTable = "Warehouse Receipt Line";
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
                field(receiptNo; Rec."No.")
                {
                    Caption = 'Receipt No.';
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
                field(qtyOutstanding; Rec."Qty. Outstanding")
                {
                    Caption = 'Qty. Outstanding';
                }
                field(qtyToReceive; Rec."Qty. to Receive")
                {
                    Caption = 'Qty. to Receive';
                }
                field(qtyReceived; Rec."Qty. Received")
                {
                    Caption = 'Qty. Received';
                }
                field(qtyToCrossDock; Rec."Qty. to Cross-Dock")
                {
                    Caption = 'Qty. to Cross-Dock';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field(lotRequired; LotRequired)
                {
                    Caption = 'Lot Required';
                    Editable = false;
                }
                field(expirationRequired; ExpirationRequired)
                {
                    Caption = 'Expiration Required';
                    Editable = false;
                }
                field(lotsJson; LotsJson)
                {
                    Caption = 'Lots';
                    Editable = false;
                }
            }
        }
    }

    var
        LotRequired: Boolean;
        ExpirationRequired: Boolean;
        LotsJson: Text;

    trigger OnAfterGetRecord()
    var
        LotMgt: Codeunit "MJS Whse. Receipt Lot Mgt.";
    begin
        LotMgt.GetLotSetup(Rec, LotRequired, ExpirationRequired);
        LotsJson := '[]';
        if LotRequired then
            LotsJson := LotMgt.GetAssignedLotsJson(Rec);
    end;
}
