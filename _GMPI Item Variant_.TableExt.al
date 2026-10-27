#pragma warning disable AL0247
tableextension 70112 "GMPI Item Variant" extends "Item Variant"
#pragma warning restore AL0247
{
    fields
    {
        field(70100; "GMPI Principal"; Code[20])
        {
            TableRelation = "GMPI Principal";
            Caption = 'Principal';
            DataClassification = ToBeClassified;
        }
        field(70101; "GMPI Brand"; Code[20])
        {
            TableRelation = "GMPI Brand";
            Caption = 'Brand';
            DataClassification = ToBeClassified;
        }
    }
}
