page 70128 "MJS Whse. Put-away Line API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Warehouse Put-away Line';
    EntitySetCaption = 'Warehouse Put-away Lines';
    EntityName = 'warehousePutAwayLine';
    EntitySetName = 'warehousePutAwayLines';
    SourceTable = "Warehouse Activity Line";
    SourceTableView = where("Activity Type" = const("Put-away"));
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
                field(putAwayNo; Rec."No.")
                {
                    Caption = 'Put-away No.';
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
            }
        }
    }
}
