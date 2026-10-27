table 70102 "GMPI Principal"
{
    Caption = 'Principal';
    DataClassification = ToBeClassified;
    LookupPageId = "GMPI Principal List";
    DrillDownPageId = "GMPI Principal List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
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
