page 70116 "MJS Customer Compliance API"
{
    // FDA LTO / S License fields for the web app's customer sync and its
    // transaction-time compliance gate (Submit for Approval, Release).
    // The fields live on the GMPI Customer table extension, which is a
    // separate app, so they are resolved by field name instead of through a
    // hard dependency. If GMPI is missing the request fails rather than
    // returning blank licences, so the gate never silently passes.
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
                field(complianceChecking; ComplianceChecking)
                {
                    Caption = 'Compliance Checking';
                }
                field(fdaLtoNumber; FdaLtoNumber)
                {
                    Caption = 'FDA LTO Number';
                }
                field(fdaLtoValidityDate; FdaLtoValidityDate)
                {
                    Caption = 'FDA LTO Validity Date';
                }
                field(sLicenseNumber; SLicenseNumber)
                {
                    Caption = 'S License Number';
                }
                field(sLicenseExpirationDate; SLicenseExpirationDate)
                {
                    Caption = 'S License Expiration Date';
                }
            }
        }
    }
    var ComplianceChecking: Boolean;
    FdaLtoNumber: Text[100];
    FdaLtoValidityDate: Date;
    SLicenseNumber: Text[100];
    SLicenseExpirationDate: Date;
    ComplianceCheckingFieldNo: Integer;
    FdaLtoNumberFieldNo: Integer;
    FdaLtoValidityDateFieldNo: Integer;
    SLicenseNumberFieldNo: Integer;
    SLicenseExpirationDateFieldNo: Integer;
    trigger OnOpenPage()
    begin
        // Resolved once per request rather than once per returned row.
        ComplianceCheckingFieldNo:=GetCustomerFieldNo('GMPI Compliance Checking');
        FdaLtoNumberFieldNo:=GetCustomerFieldNo('GMPI FDA LTO Number');
        FdaLtoValidityDateFieldNo:=GetCustomerFieldNo('GMPI FDA LTO Validity Date');
        SLicenseNumberFieldNo:=GetCustomerFieldNo('GMPI S License Number');
        SLicenseExpirationDateFieldNo:=GetCustomerFieldNo('GMPI S License Exp. Date');
    end;
    trigger OnAfterGetRecord()
    var
        CustomerRef: RecordRef;
    begin
        CustomerRef.GetTable(Rec);
        ComplianceChecking:=CustomerRef.Field(ComplianceCheckingFieldNo).Value;
        FdaLtoNumber:=CustomerRef.Field(FdaLtoNumberFieldNo).Value;
        FdaLtoValidityDate:=CustomerRef.Field(FdaLtoValidityDateFieldNo).Value;
        SLicenseNumber:=CustomerRef.Field(SLicenseNumberFieldNo).Value;
        SLicenseExpirationDate:=CustomerRef.Field(SLicenseExpirationDateFieldNo).Value;
    end;
    local procedure GetCustomerFieldNo(FieldName: Text[30]): Integer var CustomerField: Record Field;
    begin
        CustomerField.SetRange(TableNo, Database::Customer);
        CustomerField.SetRange(FieldName, FieldName);
        CustomerField.SetRange(Enabled, true);
        if not CustomerField.FindFirst()then Error(MissingFieldErr, FieldName);
        exit(CustomerField."No.");
    end;
    var MissingFieldErr: Label 'Customer field "%1" was not found. Install the GMPI extension that adds the FDA/S License fields to the Customer table.', Comment = '%1 = field name';
}
