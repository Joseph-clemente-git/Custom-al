page 70144 "MJS Sales Line Discount API"
{
    // Read-only API over the legacy Sales Line Discount table used by this
    // company. It mirrors the normalized pricing fields consumed by the web
    // app without copying or changing Business Central pricing data.
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Sales Line Discount';
    EntitySetCaption = 'Sales Line Discounts';
    EntityName = 'salesLineDiscount';
    EntitySetName = 'salesLineDiscounts';
    SourceTable = "Sales Line Discount";
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
                field(amountType; DiscountAmountType)
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
                field(assetType; Rec.Type)
                {
                    Caption = 'Asset Type';
                }
                field(assetNo; Rec.Code)
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
                field(unitPrice; EmptyUnitPrice)
                {
                    Caption = 'Unit Price';
                }
                field(lineDiscountPercent; Rec."Line Discount %")
                {
                    Caption = 'Line Discount Percent';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Clear(EmptyCode);
        Clear(EmptyLineNo);
        Clear(EmptyUnitPrice);
        ActiveStatus := 'Active';
        SalePriceType := 'Sale';
        DiscountAmountType := 'Discount';
    end;

    var
        EmptyCode: Code[20];
        EmptyLineNo: Integer;
        EmptyUnitPrice: Decimal;
        ActiveStatus: Text[30];
        SalePriceType: Text[30];
        DiscountAmountType: Text[30];
}
