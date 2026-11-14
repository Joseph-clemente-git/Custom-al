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
                // GMPI's "Allow in Sales Application" checkbox (Item Units of
                // Measure page), read by name so this app keeps no hard
                // dependency on GMPI. Ticked = the UOM stays on the Sales Order
                // line as entered; unticked = converted to the Sales UOM.
                field(salesAppApplicable; SalesAppApplicable)
                {
                    Caption = 'Sales App Applicable';
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        UomField: Record Field;
    begin
        // Resolved once per request rather than once per returned row.
        UomField.SetRange(TableNo, Database::"Item Unit of Measure");
        UomField.SetRange(FieldName, 'Allow in Sales Application');
        UomField.SetRange(Enabled, true);
        if UomField.FindFirst() then
            AllowInSalesAppFieldNo := UomField."No."
        else
            AllowInSalesAppFieldNo := 0;
    end;

    trigger OnAfterGetRecord()
    var
        UomRef: RecordRef;
    begin
        if UnitOfMeasure.Get(Rec.Code) then
            UnitOfMeasureDescription := UnitOfMeasure.Description
        else
            UnitOfMeasureDescription := '';
        // Without GMPI's field every UOM stays as entered (no conversion).
        SalesAppApplicable := true;
        // Re-read the row in full: an API page loads only the fields bound to
        // its controls, so GMPI's field is not loaded on Rec itself.
        if AllowInSalesAppFieldNo <> 0 then begin
            UomRef.Open(Database::"Item Unit of Measure");
            if UomRef.GetBySystemId(Rec.SystemId) then
                SalesAppApplicable := UomRef.Field(AllowInSalesAppFieldNo).Value;
            UomRef.Close();
        end;
    end;

    var
        UnitOfMeasure: Record "Unit of Measure";
        UnitOfMeasureDescription: Text[100];
        SalesAppApplicable: Boolean;
        AllowInSalesAppFieldNo: Integer;
}
