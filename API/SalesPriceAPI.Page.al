page 70142 "MJS Sales Price API"
{
    // Read-only API over the legacy Sales Price table used by this company.
    // This is the exact source shown by the Business Central Sales Prices page
    // (Sales Type/Code, Item No., UOM, quantity, price, and effective dates).
    // Calculated compatibility fields keep the web contract aligned with the
    // modern Price List Line API shape without copying or migrating BC data.
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Sales Price';
    EntitySetCaption = 'Sales Prices';
    EntityName = 'salesPrice';
    EntitySetName = 'salesPrices';
    SourceTable = "Sales Price";
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
                field(priceListCode; EmptyCode)
                {
                    Caption = 'Price List Code';
                }
                field(lineNo; EmptyLineNo)
                {
                    Caption = 'Line No.';
                }
                field(status; ActiveStatus)
                {
                    Caption = 'Status';
                }
                field(priceType; SalePriceType)
                {
                    Caption = 'Price Type';
                }
                field(amountType; PriceAmountType)
                {
                    Caption = 'Amount Type';
                }
                field(sourceType; Rec."Sales Type")
                {
                    Caption = 'Source Type';
                }
                field(sourceNo; Rec."Sales Code")
                {
                    Caption = 'Source No.';
                }
                field(assetType; ItemAssetType)
                {
                    Caption = 'Asset Type';
                }
                field(assetNo; Rec."Item No.")
                {
                    Caption = 'Asset No.';
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date';
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'Ending Date';
                }
                field(minimumQuantity; Rec."Minimum Quantity")
                {
                    Caption = 'Minimum Quantity';
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                }
                field(lineDiscountPercent; EmptyDiscountPercent)
                {
                    Caption = 'Line Discount Percent';
                }
                field(allowLineDisc; Rec."Allow Line Disc.")
                {
                    Caption = 'Allow Line Discount';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Clear(EmptyCode);
        Clear(EmptyLineNo);
        Clear(EmptyDiscountPercent);
        ActiveStatus := 'Active';
        SalePriceType := 'Sale';
        PriceAmountType := 'Price';
        ItemAssetType := 'Item';
    end;

    var
        EmptyCode: Code[20];
        EmptyLineNo: Integer;
        EmptyDiscountPercent: Decimal;
        ActiveStatus: Text[30];
        SalePriceType: Text[30];
        PriceAmountType: Text[30];
        ItemAssetType: Text[30];
}
