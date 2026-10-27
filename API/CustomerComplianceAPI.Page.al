page 70116 "MJS Customer Compliance API"
{
    PageType = API;
    APIPublisher = 'majesty';
    APIGroup = 'sales';
    APIVersion = 'v2.0';
    EntityCaption = 'Customer Compliance';
    EntitySetCaption = 'Customer Compliances';
    EntityName = 'customerCompliance';
    EntitySetName = 'customerCompliances';
    SourceTable = Customer;
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
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                }
                field(vatBusPostingGroup; Rec."VAT Bus. Posting Group")
                {
                    Caption = 'VAT Bus. Posting Group';
                }
                field(complianceChecking; Rec."GMPI Compliance Checking")
                {
                    Caption = 'Compliance Checking';
                }
                field(fdaLtoNumber; Rec."GMPI FDA LTO Number")
                {
                    Caption = 'FDA LTO Number';
                }
                field(fdaLtoValidityDate; Rec."GMPI FDA LTO Validity Date")
                {
                    Caption = 'FDA LTO Validity Date';
                }
                field(sLicenseNumber; Rec."GMPI S License Number")
                {
                    Caption = 'S License Number';
                }
                field(sLicenseExpirationDate; Rec."GMPI S License Exp. Date")
                {
                    Caption = 'S License Expiration Date';
                }
            }
        }
    }

}
