page 70143 "MJS Sales Price Customer API"
{
    // Minimal live customer metadata required to resolve Sales Price rows.
    // Keeping this separate from the cached customer catalog prevents a stale
    // or defaulted Customer Price Group from selecting the wrong price.
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'wms';
    APIVersion = 'v1.0';
    EntityCaption = 'Sales Price Customer';
    EntitySetCaption = 'Sales Price Customers';
    EntityName = 'salesPriceCustomer';
    EntitySetName = 'salesPriceCustomers';
    SourceTable = Customer;
    DelayedInsert = true;
    ODataKeyFields = SystemId;
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
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(number; Rec."No.")
                {
                    Caption = 'Number';
                }
                field(customerPriceGroup; Rec."Customer Price Group")
                {
                    Caption = 'Customer Price Group';
                }
                field(customerDiscGroup; Rec."Customer Disc. Group")
                {
                    Caption = 'Customer Discount Group';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
            }
        }
    }
}
