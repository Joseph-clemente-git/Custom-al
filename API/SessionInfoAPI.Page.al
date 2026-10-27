page 70121 "MJS Session Info API"
{
    // Exposes AL's built-in WorkDate() to the web app so it can replicate
    // BC's own "Posting Date is different from Work Date" confirmation
    // before posting a Warehouse Receipt/Shipment — that dialog only fires
    // inside BC's interactive client (GuiAllowed), never for calls made
    // through this API, so the caller has to ask BC for the real Work Date
    // and do the comparison itself instead of hard-coding "today".
    //
    // Bound to General Ledger Setup only because it's a singleton table
    // (always exactly one record, so the API always has something to
    // return) — Work Date itself is NOT a General Ledger Setup field. It's
    // resolved per session the same way the BC client resolves it (from the
    // signed-in/integration user's Work Date in My Settings, defaulting to
    // today), so this always reflects whatever BC itself would use.
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Session Info';
    EntitySetCaption = 'Session Info';
    EntityName = 'sessionInfo';
    EntitySetName = 'sessionInfo';
    SourceTable = "General Ledger Setup";
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(workDate; SessionWorkDate)
                {
                    Caption = 'Work Date';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SessionWorkDate := WorkDate();
    end;

    var
        SessionWorkDate: Date;
}
