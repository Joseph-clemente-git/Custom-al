page 70127 "MJS Whse. Put-away API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Warehouse Put-away';
    EntitySetCaption = 'Warehouse Put-aways';
    EntityName = 'warehousePutAway';
    EntitySetName = 'warehousePutAways';
    SourceTable = "Warehouse Activity Header";
    SourceTableView = where(Type = const("Put-away"));
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
    /// .../api/majesty/wms/v1.0/companies({id})/warehousePutAways({systemId})/Microsoft.NAV.registerPutAway
    /// Body: { "linesJson": "[{\"itemNo\":\"TI-000001\",\"quantity\":1,\"binCode\":\"...\"}]" }
    /// Registers this put-away with the given Qty. to Handle per item — the
    /// same as Register Put-away on the Warehouse Put-away page. An empty
    /// linesJson registers everything outstanding (BC's Autofill Qty. to
    /// Handle). BC removes the put-away once every line is fully handled.
    /// </summary>
    [ServiceEnabled]
    procedure registerPutAway(var actionContext: WebServiceActionContext; linesJson: Text)
    var
        PutAwayMgt: Codeunit "MJS Whse. Put-away Mgt.";
    begin
        PutAwayMgt.RegisterPutAway(Rec, linesJson);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"MJS Whse. Put-away API");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}
