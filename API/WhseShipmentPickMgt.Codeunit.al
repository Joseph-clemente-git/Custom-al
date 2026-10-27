codeunit 70132 "MJS Whse. Pick Mgt."
{
    var
        NoLinesErr: Label 'Warehouse shipment %1 has no lines to pick.', Comment = '%1 = warehouse shipment no.';
        NothingToHandleErr: Label 'No pick was created for warehouse shipment %1 — nothing to handle. Check item availability and bin contents at the location.', Comment = '%1 = warehouse shipment no.';
        NoPickErr: Label 'Warehouse shipment %1 has no open pick to register.', Comment = '%1 = warehouse shipment no.';
        InvalidJsonErr: Label 'The lines parameter is not valid JSON. Expected an array like [{"itemNo":"...","quantity":1}].';
        NothingToRegisterErr: Label 'Pick %1 has no quantity to register — every Qty. to Handle is 0.', Comment = '%1 = warehouse pick no.';
        LotTotalErr: Label 'The lots of item %1 total %2, but %3 is being registered.', Comment = '%1 = item no., %2 = lot total, %3 = quantity';
        DuplicateLotErr: Label 'Lot %1 is listed more than once for item %2.', Comment = '%1 = lot no., %2 = item no.';
        LotsOverOutstandingErr: Label 'The lots of item %1 exceed its outstanding quantity on the pick.', Comment = '%1 = item no.';
        // API sessions run in UTC, so Today/Time would stamp UTC times on the
        // documents. Convert to warehouse local time instead. The Philippines
        // is UTC+8 with no DST — Windows id "Singapore Standard Time".
        WarehouseTzTok: Label 'Singapore Standard Time', Locked = true;

    /// <summary>
    /// Replicates the BC client's Create Pick action on the Warehouse Shipment
    /// page: releases the shipment if it is still open, then runs the
    /// Whse.-Shipment - Create Pick report silently for all its lines.
    /// Errors if BC ends up creating no pick activity (so an API caller gets a
    /// real failure instead of a silent no-op).
    /// </summary>
    procedure CreatePick(var WhseShptHeader: Record "Warehouse Shipment Header"; AssignedUserId: Code[50]; SortingMethod: Enum "Whse. Activity Sorting Method")
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        ReleaseWhseShipment: Codeunit "Whse.-Shipment Release";
        CreatePickReport: Report "Whse.-Shipment - Create Pick";
    begin
        if WhseShptHeader.Status = WhseShptHeader.Status::Open then
            ReleaseWhseShipment.Release(WhseShptHeader);

        // Stamp the assignment onto the shipment header too, so Assigned User
        // ID / Assignment Date / Assignment Time / Sorting Method show on the
        // BC document (the report below only writes them to the pick).
        // Validating Assigned User ID fills the date/time automatically (it
        // requires the user to be a Warehouse Employee at the location), but
        // with the session's UTC clock — override with warehouse local time.
        if (AssignedUserId <> '') and (AssignedUserId <> WhseShptHeader."Assigned User ID") then begin
            WhseShptHeader.Validate("Assigned User ID", AssignedUserId);
            WhseShptHeader."Assignment Date" := DT2Date(LocalNow());
            WhseShptHeader."Assignment Time" := DT2Time(LocalNow());
        end;
        if SortingMethod <> WhseShptHeader."Sorting Method" then
            WhseShptHeader.Validate("Sorting Method", SortingMethod);
        WhseShptHeader.Modify(true);

        WhseShptLine.SetRange("No.", WhseShptHeader."No.");
        if not WhseShptLine.FindFirst() then
            Error(NoLinesErr, WhseShptHeader."No.");

        CreatePickReport.SetWhseShipmentLine(WhseShptLine, WhseShptHeader);
        CreatePickReport.Initialize(AssignedUserId, SortingMethod, false, false, false);
        CreatePickReport.SetHideValidationDialog(true);
        CreatePickReport.UseRequestPage(false);
        CreatePickReport.RunModal();

        if not PickExists(WhseShptHeader."No.") then
            Error(NothingToHandleErr, WhseShptHeader."No.");

        FixPickAssignmentTime(WhseShptHeader."No.");
    end;

    /// <summary>
    /// The Create Pick report stamps Assignment Date/Time on the pick using
    /// the API session's UTC clock — rewrite them in warehouse local time.
    /// </summary>
    local procedure FixPickAssignmentTime(WhseShipmentNo: Code[20])
    var
        PickHeader: Record "Warehouse Activity Header";
    begin
        FindPick(WhseShipmentNo, PickHeader);
        if PickHeader."Assigned User ID" = '' then
            exit;
        PickHeader."Assignment Date" := DT2Date(LocalNow());
        PickHeader."Assignment Time" := DT2Time(LocalNow());
        PickHeader.Modify();
    end;

    local procedure LocalNow(): DateTime
    var
        TimeZoneCU: Codeunit "Time Zone";
    begin
        exit(CurrentDateTime() + TimeZoneCU.GetTimezoneOffset(CurrentDateTime(), WarehouseTzTok));
    end;

    /// <summary>
    /// Replicates Register Pick on the Warehouse Pick document belonging to
    /// the shipment. LinesJson is an array like
    /// [{"itemNo":"TI-000001","quantity":1}] (optional binCode and lots
    /// [{"lotNo","expirationDate","quantity"}] per item) — the given quantity is applied
    /// as Qty. to Handle per item (distributed across that item's Take and
    /// Place lines); items not mentioned register 0. An empty LinesJson
    /// registers everything outstanding (BC's Autofill Qty. to Handle).
    /// </summary>
    procedure RegisterPick(WhseShipmentNo: Code[20]; LinesJson: Text)
    var
        PickHeader: Record "Warehouse Activity Header";
    begin
        FindPick(WhseShipmentNo, PickHeader);
        if LinesJson = '' then
            AutofillQtyToHandle(PickHeader)
        else
            ApplyQuantities(PickHeader, LinesJson);
        RegisterPickDoc(PickHeader);
    end;

    local procedure FindPick(WhseShipmentNo: Code[20]; var PickHeader: Record "Warehouse Activity Header")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        WhseActivityLine.SetRange("Activity Type", WhseActivityLine."Activity Type"::Pick);
        WhseActivityLine.SetRange("Whse. Document Type", WhseActivityLine."Whse. Document Type"::Shipment);
        WhseActivityLine.SetRange("Whse. Document No.", WhseShipmentNo);
        if not WhseActivityLine.FindFirst() then
            Error(NoPickErr, WhseShipmentNo);
        PickHeader.Get(PickHeader.Type::Pick, WhseActivityLine."No.");
    end;

    local procedure AutofillQtyToHandle(var PickHeader: Record "Warehouse Activity Header")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        WhseActivityLine.SetRange("Activity Type", PickHeader.Type);
        WhseActivityLine.SetRange("No.", PickHeader."No.");
        WhseActivityLine.AutofillQtyToHandle(WhseActivityLine);
    end;

    local procedure ApplyQuantities(var PickHeader: Record "Warehouse Activity Header"; LinesJson: Text)
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
        WhseActivityLine.SetRange("Activity Type", PickHeader.Type);
        WhseActivityLine.SetRange("No.", PickHeader."No.");
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
            // Optional per-item take bin: BC only pre-fills the Take bin from
            // the item's DEFAULT bin content, so a non-default bin arrives
            // blank and registration would fail — the caller selects the bin
            // (from binContents) and it is validated onto the blank Take
            // lines here.
            SetTakeBinIfBlank(PickHeader, ItemNo, CopyStr(GetJsonText(ItemObject, 'binCode'), 1, 20));
            // Optional lots chosen by the checker: a lot-tracked item can't
            // register with a blank Lot No.
            if ItemObject.Get('lots', ValueToken) then
                if ValueToken.IsArray() then
                    AssignLots(PickHeader, ItemNo, ValueToken.AsArray(), Qty);
            DistributeQty(PickHeader, ItemNo, "Warehouse Action Type"::Take, Qty);
            DistributeQty(PickHeader, ItemNo, "Warehouse Action Type"::Place, Qty);
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

    local procedure SetTakeBinIfBlank(var PickHeader: Record "Warehouse Activity Header"; ItemNo: Code[20]; BinCode: Code[20])
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        if BinCode = '' then
            exit;
        WhseActivityLine.SetRange("Activity Type", PickHeader.Type);
        WhseActivityLine.SetRange("No.", PickHeader."No.");
        WhseActivityLine.SetRange("Item No.", ItemNo);
        WhseActivityLine.SetRange("Action Type", WhseActivityLine."Action Type"::Take);
        WhseActivityLine.SetRange("Bin Code", '');
        if WhseActivityLine.FindSet(true) then
            repeat
                WhseActivityLine.Validate("Bin Code", BinCode);
                WhseActivityLine.Modify(true);
            until WhseActivityLine.Next() = 0;
    end;

    /// <summary>
    /// Sets the checker's lots (Lot No., Expiration Date as yyyy-mm-dd,
    /// Quantity in the pick line's UOM) on the item's Take and Place lines,
    /// replacing any lot Create Pick set, and splits a line (BC's Split Line)
    /// where a lot covers only part of it. The lots must total Qty. On
    /// Register, BC carries the pick's lots back to the source line's Item
    /// Tracking Lines.
    /// </summary>
    local procedure AssignLots(var PickHeader: Record "Warehouse Activity Header"; ItemNo: Code[20]; Lots: JsonArray; Qty: Decimal)
    var
        LotToken: JsonToken;
        LotObject: JsonObject;
        ValueToken: JsonToken;
        LotNos: List of [Code[50]];
        ExpirationDates: List of [Date];
        LotQtys: List of [Decimal];
        LotNo: Code[50];
        ExpirationDateText: Text;
        ExpirationDate: Date;
        LotQty: Decimal;
        Total: Decimal;
    begin
        if Lots.Count() = 0 then
            exit;
        foreach LotToken in Lots do begin
            LotObject := LotToken.AsObject();
            LotNo := CopyStr(GetJsonText(LotObject, 'lotNo'), 1, MaxStrLen(LotNo));
            if (LotNo = '') or not LotObject.Get('quantity', ValueToken) then
                Error(InvalidJsonErr);
            LotQty := ValueToken.AsValue().AsDecimal();
            if LotQty <= 0 then
                Error(InvalidJsonErr);
            ExpirationDate := 0D;
            ExpirationDateText := GetJsonText(LotObject, 'expirationDate');
            if ExpirationDateText <> '' then
                if not Evaluate(ExpirationDate, ExpirationDateText, 9) then
                    Error(InvalidJsonErr);
            if LotNos.Contains(LotNo) then
                Error(DuplicateLotErr, LotNo, ItemNo);
            LotNos.Add(LotNo);
            ExpirationDates.Add(ExpirationDate);
            LotQtys.Add(LotQty);
            Total += LotQty;
        end;
        if Total <> Qty then
            Error(LotTotalErr, ItemNo, Total, Qty);
        AssignLotsToLines(PickHeader, ItemNo, "Warehouse Action Type"::Take, LotNos, ExpirationDates, LotQtys);
        AssignLotsToLines(PickHeader, ItemNo, "Warehouse Action Type"::Place, LotNos, ExpirationDates, LotQtys);
    end;

    /// <summary>
    /// Walks the item's lines of one action type in Line No. order (the order
    /// DistributeQty fills) and gives each lot its quantity; a split inserts
    /// the remainder right after the line, so it is the next line visited.
    /// </summary>
    local procedure AssignLotsToLines(var PickHeader: Record "Warehouse Activity Header"; ItemNo: Code[20]; ActionType: Enum "Warehouse Action Type"; LotNos: List of [Code[50]]; ExpirationDates: List of [Date]; LotQtys: List of [Decimal])
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        LineToSet: Record "Warehouse Activity Line";
        NewWhseActivityLine: Record "Warehouse Activity Line";
        LotIndex: Integer;
        LotLeft: Decimal;
    begin
        LotIndex := 1;
        LotLeft := LotQtys.Get(1);
        WhseActivityLine.SetRange("Activity Type", PickHeader.Type);
        WhseActivityLine.SetRange("No.", PickHeader."No.");
        WhseActivityLine.SetRange("Item No.", ItemNo);
        WhseActivityLine.SetRange("Action Type", ActionType);
        WhseActivityLine.SetFilter("Qty. Outstanding", '>0');
        while (LotIndex <= LotNos.Count()) and WhseActivityLine.FindFirst() do begin
            // Unfiltered copy: SplitLine finds the next line No. through the
            // record's own filters.
            LineToSet.Get(WhseActivityLine."Activity Type", WhseActivityLine."No.", WhseActivityLine."Line No.");
            if LineToSet."Qty. Outstanding" > LotLeft then begin
                LineToSet.Validate("Qty. to Handle", LotLeft);
                WhseActivityLine.SplitLine(LineToSet, NewWhseActivityLine);
                // Directed put-away and pick blanks the new Take line's bin; the
                // remainder is still in the same bin.
                if (NewWhseActivityLine."Bin Code" = '') and (LineToSet."Bin Code" <> '') then begin
                    NewWhseActivityLine.Validate("Bin Code", LineToSet."Bin Code");
                    NewWhseActivityLine.Modify(true);
                end;
            end;
            LineToSet.Validate("Lot No.", LotNos.Get(LotIndex));
            if ExpirationDates.Get(LotIndex) <> 0D then
                LineToSet.Validate("Expiration Date", ExpirationDates.Get(LotIndex));
            LineToSet.Modify(true);
            LotLeft -= LineToSet."Qty. Outstanding";
            if LotLeft <= 0 then begin
                LotIndex += 1;
                if LotIndex <= LotNos.Count() then
                    LotLeft := LotQtys.Get(LotIndex);
            end;
            WhseActivityLine.SetFilter("Line No.", '>%1', LineToSet."Line No.");
        end;
        if LotIndex <= LotNos.Count() then
            Error(LotsOverOutstandingErr, ItemNo);
    end;

    /// <summary>
    /// Fills PickLot with the Lot No. lookup of one pick line — what the BC
    /// client's Item Tracking Summary shows from the line's Lot No. field
    /// (Warehouse Activity Line.LookUpTrackingSummary): the standard Item
    /// Tracking Data Collection, with the line's bin as the current bin.
    /// Filtered to the pick line's unit of measure: only lots with stock in
    /// that UOM in the line's bin are returned, Total Quantity is that UOM
    /// stock, and Available = min(that, Bin Content, Total Available Quantity)
    /// in the line's UOM (the standard summary is in base across all UOMs).
    /// </summary>
    procedure FillPickLots(PickNo: Code[20]; PickLineNo: Integer; BinCode: Code[20]; var PickLot: Record "MJS Pick Lot Buffer" temporary)
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        TempEntrySummary: Record "Entry Summary" temporary;
        ItemTrackingDataCollection: Codeunit "Item Tracking Data Collection";
        AvailableBase: Decimal;
        QtyPerUoM: Decimal;
        UoMQty: Decimal;
        Available: Decimal;
    begin
        if not WhseActivityLine.Get(WhseActivityLine."Activity Type"::Pick, PickNo, PickLineNo) then
            exit;
        // A blank take bin is filled at Register Pick from the caller's
        // choice (SetTakeBinIfBlank); look lots up in that bin. Not saved here.
        if (WhseActivityLine."Bin Code" = '') and (BinCode <> '') then
            WhseActivityLine."Bin Code" := BinCode;
        Item.Get(WhseActivityLine."Item No.");
        if Item."Item Tracking Code" = '' then
            exit;
        ItemTrackingCode.Get(Item."Item Tracking Code");

        // Same tracking spec the standard lookup builds
        // (InitTrackingSpecFromWhseActivLine is local in the base app).
        TempTrackingSpecification.Init();
        TempTrackingSpecification.SetSource(
          WhseActivityLine."Source Type", WhseActivityLine."Source Subtype", WhseActivityLine."Source No.", WhseActivityLine."Source Line No.", '', 0);
        TempTrackingSpecification."Item No." := WhseActivityLine."Item No.";
        TempTrackingSpecification."Location Code" := WhseActivityLine."Location Code";
        TempTrackingSpecification."Variant Code" := WhseActivityLine."Variant Code";
        TempTrackingSpecification."Qty. per Unit of Measure" := WhseActivityLine."Qty. per Unit of Measure";
        TempTrackingSpecification."Bin Code" := WhseActivityLine."Bin Code";
        TempTrackingSpecification."Quantity (Base)" := WhseActivityLine."Qty. Outstanding (Base)";
        TempTrackingSpecification."Qty. to Handle" := WhseActivityLine."Qty. Outstanding";
        TempTrackingSpecification."Qty. to Handle (Base)" := WhseActivityLine."Qty. Outstanding (Base)";

        ItemTrackingDataCollection.SetCurrentBinAndItemTrkgCode(WhseActivityLine."Bin Code", ItemTrackingCode);
        ItemTrackingDataCollection.RetrieveLookupData(TempTrackingSpecification, true);
        ItemTrackingDataCollection.GetTempGlobalEntrySummary(TempEntrySummary);

        QtyPerUoM := WhseActivityLine."Qty. per Unit of Measure";
        if QtyPerUoM = 0 then
            QtyPerUoM := 1;
        TempEntrySummary.Reset();
        TempEntrySummary.SetRange("Serial No.", '');
        TempEntrySummary.SetRange("Non Serial Tracking", true);
        TempEntrySummary.SetFilter("Lot No.", '<>%1', '');
        if TempEntrySummary.FindSet() then
            repeat
                UoMQty := LotQtyInUoM(WhseActivityLine, TempEntrySummary."Lot No.");
                if UoMQty > 0 then begin
                    AvailableBase := TempEntrySummary."Total Available Quantity";
                    if TempEntrySummary."Bin Active" and (TempEntrySummary."Bin Content" < AvailableBase) then
                        AvailableBase := TempEntrySummary."Bin Content";
                    Available := Round(AvailableBase / QtyPerUoM, 0.00001);
                    if UoMQty < Available then
                        Available := UoMQty;
                    PickLot.Init();
                    PickLot."Pick No." := PickNo;
                    PickLot."Pick Line No." := PickLineNo;
                    PickLot."Lot No." := TempEntrySummary."Lot No.";
                    if not PickLot.Find() then begin
                        PickLot."Expiration Date" := TempEntrySummary."Expiration Date";
                        PickLot."Total Quantity" := UoMQty;
                        PickLot."Available Quantity" := Available;
                        PickLot."Unit of Measure Code" := WhseActivityLine."Unit of Measure Code";
                        PickLot."Bin Code" := WhseActivityLine."Bin Code";
                        PickLot.Insert();
                    end;
                end;
            until TempEntrySummary.Next() = 0;
    end;

    /// <summary>
    /// A lot's stock in the pick line's own unit of measure (Warehouse Entry
    /// Quantity, not base) in the line's bin — the same Warehouse Entry
    /// filters the standard bin-content calculation uses, plus the UOM. A
    /// blank bin falls back to the whole location.
    /// </summary>
    local procedure LotQtyInUoM(WhseActivityLine: Record "Warehouse Activity Line"; LotNo: Code[50]): Decimal
    var
        WarehouseEntry: Record "Warehouse Entry";
    begin
        WarehouseEntry.SetRange("Item No.", WhseActivityLine."Item No.");
        if WhseActivityLine."Bin Code" <> '' then
            WarehouseEntry.SetRange("Bin Code", WhseActivityLine."Bin Code");
        WarehouseEntry.SetRange("Location Code", WhseActivityLine."Location Code");
        WarehouseEntry.SetRange("Variant Code", WhseActivityLine."Variant Code");
        WarehouseEntry.SetRange("Unit of Measure Code", WhseActivityLine."Unit of Measure Code");
        WarehouseEntry.SetRange("Lot No.", LotNo);
        WarehouseEntry.CalcSums(Quantity);
        exit(WarehouseEntry.Quantity);
    end;

    /// <summary>
    /// Spreads an item's registered quantity across its pick lines of one
    /// action type, first line first, capped per line at Qty. Outstanding;
    /// later lines get 0 (a split line starts with its whole quantity).
    /// </summary>
    local procedure DistributeQty(var PickHeader: Record "Warehouse Activity Header"; ItemNo: Code[20]; ActionType: Enum "Warehouse Action Type"; Qty: Decimal)
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        Remaining: Decimal;
        Handle: Decimal;
    begin
        Remaining := Qty;
        WhseActivityLine.SetRange("Activity Type", PickHeader.Type);
        WhseActivityLine.SetRange("No.", PickHeader."No.");
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
            until WhseActivityLine.Next() = 0;
    end;

    local procedure RegisterPickDoc(var PickHeader: Record "Warehouse Activity Header")
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
    begin
        WhseActivityLine.SetRange("Activity Type", PickHeader.Type);
        WhseActivityLine.SetRange("No.", PickHeader."No.");
        WhseActivityLine.SetFilter("Qty. to Handle", '>0');
        if not WhseActivityLine.FindFirst() then
            Error(NothingToRegisterErr, PickHeader."No.");
        WhseActivityRegister.ShowHideDialog(true);
        WhseActivityRegister.Run(WhseActivityLine);
    end;

    procedure PickExists(WhseShipmentNo: Code[20]): Boolean
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        WhseActivityLine.SetRange("Activity Type", WhseActivityLine."Activity Type"::Pick);
        WhseActivityLine.SetRange("Whse. Document Type", WhseActivityLine."Whse. Document Type"::Shipment);
        WhseActivityLine.SetRange("Whse. Document No.", WhseShipmentNo);
        exit(not WhseActivityLine.IsEmpty());
    end;

    /// <summary>
    /// Maps the sorting-method captions the web app sends (and BC's own
    /// captions) onto the enum. Unknown values fall back to None, matching the
    /// Create Pick dialog's default.
    /// </summary>
    procedure SortingMethodFromText(Value: Text): Enum "Whse. Activity Sorting Method"
    begin
        case UpperCase(Value) of
            'ITEM':
                exit("Whse. Activity Sorting Method"::Item);
            'DOCUMENT':
                exit("Whse. Activity Sorting Method"::Document);
            'SHELF OR BIN', 'SHELF/BIN NO.', 'SHELF OR BIN NO.':
                exit("Whse. Activity Sorting Method"::"Shelf or Bin");
            'DUE DATE':
                exit("Whse. Activity Sorting Method"::"Due Date");
            'SHIP-TO', 'DESTINATION':
                exit("Whse. Activity Sorting Method"::"Ship-To");
            'BIN RANKING':
                exit("Whse. Activity Sorting Method"::"Bin Ranking");
            'ACTION TYPE':
                exit("Whse. Activity Sorting Method"::"Action Type");
            else
                exit("Whse. Activity Sorting Method"::None);
        end;
    end;
}
