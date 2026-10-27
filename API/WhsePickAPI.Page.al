page 70125 "MJS Whse. Pick API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Warehouse Pick';
    EntitySetCaption = 'Warehouse Picks';
    EntityName = 'warehousePick';
    EntitySetName = 'warehousePicks';
    SourceTable = "Warehouse Activity Header";
    SourceTableView = where(Type = const(Pick));
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
}
