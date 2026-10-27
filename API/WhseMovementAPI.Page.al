page 70123 "MJS Whse. Movement API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Warehouse Movement';
    EntitySetCaption = 'Warehouse Movements';
    EntityName = 'warehouseMovement';
    EntitySetName = 'warehouseMovements';
    SourceTable = "Warehouse Activity Header";
    SourceTableView = where(Type = const(Movement));
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
                field(sourceDocument; Rec."Source Document")
                {
                    Caption = 'Source Document';
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Source No.';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(destinationType; Rec."Destination Type")
                {
                    Caption = 'Destination Type';
                }
                field(destinationNo; Rec."Destination No.")
                {
                    Caption = 'Destination No.';
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                }
                field(assignedUserId; Rec."Assigned User ID")
                {
                    Caption = 'Assigned User ID';
                }
                field(assignmentDate; Rec."Assignment Date")
                {
                    Caption = 'Assignment Date';
                }
                field(assignmentTime; Rec."Assignment Time")
                {
                    Caption = 'Assignment Time';
                }
                field(sortingMethod; Rec."Sorting Method")
                {
                    Caption = 'Sorting Method';
                }
                field(noOfLines; NoOfLines)
                {
                    Caption = 'No. of Lines';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        WhseActivityLine.SetRange("Activity Type", Rec.Type);
        WhseActivityLine.SetRange("No.", Rec."No.");
        NoOfLines := WhseActivityLine.Count();
    end;

    var
        WhseActivityLine: Record "Warehouse Activity Line";
        NoOfLines: Integer;

    /// <summary>
    /// Bound action: POST
    /// .../api/majesty/wms/v1.0/companies({id})/warehouseMovements({systemId})/Microsoft.NAV.registerMovement
    /// Body: { "linesJson": "[{\"itemNo\":\"TI-000001\",\"quantity\":1,\"binCode\":\"...\"}]" }
    /// Registers this movement with the given Qty. to Handle per item — the
    /// same as Register on the Warehouse Movement page. An empty linesJson
    /// registers everything outstanding (BC's Autofill Qty. to Handle). BC
    /// removes the movement once every line is fully handled.
    /// </summary>
    [ServiceEnabled]
    procedure registerMovement(var actionContext: WebServiceActionContext; linesJson: Text)
    var
        MovementMgt: Codeunit "MJS Whse. Movement Mgt.";
    begin
        MovementMgt.RegisterMovement(Rec, linesJson);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Whse. Movement API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
