page 70131 "MJS Whse. Shipment API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Warehouse Shipment';
    EntitySetCaption = 'Warehouse Shipments';
    EntityName = 'warehouseShipment';
    EntitySetName = 'warehouseShipments';
    SourceTable = "Warehouse Shipment Header";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata "Warehouse Shipment Header" = R;

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
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(documentStatus; Rec."Document Status")
                {
                    Caption = 'Document Status';
                }
                field(assignedUserId; Rec."Assigned User ID")
                {
                    Caption = 'Assigned User ID';
                }
                field(sortingMethod; Rec."Sorting Method")
                {
                    Caption = 'Sorting Method';
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
    /// .../api/majesty/wms/v1.0/companies({id})/warehouseShipments({systemId})/Microsoft.NAV.createPick
    /// Body: { "assignedUserId": "...", "sortingMethod": "Item" }
    /// Releases the shipment if needed and creates the warehouse pick — the
    /// same as the BC client's Create Pick action.
    /// </summary>
    [ServiceEnabled]
    procedure createPick(var actionContext: WebServiceActionContext; assignedUserId: Text; sortingMethod: Text)
    var
        PickMgt: Codeunit "MJS Whse. Pick Mgt.";
    begin
        PickMgt.CreatePick(Rec, CopyStr(assignedUserId, 1, 50), PickMgt.SortingMethodFromText(sortingMethod));

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Whse. Shipment API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    /// <summary>
    /// Bound action: POST
    /// .../warehouseShipments({systemId})/Microsoft.NAV.registerPick
    /// Body: { "linesJson": "[{\"itemNo\":\"TI-000001\",\"quantity\":1}]" }
    /// Registers the shipment's open Warehouse Pick with the given Qty. to
    /// Handle per item — the same as Register Pick on the pick document. An
    /// empty linesJson registers everything outstanding.
    /// </summary>
    [ServiceEnabled]
    procedure registerPick(var actionContext: WebServiceActionContext; linesJson: Text)
    var
        PickMgt: Codeunit "MJS Whse. Pick Mgt.";
    begin
        PickMgt.RegisterPick(Rec."No.", linesJson);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Whse. Shipment API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    /// <summary>
    /// Bound action: POST
    /// .../warehouseShipments({systemId})/Microsoft.NAV.postShipment
    /// Posts the Warehouse Shipment through BC's standard Whse.-Post Shipment
    /// routine (codeunit 5763) — the same as clicking Post on the Warehouse
    /// Shipment page. BC deletes the open document on success (it becomes a
    /// Posted Whse. Shipment); any refusal (not fully picked, blocked by a
    /// validation) surfaces as a normal error to the caller.
    /// </summary>
    [ServiceEnabled]
    procedure postShipment(var actionContext: WebServiceActionContext)
    var
        PostMgt: Codeunit "MJS Whse. Post Mgt.";
    begin
        PostMgt.PostShipment(Rec);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Whse. Shipment API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
