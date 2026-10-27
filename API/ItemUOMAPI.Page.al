page 70118 "MJS Item UOM API"
{
    // Exposes BC's Item Unit of Measure table (5404) per item — the set of
    // alternate Units of Measure actually configured on an item (e.g. SAC,
    // SHEET, TAB, TUBE, VIAL), which the standard BC API does not expose.
    // majesty-pharma-web calls this filtered by itemNo to populate the Unit
    // of Measure dropdown on Sales Order lines with the item's real options
    // instead of only its Base/Sales/Purch Unit of Measure fields.
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Item Unit of Measure';
    EntitySetCaption = 'Item Units of Measure';
    EntityName = 'itemUnitOfMeasure';
    EntitySetName = 'itemUnitOfMeasures';
    SourceTable = "Item Unit of Measure";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

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
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(description; UnitOfMeasureDescription)
                {
                    Caption = 'Description';
                }
                field(qtyPerUnitOfMeasure; Rec."Qty. per Unit of Measure")
                {
                    Caption = 'Qty. per Unit of Measure';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if UnitOfMeasure.Get(Rec.Code) then
            UnitOfMeasureDescription := UnitOfMeasure.Description
        else
            UnitOfMeasureDescription := '';
    end;

    var
        UnitOfMeasure: Record "Unit of Measure";
        UnitOfMeasureDescription: Text[100];
}
