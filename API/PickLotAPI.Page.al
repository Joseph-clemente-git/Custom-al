page 70106 "MJS Pick Lot API"
{
    // Lot No. lookup for one Warehouse Pick line — the same Item Tracking
    // Summary the BC client shows from the line's Lot No. field, built by the
    // standard Item Tracking Data Collection codeunit. Query with
    // $filter=pickNo eq '...' and pickLineNo eq 10000 (optionally
    // and binCode eq '...' — the take bin the caller chose when the line's
    // is blank). Backs the Lot No. List
    // on majesty-pharma-web's Checking page (fetchBcPickLots).
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Pick Lot';
    EntitySetCaption = 'Pick Lots';
    EntityName = 'pickLot';
    EntitySetName = 'pickLots';
    SourceTable = "MJS Pick Lot Buffer";
    SourceTableTemporary = true;
    DelayedInsert = true;
    ODataKeyFields = "Lot No.";
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(pickNo; Rec."Pick No.")
                {
                    Caption = 'Pick No.';
                }
                field(pickLineNo; Rec."Pick Line No.")
                {
                    Caption = 'Pick Line No.';
                }
                field(lotNo; Rec."Lot No.")
                {
                    Caption = 'Lot No.';
                }
                field(expirationDate; Rec."Expiration Date")
                {
                    Caption = 'Expiration Date';
                }
                field(totalQuantity; Rec."Total Quantity")
                {
                    Caption = 'Total Quantity';
                }
                field(availableQuantity; Rec."Available Quantity")
                {
                    Caption = 'Available Quantity';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                }
                field(binCode; Rec."Bin Code")
                {
                    Caption = 'Bin Code';
                }
            }
        }
    }

    var
        Loaded: Boolean;

    trigger OnFindRecord(Which: Text): Boolean
    var
        PickMgt: Codeunit "MJS Whse. Pick Mgt.";
        PickLineNo: Integer;
        BinCode: Code[20];
    begin
        // The pick line comes from the caller's $filter, so the rows are
        // built once, on first read, from the filtered pick line.
        if not Loaded then begin
            Loaded := true;
            if (Rec.GetFilter("Pick No.") <> '') and (Rec.GetFilter("Pick Line No.") <> '') then begin
                PickLineNo := Rec.GetRangeMin("Pick Line No.");
                if Rec.GetFilter("Bin Code") <> '' then
                    BinCode := Rec.GetRangeMin("Bin Code");
                PickMgt.FillPickLots(Rec.GetRangeMin("Pick No."), PickLineNo, BinCode, Rec);
            end;
        end;
        exit(Rec.Find(Which));
    end;
}
