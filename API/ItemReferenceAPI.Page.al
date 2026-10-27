page 70117 "MJS Item Reference API"
{
    // Barcode lookup for the warehouse scanner. Item Reference is the source
    // of truth used by BC's Item Reference Entries page; restricting the API
    // page to Bar Code rows prevents vendor/customer references from being
    // accepted as physical scans.
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Item Barcode Reference';
    EntitySetCaption = 'Item Barcode References';
    EntityName = 'itemReference';
    EntitySetName = 'itemReferences';
    SourceTable = "Item Reference";
    SourceTableView = where("Reference Type" = const("Bar Code"));
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
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure")
                {
                    Caption = 'Unit of Measure Code';
                }
                field(referenceNo; Rec."Reference No.")
                {
                    Caption = 'Barcode';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date';
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'Ending Date';
                }
            }
        }
    }
}
