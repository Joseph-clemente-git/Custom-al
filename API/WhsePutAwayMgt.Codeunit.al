codeunit 70134 "MJS Whse. Put-away Mgt."
{
    var
        InvalidJsonErr: Label 'The lines parameter is not valid JSON. Expected an array like [{"itemNo":"...","quantity":1}].';
        NothingToRegisterErr: Label 'Put-away %1 has no quantity to register — every Qty. to Handle is 0.', Comment = '%1 = warehouse put-away no.';
        SameTakeAndPlaceBinErr: Label 'The destination bin %1 must be different from the take bin for item %2 on put-away %3.', Comment = '%1 = destination bin, %2 = item no., %3 = put-away no.';

    /// <summary>
    /// Replicates Register Put-away on a Warehouse Put-away document — the
    /// activity BC creates automatically when a Warehouse Receipt is posted at
    /// a location that requires put-away. LinesJson is an array like
    /// [{"itemNo":"TI-000001","quantity":1}] — the given quantity is applied
    /// as Qty. to Handle per item (distributed across that item's Take and
    /// Place lines); items not mentioned register 0. An empty LinesJson
    /// registers everything outstanding (BC's Autofill Qty. to Handle).
    /// </summary>
    procedure RegisterPutAway(var PutAwayHeader: Record "Warehouse Activity Header"; LinesJson: Text)
    begin
        if LinesJson = '' then
            AutofillQtyToHandle(PutAwayHeader)
        else
            ApplyQuantities(PutAwayHeader, LinesJson);
        RegisterPutAwayDoc(PutAwayHeader);
    end;

    local procedure AutofillQtyToHandle(var PutAwayHeader: Record "Warehouse Activity Header")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        WhseActivityLine.SetRange("Activity Type", PutAwayHeader.Type);
        WhseActivityLine.SetRange("No.", PutAwayHeader."No.");
        WhseActivityLine.AutofillQtyToHandle(WhseActivityLine);
    end;

    local procedure ApplyQuantities(var PutAwayHeader: Record "Warehouse Activity Header"; LinesJson: Text)
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        Items: JsonArray;
        ItemToken: JsonToken;
        ValueToken: JsonToken;
        ItemObject: JsonObject;
        ItemNo: Code[20];
        Qty: Decimal;
    begin
        if not Items.ReadFrom(LinesJson) then
            Error(InvalidJsonErr);

        // Zero everything first so items the caller doesn't mention (or sends
        // 0 for) register nothing.
        WhseActivityLine.SetRange("Activity Type", PutAwayHeader.Type);
        WhseActivityLine.SetRange("No.", PutAwayHeader."No.");
        if WhseActivityLine.FindSet(true) then
            repeat
                WhseActivityLine.Validate("Qty. to Handle", 0);
                WhseActivityLine.Modify(true);
            until WhseActivityLine.Next() = 0;

        foreach ItemToken in Items do begin
            ItemObject := ItemToken.AsObject();
            if not ItemObject.Get('itemNo', ValueToken) then
                Error(InvalidJsonErr);
            ItemNo := CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(ItemNo));
            if not ItemObject.Get('quantity', ValueToken) then
                Error(InvalidJsonErr);
            Qty := ValueToken.AsValue().AsDecimal();
            // Optional per-item destination bin: on locations without
            // directed put-away and pick, BC can leave the Place line's bin
            // blank — or, when BC incorrectly pre-filled it with the Take
            // bin, the caller selects a destination bin. Validate that value
            // onto every Place line for the item before registering it.
            SetPlaceBin(PutAwayHeader, ItemNo, CopyStr(GetJsonText(ItemObject, 'binCode'), 1, 20));
            DistributeQty(PutAwayHeader, ItemNo, "Warehouse Action Type"::Take, Qty);
            DistributeQty(PutAwayHeader, ItemNo, "Warehouse Action Type"::Place, Qty);
        end;
    end;

    local procedure GetJsonText(Obj: JsonObject; KeyName: Text): Text
    var
        Token: JsonToken;
    begin
        if Obj.Get(KeyName, Token) then
            if Token.IsValue() and not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsText());
        exit('');
    end;

    local procedure SetPlaceBin(var PutAwayHeader: Record "Warehouse Activity Header"; ItemNo: Code[20]; BinCode: Code[20])
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        if BinCode = '' then
            exit;
        WhseActivityLine.SetRange("Activity Type", PutAwayHeader.Type);
        WhseActivityLine.SetRange("No.", PutAwayHeader."No.");
        WhseActivityLine.SetRange("Item No.", ItemNo);
        WhseActivityLine.SetRange("Action Type", WhseActivityLine."Action Type"::Place);
        if WhseActivityLine.FindSet(true) then
            repeat
                EnsureDifferentFromTakeBin(PutAwayHeader, ItemNo, BinCode);
                if WhseActivityLine."Bin Code" <> BinCode then begin
                    WhseActivityLine.Validate("Bin Code", BinCode);
                    WhseActivityLine.Modify(true);
                end;
            until WhseActivityLine.Next() = 0;
    end;

    local procedure EnsureDifferentFromTakeBin(var PutAwayHeader: Record "Warehouse Activity Header"; ItemNo: Code[20]; BinCode: Code[20])
    var
        TakeLine: Record "Warehouse Activity Line";
    begin
        TakeLine.SetRange("Activity Type", PutAwayHeader.Type);
        TakeLine.SetRange("No.", PutAwayHeader."No.");
        TakeLine.SetRange("Item No.", ItemNo);
        TakeLine.SetRange("Action Type", TakeLine."Action Type"::Take);
        TakeLine.SetRange("Bin Code", BinCode);
        if TakeLine.FindFirst() then
            Error(SameTakeAndPlaceBinErr, BinCode, ItemNo, PutAwayHeader."No.");
    end;

    /// <summary>
    /// Spreads an item's registered quantity across its put-away lines of one
    /// action type, first line first, capped per line at Qty. Outstanding.
    /// </summary>
    local procedure DistributeQty(var PutAwayHeader: Record "Warehouse Activity Header"; ItemNo: Code[20]; ActionType: Enum "Warehouse Action Type"; Qty: Decimal)
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        Remaining: Decimal;
        Handle: Decimal;
    begin
        Remaining := Qty;
        WhseActivityLine.SetRange("Activity Type", PutAwayHeader.Type);
        WhseActivityLine.SetRange("No.", PutAwayHeader."No.");
        WhseActivityLine.SetRange("Item No.", ItemNo);
        WhseActivityLine.SetRange("Action Type", ActionType);
        if WhseActivityLine.FindSet(true) then
            repeat
                Handle := WhseActivityLine."Qty. Outstanding";
                if Handle > Remaining then
                    Handle := Remaining;
                if WhseActivityLine."Qty. to Handle" <> Handle then begin
                    WhseActivityLine.Validate("Qty. to Handle", Handle);
                    WhseActivityLine.Modify(true);
                end;
                Remaining -= Handle;
            until (WhseActivityLine.Next() = 0) or (Remaining <= 0);
    end;

    local procedure RegisterPutAwayDoc(var PutAwayHeader: Record "Warehouse Activity Header")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
    begin
        WhseActivityLine.SetRange("Activity Type", PutAwayHeader.Type);
        WhseActivityLine.SetRange("No.", PutAwayHeader."No.");
        WhseActivityLine.SetFilter("Qty. to Handle", '>0');
        if not WhseActivityLine.FindFirst() then
            Error(NothingToRegisterErr, PutAwayHeader."No.");
        WhseActivityRegister.ShowHideDialog(true);
        WhseActivityRegister.Run(WhseActivityLine);
    end;
}
