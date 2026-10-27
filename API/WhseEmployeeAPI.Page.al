page 70122 "MJS Whse. Employee API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Warehouse Employee';
    EntitySetCaption = 'Warehouse Employees';
    EntityName = 'warehouseEmployee';
    EntitySetName = 'warehouseEmployees';
    SourceTable = "Warehouse Employee";
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
                field(userId; Rec."User ID")
                {
                    Caption = 'User ID';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(isDefault; Rec.Default)
                {
                    Caption = 'Default';
                }
            }
        }
    }
}
