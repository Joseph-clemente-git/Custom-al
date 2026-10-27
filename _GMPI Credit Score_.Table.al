table 70101 "GMPI Credit Score"
{
    Caption = 'Credit Score';
    DataClassification = ToBeClassified;
    LookupPageId = "GMPI Credit Score List";
    DrillDownPageId = "GMPI Credit Score List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
