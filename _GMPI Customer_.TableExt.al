#pragma warning disable AL0247
tableextension 70110 "GMPI Customer" extends Customer
#pragma warning restore AL0247
{
    fields
    {
        field(70100; "GMPI AR Code"; Code[20])
        {
            TableRelation = "GMPI AR Code";
            Caption = 'AR Code';
            DataClassification = ToBeClassified;
        }
        field(70101; "GMPI Credit Score"; Code[20])
        {
            TableRelation = "GMPI Credit Score";
            Caption = 'Credit Score';
            DataClassification = ToBeClassified;
        }
        field(70106; "GMPI Compliance Checking"; Boolean)
        {
            Caption = 'Compliance Checking';
            DataClassification = ToBeClassified;
            InitValue = true;
        }
        field(70102; "GMPI FDA LTO Number"; Text[100])
        {
            Caption = 'FDA LTO Number';
            DataClassification = ToBeClassified;
        }
        field(70103; "GMPI FDA LTO Validity Date"; Date)
        {
            Caption = 'FDA LTO Validity Date';
            DataClassification = ToBeClassified;
        }
        field(70104; "GMPI S License Number"; Text[100])
        {
            Caption = 'S License Number';
            DataClassification = ToBeClassified;
        }
        field(70105; "GMPI S License Exp. Date"; Date)
        {
            Caption = 'S License Expiration Date';
            DataClassification = ToBeClassified;
        }
    }
}
