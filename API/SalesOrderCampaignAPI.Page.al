page 70119 "MJS Sales Order Campaign API"
{
    // The standard salesOrders API creates the document. This companion
    // entity applies header fields that the standard API does not expose
    // before lines are inserted and the order is released.
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Sales Order Campaign';
    EntitySetCaption = 'Sales Order Campaigns';
    EntityName = 'salesOrderCampaign';
    EntitySetName = 'salesOrderCampaigns';
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Order));
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    // Release Sales Document reads this localization setup while the bound
    // action below re-releases an existing order. Grant the API page indirect
    // read access so service principals do not need a direct table assignment.
    Permissions = tabledata "Item Variant" = R,
                  tabledata "Sales Line" = RIM,
                  tabledata "Sales Comment Line" = RIMD,
                  tabledata "WHT Posting Setup" = R;

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
                field(number; Rec."No.")
                {
                    Caption = 'Number';
                }
                field(campaignNo; Rec."Campaign No.")
                {
                    Caption = 'Campaign No.';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(responsibilityCenter; Rec."Responsibility Center")
                {
                    Caption = 'Responsibility Center';
                }
                field(shipmentMethodCode; Rec."Shipment Method Code")
                {
                    Caption = 'Shipment Method Code';
                }
                field(shipToCode; Rec."Ship-to Code")
                {
                    Caption = 'Ship-to Code';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(lastLineNo; LastLineNo)
                {
                    Caption = 'Last Line No.';
                    Editable = false;
                }
            }
        }
    }

    var
        LastLineNo: Integer;

    /// <summary>
    /// Applies the selected campaign to an open sales order before its lines
    /// are created. Validate runs BC's standard campaign validation logic.
    /// </summary>
    [ServiceEnabled]
    procedure setCampaign(var actionContext: WebServiceActionContext; campaignNo: Code[20])
    begin
        Rec.TestField(Status, Rec.Status::Open);
        Rec.Validate("Campaign No.", campaignNo);
        Rec.Modify(true);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Sales Order Campaign API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    /// <summary>
    /// Applies the Ship-to Code chosen in the web app to an open sales order.
    /// A blank code selects the customer's own (sell-to) address, overriding
    /// the customer card default BC applied when the order was created.
    /// Call this before setResponsibilityCenter/setShipmentMethod: validating
    /// Ship-to Code copies the ship-to's Location and Shipment Method Codes
    /// onto the header, and those actions must have the final say.
    /// </summary>
    [ServiceEnabled]
    procedure setShipToCode(var actionContext: WebServiceActionContext; shipToCode: Code[10])
    begin
        Rec.TestField(Status, Rec.Status::Open);
        Rec.Validate("Ship-to Code", shipToCode);
        Rec.Modify(true);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Sales Order Campaign API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    /// <summary>
    /// Applies the order's location to both Location Code and Responsibility
    /// Center before release.
    /// </summary>
    [ServiceEnabled]
    procedure setResponsibilityCenter(var actionContext: WebServiceActionContext; responsibilityCenter: Code[10])
    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        ResponsibilityCenterRecord: Record "Responsibility Center";
        WasReleased: Boolean;
    begin
        WasReleased := Rec.Status = Rec.Status::Released;
        if WasReleased then
            ReleaseSalesDocument.Reopen(Rec);

        // The order's Location Code is also the Responsibility Center Code.
        // Create the master record on first use so older companies without a
        // matching Responsibility Center can still release the sales order.
        ResponsibilityCenterRecord.LockTable();
        if not ResponsibilityCenterRecord.Get(responsibilityCenter) then begin
            ResponsibilityCenterRecord.Init();
            ResponsibilityCenterRecord.Code := responsibilityCenter;
            ResponsibilityCenterRecord.Name := responsibilityCenter;
            ResponsibilityCenterRecord.Insert(true);
        end;

        Rec.Validate("Responsibility Center", responsibilityCenter);
        // Sales lines are posted with their own explicit locations. Assign the
        // same code to the header after Responsibility Center validation so
        // that validation cannot replace it with a center default.
        Rec."Location Code" := responsibilityCenter;
        Rec.Modify(true);

        if WasReleased then begin
            ReleaseSalesDocument.PerformManualRelease(Rec);

            // Reload and assert Released, the same fail-closed check the
            // release action below uses: this order was Released before the
            // Responsibility Center change, so it must not silently end up
            // Open (e.g. because an approval workflow intercepted release).
            Rec.Get(Rec."Document Type", Rec."No.");
            Rec.TestField(Status, Rec.Status::Released);
        end;

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Sales Order Campaign API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    /// <summary>
    /// Sets the order's Shipment Method Code — the web app's Delivery Type
    /// (Pickup/Delivery/Shipment) maps 1:1 to the DELIVERY/PICKUP/SHIPMENT
    /// codes already set up in this company. Reopens and re-releases around
    /// the change when the order is Released, same fail-closed pattern as
    /// setResponsibilityCenter/setLineLocation.
    /// </summary>
    [ServiceEnabled]
    procedure setShipmentMethod(var actionContext: WebServiceActionContext; shipmentMethodCode: Code[10])
    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        WasReleased: Boolean;
    begin
        WasReleased := Rec.Status = Rec.Status::Released;
        if WasReleased then
            ReleaseSalesDocument.Reopen(Rec);

        Rec.Validate("Shipment Method Code", shipmentMethodCode);
        Rec.Modify(true);

        if WasReleased then begin
            ReleaseSalesDocument.PerformManualRelease(Rec);

            Rec.Get(Rec."Document Type", Rec."No.");
            Rec.TestField(Status, Rec.Status::Released);
        end;

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Sales Order Campaign API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    /// <summary>
    /// Runs Business Central's standard sales-document release logic and
    /// refuses to return success unless the persisted Sales Header is Released.
    /// Copies External Document No. into Your Reference beforehand so the
    /// customer's PO/reference number carries onto the released order.
    /// </summary>
    [ServiceEnabled]
    procedure release(var actionContext: WebServiceActionContext)
    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        if Rec."External Document No." <> '' then begin
            Rec.Validate("Your Reference", Rec."External Document No.");
            Rec.Modify(true);
        end;

        if Rec.Status <> Rec.Status::Released then
            ReleaseSalesDocument.PerformManualRelease(Rec);

        // Reload the header so the API response and the assertion both use
        // the status that was persisted by the release codeunit.
        Rec.Get(Rec."Document Type", Rec."No.");
        Rec.TestField(Status, Rec.Status::Released);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Sales Order Campaign API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    /// <summary>
    /// Sets the order's header-level remarks (BC's standard Sales Comment
    /// Line, Document Line No. 0 — the same place the "Comments" action on
    /// the Sales Order card reads from). Replaces any comment lines this
    /// action previously wrote; splits text longer than 80 characters across
    /// multiple comment lines since that is the field's storage limit.
    /// </summary>
    [ServiceEnabled]
    procedure setRemarks(var actionContext: WebServiceActionContext; remarks: Text[2048])
    begin
        SetCommentLines(0, remarks);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Sales Order Campaign API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    /// <summary>
    /// Sets a single sales line's remarks (BC's standard Sales Comment Line
    /// keyed to that line's Document Line No. — the same place the line's own
    /// "Comments" action reads from). lineNo is the Sales Line."Line No."
    /// returned as lastLineNo by addItemLine/addItemVariantLine.
    /// </summary>
    [ServiceEnabled]
    procedure setLineRemarks(var actionContext: WebServiceActionContext; lineNo: Integer; remarks: Text[512])
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Get(Rec."Document Type", Rec."No.", lineNo);
        SetCommentLines(lineNo, remarks);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Sales Order Campaign API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    /// <summary>
    /// Corrects a single sales line's Location Code after the order already
    /// has lines (e.g. re-syncing a legacy order at final approval). Reopens
    /// and re-releases around the change when the order is Released, using
    /// the same fail-closed assertion as setResponsibilityCenter/release so
    /// this never returns success while the persisted order is still Open.
    /// </summary>
    [ServiceEnabled]
    procedure setLineLocation(var actionContext: WebServiceActionContext; lineNo: Integer; locationCode: Code[10])
    var
        SalesLine: Record "Sales Line";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        WasReleased: Boolean;
    begin
        SalesLine.Get(Rec."Document Type", Rec."No.", lineNo);
        WasReleased := Rec.Status = Rec.Status::Released;
        if WasReleased then
            ReleaseSalesDocument.Reopen(Rec);

        SalesLine.Validate("Location Code", locationCode);
        SalesLine.Modify(true);

        if WasReleased then begin
            ReleaseSalesDocument.PerformManualRelease(Rec);

            Rec.Get(Rec."Document Type", Rec."No.");
            Rec.TestField(Status, Rec.Status::Released);
        end;

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Sales Order Campaign API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    /// <summary>
    /// Replaces the comment lines for this document (or, for DocumentLineNo
    /// &lt;&gt; 0, for one of its sales lines) with the given text, chunked
    /// into Text[80] rows. An empty NewText clears the existing comments.
    /// </summary>
    local procedure SetCommentLines(DocumentLineNo: Integer; NewText: Text)
    var
        SalesCommentLine: Record "Sales Comment Line";
        NextLineNo: Integer;
        RemainingStart: Integer;
    begin
        SalesCommentLine.SetRange("Document Type", Rec."Document Type");
        SalesCommentLine.SetRange("No.", Rec."No.");
        SalesCommentLine.SetRange("Document Line No.", DocumentLineNo);
        SalesCommentLine.DeleteAll();

        NextLineNo := 10000;
        RemainingStart := 1;
        while RemainingStart <= StrLen(NewText) do begin
            SalesCommentLine.Init();
            SalesCommentLine."Document Type" := Rec."Document Type";
            SalesCommentLine."No." := Rec."No.";
            SalesCommentLine."Document Line No." := DocumentLineNo;
            SalesCommentLine."Line No." := NextLineNo;
            SalesCommentLine.Date := Today;
            SalesCommentLine.Comment := CopyStr(NewText, RemainingStart, 80);
            SalesCommentLine.Insert(true);

            RemainingStart += 80;
            NextLineNo += 10000;
        end;
    end;

    /// <summary>
    /// Adds an item line under this API object's explicit permissions. The
    /// Philippine Localization reads WHT Posting Setup from Sales Line table
    /// triggers, which fails through the standard salesOrderLines API when an
    /// Entra application has no direct permission to localization table 80002.
    /// </summary>
    [ServiceEnabled]
    procedure addItemLine(
        var actionContext: WebServiceActionContext;
        itemNumber: Code[20];
        quantity: Decimal;
        unitPrice: Decimal;
        applyUnitPrice: Boolean;
        discountPercent: Decimal;
        locationCode: Code[10])
    begin
        AddItemLineInternal(
            actionContext, itemNumber, '', quantity, unitPrice,
            applyUnitPrice, discountPercent, locationCode);
    end;

    /// <summary>
    /// Adds an item line and validates its Item Variant Code through the
    /// standard Sales Line field trigger. Kept as a separate action so older
    /// clients that call addItemLine remain compatible.
    /// </summary>
    [ServiceEnabled]
    procedure addItemVariantLine(
        var actionContext: WebServiceActionContext;
        itemNumber: Code[20];
        variantCode: Code[10];
        quantity: Decimal;
        unitPrice: Decimal;
        applyUnitPrice: Boolean;
        discountPercent: Decimal;
        locationCode: Code[10])
    begin
        AddItemLineInternal(
            actionContext, itemNumber, variantCode, quantity, unitPrice,
            applyUnitPrice, discountPercent, locationCode);
    end;

    local procedure AddItemLineInternal(
        var actionContext: WebServiceActionContext;
        itemNumber: Code[20];
        variantCode: Code[10];
        quantity: Decimal;
        unitPrice: Decimal;
        applyUnitPrice: Boolean;
        discountPercent: Decimal;
        locationCode: Code[10])
    var
        SalesLine: Record "Sales Line";
        NextLineNo: Integer;
    begin
        Rec.TestField(Status, Rec.Status::Open);
        if quantity <= 0 then
            Error('Quantity must be greater than zero.');

        SalesLine.SetRange("Document Type", Rec."Document Type");
        SalesLine.SetRange("Document No.", Rec."No.");
        if SalesLine.FindLast() then
            NextLineNo := SalesLine."Line No." + 10000
        else
            NextLineNo := 10000;

        SalesLine.Init();
        SalesLine.Validate("Document Type", Rec."Document Type");
        SalesLine.Validate("Document No.", Rec."No.");
        SalesLine.Validate("Line No.", NextLineNo);
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", itemNumber);
        if variantCode <> '' then
            SalesLine.Validate("Variant Code", variantCode);
        if locationCode <> '' then
            SalesLine.Validate("Location Code", locationCode);
        SalesLine.Validate(Quantity, quantity);
        if applyUnitPrice then
            SalesLine.Validate("Unit Price", unitPrice);
        if discountPercent > 0 then
            SalesLine.Validate("Line Discount %", discountPercent);
        SalesLine.Modify(true);

        LastLineNo := NextLineNo;

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Sales Order Campaign API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
