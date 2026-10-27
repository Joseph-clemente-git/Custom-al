codeunit 70135 "MJS Whse. Movement Mgt."
{
    var
        InvalidJsonErr: Label 'The lines parameter is not valid JSON. Expected an array like [{"itemNo":"...","quantity":1}].';
        NothingToRegisterErr: Label 'Movement %1 has no quantity to register — every Qty. to Handle is 0.', Comment = '%1 = warehouse movement no.';

    /// <summary>
    /// Replicates Register on a Warehouse Movement document — the activity BC
    /// creates from the Movement Worksheet's Create Movement function.
    /// LinesJson is an array like [{"itemNo":"TI-000001","quantity":1}] — the
    /// given quantity is applied as Qty. to Handle per item (distributed
    /// across that item's Take and Place lines); items not mentioned register
    /// 0. An empty LinesJson registers everything outstanding (BC's Autofill
    /// Qty. to Handle).
    /// </summary>
    procedure RegisterMovement(var MovementHeader: Record "Warehouse Activity Header"; LinesJson: Text)
    begin
        if LinesJson = '' then
            AutofillQtyToHandle(MovementHeader)
        else
            ApplyQuantities(MovementHeader, LinesJson);
        RegisterMovementDoc(MovementHeader);
    end;

    local procedure AutofillQtyToHandle(var MovementHeader: Record "Warehouse Activity Header")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        WhseActivityLine.SetRange("Activity Type", MovementHeader.Type);
        WhseActivityLine.SetRange("No.", MovementHeader."No.");
        WhseActivityLine.AutofillQtyToHandle(WhseActivityLine);
    end;

    local procedure ApplyQuantities(var MovementHeader: Record "Warehouse Activity Header"; LinesJson: Text)
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
        WhseActivityLine.SetRange("Activity Type", MovementHeader.Type);
        WhseActivityLine.SetRange("No.", MovementHeader."No.");
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
            // blank — the caller selects the destination bin (from
            // binContents / the movement line list) and it is validated onto
            // the blank Place lines here.
            SetPlaceBinIfBlank(MovementHeader, ItemNo, CopyStr(GetJsonText(ItemObject, 'binCode'), 1, 20));
            DistributeQty(MovementHeader, ItemNo, "Warehouse Action Type"::Take, Qty);
            DistributeQty(MovementHeader, ItemNo, "Warehouse Action Type"::Place, Qty);
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

    local procedure SetPlaceBinIfBlank(var MovementHeader: Record "Warehouse Activity Header"; ItemNo: Code[20]; BinCode: Code[20])
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        if BinCode = '' then
            exit;
        WhseActivityLine.SetRange("Activity Type", MovementHeader.Type);
        WhseActivityLine.SetRange("No.", MovementHeader."No.");
        WhseActivityLine.SetRange("Item No.", ItemNo);
        WhseActivityLine.SetRange("Action Type", WhseActivityLine."Action Type"::Place);
        WhseActivityLine.SetRange("Bin Code", '');
        if WhseActivityLine.FindSet(true) then
            repeat
                WhseActivityLine.Validate("Bin Code", BinCode);
                WhseActivityLine.Modify(true);
            until WhseActivityLine.Next() = 0;
    end;

    /// <summary>
    /// Spreads an item's registered quantity across its movement lines of one
    /// action type, first line first, capped per line at Qty. Outstanding.
    /// </summary>
    local procedure DistributeQty(var MovementHeader: Record "Warehouse Activity Header"; ItemNo: Code[20]; ActionType: Enum "Warehouse Action Type"; Qty: Decimal)
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        Remaining: Decimal;
        Handle: Decimal;
    begin
        Remaining := Qty;
        WhseActivityLine.SetRange("Activity Type", MovementHeader.Type);
        WhseActivityLine.SetRange("No.", MovementHeader."No.");
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

    local procedure RegisterMovementDoc(var MovementHeader: Record "Warehouse Activity Header")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
    begin
        WhseActivityLine.SetRange("Activity Type", MovementHeader.Type);
        WhseActivityLine.SetRange("No.", MovementHeader."No.");
        WhseActivityLine.SetFilter("Qty. to Handle", '>0');
        if not WhseActivityLine.FindFirst() then
            Error(NothingToRegisterErr, MovementHeader."No.");
        WhseActivityRegister.ShowHideDialog(true);
        WhseActivityRegister.Run(WhseActivityLine);
    end;
}
