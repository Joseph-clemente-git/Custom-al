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
                // GMPI's Deals / Wholesale Discount 1-6, which GMPI copies onto
                // the Sales Line from the best discount row. Resolved by name
                // (GMPI is a separate app); blank/0 when GMPI is not installed
                // so pricing reads keep working.
                field(deals; Deals)
                {
                    Caption = 'Deals';
                }
                field(wholesaleDiscount1; WholesaleDiscount[1])
                {
                    Caption = 'Wholesale Discount 1';
                }
                field(wholesaleDiscount2; WholesaleDiscount[2])
                {
                    Caption = 'Wholesale Discount 2';
                }
                field(wholesaleDiscount3; WholesaleDiscount[3])
                {
                    Caption = 'Wholesale Discount 3';
                }
                field(wholesaleDiscount4; WholesaleDiscount[4])
                {
                    Caption = 'Wholesale Discount 4';
                }
                field(wholesaleDiscount5; WholesaleDiscount[5])
                {
                    Caption = 'Wholesale Discount 5';
                }
                field(wholesaleDiscount6; WholesaleDiscount[6])
                {
                    Caption = 'Wholesale Discount 6';
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        i: Integer;
    begin
        // Resolved once per request rather than once per returned row.
        DealsFieldNo:=GetDiscountFieldNo('GMPI Deals');
        for i:=1 to 6 do WholesaleDiscountFieldNo[i]:=GetDiscountFieldNo(StrSubstNo('GMPI Wholesale Discount %1', i));
    end;
    trigger OnAfterGetRecord()
    var
        DiscountRef: RecordRef;
        i: Integer;
    begin
        Clear(Deals);
        Clear(WholesaleDiscount);
        DiscountRef.GetTable(Rec);
        if DealsFieldNo <> 0 then Deals:=DiscountRef.Field(DealsFieldNo).Value;
        for i:=1 to 6 do if WholesaleDiscountFieldNo[i] <> 0 then WholesaleDiscount[i]:=DiscountRef.Field(WholesaleDiscountFieldNo[i]).Value;
        Clear(EmptyCode);
        Clear(EmptyLineNo);
        Clear(EmptyUnitPrice);
        ActiveStatus:='Active';
        SalePriceType:='Sale';
        DiscountAmountType:='Discount';
    end;
    local procedure GetDiscountFieldNo(FieldName: Text[30]): Integer
    var
        DiscountField: Record Field;
    begin
        DiscountField.SetRange(TableNo, Database::"Sales Line Discount");
        DiscountField.SetRange(FieldName, FieldName);
        DiscountField.SetRange(Enabled, true);
        if DiscountField.FindFirst() then exit(DiscountField."No.");
        exit(0);
    end;
    var Deals: Text[20];
    WholesaleDiscount: array[6] of Decimal;
    DealsFieldNo: Integer;
    WholesaleDiscountFieldNo: array[6] of Integer;
    EmptyCode: Code[20];
    EmptyLineNo: Integer;
    EmptyUnitPrice: Decimal;
    ActiveStatus: Text[30];
    SalePriceType: Text[30];
    DiscountAmountType: Text[30];
}
