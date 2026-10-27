page 70149 "MJS Ship-to Address API"
{
    // Ship-to Address is not exposed by the standard Business Central v2.0
    // API. This read-only endpoint supplies the Sales Order Ship-to picker and
    // flags the address selected as the default on the customer card.
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Ship-to Address';
    EntitySetCaption = 'Ship-to Addresses';
    EntityName = 'shipToAddress';
    EntitySetName = 'shipToAddresses';
    SourceTable = "Ship-to Address";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DataAccessIntent = ReadOnly;

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
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(name2; Rec."Name 2")
                {
                    Caption = 'Name 2';
                }
                field(address; Rec.Address)
                {
                    Caption = 'Address';
                }
                field(address2; Rec."Address 2")
                {
                    Caption = 'Address 2';
                }
                field(city; Rec.City)
                {
                    Caption = 'City';
                }
                field(county; Rec.County)
                {
                    Caption = 'County';
                }
                field(postCode; Rec."Post Code")
                {
                    Caption = 'Post Code';
                }
                field(countryRegionCode; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code';
                }
                field(contact; Rec.Contact)
                {
                    Caption = 'Contact';
                }
                field(phoneNo; Rec."Phone No.")
                {
                    Caption = 'Phone No.';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(shipmentMethodCode; Rec."Shipment Method Code")
                {
                    Caption = 'Shipment Method Code';
                }
                field(isDefault; IsDefault)
                {
                    Caption = 'Is Default';
                    Editable = false;
                }
            }
        }
    }

    var
        Customer: Record Customer;
        IsDefault: Boolean;

    trigger OnAfterGetRecord()
    begin
        // Customer."Ship-to Code" is the address BC applies by default when a
        // sales order is created for this customer.
        if Customer."No." <> Rec."Customer No." then
            if not Customer.Get(Rec."Customer No.") then
                Clear(Customer);
        IsDefault := (Customer."Ship-to Code" <> '') and (Customer."Ship-to Code" = Rec.Code);
    end;
}
