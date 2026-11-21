codeunit 70133 "MJS Whse. Post Mgt."
{
    var NoShipmentLinesErr: Label 'Warehouse shipment %1 has no lines to post.', Comment = '%1 = warehouse shipment no.';
    NoReceiptLinesErr: Label 'Warehouse receipt %1 has no lines to post.', Comment = '%1 = warehouse receipt no.';
    /// <summary>
    /// Posts a Warehouse Shipment through BC's standard Whse.-Post Shipment
    /// codeunit (5763) — the same routine the BC client's Post action on the
    /// Warehouse Shipment page runs (post invoice / preview / suppress-commit
    /// all left at their defaults: a normal, non-preview post). Success
    /// deletes the open Warehouse Shipment document and creates a Posted
    /// Whse. Shipment; any refusal (e.g. not fully picked) is raised as a
    /// normal AL error, which the caller (the API bound action) returns to
    /// the web app as-is.
    /// </summary>
    procedure PostShipment(WhseShptHeader: Record "Warehouse Shipment Header")
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
    begin
        WhseShptLine.SetRange("No.", WhseShptHeader."No.");
        if not WhseShptLine.FindFirst()then Error(NoShipmentLinesErr, WhseShptHeader."No.");
        WhsePostShipment.Run(WhseShptLine);
    end;
    /// <summary>
    /// Posts a Warehouse Receipt through BC's standard Whse.-Post Receipt
    /// codeunit (5760) — the same routine the BC client's Post action on the
    /// Warehouse Receipt page runs. Unlike shipments, receipts need no prior
    /// release or pick: if the location requires put-away, BC automatically
    /// creates the Warehouse Put-away activity as part of this call (register
    /// it afterwards through the Put-away API's registerPutAway action).
    /// Success deletes the open Warehouse Receipt document and creates a
    /// Posted Whse. Receipt; any refusal is raised as a normal AL error, which
    /// the caller (the API bound action) returns to the web app as-is.
    /// </summary>
    procedure PostReceipt(WhseRcptHeader: Record "Warehouse Receipt Header")
    var
        WhseRcptLine: Record "Warehouse Receipt Line";
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
        WhseSetup: Record "Warehouse Setup";
    begin
        WhseRcptLine.SetRange("No.", WhseRcptHeader."No.");
        if not WhseRcptLine.FindFirst()then Error(NoReceiptLinesErr, WhseRcptHeader."No.");
        // BC's OnInsert copies Posted Whse. Receipt Nos. only when that series has Default Nos.; posting then needs it.
        WhseRcptHeader.Get(WhseRcptHeader."No.");
        if WhseRcptHeader."Receiving No. Series" = '' then begin
            WhseSetup.Get();
            WhseSetup.TestField("Posted Whse. Receipt Nos.");
            WhseRcptHeader."Receiving No. Series":=WhseSetup."Posted Whse. Receipt Nos.";
            WhseRcptHeader.Modify();
        end;
        WhsePostReceipt.Run(WhseRcptLine);
    end;
    /// <summary>
    /// Sets Qty. to Receive on one Warehouse Receipt line (in the line's unit
    /// of measure), for a partial receipt. Validate runs BC's own rules: the
    /// quantity can't be negative or above Qty. Outstanding. Post Receipt then
    /// receives this quantity, and the rest stays open on the receipt. On a
    /// lot-tracked line the lots must total the same quantity, or BC refuses
    /// to post.
    /// </summary>
    procedure SetQtyToReceive(WhseRcptHeader: Record "Warehouse Receipt Header"; LineNo: Integer; QtyToReceive: Decimal)
    var
        WhseRcptLine: Record "Warehouse Receipt Line";
    begin
        WhseRcptLine.Get(WhseRcptHeader."No.", LineNo);
        WhseRcptLine.Validate("Qty. to Receive", QtyToReceive);
        WhseRcptLine.Modify(true);
    end;
}
