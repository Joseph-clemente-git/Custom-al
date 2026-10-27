page 70139 "MJS VAT Bus. Post. Group API"
{
    // Supplies the Sales Order header lookup with the same codes and
    // descriptions shown by Business Central's VAT Bus. Posting Group lookup.
    // GMPI's setup keeps separate Customer- and Vendor-side groups with
    // parallel descriptions (e.g. "Customer - Vatable" / "Vendor - Vatable");
    // only the Customer-side groups are relevant to a sales order.
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'VAT Business Posting Group';
    EntitySetCaption = 'VAT Business Posting Groups';
    EntityName = 'vatBusinessPostingGroup';
    EntitySetName = 'vatBusinessPostingGroups';
    SourceTable = "VAT Business Posting Group";
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DataAccessIntent = ReadOnly;

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
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetFilter(Description, '@*Customer*');
    end;
}
