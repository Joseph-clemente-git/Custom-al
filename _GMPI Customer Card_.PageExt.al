#pragma warning disable AL0247
pageextension 70106 "GMPI Customer Card" extends "Customer Card"
#pragma warning restore AL0247
{
    layout
    {
        addlast(General)
        {
            field(GMPIARCode; Rec."GMPI AR Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the AR code assigned to the customer.';
            }
            field(GMPICreditScore; Rec."GMPI Credit Score")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the credit score assigned to the customer.';
            }
            field(GMPIComplianceChecking; Rec."GMPI Compliance Checking")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the FDA LTO and S License credentials are validated before this customer can transact. Turn this off to exempt the customer from the regulatory check.';
            }
            field(GMPIFdaLtoNumber; Rec."GMPI FDA LTO Number")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the FDA LTO number of the customer.';
            }
            field(GMPIFdaLtoValidityDate; Rec."GMPI FDA LTO Validity Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date until which the FDA LTO is valid.';
            }
            field(GMPISLicenseNumber; Rec."GMPI S License Number")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the S license number of the customer.';
            }
            field(GMPISLicenseExpirationDate; Rec."GMPI S License Exp. Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the expiration date of the S license.';
            }
        }
    }
}
