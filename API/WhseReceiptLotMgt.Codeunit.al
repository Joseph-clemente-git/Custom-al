codeunit 70136 "MJS Whse. Receipt Lot Mgt."
{
    // Lot assignment on inbound — the API equivalent of Item Tracking Lines on
    // a Warehouse Receipt line (which BC opens on the line's source document).
    // Custom rule: Purchase Order receiving only uses Lot Nos. (batches) that
    // already exist as Lot No. Information cards — it never creates a lot,
    // like BC's own Lot Info. Inbound Must Exist, but for every item.

    var
        InvalidJsonErr: Label 'The lots parameter is not valid JSON. Expected an array like [{"lotNo":"L001","expirationDate":"2027-12-31","quantity":1}].';
        UnsupportedSourceErr: Label 'Lots can only be created here on purchase order receipt lines — %1 %2 takes its lots from its source document.', Comment = '%1 = source document, %2 = source no.';
        BlankLotErr: Label 'Every lot needs a Lot No. and a quantity above 0.';
        DuplicateLotErr: Label 'Lot %1 is listed more than once.', Comment = '%1 = lot no.';
        ExpirationRequiredErr: Label 'Item %1 requires an expiration date for lot %2.', Comment = '%1 = item no., %2 = lot no.';
        LotNotFoundErr: Label 'Lot %1 does not exist for item %2. Only Lot Nos. in Business Central (Lot No. Information) can be received.', Comment = '%1 = lot no., %2 = item no.';
        LotBlockedErr: Label 'Lot %1 of item %2 is blocked.', Comment = '%1 = lot no., %2 = item no.';
        ExpirationMismatchErr: Label 'Lot %1 already expires on %2 in Business Central; it cannot be received with %3.', Comment = '%1 = lot no., %2 = existing expiration date, %3 = entered expiration date';
        TooMuchErr: Label 'The lots total %1, more than the %2 outstanding on receipt line %3.', Comment = '%1 = lots total, %2 = qty. outstanding, %3 = line no.';

    /// <summary>
    /// Replaces the lot tracking of one Warehouse Receipt line with LotsJson
    /// ([{"lotNo","expirationDate" (yyyy-mm-dd, required),"quantity"}], in the
    /// line's unit of measure) — the same Reservation Entries (status
    /// Surplus) BC's Item Tracking Lines page writes for the source line,
    /// created through the standard Create Reserv. Entry codeunit. Every lot
    /// must already exist (Lot No. Information, not Blocked) and keep the
    /// expiry already posted for it. An empty array clears the lots.
    /// </summary>
    procedure AssignLots(WhseRcptHeader: Record "Warehouse Receipt Header"; LineNo: Integer; LotsJson: Text)
    var
        WhseRcptLine: Record "Warehouse Receipt Line";
        Item: Record Item;
        ReservEntry: Record "Reservation Entry";
        LotNoInfo: Record "Lot No. Information";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        Lots: JsonArray;
        LotToken: JsonToken;
        SeenLots: List of [Code[50]];
        LotNo: Code[50];
        ExpirationDate: Date;
        ExistingExpirationDate: Date;
        Qty: Decimal;
        Total: Decimal;
    begin
        WhseRcptLine.Get(WhseRcptHeader."No.", LineNo);
        // Purchase Order receiving only: a sales return brings back the
        // customer's original lot (Get Posted Document Lines to Reverse).
        if WhseRcptLine."Source Type" <> Database::"Purchase Line" then
            Error(UnsupportedSourceErr, WhseRcptLine."Source Document", WhseRcptLine."Source No.");
        if not Lots.ReadFrom(LotsJson) then
            Error(InvalidJsonErr);
        Item.Get(WhseRcptLine."Item No.");
        Item.TestField("Item Tracking Code");

        // Validate everything before touching the existing tracking.
        foreach LotToken in Lots do begin
            ReadLot(LotToken, LotNo, ExpirationDate, Qty);
            if (LotNo = '') or (Qty <= 0) then
                Error(BlankLotErr);
            if SeenLots.Contains(LotNo) then
                Error(DuplicateLotErr, LotNo);
            SeenLots.Add(LotNo);
            // Purchase Order receiving always records the lot's expiry.
            if ExpirationDate = 0D then
                Error(ExpirationRequiredErr, Item."No.", LotNo);
            if not LotNoInfo.Get(WhseRcptLine."Item No.", WhseRcptLine."Variant Code", LotNo) then
                Error(LotNotFoundErr, LotNo, Item."No.");
            if LotNoInfo.Blocked then
                Error(LotBlockedErr, LotNo, Item."No.");
            ExistingExpirationDate := GetPostedExpirationDate(WhseRcptLine, LotNo);
            if (ExistingExpirationDate <> 0D) and (ExistingExpirationDate <> ExpirationDate) then
                Error(ExpirationMismatchErr, LotNo, ExistingExpirationDate, ExpirationDate);
            Total += Qty;
        end;
        if Total > WhseRcptLine."Qty. Outstanding" then
            Error(TooMuchErr, Total, WhseRcptLine."Qty. Outstanding", LineNo);

        // Replace the line's lot tracking; real reservations are left alone.
        FilterLotTracking(WhseRcptLine, ReservEntry);
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Surplus);
        ReservEntry.DeleteAll(true);

        foreach LotToken in Lots do begin
            ReadLot(LotToken, LotNo, ExpirationDate, Qty);
            Clear(ReservEntry);
            ReservEntry."Lot No." := LotNo;
            CreateReservEntry.CreateReservEntryFor(
              WhseRcptLine."Source Type", WhseRcptLine."Source Subtype", WhseRcptLine."Source No.", '', 0, WhseRcptLine."Source Line No.",
              WhseRcptLine."Qty. per Unit of Measure", Qty, Round(Qty * WhseRcptLine."Qty. per Unit of Measure", 0.00001), ReservEntry);
            CreateReservEntry.SetDates(0D, ExpirationDate);
            CreateReservEntry.CreateEntry(
              WhseRcptLine."Item No.", WhseRcptLine."Variant Code", WhseRcptLine."Location Code", WhseRcptLine.Description,
              WhseRcptLine."Due Date", 0D, 0, "Reservation Status"::Surplus);
        end;
    end;

    /// <summary>
    /// The lots already assigned to a receipt line's source line, as JSON
    /// [{"lotNo","expirationDate","quantity"}] in the line's unit of measure.
    /// </summary>
    procedure GetAssignedLotsJson(WhseRcptLine: Record "Warehouse Receipt Line"): Text
    var
        ReservEntry: Record "Reservation Entry";
        Lots: JsonArray;
        LotObject: JsonObject;
        QtyPerUoM: Decimal;
        Result: Text;
    begin
        QtyPerUoM := WhseRcptLine."Qty. per Unit of Measure";
        if QtyPerUoM = 0 then
            QtyPerUoM := 1;
        FilterLotTracking(WhseRcptLine, ReservEntry);
        if ReservEntry.FindSet() then
            repeat
                Clear(LotObject);
                LotObject.Add('lotNo', ReservEntry."Lot No.");
                if ReservEntry."Expiration Date" <> 0D then
                    LotObject.Add('expirationDate', Format(ReservEntry."Expiration Date", 0, 9))
                else
                    LotObject.Add('expirationDate', '');
                LotObject.Add('quantity', Round(ReservEntry."Quantity (Base)" / QtyPerUoM, 0.00001));
                Lots.Add(LotObject);
            until ReservEntry.Next() = 0;
        Lots.WriteTo(Result);
        exit(Result);
    end;

    /// <summary>
    /// Whether posting this purchase receipt line needs lots (the item's Item
    /// Tracking Code has Lot Purchase Inbound Tracking); every such lot needs
    /// an expiration date. Other source types report false: their
    /// lots come from the source document.
    /// </summary>
    procedure GetLotSetup(WhseRcptLine: Record "Warehouse Receipt Line"; var LotRequired: Boolean; var ExpirationRequired: Boolean)
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        LotRequired := false;
        ExpirationRequired := false;
        if WhseRcptLine."Source Type" <> Database::"Purchase Line" then
            exit;
        if not Item.Get(WhseRcptLine."Item No.") then
            exit;
        if (Item."Item Tracking Code" = '') or not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit;
        LotRequired := ItemTrackingCode."Lot Purchase Inbound Tracking";
        // Purchase Order receiving always records the lot's expiry.
        ExpirationRequired := LotRequired;
    end;

    /// <summary>
    /// The expiry already posted for an existing lot (on Item Ledger Entry), or 0D when the lot has no posted entries yet.
    /// </summary>
    local procedure GetPostedExpirationDate(WhseRcptLine: Record "Warehouse Receipt Line"; LotNo: Code[50]): Date
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetLoadFields("Expiration Date");
        ItemLedgerEntry.SetRange("Item No.", WhseRcptLine."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", WhseRcptLine."Variant Code");
        ItemLedgerEntry.SetRange("Lot No.", LotNo);
        ItemLedgerEntry.SetFilter("Expiration Date", '<>%1', 0D);
        if ItemLedgerEntry.FindFirst() then
            exit(ItemLedgerEntry."Expiration Date");
        exit(0D);
    end;

    local procedure FilterLotTracking(WhseRcptLine: Record "Warehouse Receipt Line"; var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.SetSourceFilter(
          WhseRcptLine."Source Type", WhseRcptLine."Source Subtype", WhseRcptLine."Source No.", WhseRcptLine."Source Line No.", true);
        ReservEntry.SetSourceFilter('', 0);
        ReservEntry.SetRange(Positive, true);
        ReservEntry.SetFilter("Lot No.", '<>%1', '');
    end;

    local procedure ReadLot(LotToken: JsonToken; var LotNo: Code[50]; var ExpirationDate: Date; var Qty: Decimal)
    var
        LotObject: JsonObject;
        ValueToken: JsonToken;
        DateText: Text;
    begin
        if not LotToken.IsObject() then
            Error(InvalidJsonErr);
        LotObject := LotToken.AsObject();
        LotNo := '';
        ExpirationDate := 0D;
        Qty := 0;
        if LotObject.Get('lotNo', ValueToken) then
            if not ValueToken.AsValue().IsNull() then
                LotNo := CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(LotNo));
        if LotObject.Get('quantity', ValueToken) then
            if not ValueToken.AsValue().IsNull() then
                Qty := ValueToken.AsValue().AsDecimal();
        if LotObject.Get('expirationDate', ValueToken) then
            if not ValueToken.AsValue().IsNull() then begin
                DateText := ValueToken.AsValue().AsText();
                if (DateText <> '') and not Evaluate(ExpirationDate, DateText, 9) then
                    Error(InvalidJsonErr);
            end;
    end;
}
