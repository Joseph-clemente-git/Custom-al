page 70129 "MJS Whse. Receipt API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Warehouse Receipt';
    EntitySetCaption = 'Warehouse Receipts';
    EntityName = 'warehouseReceipt';
    EntitySetName = 'warehouseReceipts';
    SourceTable = "Warehouse Receipt Header";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;

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
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(assignedUserId; Rec."Assigned User ID")
                {
                    Caption = 'Assigned User ID';
                }
                field(sortingMethod; Rec."Sorting Method")
                {
                    Caption = 'Sorting Method';
                }
                field(documentStatus; Rec."Document Status")
                {
                    Caption = 'Document Status';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
            }
        }
    }

    /// <summary>
    /// Bound action: POST
    /// .../api/majesty/wms/v1.0/companies({id})/warehouseReceipts({systemId})/Microsoft.NAV.postReceipt
    /// Posts the Warehouse Receipt through BC's standard Whse.-Post Receipt
    /// routine (codeunit 5760) — the same as clicking Post on the Warehouse
    /// Receipt page. Warehouse Receipts are created on the BC side (Get
    /// Source Documents) and need no release or pick, so this is the only
    /// write action needed before put-away: if the location requires
    /// put-away, BC creates the Warehouse Put-away activity automatically as
    /// part of this call — look it up via the Put-away API and register it
    /// with registerPutAway there. BC deletes the open document on success
    /// (it becomes a Posted Whse. Receipt); any refusal surfaces as a normal
    /// error to the caller.
    /// </summary>
    /// <summary>
    /// Bound action: POST .../warehouseReceipts({systemId})/Microsoft.NAV.assignLots
    /// Body: { "lineNo": 10000, "lotsJson": "[{\"lotNo\":\"L001\",\"expirationDate\":\"2027-12-31\",\"quantity\":5}]" }
    /// Creates (replaces) the lots on one purchase order receipt line — Item
    /// Tracking Lines on its purchase line — so Post Receipt can receive
    /// lot-tracked items. See MJS Whse. Receipt Lot Mgt.
    /// </summary>
    [ServiceEnabled]
    procedure assignLots(var actionContext: WebServiceActionContext; lineNo: Integer; lotsJson: Text)
    var
        LotMgt: Codeunit "MJS Whse. Receipt Lot Mgt.";
    begin
        LotMgt.AssignLots(Rec, lineNo, lotsJson);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Whse. Receipt API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    [ServiceEnabled]
    procedure postReceipt(var actionContext: WebServiceActionContext)
    var
        PostMgt: Codeunit "MJS Whse. Post Mgt.";
    begin
        PostMgt.PostReceipt(Rec);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Whse. Receipt API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
