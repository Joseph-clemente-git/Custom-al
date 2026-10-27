table 70100 "GMPI AR Code"
{
    Caption = 'AR Code';
    DataClassification = ToBeClassified;
    LookupPageId = "GMPI AR Code List";
    DrillDownPageId = "GMPI AR Code List";

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
